// --------------------------------------------------------------------------------
// The MIT License (MIT)
//
// Copyright (c) 2014-2016 Shiny Development
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

#import <UIKit/UIKit.h>
#import "SDStatusBarOverriderPost10_0.h"

typedef NS_ENUM(int, StatusBarItem10_0) {
  DoNotDisturb = 1,
  AirplaneModeIcon = 2,
  SignalStrengthBars = 3,
  // 4
  // 5
  // 6
  // 7 - clock align right
  // 8
  BatteryDetail = 9,
  // 10
  // 11 - bluetooth battery detail
  Bluetooth = 12,
  // 13 - TTY
  Alarms = 14,
  // 15
  // 16 - carrier
  // 17 - location services
  RotationLock = 18,
  // 19
  // 20 - airplay
  // 21 - microphone
  // 22
  // 23 - school desk?
  // 24 - VPN
  // 25 - call forwarding
  // 26 - network activity
  // 27
  // 28
  // 29
  // 30
  // 31 - device locked
  // 32 - water warning
  // 33 - headphones?
};

typedef NS_ENUM(unsigned int, BatteryState) {
  BatteryStateUnplugged = 0
};

typedef struct {
  _Bool itemIsEnabled[34];
  char timeString[64];
  int gsmSignalStrengthRaw;
  int gsmSignalStrengthBars;
  char serviceString[100];
  char serviceCrossfadeString[100];
  char serviceImages[2][100];
  char operatorDirectory[1024];
  unsigned int serviceContentType;
  int wifiSignalStrengthRaw;
  int wifiSignalStrengthBars;
  unsigned int dataNetworkType;
  int batteryCapacity;
  unsigned int batteryState;
  char batteryDetailString[150];
  int bluetoothBatteryCapacity;
  int thermalColor;
  unsigned int thermalSunlightMode:1;
  unsigned int slowActivity:1;
  unsigned int syncActivity:1;
  char activityDisplayId[256];
  unsigned int bluetoothConnected:1;
  unsigned int displayRawGSMSignal:1;
  unsigned int displayRawWifiSignal:1;
  unsigned int locationIconType:1;
  unsigned int quietModeInactive:1;
  unsigned int tetheringConnectionCount;
  unsigned int batterySaverModeActive:1;
  unsigned int deviceIsRTL:1;
  unsigned int lock:1;
  char breadcrumbTitle[256];
  char breadcrumbSecondaryTitle[256];
  char personName[100];
  char returnToAppBundleIdentifier[100];
  unsigned int electronicTollCollectionAvailable:1;
  unsigned int wifiLinkWarning:1;
} StatusBarRawData;

typedef struct {
  _Bool overrideItemIsEnabled[34];
  unsigned int overrideTimeString:1;
  unsigned int overrideGsmSignalStrengthRaw:1;
  unsigned int overrideGsmSignalStrengthBars:1;
  unsigned int overrideServiceString:1;
  unsigned int overrideServiceImages:2;
  unsigned int overrideOperatorDirectory:1;
  unsigned int overrideServiceContentType:1;
  unsigned int overrideWifiSignalStrengthRaw:1;
  unsigned int overrideWifiSignalStrengthBars:1;
  unsigned int overrideDataNetworkType:1;
  unsigned int disallowsCellularDataNetworkTypes:1;
  unsigned int overrideBatteryCapacity:1;
  unsigned int overrideBatteryState:1;
  unsigned int overrideBatteryDetailString:1;
  unsigned int overrideBluetoothBatteryCapacity:1;
  unsigned int overrideThermalColor:1;
  unsigned int overrideSlowActivity:1;
  unsigned int overrideActivityDisplayId:1;
  unsigned int overrideBluetoothConnected:1;
  unsigned int overrideBreadcrumb:1;
  unsigned int overrideLock;
  unsigned int overrideDisplayRawGSMSignal:1;
  unsigned int overrideDisplayRawWifiSignal:1;
  unsigned int overridePersonName:1;
  unsigned int overrideWifiLinkWarning:1;
  StatusBarRawData values;
} StatusBarOverrideData;

@class UIStatusBarServer;

// http://localhost:10000/protocols/UIStatusBarServerClient.h (commented some methods, and added structs)
/* Generated by RuntimeBrowser.
 */

@protocol UIStatusBarServerClient

@required

- (void)statusBarServer:(UIStatusBarServer *)arg1 didReceiveStatusBarData:(const StatusBarRawData *)data withActions:(int)arg3;
- (void)statusBarServer:(UIStatusBarServer *)arg1 didReceiveStyleOverrides:(int)arg2;
- (void)statusBarServer:(UIStatusBarServer *)arg1 didReceiveGlowAnimationState:(bool)arg2 forStyle:(long long)arg3;
- (void)statusBarServer:(UIStatusBarServer *)arg1 didReceiveDoubleHeightStatusString:(NSString *)arg2 forStyle:(long long)arg3;

@end

// http://localhost:10000/classes/UIStatusBarServer.h (commented some methods, and added structs)
/* Generated by RuntimeBrowser.
 */

@interface UIStatusBarServer : NSObject

@property (nonatomic, strong) id<UIStatusBarServerClient> statusBar;

+ (void)postStatusBarOverrideData:(StatusBarOverrideData *)arg1;
+ (void)permanentizeStatusBarOverrideData;
+ (const StatusBarRawData *)getStatusBarData;
+ (StatusBarOverrideData *)getStatusBarOverrideData;

@end

@implementation SDStatusBarOverriderPost10_0

