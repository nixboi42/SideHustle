#import "SCBridge.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <objc/runtime.h>
#import <sys/sysctl.h>
#import <dlfcn.h>

// Declarations describe the checked ABI; no private framework is redistributed.
@interface SCNativeObject : NSObject
+ (id)serviceWithName:(NSString *)name;
+ (id)sharedManager;
- (NSArray *)_devicesByForcingFetchFromRelay:(BOOL)force;
- (NSArray *)connectedDevices;
- (NSString *)model;
- (NSString *)name;
- (NSUUID *)identifier;
- (UTType *)deviceType;
- (void)connectToDevice:(id)device completion:(void (^)(NSError *))completion;
- (void)disconnectFromDevice:(id)device completion:(void (^)(NSError *))completion;
@end

@implementation SCPeer
@end

BOOL SCAllowPeer(BOOL nativeEligible, BOOL isIPad, NSString *model) {
    if(!isIPad)return NO;
    if(nativeEligible)return YES;
    // All iPads capable of iPadOS 13 that lack official Sidecar support.
    // Match exact Wi-Fi/cellular identifiers; never allow a whole model prefix.
    static NSSet<NSString *> *legacyModels;
    static dispatch_once_t once;
    dispatch_once(&once,^{
        legacyModels=[NSSet setWithArray:@[
            @"iPad5,1", @"iPad5,2",   // iPad mini 4
            @"iPad5,3", @"iPad5,4",   // iPad Air 2
            @"iPad6,11", @"iPad6,12"  // iPad (5th generation)
        ]];
    });
    return model && [legacyModels containsObject:model];
}

// Compare callable types, not compiler-specific stack sizes/argument offsets.
BOOL SCMethodMatchesSignature(Class type, SEL selector, BOOL classMethod, const char *encoding) {
    if(!type)return NO;
    Method method=classMethod?class_getClassMethod(type,selector):class_getInstanceMethod(type,selector);
    if(!method)return NO;
    NSMethodSignature *expected=[NSMethodSignature signatureWithObjCTypes:encoding];
    if(method_getNumberOfArguments(method)!=expected.numberOfArguments)return NO;
    char *actual=method_copyReturnType(method);
    BOOL matches=actual && !strcmp(actual,expected.methodReturnType);
    free(actual);
    if(!matches)return NO;
    for(unsigned int i=0;i<expected.numberOfArguments;i++) {
        actual=method_copyArgumentType(method,i);
        matches=actual && !strcmp(actual,[expected getArgumentTypeAtIndex:i]);
        free(actual);
        if(!matches)return NO;
    }
    return YES;
}

// Bound work and reject malformed native-service responses before using them.
BOOL SCValidDiscoveryCollections(id raw, id connected) {
    return [raw isKindOfClass:NSArray.class] && [connected isKindOfClass:NSArray.class]
        && [raw count]<=128 && [connected count]<=128;
}
BOOL SCValidPeerMetadata(id model, id type, id identifier, id name) {
    return [model isKindOfClass:NSString.class] && [model length]>0 && [model length]<=128
        && [type isKindOfClass:UTType.class] && [identifier isKindOfClass:NSUUID.class]
        && (!name || ([name isKindOfClass:NSString.class] && [name length]<=256));
}

static NSError *SCError(NSInteger code, NSString *message) {
    return [NSError errorWithDomain:@"SideHustle" code:code userInfo:@{NSLocalizedDescriptionKey:message}];
}

