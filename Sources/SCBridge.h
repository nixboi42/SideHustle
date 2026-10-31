#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SCPeer : NSObject
@property(nonatomic, strong) id nativeObject;
@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *model;
@property(nonatomic) BOOL nativeEligible;
@property(nonatomic) BOOL connected;
@end

BOOL SCFrameworkUUIDMatches(const void * _Nullable commands, size_t length, uint32_t count);
BOOL SCValidDiscoveryCollections(id _Nullable raw, id _Nullable connected);
BOOL SCValidPeerMetadata(id _Nullable model, id _Nullable type, id _Nullable identifier, id _Nullable name);

BOOL SCAllowPeer(BOOL nativeEligible, BOOL isIPad, NSString *model);

@protocol SCBackend <NSObject>
- (nullable NSArray<SCPeer *> *)peersWithError:(NSError **)error;
- (NSUInteger)connectedCount;
- (void)connect:(SCPeer *)peer completion:(void (^)(NSError * _Nullable))completion;
- (void)disconnect:(SCPeer *)peer completion:(void (^)(NSError * _Nullable))completion;
@end

@interface SCNativeBackend : NSObject <SCBackend>
@property(nonatomic, readonly, copy) NSString *build;
- (nullable instancetype)initWithError:(NSError **)error;
@end

// All controller methods and callbacks run on the main queue. No retry loop.
@interface SCSession : NSObject
@property(nonatomic, readonly) BOOL busy;
@property(nonatomic, readonly) BOOL blocked;
@property(nonatomic, copy) void (^changed)(NSString *status);
@property(nonatomic, copy) void (^record)(NSDictionary *event);
- (instancetype)initWithBackend:(id<SCBackend>)backend timeout:(NSTimeInterval)timeout;
- (void)connect:(SCPeer *)peer;
- (void)disconnect:(SCPeer *)peer;
@end
NS_ASSUME_NONNULL_END
