// --------------------------------------------------------------------------------
// The MIT License (MIT)
//
// Copyright (c) 2014 Shiny Development
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// --------------------------------------------------------------------------------

#import "ViewController.h"
#import "SDStatusBarManager.h"

@interface ViewController () 
@property (strong, nonatomic) IBOutlet UIButton *overrideButton;
@property (strong, nonatomic) IBOutlet UITextField *timeStringTextField;
@property (strong, nonatomic) IBOutlet UILabel *dateStringLabel;
@property (strong, nonatomic) IBOutlet UITextField *dateStringTextField;
@property (strong, nonatomic) IBOutlet UITextField *carrierNameTextField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *bluetoothSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *networkModeSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *networkTypeSegmentedControl;
@property (strong, nonatomic) IBOutlet UISwitch *wifiSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *batteryPercentageSwitch;
@end

@implementation ViewController

#pragma mark View lifecycle
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.overrideButton.titleLabel.adjustsFontSizeToFitWidth = YES;
  
  if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone )
  {
    [self.networkModeSegmentedControl setTitle:@"Cellular" forSegmentAtIndex:1];
    [self.networkModeSegmentedControl removeSegmentAtIndex:2 animated:NO];
  }

  [self setOverrideButtonText];
  [self setBluetoothSegementedControlSelectedSegment];
  [self setNetworkModeSegementedControlSelectedSegment];
  [self setNetworkTypeSegementedControlSelectedSegment];
  [self setCarrierNameTextFieldText];
  [self setTimeStringTextFieldText];
  [self setDateFieldVisibility];
  
  [self setNetworkTypeSegmentedControlEnabled];
  
  NSDictionary *environment = [[NSProcessInfo processInfo] environment];
  if ([environment[@"SIMULATOR_STATUS_MAGIC_OVERRIDES"] isEqualToString:@"ENABLE"]) {
    [[SDStatusBarManager sharedInstance] enableOverrides];
    [self setOverrideButtonText];
  }
  if ([environment[@"SIMULATOR_STATUS_MAGIC_OVERRIDES"] isEqualToString:@"DISABLE"]) {
    [[SDStatusBarManager sharedInstance] disableOverrides];
    [self setOverrideButtonText];
  }
}

#pragma mark Actions
- (IBAction)overrideButtonTapped:(UIButton *)sender
{
  if ([SDStatusBarManager sharedInstance].usingOverrides) {
    [[SDStatusBarManager sharedInstance] disableOverrides];
    [self setOverrideButtonText];
  } else {
    [[SDStatusBarManager sharedInstance] enableOverrides];
    [self setOverrideButtonText];
  }
}

- (IBAction)carrierNameTextFieldEditingChanged:(UITextField *)textField
{
  [SDStatusBarManager sharedInstance].carrierName = textField.text;
}

- (IBAction)timeStringTextFieldEditingChanged:(UITextField *)textField
{
  [SDStatusBarManager sharedInstance].timeString = textField.text;
}

- (IBAction)dateStringTextFieldEditingChanged:(UITextField *)textField
{
	[SDStatusBarManager sharedInstance].dateString = textField.text;
}

- (IBAction)bluetoothStatusChanged:(UISegmentedControl *)sender
{
  // Note: The order of the segments should match the definition of SDStatusBarManagerBluetoothState
  [[SDStatusBarManager sharedInstance] setBluetoothState:sender.selectedSegmentIndex];
}

- (IBAction)networkModeTypeChanged:(UISegmentedControl *)sender
{
  switch ( sender.selectedSegmentIndex )
  {
    case 0: // Airplay Mode
      [[SDStatusBarManager sharedInstance] setAirplaneMode:YES];
      [[SDStatusBarManager sharedInstance] setIPadGsmSignalEnabled:NO];
      break;
      
    case 1: // Wi-Fi Only
      [[SDStatusBarManager sharedInstance] setAirplaneMode:NO];
      [[SDStatusBarManager sharedInstance] setIPadGsmSignalEnabled:NO];
      break;
      
    case 2: // Wi-Fi + Cellular
      [[SDStatusBarManager sharedInstance] setAirplaneMode:NO];
      [[SDStatusBarManager sharedInstance] setIPadGsmSignalEnabled:YES];
      break;
      
    default:
      break;
  }
  
  if ([SDStatusBarManager sharedInstance].usingOverrides) {
    [[SDStatusBarManager sharedInstance] disableOverrides];
    [[SDStatusBarManager sharedInstance] enableOverrides];
  }
  
  [self setNetworkTypeSegmentedControlEnabled];
}

