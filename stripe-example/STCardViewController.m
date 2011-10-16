#import "Stripe.h"
#import "STCardViewController.h"

@implementation STCardViewController
@synthesize stripeConnection, nameField, numberField, expiryField, CVCField, pickerView, keyboardToolbar, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.navigationItem.leftBarButtonItem = 
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    }
    
    return self;
}

- (void)cancel:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameField.inputAccessoryView = self.keyboardToolbar;
    self.nameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    self.numberField.inputAccessoryView = self.keyboardToolbar;
    self.numberField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.expiryField.inputAccessoryView = self.keyboardToolbar;
    self.expiryField.inputView = self.pickerView;
    
    self.CVCField.inputAccessoryView = self.keyboardToolbar;
    self.CVCField.keyboardType = UIKeyboardTypeNumberPad;
}

- (IBAction)fieldSelected:(UISegmentedControl *)control {
    if (control.selectedSegmentIndex == 0) {
        if (self.numberField.isFirstResponder) {
            [self.nameField becomeFirstResponder];
            
        } else if (self.expiryField.isFirstResponder) {
            [self.numberField becomeFirstResponder];
        } else if (self.CVCField.isFirstResponder) {
            [self.expiryField becomeFirstResponder];
        }
    } else {
        
        if (self.nameField.isFirstResponder) {
            [self.numberField becomeFirstResponder];
            
        } else if (self.numberField.isFirstResponder) {
            [self.expiryField becomeFirstResponder];
            
        } else if (self.expiryField.isFirstResponder) {
            
            [self.CVCField becomeFirstResponder];
        }
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return component == 0 ? 12 : 40;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0)
        return [[NSNumber numberWithInteger:row + 1] stringValue];
    else {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
        return [[NSNumber numberWithInteger:[components year] + row] stringValue];
    }
}

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *month = [self pickerView:aPickerView 
                           titleForRow:[self.pickerView selectedRowInComponent:0]
                          forComponent:0];
    NSString *year = [self pickerView:aPickerView 
                          titleForRow:[self.pickerView selectedRowInComponent:1]
                         forComponent:1];
    self.expiryField.text = [NSString stringWithFormat:@"%@/%@", month, year];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nameField becomeFirstResponder];
}

- (NSString *)title {
    return @"Add Credit Card";
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    StripeCard *card      = [[StripeCard alloc] init];
    card.number           = self.numberField.text;
    
    NSArray *date = [self.expiryField.text componentsSeparatedByString:@"/"];
    if (date.count == 2) {
        card.expiryMonth      = [NSNumber numberWithInteger:[[date objectAtIndex:0] integerValue]];
        card.expiryYear       = [NSNumber numberWithInteger:[[date objectAtIndex:1] integerValue]];
    }
    
    card.name             = self.nameField.text;
    card.cardSecurityCode = self.CVCField.text;
    
    sender.enabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.stripeConnection performRequestWithCard:card 
                                    amountInCents:[NSNumber numberWithInteger:200] 
                                          success:^(StripeResponse *token) 
     {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         [self.navigationController dismissModalViewControllerAnimated:YES];
         [self.delegate addToken:token.token];
     }
                                          failure:^(NSDictionary *failure) 
     {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         sender.enabled = YES;
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                          message:[[failure objectForKey:@"error"] 
                                                                   objectForKey:@"message"]
                                                         delegate:nil 
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
     }];

}

@end
