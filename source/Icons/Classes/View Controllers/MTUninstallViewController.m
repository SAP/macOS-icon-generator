/*
     MTUninstallViewController.m
     Copyright 2022 SAP SE
     
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
@property (weak) IBOutlet NSImageView *cautionImageView;
@property (weak) IBOutlet NSSlider *speedSlider;
@property (weak) IBOutlet NSSlider *scalingSlider;
@property (weak) IBOutlet NSButton *autoAdjustCheckbox;
@property (weak) IBOutlet NSButton *autoOutputSizeCheckbox;
@property (weak) IBOutlet NSPopUpButton *outputSizeMenu;

@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readwrite) NSUserDefaultsController *defaultsController;
@property (nonatomic, strong, readwrite) NSString *bannerText;
@property (nonatomic, assign) NSInteger selectedTag;
@property (readonly) BOOL enableRemoveBannerMenu;
@end

@implementation MTUninstallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize some stuff
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
    _defaultsController = [[NSUserDefaultsController alloc] initWithDefaults:_userDefaults initialValues:nil];

    [_uninstallIconView setDelegate:self];
    [_uninstallIconView setAutoInsetEnabled:[_userDefaults boolForKey:kMTDefaultsAutoImageSize]];

    // output sizes menu
    [[_outputSizeMenu menu] removeAllItems];
    for (NSNumber *outputSize in kMTOutputSizes) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ x %@ %@", outputSize, outputSize, NSLocalizedString(@"outputSize", nil)]
                                                          action:nil
                                                   keyEquivalent:@""];
        [menuItem setTag:[outputSize integerValue]];
        [[_outputSizeMenu menu] addItem:menuItem];
    }

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
           withKeyPath:[@"values." stringByAppendingString:kMTDefaultsAnimationDuration]
               options:nil];

    [_autoAdjustCheckbox bind:NSValueBinding
                     toObject:_defaultsController
                  withKeyPath:[@"values." stringByAppendingString:kMTDefaultsAutoImageSize]
                      options:nil];

    [_autoOutputSizeCheckbox bind:NSValueBinding
                         toObject:_defaultsController
                      withKeyPath:[@"values." stringByAppendingString:kMTDefaultsAutoOutputSize]
                          options:nil];

    [_outputSizeMenu bind:NSSelectedTagBinding
                 toObject:_defaultsController
              withKeyPath:[@"values." stringByAppendingString:kMTDefaultsOutputSize]
                  options:nil];
    
    // update the slider's tooltips
    [self updateSpeedSliderToolTip:nil];
    [self updateScalingSliderToolTip:nil];

#pragma mark notifications

    // get notified if the image changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageChanged:)
                                                 name:@"corp.sap.Icons.installImageChangedNotification"
                                               object:nil];
    
    // get notified if the icon should be saved
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveIcon:)
                                                 name:@"corp.sap.Icons.saveIconNotification"
                                               object:nil];
}

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
    
    if (sender && [_autoAdjustCheckbox state] == NSControlStateValueOn) {
        [_autoAdjustCheckbox setAllowsMixedState:YES];
        [_autoAdjustCheckbox setState:NSControlStateValueMixed];
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
    }
}

- (IBAction)setAutoOutputSize:(id)sender
{
    [_autoOutputSizeCheckbox setAllowsMixedState:NO];
    
    if ([_autoOutputSizeCheckbox state] == NSControlStateValueOn) {
        
        NSImage *sourceImage = [_uninstallIconView image];
        
        if ([sourceImage isValid]) {
        
            for (NSNumber *anOutputSize in [kMTOutputSizes reverseObjectEnumerator]) {
                BOOL canBeScaled = [sourceImage canBeScaledToSize:NSMakeSize([anOutputSize floatValue], [anOutputSize floatValue])];
                
                if (canBeScaled) {
                    [_userDefaults setInteger:[anOutputSize integerValue] forKey:kMTDefaultsOutputSize];
                    [_outputSizeMenu selectItemWithTag:[anOutputSize integerValue]];
                    [self updateUpscaleWarningWithSize:[anOutputSize integerValue]];
                    break;
                }
            }
        }
    
    }
}

- (void)menu:(NSMenu*)menu willHighlightItem:(NSMenuItem*)item
{
    if (item) { [self updateUpscaleWarningWithSize:[item tag]]; }
}

- (void)menuWillOpen:(NSMenu*)menu
{
    _selectedTag = [_outputSizeMenu selectedTag];
}

- (void)menuDidClose:(NSMenu*)menu
{
    NSInteger newSelectedTag = [_outputSizeMenu selectedTag];
    [self updateUpscaleWarningWithSize:newSelectedTag];

    if (newSelectedTag != _selectedTag && [_autoOutputSizeCheckbox state] == NSControlStateValueOn) {
        [_autoOutputSizeCheckbox setAllowsMixedState:YES];
        [_autoOutputSizeCheckbox setState:NSControlStateValueMixed];
    }
}

- (void)updateUpscaleWarningWithSize:(NSInteger)outputSize
{
    NSImage *sourceImage = [_uninstallIconView image];
    
    if ([sourceImage isValid]) {
        BOOL canBeScaled = [sourceImage canBeScaledToSize:NSMakeSize(outputSize, outputSize)];
        [_cautionImageView setHidden:canBeScaled];
        [_cautionImageView setToolTip:NSLocalizedString(@"upscaleWarning", nil)];
    }
}

- (void)view:(MTDropView*)view didChangeImage:(NSImage*)image
{
    [self updateUpscaleWarningWithSize:[self->_userDefaults integerForKey:kMTDefaultsOutputSize]];
    [self updateScalingSliderToolTip:nil];

    [_autoAdjustCheckbox setAllowsMixedState:NO];
    if ([_userDefaults boolForKey:kMTDefaultsAutoImageSize]) { [_autoAdjustCheckbox setState:NSControlStateValueOn]; }

    [_autoOutputSizeCheckbox setAllowsMixedState:NO];
    if ([_userDefaults boolForKey:kMTDefaultsAutoOutputSize]) {
        [_autoOutputSizeCheckbox setState:NSControlStateValueOn];
        [self setAutoOutputSize:nil];
    }
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"corp.sap.Icons.uninstallImageChangedNotification"
                                                        object:image
                                                      userInfo:nil
    ];
}

- (void)imageChanged:(NSNotification*)aNotification
{
    NSImage *image = [aNotification object];
    
    if ([image isValid]) {
        [_uninstallIconView setImage:image];
        
        [self updateUpscaleWarningWithSize:[self->_userDefaults integerForKey:kMTDefaultsOutputSize]];
        [self updateScalingSliderToolTip:nil];

        [_autoAdjustCheckbox setAllowsMixedState:NO];
        if ([_userDefaults boolForKey:kMTDefaultsAutoImageSize]) { [_autoAdjustCheckbox setState:NSControlStateValueOn]; }

        [_autoOutputSizeCheckbox setAllowsMixedState:NO];
        if ([_userDefaults boolForKey:kMTDefaultsAutoOutputSize]) {
            [_autoOutputSizeCheckbox setState:NSControlStateValueOn];
            [self setAutoOutputSize:nil];
        }
    }
}

- (void)saveIcon:(NSNotification*)aNotification
{
    NSString *path = [aNotification object];
    
    if (path) {
        
        NSInteger outputSize = [_userDefaults integerForKey:kMTDefaultsOutputSize];
        CGFloat animationDuration = [_userDefaults floatForKey:kMTDefaultsAnimationDuration];

        MTIconSet *iconSet = [[MTIconSet alloc] init];
        [iconSet setUninstallIcon:[NSImage imageWithView:[_uninstallIconView icon] size:NSMakeSize(outputSize, outputSize)]];
        [iconSet setAnimationDuration:animationDuration];
        [iconSet writeToFolder:path createFolder:NO completionHandler:nil];
    }
}

- (void)dealloc
{
    // remove our observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
