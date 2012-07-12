#import "Stripe.h"
#import "STRootViewController.h"
#import "STCardViewController.h"

@interface STRootViewController ()
@property (strong, nonatomic) StripeConnection *stripeConnection;
@property (strong, nonatomic) NSMutableArray *responses;
@end

@implementation STRootViewController
@synthesize stripeConnection = _stripeConnection, responses;

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        self.stripeConnection = [StripeConnection connectionWithPublishableKey:@"pk_TnhRcCjprRi5m4bld3H2jhYFw6OQM"];
        self.navigationItem.rightBarButtonItem = 
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self
                                                      action:@selector(addCard:)];
        self.responses = [NSMutableArray array];
    }
    
    return self;
}

- (void)addCard:(id)sender {
    STCardViewController *cardViewController = [[STCardViewController alloc] init];
    cardViewController.stripeConnection = self.stripeConnection;
    cardViewController.delegate = (id <STCardViewControllerDelegate>)self;
    
    [self.navigationController presentModalViewController:
     [[UINavigationController alloc]
      initWithRootViewController:cardViewController]
                                         animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.responses.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"TokenCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    
    StripeResponse *response = [self.responses objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ ending with %@", response.card.type, response.card.lastFourDigits];
    cell.detailTextLabel.text = response.token;
    return cell;
}

- (void)addResponse:(StripeResponse *)response {
    [self.responses insertObject:response atIndex:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSString *)title {
    return @"Payments Example";
}

@end
