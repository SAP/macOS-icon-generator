/*
     MTUninstallViewController.m
     Copyright 2022-2025 SAP SE
     
     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at
     
     http://www.apache.org/licenses/LICENSE-2.0
     
     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License.
*/

#import "MTUninstallViewController.h"

@interface MTUninstallViewController ()
@property (weak) IBOutlet MTUninstallIconView *uninstallIconView;
@property (weak) IBOutlet NSSlider *speedSlider;
@property (weak) IBOutlet NSSlider *scalingSlider;
@property (weak) IBOutlet NSButton *autoAdjustCheckbox;

@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readwrite) NSUserDefaultsController *defaultsController;
@property (nonatomic, strong, readwrite) NSString *bannerText;
@property (readonly) BOOL enableRemoveBannerMenu;
@end

@implementation MTUninstallViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // initialize some stuff
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
    _defaultsController = [[NSUserDefaultsController alloc] initWithDefaults:_userDefaults initialValues:nil];

    [_uninstallIconView setDelegate:self];
    [_uninstallIconView setAccessibilityChildren:nil];
    [_uninstallIconView setAutoInsetEnabled:[_userDefaults boolForKey:kMTDefaultsAutoImageSizeKey]];
    [_uninstallIconView setImageInset:[_userDefaults floatForKey:kMTDefaultsImageSizeAdjustmentKey]];

    // anmimation speed slider
    [_speedSlider setMinValue:kMTAnimationDurationMin];
    [_speedSlider setMaxValue:kMTAnimationDurationMax];

    // scaling slider
    [_scalingSlider setMinValue:kMTImageInsetMin];
    [_scalingSlider setMaxValue:kMTImageInsetMax];
    
#pragma mark bindings

    // bindings to our custom defaults controller
    [_speedSlider bind:NSValueBinding
              toObject:_defaultsController
           withKeyPath:[@"values." stringByAppendingString:kMTDefaultsAnimationDurationKey]
               options:nil
    ];

    [_autoAdjustCheckbox bind:NSValueBinding
                     toObject:_defaultsController
                  withKeyPath:[@"values." stringByAppendingString:kMTDefaultsAutoImageSizeKey]
                      options:nil
    ];
    
    // update the slider's tooltips
    [self updateSpeedSliderToolTip:nil];
    [self updateScalingSliderToolTip:nil];

#pragma mark notifications

    // get notified if the image changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageChanged:)
                                                 name:kMTNotificationNameImageChanged
                                               object:nil
    ];
    
    // get notified if the icon should be saved
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveIcon:)
                                                 name:kMTNotificationNameSaveIcon
                                               object:nil
    ];
}

#pragma mark IBActions

- (IBAction)updateSpeedSliderToolTip:(id)sender
{
    CGFloat duration = [_speedSlider doubleValue];
    
    // unfortunately NSDateComponentsFormatter does only support
    // integer numbers as seconds, so we have to format our duration
    // using NSNumberFormatter and NSDateComponentsFormatter to get
    // a localized variant
    NSDateComponentsFormatter *fractionFormatter = [[NSDateComponentsFormatter alloc] init];
    [fractionFormatter setAllowedUnits:NSCalendarUnitSecond];
    [fractionFormatter setUnitsStyle:NSDateComponentsFormatterUnitsStyleFull];
    
    NSNumberFormatter *secondsFormatter = [[NSNumberFormatter alloc] init];
    [secondsFormatter setMaximumIntegerDigits:1];
    [secondsFormatter setMinimumFractionDigits:0];
    [secondsFormatter setMaximumFractionDigits:0];
    [secondsFormatter setRoundingMode:NSNumberFormatterRoundFloor];
    [secondsFormatter setAlwaysShowsDecimalSeparator:YES];
    
    NSString *secondsString = [secondsFormatter stringFromNumber:[NSNumber numberWithDouble:duration]];
    NSString *fractionString = [fractionFormatter stringFromTimeInterval:duration * 1000];

    [_speedSlider setToolTip:[NSString localizedStringWithFormat:NSLocalizedString(@"speedSliderTooltip", nil), [secondsString stringByAppendingString:fractionString]]];
    
    if (sender) { [_uninstallIconView animateWithDuration:duration repeatCount:3]; }
}

