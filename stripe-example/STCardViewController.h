@class StripeConnection;

@protocol STCardViewControllerDelegate <NSObject>
- (void)addToken:(NSString *)token;
@end

@interface STCardViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) StripeConnection *stripeConnection;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UITextField *expiryField;
@property (weak, nonatomic) IBOutlet UITextField *CVCField;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIToolbar *keyboardToolbar;
@property (weak, nonatomic) id <STCardViewControllerDelegate>delegate;

- (IBAction)fieldSelected:(UISegmentedControl *)control;
- (IBAction)donePressed:(id)sender;
@end