- (IBAction)networkTypeChanged:(UISegmentedControl *)sender
{
  // Note: The order of the segments should match the definition of SDStatusBarManagerNetworkType
  [[SDStatusBarManager sharedInstance] setNetworkType:sender.selectedSegmentIndex];
}

- (IBAction)wifiOnStatusChanged:(UISwitch *)sender
{
  BOOL disabled = !sender.isOn;
  [[SDStatusBarManager sharedInstance] setDisableWifi:disabled];
}

- (IBAction)showBatteryPercentageStatusChanged:(UISwitch *)sender
{
  BOOL enabled = sender.isOn;
  [[SDStatusBarManager sharedInstance] setBatteryDetailEnabled:enabled];
}

#pragma mark Text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

#pragma mark UI helpers
- (void)setOverrideButtonText
{
  if ([SDStatusBarManager sharedInstance].usingOverrides) {
    [self.overrideButton setTitle:NSLocalizedString(@"Restore Default Status Bar", @"Restore Default Status Bar")  forState:UIControlStateNormal];
  } else {
    [self.overrideButton setTitle:NSLocalizedString(@"Apply Clean Status Bar Overrides", "Apply Clean Status Bar Overrides") forState:UIControlStateNormal];
  }
}

- (void)setBluetoothSegementedControlSelectedSegment
{
  // Note: The order of the segments should match the definition of SDStatusBarManagerBluetoothState
  self.bluetoothSegmentedControl.selectedSegmentIndex = [SDStatusBarManager sharedInstance].bluetoothState;
}

- (void)setNetworkModeSegementedControlSelectedSegment
{
  if ( [SDStatusBarManager sharedInstance].airplaneMode )
  {
    self.networkTypeSegmentedControl.selectedSegmentIndex = 0;
  }
  else if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone )
  {
    self.networkTypeSegmentedControl.selectedSegmentIndex = 1;
  }
  else // UIUserInterfaceIdiomPad
  {
    BOOL iPadGsmSignalEnabled = [SDStatusBarManager sharedInstance].iPadGsmSignalEnabled;
    if ( iPadGsmSignalEnabled )
      self.networkTypeSegmentedControl.selectedSegmentIndex = 2;
    else
      self.networkTypeSegmentedControl.selectedSegmentIndex = 1;
  }
}

- (void)setNetworkTypeSegementedControlSelectedSegment
{
  // Note: The order of the segments should match the definition of SDStatusBarManagerNetworkType
  self.networkTypeSegmentedControl.selectedSegmentIndex = [SDStatusBarManager sharedInstance].networkType;
}

- (void)setCarrierNameTextFieldText
{
  self.carrierNameTextField.placeholder = NSLocalizedString(@"Carrier", @"Carrier");
  self.carrierNameTextField.text = [SDStatusBarManager sharedInstance].carrierName;
}

- (void)setTimeStringTextFieldText
{
  self.timeStringTextField.text = [SDStatusBarManager sharedInstance].timeString;
}

- (void)setDateStringTextFieldText
{
  self.dateStringTextField.text = [SDStatusBarManager sharedInstance].dateString;
}

- (void)setDateFieldVisibility
{
  // Only show the date field on iPad devices as the date is never shown on iPhone devices.
  BOOL dateFieldHidden = UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad;
  self.dateStringLabel.hidden = dateFieldHidden;
  self.dateStringTextField.hidden = dateFieldHidden;
}

- (void)setNetworkTypeSegmentedControlEnabled
{
  BOOL enabled;
  if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone )
  {
    enabled = ( self.networkModeSegmentedControl.selectedSegmentIndex == 1 );
  }
  else // UIUserInterfaceIdiomPad
  {
    enabled = ( self.networkModeSegmentedControl.selectedSegmentIndex == 2 );
  }
  self.networkTypeSegmentedControl.enabled = enabled;
}
 
#pragma mark Status bar settings
- (BOOL)prefersStatusBarHidden
{
  return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleDefault;
}

@end
