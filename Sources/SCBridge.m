#import "SCBridge.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <objc/runtime.h>
#import <mach-o/loader.h>
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
    return isIPad && (nativeEligible || [model isEqualToString:@"iPad6,11"] || [model isEqualToString:@"iPad6,12"]);
}

// The caller supplies a readable byte span; never trust load-command sizes.
BOOL SCFrameworkUUIDMatches(const void *commands, size_t length, uint32_t count) {
    if(!commands || length>(1U<<20) || count>length/sizeof(struct load_command))return NO;
    const uint8_t *bytes=commands;size_t offset=0;BOOL matched=NO,found=NO;
    for(uint32_t i=0;i<count;i++) {
        if(length-offset<sizeof(struct load_command))return NO;
        struct load_command command;memcpy(&command,bytes+offset,sizeof(command));
        if(command.cmdsize<sizeof(command) || command.cmdsize>length-offset || command.cmdsize%8)return NO;
        if(command.cmd==LC_UUID) {
            if(found || command.cmdsize!=sizeof(struct uuid_command))return NO;
            struct uuid_command uuid;memcpy(&uuid,bytes+offset,sizeof(uuid));found=YES;
            matched=[[[[NSUUID alloc]initWithUUIDBytes:uuid.uuid]UUIDString]isEqualToString:@"0892FBEC-B253-34DF-946C-BC97FC532F00"];
        }
        offset+=command.cmdsize;
    }
    return found && matched && offset==length;
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
    char build[64]={0}; size_t n=sizeof(build);
    if (sysctlbyname("kern.osversion",build,&n,NULL,0)!=0 || n==0 || n>sizeof(build) || build[n-1]!=0) {
        if(error)*error=SCError(1,@"Cannot read this macOS build."); return nil;
    }
    _build=@(build);
    if (strcmp(build,"26B123")) {
        if(error)*error=SCError(2,@"This preview supports macOS build 26B123 only. Native APIs must be reviewed for other builds."); return nil;
    }
    _framework=dlopen("/System/Library/PrivateFrameworks/SidecarCore.framework/Versions/A/SidecarCore",RTLD_LAZY|RTLD_LOCAL);
    _eligible=_framework?(BOOL(*)(id))dlsym(_framework,"SidecarDisplayIsSupportedReceivingDevice"):NULL;
    Dl_info info={0};
    if (!_eligible || !dladdr((void *)_eligible,&info)) {
        if(error)*error=SCError(3,@"The installed Sidecar framework is unavailable."); return nil;
    }
    const struct mach_header_64 *h=info.dli_fbase;
    if(h->magic!=MH_MAGIC_64) { if(error)*error=SCError(4,@"Unexpected framework image.");return nil; }
    if(!SCFrameworkUUIDMatches(h+1,h->sizeofcmds,h->ncmds)) {
        if(error)*error=SCError(5,@"Sidecar framework version changed. Connection controls are disabled.");return nil;
    }
    Class svc=NSClassFromString(@"SidecarService"),mgr=NSClassFromString(@"SidecarDisplayManager");
    _deviceClass=NSClassFromString(@"SidecarDevice");
    NSArray *checks=@[
        @[svc?:[NSObject class],@"serviceWithName:",@YES,@"@24@0:8@16"],
        @[svc?:[NSObject class],@"_devicesByForcingFetchFromRelay:",@NO,@"@20@0:8B16"],
        @[mgr?:[NSObject class],@"sharedManager",@YES,@"@16@0:8"],
        @[mgr?:[NSObject class],@"connectedDevices",@NO,@"@16@0:8"],
        @[mgr?:[NSObject class],@"connectToDevice:completion:",@NO,@"v32@0:8@16@?24"],
        @[mgr?:[NSObject class],@"disconnectFromDevice:completion:",@NO,@"v32@0:8@16@?24"],
        @[_deviceClass?:[NSObject class],@"model",@NO,@"@16@0:8"],
        @[_deviceClass?:[NSObject class],@"deviceType",@NO,@"@16@0:8"],
        @[_deviceClass?:[NSObject class],@"name",@NO,@"@16@0:8"],
        @[_deviceClass?:[NSObject class],@"identifier",@NO,@"@16@0:8"]];
    for(NSArray *c in checks) {
        SEL sel=NSSelectorFromString(c[1]);
        Method m=[c[2]boolValue]?class_getClassMethod(c[0],sel):class_getInstanceMethod(c[0],sel);
        if(!m || strcmp(method_getTypeEncoding(m),[c[3]UTF8String])) {
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
