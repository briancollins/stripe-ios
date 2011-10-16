#import "Stripe.h"
#import "STRootViewController.h"
#import "STCardViewController.h"

@interface STRootViewController ()
@property (strong, nonatomic) StripeConnection *stripeConnection;
@property (strong, nonatomic) NSMutableArray *tokens;
@end

@implementation STRootViewController
@synthesize stripeConnection = _stripeConnection, tokens;

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        self.stripeConnection = [StripeConnection connectionWithPublishableKey:@"pk_dl4LcpeAxUEPHN3FxzuAQQmhCGmx5"];
        self.navigationItem.rightBarButtonItem = 
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self
                                                      action:@selector(addCard:)];
        self.tokens = [NSMutableArray array];
    }
    
    return self;
}

- (void)addCard:(id)sender {
    STCardViewController *cardViewController = [[STCardViewController alloc] initWithNibName:@"STCardViewController" bundle:[NSBundle mainBundle]];
    cardViewController.stripeConnection = self.stripeConnection;
    cardViewController.delegate = (id <STCardViewControllerDelegate>)self;
    
    [self.navigationController presentModalViewController:
     [[UINavigationController alloc]
      initWithRootViewController:cardViewController]
                                         animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tokens.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"TokenCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [self.tokens objectAtIndex:indexPath.row];
    return cell;
}

- (void)addToken:(NSString *)token {
    [self.tokens insertObject:token atIndex:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSString *)title {
    return @"Payments Example";
}

@end