@synthesize timeString;
@synthesize carrierName;
@synthesize bluetoothConnected;
@synthesize bluetoothEnabled;
@synthesize dataNetworkMode;
@synthesize airplaneMode;
@synthesize disableWifi;
@synthesize batteryDetailEnabled;

- (void)enableOverrides
{
  StatusBarOverrideData *overrides = [UIStatusBarServer getStatusBarOverrideData];

  // Set 9:41 time in current localization
  strcpy(overrides->values.timeString, [self.timeString cStringUsingEncoding:NSUTF8StringEncoding]);
  overrides->overrideTimeString = 1;
  
  // Airplane Mode
  if (!self.airplaneMode) {
    // hide airplane
    overrides->values.itemIsEnabled[AirplaneModeIcon] = 0;
    overrides->overrideItemIsEnabled[AirplaneModeIcon] = 0;
    // Enable 5 bars of mobile (iPhone only)
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
      overrides->overrideItemIsEnabled[SignalStrengthBars] = 1;
      overrides->values.itemIsEnabled[SignalStrengthBars] = 1;
      overrides->overrideGsmSignalStrengthBars = 1;
      overrides->values.gsmSignalStrengthBars = 5;
    }
  } else {
    // show airplane
    overrides->values.itemIsEnabled[AirplaneModeIcon] = 1;
    overrides->overrideItemIsEnabled[AirplaneModeIcon] = 1;
    // remove any previous 5 bars override
    overrides->overrideItemIsEnabled[SignalStrengthBars] = 0;
    overrides->values.itemIsEnabled[SignalStrengthBars] = 0;
    overrides->overrideGsmSignalStrengthBars = 0;
  }

  // Data Network
  if (self.disableWifi) {
    overrides->overrideDataNetworkType = 1;
    overrides->values.dataNetworkType = self.dataNetworkMode;
    overrides->disallowsCellularDataNetworkTypes = (self.airplaneMode ? 1 : 0);
  } else {
    overrides->overrideDataNetworkType = 1;
    overrides->values.dataNetworkType = 5; // WiFi
    overrides->disallowsCellularDataNetworkTypes = 1;
  }
  
  // Remove carrier text for iPhone, set it to "iPad" for the iPad
  overrides->overrideServiceString = 1;
  NSString *carrierText = @""; // show empty carrier text if in Airplane Mode
  if (!self.airplaneMode) {
    carrierText = self.carrierName;
    if ([carrierText length] <= 0) {
      carrierText = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? @"" : @"iPad";
    }
  }
  strcpy(overrides->values.serviceString, [carrierText cStringUsingEncoding:NSUTF8StringEncoding]);

  // Battery: 100% and unplugged
  overrides->overrideItemIsEnabled[BatteryDetail] = YES;
  overrides->values.itemIsEnabled[BatteryDetail] = self.batteryDetailEnabled;
  overrides->overrideBatteryCapacity = YES;
  overrides->values.batteryCapacity = 100;
  overrides->overrideBatteryState = YES;
  overrides->values.batteryState = BatteryStateUnplugged;
  overrides->overrideBatteryDetailString = YES;
  NSString *batteryDetailString = self.batteryDetailEnabled ? [NSString stringWithFormat:@"%@%%", @(overrides->values.batteryCapacity)] : @" "; // Setting this to an empty string will not work, it needs to be a @" "
  strcpy(overrides->values.batteryDetailString, [batteryDetailString cStringUsingEncoding:NSUTF8StringEncoding]);

  // Bluetooth
  overrides->overrideItemIsEnabled[Bluetooth] = !!self.bluetoothEnabled;
  overrides->values.itemIsEnabled[Bluetooth] = !!self.bluetoothEnabled;
  if (self.bluetoothEnabled) {
    overrides->overrideBluetoothConnected = self.bluetoothConnected;
    overrides->values.bluetoothConnected = self.bluetoothConnected;
  }

  // Actually update the status bar
  [UIStatusBarServer postStatusBarOverrideData:overrides];

  // Remove the @" " used to trick the battery percentage into not showing, if used
  if (!self.batteryDetailEnabled) {
    batteryDetailString = @"";
    strcpy(overrides->values.batteryDetailString, [batteryDetailString cStringUsingEncoding:NSUTF8StringEncoding]);
    [UIStatusBarServer postStatusBarOverrideData:overrides];
  }

  // Lock in the changes, reset simulator will remove this
  [UIStatusBarServer permanentizeStatusBarOverrideData];
}

- (void)disableOverrides
{
  StatusBarOverrideData *overrides = [UIStatusBarServer getStatusBarOverrideData];

  // Remove all overrides that use the array of bools
  bzero(overrides->overrideItemIsEnabled, sizeof(overrides->overrideItemIsEnabled));
  bzero(overrides->values.itemIsEnabled, sizeof(overrides->values.itemIsEnabled));

  // Remove specific overrides (separate flags)
  overrides->overrideTimeString = 0;
  overrides->overrideGsmSignalStrengthBars = 0;
  overrides->overrideBatteryCapacity = 0;
  overrides->overrideBatteryState = 0;
  overrides->overrideBatteryDetailString = 0;
  overrides->overrideBluetoothConnected = 0;

  // Carrier text (it's an override to set it back to the default)
  overrides->overrideServiceString = 1;
  strcpy(overrides->values.serviceString, [NSLocalizedString(@"Carrier", @"Carrier") cStringUsingEncoding:NSUTF8StringEncoding]);

  // Actually update the status bar
  [UIStatusBarServer postStatusBarOverrideData:overrides];

  // Have to call this to remove all the overrides
  [UIStatusBarServer permanentizeStatusBarOverrideData];
}

@end
