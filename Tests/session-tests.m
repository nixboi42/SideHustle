#import <Foundation/Foundation.h>
#import "SCBridge.h"
#import <objc/runtime.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface FakeBackend : NSObject <SCBackend>
@property NSUInteger connects;
@property NSUInteger disconnects;
@property NSUInteger existing;
@property(copy) void (^pending)(NSError *);
@property BOOL completeDisconnect;
@property(strong) NSError *disconnectError;
@end
@implementation FakeBackend
- (NSArray *)peersWithError:(NSError **)error {(void)error;return @[];}
- (NSUInteger)connectedCount {return self.existing;}
- (void)connect:(SCPeer *)p completion:(void (^)(NSError *))c {(void)p;self.connects++;self.pending=c;}
- (void)disconnect:(SCPeer *)p completion:(void (^)(NSError *))c {(void)p;self.disconnects++;if(self.completeDisconnect)c(self.disconnectError);}
@end
static void require(BOOL condition,NSString *message) {
    if(!condition){fprintf(stderr,"FAIL: %s\n",message.UTF8String);exit(1);}
}
static void tick(NSTimeInterval duration) {
    NSDate *end=[NSDate dateWithTimeIntervalSinceNow:duration];
    while(end.timeIntervalSinceNow>0)[[NSRunLoop mainRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
}
int main(void) {@autoreleasepool {
    require(SCMethodMatchesSignature(FakeBackend.class,@selector(connectedCount),NO,[[NSString stringWithFormat:@"%s16@0:8",@encode(NSUInteger)]UTF8String]),@"runtime integer signature matches");
    require(SCMethodMatchesSignature(FakeBackend.class,@selector(connect:completion:),NO,"v32@0:8@16@?24"),@"object and block arguments match");
    require(SCMethodMatchesSignature(FakeBackend.class,@selector(connect:completion:),NO,"v40@0:8@24@?32"),@"stack size and offsets do not restrict OS builds");
    require(!SCMethodMatchesSignature(FakeBackend.class,@selector(connect:completion:),NO,"v32@0:8@16@24"),@"object cannot replace completion block");
    require(!SCMethodMatchesSignature(FakeBackend.class,@selector(connect:completion:),NO,"@32@0:8@16@?24"),@"changed return type rejected");
    require(!SCMethodMatchesSignature(FakeBackend.class,@selector(connect:completion:),NO,"v24@0:8@16"),@"missing argument rejected");
    require(!SCMethodMatchesSignature(FakeBackend.class,@selector(connect:completion:),YES,"v32@0:8@16@?24"),@"class and instance methods distinguished");
    require(!SCMethodMatchesSignature(FakeBackend.class,NSSelectorFromString(@"missingSidecarMethod"),NO,"v16@0:8"),@"missing method rejected");
    require(SCMethodMatchesSignature(FakeBackend.class,@selector(new),YES,"@16@0:8"),@"inherited class method matches");
    require(!SCMethodMatchesSignature(FakeBackend.class,@selector(setExisting:),NO,"v24@0:8d16"),@"changed scalar argument rejected");
    require(!SCMethodMatchesSignature(Nil,@selector(connectedCount),NO,"Q16@0:8"),@"missing class rejected");
    require(SCAllowPeer(NO,YES,@"iPad6,11"),@"physical iPad 5 allowed locally");
    require(SCAllowPeer(NO,YES,@"iPad6,12"),@"cellular variant allowed locally");
    for(NSString *model in @[@"iPad5,1",@"iPad5,2",@"iPad5,3",@"iPad5,4",@"iPad6,11",@"iPad6,12"]) {
        require(SCAllowPeer(NO,YES,model),@"iPadOS 13 legacy model allowed");
        require(!SCAllowPeer(NO,NO,model),@"legacy identifier requires iPad device type");
        require(!SCAllowPeer(YES,NO,model),@"native predicate cannot bypass iPad type");
    }
    for(NSString *model in @[@"iPad4,1",@"iPad4,2",@"iPad4,3",@"iPad4,4",@"iPad4,5",@"iPad4,6",@"iPad4,7",@"iPad4,8",@"iPad4,9",@"iPad5,10",@"iPad6,1",@"iPad6,110",@"iPad99,1",@""]) {
        require(!SCAllowPeer(NO,YES,model),@"pre-iPadOS 13 and unknown identifiers excluded");
    }
    require(!SCAllowPeer(YES,NO,@"iPhone14,4"),@"non-iPad excluded even with true predicate");
    require(SCAllowPeer(YES,YES,@"iPad7,5"),@"native-supported iPad retained");
    require(SCValidDiscoveryCollections(@[],@[]),@"empty arrays are valid");
    require(!SCValidDiscoveryCollections(nil,@[]),@"nil discovery fails closed");
    require(!SCValidDiscoveryCollections(@{},@[]),@"non-array discovery rejected");
    require(!SCValidDiscoveryCollections(@[],@"bad"),@"invalid connected collection rejected");
    NSMutableArray *many=[NSMutableArray array];for(int i=0;i<129;i++)[many addObject:@0];
    require(!SCValidDiscoveryCollections(many,@[]),@"oversized discovery rejected");
    UTType *type=[UTType typeWithIdentifier:@"com.apple.ipad"];NSUUID *uuid=[NSUUID UUID];
    require(SCValidPeerMetadata(@"iPad6,11",type,uuid,nil),@"missing name uses model fallback");
    require(!SCValidPeerMetadata(@"iPad6,11",type,uuid,@42),@"non-string name rejected");
    require(!SCValidPeerMetadata(@"iPad6,11",type,@"bad",@"iPad"),@"invalid identity rejected");
    require(!SCValidPeerMetadata(@"",type,uuid,@"iPad"),@"empty model rejected");
    require(!SCValidPeerMetadata(@"iPad6,11",type,uuid,[@"x" stringByPaddingToLength:257 withString:@"x" startingAtIndex:0]),@"oversized name rejected");
    SCPeer *peer=[SCPeer new];peer.model=@"iPad6,11";
    FakeBackend *b=[FakeBackend new];b.existing=1;
    SCSession *s=[[SCSession alloc]initWithBackend:b timeout:1];
    [s connect:peer];require(b.connects==0,@"never takes over an existing session");
    b.existing=0;[s connect:peer];[s connect:peer];
    require(b.connects==1 && s.busy,@"double click yields one request");
    b.pending(nil);tick(0.01);
    require(!s.busy && b.disconnects==0,@"success remains connected until user disconnects");
    b.completeDisconnect=YES;[s disconnect:peer];tick(0.01);
    require(b.disconnects==1 && !s.busy,@"normal native disconnect completes");
    b=[FakeBackend new];s=[[SCSession alloc]initWithBackend:b timeout:0.02];
    [s connect:peer];b.pending([NSError errorWithDomain:@"AuthorizationTest" code:1 userInfo:nil]);tick(0.05);
    require(b.connects==1 && b.disconnects==0 && !s.busy,@"error is reported with no automatic retry");
    b=[FakeBackend new];b.completeDisconnect=YES;
    s=[[SCSession alloc]initWithBackend:b timeout:0.01];
    __block NSUInteger completions=0;
    s.record=^(NSDictionary *event){if([event[@"event"]isEqual:@"connect_completion"])completions++;};
    [s connect:peer];tick(0.04);
    require(s.blocked && !s.busy && b.connects==1 && b.disconnects==1,@"timeout requests one cleanup and blocks reconnect");
    b.pending(nil);tick(0.01);[s connect:peer];
    require(b.connects==1 && completions==0,@"late success cannot un-block or overwrite timeout state");
    b=[FakeBackend new];b.completeDisconnect=YES;
    b.disconnectError=[NSError errorWithDomain:@"DisconnectTest" code:2 userInfo:nil];
    s=[[SCSession alloc]initWithBackend:b timeout:1];
    [s disconnect:peer];tick(0.01);
    require(!s.busy && b.disconnects==1,@"disconnect error releases busy state");
    b=[FakeBackend new];b.completeDisconnect=YES;
    s=[[SCSession alloc]initWithBackend:b timeout:1];
    for(int i=0;i<25;i++) {
        [s connect:peer];b.pending(nil);tick(0.002);
        require(!s.busy,@"repeated connection completion");
        [s disconnect:peer];[s disconnect:peer];tick(0.002);
        require(!s.busy && b.disconnects==(NSUInteger)i+1,@"repeated cleanup and duplicate disconnect");
    }
    b=[FakeBackend new];s=[[SCSession alloc]initWithBackend:b timeout:1];
    [s connect:peer];
    void (^callback)(NSError *)=b.pending;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT,0),^{callback(nil);callback(nil);});
    tick(0.05);require(!s.busy,@"background duplicate callbacks handled on main queue");
    b=[FakeBackend new];s=[[SCSession alloc]initWithBackend:b timeout:0.01];
    [s connect:peer];tick(10.1);
    require(!s.busy && s.blocked && b.disconnects==1,@"missing cleanup completion expires and blocks");
    puts("PASS: model policy, existing-session protection, duplicate request, success, disconnect, failure/no retry, timeout cleanup and stale callback checks.");
    return 0;
}}
