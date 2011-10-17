#import "Stripe.h"

@interface StripeCard ()
@property (readonly) NSDictionary *attributes;
@property (strong, readwrite) NSString *country;
@property (strong, readwrite) NSString *cvcCheck;
@property (strong, readwrite) NSString *lastFourDigits;
@property (strong, readwrite) NSString *type;
@end

@interface StripeConnection ()
@property (strong, nonatomic) NSString *publishableKey;
@end

@implementation StripeConnection
@synthesize publishableKey = _publishableKey;

+ (StripeConnection *)connectionWithPublishableKey:(NSString *)publishableKey {
    return [[self alloc] initWithPublishableKey:publishableKey];
}

- (id)initWithPublishableKey:(NSString *)publishableKey {
    if ((self = [super init])) {
        self.publishableKey = publishableKey;
    }
    
    return self;
}

- (NSString *)escapedString:(NSString *)string {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 );
}

- (NSData *)HTTPBodyWithCard:(StripeCard *)card amountInCents:(NSNumber *)amount currency:(NSString *)currency {
    NSMutableString *body = [NSMutableString string];
    NSDictionary *attributes = card.attributes;

    for (NSString *key in attributes) {
        NSString *value = [attributes objectForKey:key];
        if ((id)value == [NSNull null]) continue;
        
        if (body.length != 0)
            [body appendString:@"&"];
        
        if ([value isKindOfClass:[NSString class]])
            value = [self escapedString:value];
        
        [body appendFormat:@"card[%@]=%@", [self escapedString:key], value];
    }
    
    if (amount) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"amount=%@", amount];
    }
    
    if (currency) {
        if (body.length != 0)
            [body appendString:@"&"];
        [body appendFormat:@"currency=%@", currency];
    }
    
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)performRequestWithCard:(StripeCard *)card amountInCents:(NSNumber *)amount currency:(NSString *)currency success:(void (^)(StripeResponse *response))success error:(void (^)(NSError *error))error {
    NSURL *url = [[NSURL URLWithString:
                   [NSString stringWithFormat:kStripeAPIBase, [self escapedString:self.publishableKey]]]
                  URLByAppendingPathComponent:kStripeTokenPath];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPBody = [self HTTPBodyWithCard:card amountInCents:amount currency:currency];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:^(NSURLResponse *response, NSData *body, NSError *requestError) 
    {
        if (!response && requestError) {
            if ([requestError.domain isEqualToString:@"NSURLErrorDomain"] && 
                requestError.code == NSURLErrorUserCancelledAuthentication) {
                error([NSError errorWithDomain:@"Stripe" code:0 userInfo:
                       [NSDictionary dictionaryWithObject:@"Authentication failed" forKey:@"message"]]);
            } else
                error(requestError);
            
            return;
        }
        
        NSDictionary *unserialized = [NSJSONSerialization JSONObjectWithData:body options:0 error:NULL];
        if ([(NSHTTPURLResponse *)response statusCode] == 200) {
            StripeResponse *stripeResponse = [[StripeResponse alloc] initWithResponseDictionary:unserialized];
        
            success(stripeResponse);
        } else {
            error([NSError errorWithDomain:@"Stripe" code:0 userInfo:[unserialized objectForKey:@"error"]]);
        }
    }];
}

- (void)performRequestWithCard:(StripeCard *)card amountInCents:(NSNumber *)amount success:(void (^)(StripeResponse *response))success error:(void (^)(NSError *error))error {
    [self performRequestWithCard:card amountInCents:amount currency:@"usd" success:success error:error];
}

@end


@implementation StripeCard
@synthesize number, expiryMonth, expiryYear, securityCode, name, addressLine1, addressLine2, addressZip, addressState, addressCountry, country, cvcCheck, lastFourDigits, type;

- (NSDictionary *)attributes {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.number         ? self.number : [NSNull null],         @"number",
            self.expiryMonth    ? self.expiryMonth : [NSNull null],    @"exp_month",
            self.expiryYear     ? self.expiryYear : [NSNull null],     @"exp_year",
            self.securityCode   ? self.securityCode : [NSNull null],   @"cvc",
            self.name           ? self.name : [NSNull null],           @"name",
            self.addressLine1   ? self.addressLine1 : [NSNull null],   @"address_line1",
            self.addressLine2   ? self.addressLine2 : [NSNull null],   @"address_line2",
            self.addressZip     ? self.addressZip : [NSNull null],     @"address_zip",
            self.addressState   ? self.addressState : [NSNull null],   @"address_state",
            self.addressCountry ? self.addressCountry : [NSNull null], @"address_country",
            nil];
}

- (id)initWithResponseDictionary:(NSDictionary *)card {
    if ((self = [super init])) {
        self.country = [card objectForKey:@"country"];
        self.cvcCheck = [card objectForKey:@"cvc_check"];
        self.expiryMonth = [card objectForKey:@"exp_month"];
        self.expiryYear = [card objectForKey:@"exp_year"];
        self.lastFourDigits = [card objectForKey:@"last4"];
        self.type = [card objectForKey:@"type"];
    }
    
    return self;
}

@end

@implementation StripeResponse
@synthesize createdAt, currency, amount, isUsed, isLiveMode, token, card;

- (id)initWithResponseDictionary:(NSDictionary *)response {
    if ((self = [super init])) {
        self.createdAt = [response objectForKey:@"created"];
        self.currency = [response objectForKey:@"currency"];
        self.isUsed = [[response objectForKey:@"used"] boolValue];
        self.amount = [response objectForKey:@"amount"];
        self.isLiveMode = [[response objectForKey:@"livemode"] boolValue];
        self.token = [response objectForKey:@"id"];
        self.card = [[StripeCard alloc] initWithResponseDictionary:[response objectForKey:@"card"]];
    }
    
    return self;
}

@end
