#define kStripeAPIBase @"https://%@:@api.stripe.com/v1"
#define kStripeTokenPath @"tokens"

@interface StripeCard : NSObject

@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSNumber *expiryMonth;
@property (strong, nonatomic) NSNumber *expiryYear;
@property (strong, nonatomic) NSString *securityCode;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *addressLine1;
@property (strong, nonatomic) NSString *addressLine2;
@property (strong, nonatomic) NSString *addressZip;
@property (strong, nonatomic) NSString *addressState;
@property (strong, nonatomic) NSString *addressCountry;

@property (strong, readonly) NSString *country;
@property (strong, readonly) NSString *cvcCheck;
@property (strong, readonly) NSString *lastFourDigits;
@property (strong, readonly) NSString *type;

- (id)initWithResponseDictionary:(NSDictionary *)card;

@end

@interface StripeResponse : NSObject
@property (strong, nonatomic) NSNumber *createdAt;
@property (strong, nonatomic) NSString *currency;
@property (strong, nonatomic) NSNumber *amount;
@property (nonatomic) BOOL isUsed;
@property (nonatomic) BOOL isLiveMode;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) StripeCard *card;

- (id)initWithResponseDictionary:(NSDictionary *)response;
@end

@interface StripeConnection : NSObject

+ (StripeConnection *)connectionWithPublishableKey:(NSString *)publishableKey;
- (id)initWithPublishableKey:(NSString *)publishableKey;
- (void)performRequestWithCard:(StripeCard *)card amountInCents:(NSNumber *)amount currency:(NSString *)currency success:(void (^)(StripeResponse *response))success error:(void (^)(NSError *error))error;
- (void)performRequestWithCard:(StripeCard *)card amountInCents:(NSNumber *)amount success:(void (^)(StripeResponse *response))success error:(void (^)(NSError *error))error;

@end

