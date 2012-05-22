#import "Stripe.h"
#import "STCardViewController.h"

@implementation STCardViewController
@synthesize stripeConnection, nameField, numberField, expiryField, CVCField, pickerView, keyboardToolbar, delegate, segmentedControl, fields = _fields;

- (id)init {
    if ((self = [super init])) {
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
    self.nameField.returnKeyType = UIReturnKeyNext;
    
    self.numberField.inputAccessoryView = self.keyboardToolbar;
    self.numberField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.expiryField.inputAccessoryView = self.keyboardToolbar;
    self.expiryField.inputView = self.pickerView;
    
    self.CVCField.inputAccessoryView = self.keyboardToolbar;
    self.CVCField.keyboardType = UIKeyboardTypeNumberPad;
    self.CVCField.returnKeyType = UIReturnKeyGo;
    
    self.fields = [NSArray arrayWithObjects:
                   self.nameField,
                   self.numberField,
                   self.expiryField,
                   self.CVCField,
                   nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger i = [self.fields indexOfObject:textField];
    if (i < self.fields.count - 1) {
        [[self.fields objectAtIndex:i + 1] becomeFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSInteger i = [self.fields indexOfObject:textField];
    if (i == self.fields.count - 1) {
        [self.segmentedControl setEnabled:YES forSegmentAtIndex:0];
        [self.segmentedControl setEnabled:NO forSegmentAtIndex:1];
    } else if (i == 0) {
        [self.segmentedControl setEnabled:NO forSegmentAtIndex:0];
        [self.segmentedControl setEnabled:YES forSegmentAtIndex:1];
    } else {
        [self.segmentedControl setEnabled:YES forSegmentAtIndex:0];
        [self.segmentedControl setEnabled:YES forSegmentAtIndex:1];
    }
    
    return YES;
}

- (void)viewDidUnload {
    self.fields = nil;
    [super viewDidUnload];
}

- (IBAction)fieldSelected:(UISegmentedControl *)control {
    NSInteger idx = NSNotFound;
    NSInteger i = 0;
    for (UIResponder *r in self.fields) {
        if (r.isFirstResponder) {
            idx = i;
            break;
        }
        
        i++;
    }
    
    if (idx == NSNotFound) return;

    if (control.selectedSegmentIndex == 0) {
        if (idx > 0) {
            [[self.fields objectAtIndex:idx - 1] becomeFirstResponder];
        }
    } else {
        if (idx < self.fields.count - 1) {
            [[self.fields objectAtIndex:idx + 1] becomeFirstResponder];
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
        return [NSString stringWithFormat:@"%02d", row + 1];
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
    self.expiryField.text = [NSString stringWithFormat:@"%02d/%@", [month integerValue], year];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.nameField becomeFirstResponder];
}

- (NSString *)title {
    return @"Add Credit Card";
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0)
        return 50.0f;
    else
        return 80.0f;
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    StripeCard *card      = [[StripeCard alloc] init];
    card.number           = self.numberField.text;
    
    NSArray *date = [self.expiryField.text componentsSeparatedByString:@"/"];
    if (date.count == 2) {
        card.expiryMonth      = [NSNumber numberWithInteger:[[date objectAtIndex:0] integerValue]];
        card.expiryYear       = [NSNumber numberWithInteger:[[date objectAtIndex:1] integerValue]];
    }
    
    card.name         = self.nameField.text;
    card.securityCode = self.CVCField.text;
    
    sender.enabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.stripeConnection performRequestWithCard:card 
                                          success:^(StripeResponse *response) 
     {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         [self.navigationController dismissModalViewControllerAnimated:YES];
         [self.delegate addResponse:response];
     }
                                          error:^(NSError *error) 
     {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         sender.enabled = YES;
         
         if ([error.domain isEqualToString:@"Stripe"]) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                             message:[error.userInfo objectForKey:@"message"]
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             
         } else {
             /* Handle network error here */
             NSLog(@"%@", error);
         }
     }];

}

@end
