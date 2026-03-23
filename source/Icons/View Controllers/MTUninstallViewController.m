/*
    MTUninstallViewController.m
    Copyright 2016-2026 SAP SE

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
#import "MTColorValueTransformer.h"
#import "MTGroupDefaults.h"

@interface MTUninstallViewController ()
@property (weak) IBOutlet MTUninstallIconView *uninstallIconView;
@property (weak) IBOutlet NSSlider *speedSlider;
@property (weak) IBOutlet NSSlider *scalingSlider;
@property (weak) IBOutlet NSSlider *badgeShadowOffsetSlider;
@property (weak) IBOutlet NSSlider *badgeShadowRadiusSlider;
@property (weak) IBOutlet NSSlider *badgeShadowAngleSlider;
@property (weak) IBOutlet NSSlider *badgeIconSizeSlider;
@property (weak) IBOutlet NSSlider *badgeIconMarginSlider;
@property (weak) IBOutlet NSButton *autoAdjustCheckbox;
@property (weak) IBOutlet NSButton *badgeIconShadowCheckbox;
@property (weak) IBOutlet NSColorWell *badgeShadowColorWell;
@property (weak) IBOutlet NSTextField *angleTextField;
@property (weak) IBOutlet NSGridView *positionButtonGridView;

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
    _userDefaults = [MTGroupDefaults sharedDefaults];
    _defaultsController = [MTGroupDefaults sharedDefaultsController];
    
#pragma mark - Slider setup
    
    // anmimation speed slider
    [_speedSlider setMinValue:kMTAnimationDurationMin];
    [_speedSlider setMaxValue:kMTAnimationDurationMax];
    CGFloat animationDuration = [_userDefaults floatForKey:kMTDefaultsAnimationDurationKey];
    CGFloat clampedDuration = fminf(fmaxf(animationDuration, kMTAnimationDurationMin), kMTAnimationDurationMax);
    if (fabs(animationDuration - clampedDuration) > FLT_EPSILON) { [_userDefaults setFloat:clampedDuration forKey:kMTDefaultsAnimationDurationKey]; }

    // scaling slider
    [_scalingSlider setMinValue:kMTImageInsetMin];
    [_scalingSlider setMaxValue:kMTImageInsetMax];
    CGFloat imageScaling = [_userDefaults floatForKey:kMTDefaultsImageSizeAdjustmentKey];
    CGFloat clampedScaling = fminf(fmaxf(imageScaling, kMTImageInsetMin), kMTImageInsetMax);
    if (fabs(imageScaling - clampedScaling) > FLT_EPSILON) { [_userDefaults setFloat:clampedScaling forKey:kMTDefaultsImageSizeAdjustmentKey]; }
    [_uninstallIconView setImageInset:clampedScaling];
    
    // badge icon size slider
    [_badgeIconSizeSlider setMinValue:kMTBadgeIconSizeMin];
    [_badgeIconSizeSlider setMaxValue:kMTBadgeIconSizeMax];
    CGFloat badgeSize = [_userDefaults floatForKey:kMTDefaultsBadgeIconSizeKey];
    CGFloat clampedBadgeSize = fminf(fmaxf(badgeSize, kMTBadgeIconSizeMin), kMTBadgeIconSizeMax);
    if (fabs(badgeSize - clampedBadgeSize) > FLT_EPSILON) { [_userDefaults setFloat:clampedBadgeSize forKey:kMTDefaultsBadgeIconSizeKey]; }
    [_uninstallIconView setBadgeSize:clampedBadgeSize];
    
    // badge icon margin slider
    [_badgeIconMarginSlider setMinValue:kMTBadgeIconMarginMin];
    [_badgeIconMarginSlider setMaxValue:kMTBadgeIconMarginMax];
    CGFloat badgeMargin = [_userDefaults floatForKey:kMTDefaultsBadgeIconMarginKey];
    CGFloat clampedBadgeMargin = fminf(fmaxf(badgeMargin, kMTBadgeIconMarginMin), kMTBadgeIconMarginMax);
    if (fabs(badgeMargin - clampedBadgeMargin) > FLT_EPSILON) { [_userDefaults setFloat:clampedBadgeMargin forKey:kMTDefaultsBadgeIconMarginKey]; }
    [_uninstallIconView setBadgeMargin:clampedBadgeMargin];

    // badge shadow radius slider
    [_badgeShadowRadiusSlider setMinValue:kMTBadgeShadowRadiusMin];
    [_badgeShadowRadiusSlider setMaxValue:kMTBadgeShadowRadiusMax];
    
    // badge shadow offset slider
    [_badgeShadowOffsetSlider setMinValue:kMTBadgeShadowOffsetMin];
    [_badgeShadowOffsetSlider setMaxValue:kMTBadgeShadowOffsetMax];
    
    // badge shadow angle slider
    [_badgeShadowAngleSlider setMinValue:kMTBadgeShadowAngleMin];
    [_badgeShadowAngleSlider setMaxValue:kMTBadgeShadowAngleMax];

    [_uninstallIconView setDelegate:self];
    [_uninstallIconView setAccessibilityChildren:nil];
    [_uninstallIconView setAutoInsetEnabled:[_userDefaults boolForKey:kMTDefaultsAutoImageSizeKey]];
    [_uninstallIconView setApplyIconShape:[_userDefaults boolForKey:kMTDefaultsRenderImagesInIconShapeKey]];
    [_uninstallIconView setUsesOldIconShape:[_userDefaults boolForKey:kMTDefaultsUseOldIconShapeKey]];

#pragma mark - Bindings

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
    
    [_scalingSlider bind:NSValueBinding
                toObject:_uninstallIconView
             withKeyPath:@"imageInset"
                 options:nil
    ];
    
    [_badgeIconSizeSlider bind:NSValueBinding
                      toObject:_uninstallIconView
                   withKeyPath:@"badgeSize"
                       options:nil
    ];
    
    [_badgeIconMarginSlider bind:NSValueBinding
                        toObject:_uninstallIconView
                     withKeyPath:@"badgeMargin"
                       options:nil
    ];
    
    [_badgeShadowOffsetSlider bind:NSValueBinding
                          toObject:_uninstallIconView
                       withKeyPath:@"deleteBadge.shadowOffset"
                           options:nil
    ];
    
    [_badgeShadowRadiusSlider bind:NSValueBinding
                          toObject:_uninstallIconView
                       withKeyPath:@"deleteBadge.shadowRadius"
                           options:nil
    ];
    
    [_badgeShadowAngleSlider bind:NSValueBinding
                         toObject:_uninstallIconView
                      withKeyPath:@"deleteBadge.shadowAngle"
                          options:nil
    ];
    
    [_badgeIconShadowCheckbox bind:NSValueBinding
                          toObject:_defaultsController
                       withKeyPath:[@"values." stringByAppendingString:kMTDefaultsBadgeIconAddShadowKey]
                           options:nil
    ];
        
    [_badgeShadowColorWell bind:NSValueBinding
                       toObject:_defaultsController
                    withKeyPath:[@"values." stringByAppendingString:kMTDefaultsBadgeIconShadowColorKey]
                        options:[NSDictionary dictionaryWithObject: [[MTColorValueTransformer alloc] init] forKey:NSValueTransformerBindingOption]
    ];
    
    // set the initial slider tooltips
    [self updateSpeedSliderToolTip:nil];
    [self updateScalingSliderToolTip:nil];
    [self updateBadgeIconSizeSliderToolTip:nil];
    [self updateBadgeIconMarginSliderToolTip:nil];
    [self updateBadgeShadowAngleSliderToolTip:nil];
    [self updateBadgeShadowOffsetSliderToolTip:nil];
    [self updateBadgeShadowRadiusSliderToolTip:nil];
    
    // set the delete badge icon
    [self setBadgeIcon];
    
    // enable the correct button for the badge position
    [self updateBadgePosition:nil];

#pragma mark - Notifications

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
    
    // get notified if the delete badge icon changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(badgeIconChanged:)
                                                 name:kMTNotificationNameDeleteBadgeIconChanged
                                               object:nil
    ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(copyIcon:)
                                                 name:kMTNotificationNameCopyIcon
                                               object:nil
    ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iconShapeSettingsChanged:)
                                                 name:kMTNotificationNameIconShapeSettings
                                               object:nil
    ];
}

- (void)setBadgeIcon
{
    NSImage *deleteBadgeImage = nil;
    NSData *sfSymbol = [_userDefaults objectForKey:kMTDefaultsDeleteBadgeSFSymbolKey];
    
    if (sfSymbol) {
        
        deleteBadgeImage = [[NSImage alloc] initWithData:sfSymbol];
        
    } else {
        
        NSData *bookmarkData = [_userDefaults objectForKey:kMTDefaultsDeleteBadgeIconBookmarkKey];
        BOOL stale = NO;
        
        NSURL *deleteBadgeURL = [NSURL URLByResolvingBookmarkData:bookmarkData
                                                          options:0
                                                    relativeToURL:nil
                                              bookmarkDataIsStale:&stale
                                                            error:nil
        ];
        
        if (stale) {
            
            NSData *newData = [deleteBadgeURL bookmarkDataWithOptions:0
                                       includingResourceValuesForKeys:nil
                                                        relativeToURL:nil
                                                                error:nil
            ];
            
            if (newData) { [self->_userDefaults setObject:newData forKey:kMTDefaultsDeleteBadgeIconBookmarkKey]; }
        }
        
        if (deleteBadgeURL && [deleteBadgeURL startAccessingSecurityScopedResource]) {
            
            deleteBadgeImage = [[NSImage alloc] initWithContentsOfURL:deleteBadgeURL];
            [deleteBadgeURL stopAccessingSecurityScopedResource];
        }
    }
    
    MTDeleteBadgeView *deleteBadge = [[MTDeleteBadgeView alloc] initWithFrame:[_uninstallIconView bounds]];
    
    if ([deleteBadgeImage isValid]) {

        CGFloat badgeSize = [_userDefaults floatForKey:kMTDefaultsBadgeIconSizeKey];
        CGFloat clampedBadgeSize = fminf(fmaxf(badgeSize, kMTBadgeIconSizeMin), kMTBadgeIconSizeMax);
        if (fabs(badgeSize - clampedBadgeSize) > FLT_EPSILON) { [_userDefaults setFloat:clampedBadgeSize forKey:kMTDefaultsBadgeIconSizeKey]; }
        [_uninstallIconView setBadgeSize:clampedBadgeSize];
        
        CGFloat badgeMargin = [_userDefaults floatForKey:kMTDefaultsBadgeIconMarginKey];
        CGFloat clampedBadgeMargin = fminf(fmaxf(badgeMargin, kMTBadgeIconMarginMin), kMTBadgeIconMarginMax);
        if (fabs(badgeMargin - clampedBadgeMargin) > FLT_EPSILON) { [_userDefaults setFloat:clampedBadgeMargin forKey:kMTDefaultsBadgeIconMarginKey]; }
        [_uninstallIconView setBadgeMargin:clampedBadgeMargin];
       
        CGFloat badgeShadowRadius = [_userDefaults floatForKey:kMTDefaultsBadgeIconShadowRadiusKey];
        CGFloat clampedRadius = fminf(fmaxf(badgeShadowRadius, kMTBadgeShadowRadiusMin), kMTBadgeShadowRadiusMax);
        if (fabs(badgeShadowRadius - clampedRadius) > FLT_EPSILON) { [_userDefaults setFloat:clampedRadius forKey:kMTDefaultsBadgeIconShadowRadiusKey]; }
        
        CGFloat badgeShadowOffset = [_userDefaults floatForKey:kMTDefaultsBadgeIconShadowOffsetKey];
        CGFloat clampedOffset = fminf(fmaxf(badgeShadowOffset, kMTBadgeShadowOffsetMin), kMTBadgeShadowOffsetMax);
        if (fabs(badgeShadowOffset - clampedOffset) > FLT_EPSILON) { [_userDefaults setFloat:clampedOffset forKey:kMTDefaultsBadgeIconShadowOffsetKey]; }
        
        CGFloat badgeShadowAngle = [_userDefaults floatForKey:kMTDefaultsBadgeIconShadowAngleKey];
        CGFloat clampedAngle = fminf(fmaxf(badgeShadowAngle, kMTBadgeShadowAngleMin), kMTBadgeShadowAngleMax);
        if (fabs(badgeShadowAngle - clampedAngle) > FLT_EPSILON) { [_userDefaults setFloat:clampedAngle forKey:kMTDefaultsBadgeIconShadowAngleKey]; }
        
        [deleteBadge setImage:deleteBadgeImage];
        [deleteBadge setShowsShadow:[_userDefaults boolForKey:kMTDefaultsBadgeIconAddShadowKey]];
        [deleteBadge setShadowRadius:clampedRadius];
        [deleteBadge setShadowOffset:clampedOffset];
        [deleteBadge setShadowAngle:clampedAngle];
        [deleteBadge setShadowColor:[_badgeShadowColorWell color]];
    }
        
    [_uninstallIconView setDeleteBadge:deleteBadge];
}

- (void)enablePositionButtonAtIndex:(NSInteger)index
{
    NSInteger numberOfButtons = [_positionButtonGridView numberOfColumns];
    
    for (int i = 0; i < numberOfButtons; i++) {
        
        NSGridCell *cell = [_positionButtonGridView cellAtColumnIndex:i rowIndex:0];
        id contentView = [cell contentView];
        
        if ([[contentView class] isEqualTo:[NSButton class]]) {
            
            NSButton *positionButton = (NSButton*)contentView;
            
            if ([positionButton tag] == index) {
                [positionButton setContentTintColor:[NSColor controlAccentColor]];
            } else {
                [positionButton setContentTintColor:nil];
            }
        }
    }
}

#pragma mark - IBActions

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

- (IBAction)updateBadgePosition:(id)sender
{
    NSInteger position = 0;
    
    if (sender && [_uninstallIconView hasCustomDeleteBadge]) {
        
        position = [sender tag];
        [_userDefaults setInteger:position forKey:kMTDefaultsBadgePositionDefaultKey];
        
    } else if ([_uninstallIconView hasCustomDeleteBadge]) {
        
        position = [_userDefaults integerForKey:kMTDefaultsBadgePositionDefaultKey];
    }
    
    [self enablePositionButtonAtIndex:position];
    [_uninstallIconView setBadgePosition:(MTBadgePosition)position];
}

- (IBAction)updateBadgeIconSizeSliderToolTip:(id)sender
{
    NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
    [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [percentFormatter setMaximumFractionDigits:1];
    [percentFormatter setMultiplier:@100];
    [_badgeIconSizeSlider setToolTip:[NSString localizedStringWithFormat:NSLocalizedString(@"badgeIconSizeSliderTooltip", nil), [percentFormatter stringFromNumber:[NSNumber numberWithDouble:[_badgeIconSizeSlider doubleValue]]]]];
    
    if (sender) { [_userDefaults setFloat:[_uninstallIconView badgeSize] forKey:kMTDefaultsBadgeIconSizeKey]; }
}

- (IBAction)updateBadgeIconMarginSliderToolTip:(id)sender
{
    NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
    [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [percentFormatter setMaximumFractionDigits:1];
    [percentFormatter setMultiplier:@100];
    [_badgeIconMarginSlider setToolTip:[NSString localizedStringWithFormat:NSLocalizedString(@"badgeIconMarginSliderTooltip", nil), [percentFormatter stringFromNumber:[NSNumber numberWithDouble:[_badgeIconMarginSlider doubleValue]]]]];
    
    if (sender) { [_userDefaults setFloat:[_uninstallIconView badgeMargin] forKey:kMTDefaultsBadgeIconMarginKey]; }
}

- (IBAction)updateBadgeShadowAngleSliderToolTip:(id)sender
{
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:[_badgeShadowAngleSlider doubleValue]
                                                                       unit:[NSUnitAngle degrees]
    ];
    NSMeasurementFormatter *angleFormatter = [[NSMeasurementFormatter alloc] init];
    [[angleFormatter numberFormatter] setMinimumFractionDigits:0];
    [[angleFormatter numberFormatter] setMaximumFractionDigits:0];
    [angleFormatter setUnitStyle:NSFormattingUnitStyleShort];
    
    NSString *angleString = [angleFormatter stringFromMeasurement:measurement];
    [_badgeShadowAngleSlider setToolTip:[NSString localizedStringWithFormat:NSLocalizedString(@"badgeShadowAngleSliderTooltip", nil), angleString]];
    [_angleTextField setStringValue:angleString];
    
    if (sender) { [_userDefaults setFloat:[[_uninstallIconView deleteBadge] shadowAngle] forKey:kMTDefaultsBadgeIconShadowAngleKey]; }
}

- (IBAction)updateBadgeShadowOffsetSliderToolTip:(id)sender
{
    NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
    [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [percentFormatter setMaximumFractionDigits:1];
    [percentFormatter setMultiplier:@100];
    [_badgeShadowOffsetSlider setToolTip:[NSString localizedStringWithFormat:NSLocalizedString(@"badgeShadowOffsetSliderTooltip", nil), [percentFormatter stringFromNumber:[NSNumber numberWithDouble:[_badgeShadowOffsetSlider doubleValue]]]]];
        
    if (sender) { [_userDefaults setFloat:[[_uninstallIconView deleteBadge] shadowOffset] forKey:kMTDefaultsBadgeIconShadowOffsetKey]; }
}

- (IBAction)updateBadgeShadowRadiusSliderToolTip:(id)sender
{
    NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
    [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [percentFormatter setMaximumFractionDigits:1];
    [percentFormatter setMultiplier:@100];
    [_badgeShadowRadiusSlider setToolTip:[NSString localizedStringWithFormat:NSLocalizedString(@"badgeShadowRadiusSliderTooltip", nil), [percentFormatter stringFromNumber:[NSNumber numberWithDouble:[_badgeShadowRadiusSlider doubleValue]]]]];
        
    if (sender) { [_userDefaults setFloat:[[_uninstallIconView deleteBadge] shadowRadius] forKey:kMTDefaultsBadgeIconShadowRadiusKey]; }
}

- (IBAction)updateDeleteBadge:(id)sender
{
    [self setBadgeIcon];
}

#pragma mark - MTDropViewDelegate

- (void)view:(MTDropView*)view didChangeImage:(NSImage *)image applicationBundle:(BOOL)application
{
    [self updateScalingSliderToolTip:nil];

    [_autoAdjustCheckbox setAllowsMixedState:NO];
    if ([_userDefaults boolForKey:kMTDefaultsAutoImageSizeKey]) { [_autoAdjustCheckbox setState:NSControlStateValueOn]; }
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameImageChanged
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                image, kMTNotificationKeyImage,
                                                                [NSNumber numberWithBool:application], kMTNotificationKeyIsAppBundle,
                                                                nil
                                                               ]
    ];
}

- (void)view:(MTDropView *)view hasBeenClickedAtLocation:(NSPoint)location
{
    if (@available(macOS 15.1, *)) {
        
        if (![_uninstallIconView image]) {
            
            // post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameShowImagePlayground
                                                                object:self
                                                              userInfo:nil
            ];
        }
        
    } else {
        
        return;
    }
}

#pragma mark - NSNotification handlers

- (void)imageChanged:(NSNotification*)aNotification
{
    if (![[aNotification object] isEqualTo:self]) {

        NSDictionary *userInfo = [aNotification userInfo];

        NSImage *image = [userInfo objectForKey:kMTNotificationKeyImage];
        
        if ([image isValid]) {
                
            BOOL isApplication = [[userInfo valueForKey:kMTNotificationKeyIsAppBundle] boolValue];
            [_uninstallIconView setIsAppBundle:isApplication];
            [_uninstallIconView setUsesOldIconShape:[_userDefaults boolForKey:kMTDefaultsUseOldIconShapeKey]];
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
            
            [NSImage imageWithView:[_uninstallIconView icon]
                              size:NSMakeSize(outputSize, outputSize)
                 completionHandler:^(NSImage *image) {
                
                MTIconSet *iconSet = [[MTIconSet alloc] init];
                [iconSet setUninstallIcon:image];
                [iconSet setAnimationDuration:([self->_userDefaults boolForKey:kMTDefaultsSaveAnimatedUninstallIconKey]) ? animationDuration : 0];
                [iconSet setFileNamePrefix:[userInfo objectForKey:kMTNotificationKeyFileNamePrefix]];
                [iconSet writeToFolder:path
                          createFolder:NO
                          animatedOnly:![self->_userDefaults boolForKey:kMTDefaultsSaveUninstallIconKey]
                     completionHandler:nil
                ];
            }];
        }
    }
}

- (void)badgeIconChanged:(NSNotification*)aNotification
{
    [self setBadgeIcon];
    [self updateBadgePosition:nil];
}

- (void)copyIcon:(NSNotification*)aNotification
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:kMTDefaultsMainWindowSelectedTabKey] == 1) {
        
        [NSImage imageWithView:[_uninstallIconView icon]
                          size:NSMakeSize(kMTOutputSizeMax, kMTOutputSizeMax)
             completionHandler:^(NSImage *image) {
            
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard clearContents];
            [pasteboard writeObjects:[NSArray arrayWithObject:image]];
        }];
    }
}

- (void)iconShapeSettingsChanged:(NSNotification*)aNotification
{
    [_uninstallIconView setApplyIconShape:[_userDefaults boolForKey:kMTDefaultsRenderImagesInIconShapeKey]];
    [_uninstallIconView setUsesOldIconShape:[_userDefaults boolForKey:kMTDefaultsUseOldIconShapeKey]];
    if ([[_uninstallIconView unmodifiedImage] isValid]) { [_uninstallIconView setImage:[_uninstallIconView unmodifiedImage]]; }
}

- (void)dealloc
{
    // remove our observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameImageChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameSaveIcon object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameDeleteBadgeIconChanged object:nil];
}

@end