@implementation SCNativeBackend {
    void *_framework; // Kept loaded for the lifetime of native objects/callbacks.
    BOOL (*_eligible)(id);
    id _service;
    id _manager;
    Class _deviceClass;
}
- (instancetype)initWithError:(NSError **)error {
    if (!(self=[super init])) return nil;
    if(![NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){13,0,0}]) {
        if(error)*error=SCError(2,@"SideHustle requires macOS 13 or later.");return nil;
    }
    // Build is diagnostic metadata; it must not decide framework compatibility.
    char build[64]={0}; size_t n=sizeof(build);
    if(sysctlbyname("kern.osversion",build,&n,NULL,0)==0 && n>0 && n<=sizeof(build) && build[n-1]==0)
        _build=@(build);
    else _build=NSProcessInfo.processInfo.operatingSystemVersionString;
    _framework=dlopen("/System/Library/PrivateFrameworks/SidecarCore.framework/Versions/A/SidecarCore",RTLD_LAZY|RTLD_LOCAL);
    _eligible=_framework?(BOOL(*)(id))dlsym(_framework,"SidecarDisplayIsSupportedReceivingDevice"):NULL;
    if(!_eligible) {
        if(error)*error=SCError(3,@"The installed Sidecar framework is unavailable or missing required APIs.");return nil;
    }
    Class svc=NSClassFromString(@"SidecarService"),mgr=NSClassFromString(@"SidecarDisplayManager");
    _deviceClass=NSClassFromString(@"SidecarDevice");
    if(!svc || !mgr || !_deviceClass) {
        if(error)*error=SCError(6,@"Required Sidecar classes are unavailable. Connection controls are disabled.");return nil;
    }
    NSArray *checks=@[
        @[svc,@"serviceWithName:",@YES,@"@24@0:8@16"],
        @[svc,@"_devicesByForcingFetchFromRelay:",@NO,@"@20@0:8B16"],
        @[mgr,@"sharedManager",@YES,@"@16@0:8"],
        @[mgr,@"connectedDevices",@NO,@"@16@0:8"],
        @[mgr,@"connectToDevice:completion:",@NO,@"v32@0:8@16@?24"],
        @[mgr,@"disconnectFromDevice:completion:",@NO,@"v32@0:8@16@?24"],
        @[_deviceClass,@"model",@NO,@"@16@0:8"],
        @[_deviceClass,@"deviceType",@NO,@"@16@0:8"],
        @[_deviceClass,@"name",@NO,@"@16@0:8"],
        @[_deviceClass,@"identifier",@NO,@"@16@0:8"]];
    for(NSArray *c in checks) {
        SEL sel=NSSelectorFromString(c[1]);
        if(!SCMethodMatchesSignature(c[0],sel,[c[2]boolValue],[c[3]UTF8String])) {
            if(error)*error=SCError(6,@"Native API compatibility check failed. Connection controls are disabled.");return nil;
        }
    }
    NSString *__unsafe_unretained *name=(NSString *__unsafe_unretained *)dlsym(_framework,"SidecarServiceNameDisplay");
    if(!name||!*name) { if(error)*error=SCError(7,@"Native display service is unavailable.");return nil; }
    _service=[(id)svc serviceWithName:*name]; _manager=[(id)mgr sharedManager];
    if(!_service||!_manager) { if(error)*error=SCError(8,@"Native display service could not start.");return nil; }
    return self;
}
- (NSArray<SCPeer *> *)peersWithError:(NSError **)error {
    NSArray *raw=[_service _devicesByForcingFetchFromRelay:YES];
    NSArray *connected=[_manager connectedDevices];
    if(!SCValidDiscoveryCollections(raw,connected)) {
        if(error)*error=SCError(11,@"Unexpected discovery response. Discovery stopped.");return nil;
    }
    NSMutableSet *identifiers=[NSMutableSet set];
    NSMutableArray *peers=[NSMutableArray array];
    for(SCNativeObject *d in raw) {
        if(![d isKindOfClass:_deviceClass]) { if(error)*error=SCError(9,@"Unexpected device object. Discovery stopped.");return nil; }
        NSString *model=[d model]; UTType *type=[d deviceType]; NSUUID *identifier=[d identifier];
        NSString *name=[d name];
        if(!SCValidPeerMetadata(model,type,identifier,name) || [identifiers containsObject:identifier]) {
            if(error)*error=SCError(10,@"Unexpected device metadata. Discovery stopped.");return nil;
        }
        [identifiers addObject:identifier];
        BOOL native=_eligible(d);
        if(!SCAllowPeer(native,[type conformsToType:[UTType typeWithIdentifier:@"com.apple.ipad"]],model))continue;
        SCPeer *peer=[SCPeer new]; peer.nativeObject=d; peer.identifier=identifier.UUIDString;
        peer.model=model;peer.nativeEligible=native;peer.name=name?:model;
        peer.connected=[connected containsObject:d];
        [peers addObject:peer];
    }
    return peers;
}
- (NSUInteger)connectedCount {
    id connected=[_manager connectedDevices];
    // An unavailable/malformed state must never permit session takeover.
    return [connected isKindOfClass:NSArray.class] && [connected count]<=128 ? [connected count] : NSUIntegerMax;
}
- (void)connect:(SCPeer *)peer completion:(void (^)(NSError *))completion {
    [_manager connectToDevice:peer.nativeObject completion:completion];
}
- (void)disconnect:(SCPeer *)peer completion:(void (^)(NSError *))completion {
    [_manager disconnectFromDevice:peer.nativeObject completion:completion];
}
@end