- (IBAction)updateScalingSliderToolTip:(id)sender
{
    NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
    [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [percentFormatter setMaximumFractionDigits:1];
    [percentFormatter setMultiplier:@100];
    [_scalingSlider setToolTip:[NSString localizedStringWithFormat:NSLocalizedString(@"scalingSliderTooltip", nil), [percentFormatter stringFromNumber:[NSNumber numberWithDouble:[_scalingSlider doubleValue]]]]];
    
    if (sender) {
        
        if ([_autoAdjustCheckbox state] == NSControlStateValueOn) {
            
            [_autoAdjustCheckbox setAllowsMixedState:YES];
            [_autoAdjustCheckbox setState:NSControlStateValueMixed];
            
            [_userDefaults removeObjectForKey:kMTDefaultsImageSizeAdjustmentKey];
                        
        } else if ([_autoAdjustCheckbox state] == NSControlStateValueOff) {
            
            [_userDefaults setFloat:[_uninstallIconView imageInset] forKey:kMTDefaultsImageSizeAdjustmentKey];
        }
    }
}

- (IBAction)setAutoAdjust:(id)sender
{
    [_autoAdjustCheckbox setAllowsMixedState:NO];
    
    BOOL enable = ([_autoAdjustCheckbox state] == NSControlStateValueOn) ? YES : NO;
    [_uninstallIconView setAutoInsetEnabled:enable];
    
    if (enable) {
        
        [_uninstallIconView setImageInset:[_uninstallIconView autoInset]];
        [self updateScalingSliderToolTip:nil];
        
        [_userDefaults removeObjectForKey:kMTDefaultsImageSizeAdjustmentKey];
        
    } else {
        
        [_userDefaults setFloat:[_uninstallIconView imageInset] forKey:kMTDefaultsImageSizeAdjustmentKey];
    }
}

- (void)view:(MTDropView*)view didChangeImageAtURL:(NSURL*)url
{
    [self updateScalingSliderToolTip:nil];

    [_autoAdjustCheckbox setAllowsMixedState:NO];
    if ([_userDefaults boolForKey:kMTDefaultsAutoImageSizeKey]) { [_autoAdjustCheckbox setState:NSControlStateValueOn]; }
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameImageChanged
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:url
                                                                                           forKey:kMTNotificationKeyImageURL
                                                               ]
    ];
}

- (void)imageChanged:(NSNotification*)aNotification
{
    if (![[aNotification object] isEqualTo:self]) {

        NSURL *imageURL = [[aNotification userInfo] objectForKey:kMTNotificationKeyImageURL];
        NSImage *image = [NSImage imageWithFileAtURL:imageURL];
        
        if ([image isValid]) {
            
            [_uninstallIconView setImage:image];
            
            [self updateScalingSliderToolTip:nil];
            
            [_autoAdjustCheckbox setAllowsMixedState:NO];
            if ([_userDefaults boolForKey:kMTDefaultsAutoImageSizeKey]) { [_autoAdjustCheckbox setState:NSControlStateValueOn]; }
        }
    }
}

- (void)saveIcon:(NSNotification*)aNotification
{
    if ([_userDefaults boolForKey:kMTDefaultsSaveUninstallIconKey] ||
        [_userDefaults boolForKey:kMTDefaultsSaveAnimatedUninstallIconKey]) {
        
        NSDictionary *userInfo = [aNotification userInfo];
        NSString *path = [userInfo objectForKey:kMTNotificationKeyFolderPath];
        
        if (path) {
            
            NSInteger outputSize = [_userDefaults integerForKey:kMTDefaultsOutputSizeKey];
            CGFloat animationDuration = [_userDefaults floatForKey:kMTDefaultsAnimationDurationKey];
            
            MTIconSet *iconSet = [[MTIconSet alloc] init];
            [iconSet setUninstallIcon:[NSImage imageWithView:[_uninstallIconView icon]
                                                        size:NSMakeSize(outputSize, outputSize)]
            ];
            [iconSet setAnimationDuration:([_userDefaults boolForKey:kMTDefaultsSaveAnimatedUninstallIconKey]) ? animationDuration : 0];
            [iconSet setFileNamePrefix:[userInfo objectForKey:kMTNotificationKeyFileNamePrefix]];
            [iconSet writeToFolder:path
                      createFolder:NO
                      animatedOnly:![_userDefaults boolForKey:kMTDefaultsSaveUninstallIconKey]
                 completionHandler:nil
            ];
        }
    }
}

- (void)dealloc
{
    // remove our observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameImageChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameSaveIcon object:nil];
}

@end