@implementation SCSession {
    id<SCBackend> _backend;
    NSTimeInterval _timeout;
    NSUInteger _generation;
}
- (instancetype)initWithBackend:(id<SCBackend>)backend timeout:(NSTimeInterval)timeout {
    if((self=[super init])) {_backend=backend;_timeout=timeout;_changed=^(NSString *s){(void)s;};_record=^(NSDictionary *e){(void)e;};}return self;
}
- (void)event:(NSString *)name error:(NSError *)error {
    self.record(@{@"event":name,@"errorDomain":error.domain?:@"",@"errorCode":@(error.code)});
}
- (void)connect:(SCPeer *)peer {
    NSAssert(NSThread.isMainThread,@"Main queue required");
    if(self.busy||self.blocked)return;
    if([_backend connectedCount]>0) {self.changed(@"A Sidecar session is already active. Use Displays settings to manage it.");return;}
    _busy=YES; NSUInteger generation=++_generation;
    self.changed(@"Connecting…");[self event:@"connect_request" error:nil];
    __weak SCSession *weakSelf=self;
    [_backend connect:peer completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(),^{
            SCSession *s=weakSelf;if(!s || generation!=s->_generation)return;
            s->_busy=NO;++s->_generation;
            [s event:@"connect_completion" error:error];
            s.changed(error?[NSString stringWithFormat:@"Connection failed (%@, %ld). Check normal Apple Account, 2FA and trust settings. No retry was made.",error.domain,(long)error.code]:@"Connected. Move a Mac window onto your iPad to use the extended display.");
        });
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(_timeout*NSEC_PER_SEC)),dispatch_get_main_queue(),^{
        SCSession *s=weakSelf;if(!s||generation!=s->_generation)return;
        ++s->_generation;s->_blocked=YES;
        [s event:@"connect_timeout" error:nil];
        s.changed(@"Connection timed out. Requesting native cleanup; further connections are disabled. Check Displays before reopening this app.");
        [s cleanup:peer];
    });
}
- (void)cleanup:(SCPeer *)peer {
    // Invalidate the old callback generation before cleanup. Never reconnect here.
    __weak SCSession *weakSelf=self;NSUInteger generation=++_generation;
    [self event:@"disconnect_request" error:nil];
    [_backend disconnect:peer completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(),^{
            SCSession *s=weakSelf;if(!s||generation!=s->_generation)return;
            ++s->_generation;s->_busy=NO;[s event:@"disconnect_completion" error:error];
            if(s.blocked)s.changed(@"Timeout cleanup finished. A late remote connection is still possible. Check Displays; reopen this app only after checking native state.");
            else s.changed(error?[NSString stringWithFormat:@"Disconnect failed (%@, %ld). Use the standard Sidecar menu.",error.domain,(long)error.code]:@"Disconnected.");
        });
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,10*NSEC_PER_SEC),dispatch_get_main_queue(),^{
        SCSession *s=weakSelf;if(!s||generation!=s->_generation)return;
        ++s->_generation;s->_busy=NO;s->_blocked=YES;[s event:@"disconnect_timeout" error:nil];
        s.changed(@"Cleanup timed out. Use the standard Sidecar menu to check and disconnect. Further connections are disabled.");
    });
}
- (void)disconnect:(SCPeer *)peer {
    NSAssert(NSThread.isMainThread,@"Main queue required");
    if(self.busy)return;_busy=YES;self.changed(@"Disconnecting…");[self cleanup:peer];
}
@end
