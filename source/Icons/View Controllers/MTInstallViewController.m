/*
    MTInstallViewController.m
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

#import "MTInstallViewController.h"
#import "MTAttributedString.h"
#import "MTGroupDefaults.h"

@interface MTInstallViewController ()
@property (weak) IBOutlet MTInstallIconView *installIconView;
@property (weak) IBOutlet NSTextField *bannerTextField;
@property (weak) IBOutlet NSColorWell *bannerColorWell;
@property (weak) IBOutlet NSColorWell *bannerTextColorWell;
@property (weak) IBOutlet NSGridView *positionButtonGridView;
@property (weak) IBOutlet NSTableView *savedBannersTable;
@property (weak) IBOutlet NSArrayController *savedBannersController;
@property (weak) IBOutlet NSSlider *overlaySlider;
@property (weak) IBOutlet NSSlider *textMarginSlider;
@property (weak) IBOutlet NSSlider *bannerAngleSlider;
@property (weak) IBOutlet NSSlider *bannerHeightSlider;
@property (weak) IBOutlet NSSlider *bannerMarginSlider;
@property (weak) IBOutlet NSPopUpButton *fontButton;
@property (weak) IBOutlet NSPopUpButton *fontFaceButton;

@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readwrite) NSUserDefaultsController *defaultsController;
@property (nonatomic, strong, readwrite) NSString *bannerText;
@end

@implementation MTInstallViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // initialize some stuff
    _userDefaults = [MTGroupDefaults sharedDefaults];
    _defaultsController = [MTGroupDefaults sharedDefaultsController];
        
    // create the font menu…
    [self updateFontMenu];
    NSString *fontFamily = [_fontButton titleOfSelectedItem];
    if (fontFamily) { [self updateFontFacesForFamily:fontFamily]; }
    
    // …and select the last font used
    if ([_userDefaults objectForKey:kMTDefaultsSelectedFontKey]) {
        
        NSString *selectedFontName = [_userDefaults stringForKey:kMTDefaultsSelectedFontKey];
        NSString *fontFamily = nil;
        
        if (selectedFontName) {
            
            NSFont *selectedFont = [NSFont fontWithName:selectedFontName size:0];
            
            if (selectedFont) {
                
                NSFontDescriptor *fontDescriptor = [selectedFont fontDescriptor];
                fontFamily = [fontDescriptor objectForKey:NSFontFamilyAttribute];
            }
        }
        
        [self selectFontButtonsWithFamilyName:fontFamily fontFace:selectedFontName];
    }
    
#pragma mark - Slider setup
    
    [_textMarginSlider setMinValue:kMTBannerTextMarginMin];
    [_textMarginSlider setMaxValue:kMTBannerTextMarginMax];
    CGFloat textMargin = [_userDefaults floatForKey:kMTDefaultsTextMarginDefaultKey];
    CGFloat clampedTextMargin = fminf(fmaxf(textMargin, kMTBannerTextMarginMin), kMTBannerTextMarginMax);
    if (fabs(textMargin - clampedTextMargin) > FLT_EPSILON) { [_userDefaults setFloat:clampedTextMargin forKey:kMTDefaultsTextMarginDefaultKey]; }
    [_installIconView setBannerTextMargin:clampedTextMargin];
    
    [_bannerAngleSlider setMinValue:kMTBannerAngleMin];
    [_bannerAngleSlider setMaxValue:kMTBannerAngleMax];
    CGFloat bannerAngle = [_userDefaults floatForKey:kMTDefaultsBannerAngleDefaultKey];
    CGFloat clampedBannerAngle = fminf(fmaxf(bannerAngle, kMTBannerAngleMin), kMTBannerAngleMax);
    if (fabs(bannerAngle - clampedBannerAngle) > FLT_EPSILON) { [_userDefaults setFloat:clampedBannerAngle forKey:kMTDefaultsBannerAngleDefaultKey]; }
    [_installIconView setBannerAngle:clampedBannerAngle];
    
    [_bannerHeightSlider setMinValue:kMTBannerHeightMin];
    [_bannerHeightSlider setMaxValue:kMTBannerHeightMax];
    CGFloat bannerHeight = [_userDefaults floatForKey:kMTDefaultsBannerHeightDefaultKey];
    CGFloat clampedBannerHeight = fminf(fmaxf(bannerHeight, kMTBannerHeightMin), kMTBannerHeightMax);
    if (fabs(bannerHeight - clampedBannerHeight) > FLT_EPSILON) { [_userDefaults setFloat:clampedBannerHeight forKey:kMTDefaultsBannerHeightDefaultKey]; }
    [_installIconView setBannerHeight:clampedBannerHeight];
    
    [_bannerMarginSlider setMinValue:kMTBannerMarginMin];
    [_bannerMarginSlider setMaxValue:kMTBannerMarginMax];
    CGFloat bannerMargin = [_userDefaults floatForKey:kMTDefaultsBannerMarginDefaultKey];
    CGFloat clampedBannerMargin = fminf(fmaxf(bannerMargin, kMTBannerMarginMin), kMTBannerMarginMax);
    if (fabs(bannerMargin - clampedBannerMargin) > FLT_EPSILON) { [_userDefaults setFloat:clampedBannerMargin forKey:kMTDefaultsBannerMarginDefaultKey]; }
    [_installIconView setBannerMargin:clampedBannerMargin];
    
    [_overlaySlider setMinValue:kMTOverlayImageScalingMin];
    [_overlaySlider setMaxValue:kMTOverlayImageScalingMax];
    BOOL rememberOverlayPosition = ([_userDefaults boolForKey:kMTDefaultsRememberOverlayPositionKey]);
    CGFloat overlayScaling = (rememberOverlayPosition) ? [_userDefaults floatForKey:kMTDefaultsOverlayScalingKey] : kMTOverlayImageScalingDefault;
    CGFloat clampedScaling = fminf(fmaxf(overlayScaling, kMTOverlayImageScalingMin), kMTOverlayImageScalingMax);
    if (fabs(overlayScaling - clampedScaling) > FLT_EPSILON) { [_userDefaults setFloat:kMTOverlayImageScalingDefault forKey:kMTDefaultsOverlayScalingKey]; }
    [_installIconView setOverlayImageScalingFactor:clampedScaling];
    
    // restore the position of the overlay image
    if (rememberOverlayPosition) {
        
        NSString *storedPositionString = [_userDefaults stringForKey:kMTDefaultsOverlayPositionKey];
        
        if (storedPositionString) {
            
            NSPoint storedPosition = NSPointFromString(storedPositionString);
            if (storedPosition.x > 0 && storedPosition.y > 0) { [_installIconView setOverlayPosition:storedPosition]; }
        }
    }

    [_installIconView setDelegate:self];
    [_installIconView setAccessibilityChildren:nil];
    [_installIconView setApplyIconShape:[_userDefaults boolForKey:kMTDefaultsRenderImagesInIconShapeKey]];
    [_installIconView setUsesOldIconShape:[_userDefaults boolForKey:kMTDefaultsUseOldIconShapeKey]];
    [_installIconView setDrawBannerInIconShape:[_userDefaults boolForKey:kMTDefaultsDrawBannerInIconShapeKey]];
    
    // enable the correct button for the banner position
    [self enablePositionButtonAtIndex:[_userDefaults integerForKey:kMTDefaultsPositionDefaultKey]];
    
#pragma mark - Bindings
    
    NSDictionary *colorBindingOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [[MTColorValueTransformer alloc] init], NSValueTransformerBindingOption,
                                         nil
    ];
    [_bannerColorWell bind:NSValueBinding
                  toObject:_defaultsController
               withKeyPath:[@"values." stringByAppendingString:kMTDefaultsBannerColorKey]
                   options:colorBindingOptions
    ];
    
    [_bannerTextColorWell bind:NSValueBinding
                      toObject:_defaultsController
                   withKeyPath:[@"values." stringByAppendingString:kMTDefaultsBannerTextColorKey]
                       options:colorBindingOptions
    ];
    
    [_overlaySlider bind:NSValueBinding
                toObject:_installIconView
             withKeyPath:@"overlayImageScalingFactor"
                 options:nil
    ];
    
    [_textMarginSlider bind:NSValueBinding
                   toObject:_installIconView
                withKeyPath:@"bannerTextMargin"
                    options:nil
    ];
    
    [_bannerAngleSlider bind:NSValueBinding
                    toObject:_installIconView
                 withKeyPath:@"bannerAngle"
                     options:nil
    ];
    
    [_bannerHeightSlider bind:NSValueBinding
                    toObject:_installIconView
                 withKeyPath:@"bannerHeight"
                     options:nil
    ];
    
    [_bannerMarginSlider bind:NSValueBinding
                    toObject:_installIconView
                 withKeyPath:@"bannerMargin"
                     options:nil
    ];
    
    [_savedBannersController bind:NSContentArrayBinding
                         toObject:_defaultsController
                      withKeyPath:[@"values." stringByAppendingString:kMTDefaultsSavedBannersKey]
                          options:nil
    ];
    
    // initially sort the table
    NSSortDescriptor *initialSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"bannerName"
                                                                            ascending:YES
                                                                             selector:@selector(localizedCaseInsensitiveCompare:)
    ];
    [self.savedBannersController setSortDescriptors:[NSArray arrayWithObject:initialSortDescriptor]];

#pragma mark - Notifications

    // get notified if the image changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageChanged:)
                                                 name:kMTNotificationNameImageChanged
                                               object:nil
    ];
    
    // get notified if the overlay image changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(overlayImageChanged:)
                                                 name:kMTNotificationNameOverlayImageChanged
                                               object:nil
    ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(overlayPositionChanged:)
                                                 name:kMTNotificationNameOverlayImagePositionChanged
                                               object:nil
    ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(overlayScalingChanged:)
                                                 name:kMTNotificationNameOverlayImageScalingChanged
                                               object:nil
    ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rememberOverlayPosition:)
                                                 name:kMTNotificationNameRememberOverlayPosition
                                               object:nil
    ];
    
    // get notified if the banner's text was truncated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bannerTextTruncated:)
                                                 name:kMTNotificationNameBannerTruncated
                                               object:nil
    ];
    
    // get notified if the icon should be saved
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveIcon:)
                                                 name:kMTNotificationNameSaveIcon
                                               object:nil
    ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fontSetChanged:)
                                                 name:NSFontSetChangedNotification
                                               object: nil
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
    
    // update the slider's tooltips
    [self updateTextMarginSliderToolTip:nil];
    [self updateOverlaySliderToolTip:nil];
    [self updateBannerAngleSliderToolTip:nil];
    [self updateBannerHeightSliderToolTip:nil];
    [self updateBannerMarginSliderToolTip:nil];
}

- (BOOL)applyBannerWithDictionary:(NSDictionary*)bannerDict
{
    BOOL success = NO;
        
    if (bannerDict) {
        
        NSData *bannerData = [bannerDict objectForKey:kMTDefaultsBannerDataKey];
        
        if (bannerData) {
            
            NSAttributedString *bannerText = [[NSAttributedString alloc] initWithRTF:bannerData
                                                                  documentAttributes:nil
            ];

            [self.bannerTextField setStringValue:[bannerText string]];
            [self enablePositionButtonAtIndex:[[bannerDict valueForKey:kMTDefaultsBannerPositionKey] integerValue]];
            [_bannerTextColorWell setColor:[bannerText textColor]];
            [_bannerColorWell setColor:[bannerText backgroundColor]];
            [_installIconView setBannerAttributes:bannerText];

            // select the font and type face
            NSFontDescriptor *fontDescriptor = [[bannerText font] fontDescriptor];
            NSString *fontFamily = [fontDescriptor objectForKey:NSFontFamilyAttribute];
            NSString *fontFace = [fontDescriptor objectForKey:NSFontNameAttribute];
            [self selectFontButtonsWithFamilyName:fontFamily fontFace:fontFace];
            
            NSUInteger bannerPosition = [[bannerDict valueForKey:kMTDefaultsBannerPositionKey] integerValue];
            [_installIconView setBannerPosition:(MTBannerPosition)bannerPosition];
            
            // If the banner was saved with an older version of the application that does
            // not support one or more of the following attributes, we will use the default
            // values to make sure the banner looks the same as in the old version.
            CGFloat textMargin = kMTBannerTextMarginDefault;
            CGFloat bannerAngle = kMTBannerAngleDefault;
            CGFloat bannerHeight = kMTBannerHeightDefault;
            CGFloat bannerMargin = kMTBannerMarginDefault;
            
            if ([bannerDict objectForKey:kMTDefaultsBannerTextMarginKey]) { textMargin = [[bannerDict valueForKey:kMTDefaultsBannerTextMarginKey] floatValue]; }
            if ([bannerDict objectForKey:kMTDefaultsBannerAngleKey]) { bannerAngle = [[bannerDict valueForKey:kMTDefaultsBannerAngleKey] floatValue]; }
            if ([bannerDict objectForKey:kMTDefaultsBannerHeightKey]) { bannerHeight = [[bannerDict valueForKey:kMTDefaultsBannerHeightKey] floatValue]; }
            if ([bannerDict objectForKey:kMTDefaultsBannerMarginKey]) { bannerMargin = [[bannerDict valueForKey:kMTDefaultsBannerMarginKey] floatValue]; }
                
            [_installIconView setBannerTextMargin:textMargin];
            [_installIconView setBannerAngle:bannerAngle];
            [_installIconView setBannerHeight:bannerHeight];
            [_installIconView setBannerMargin:bannerMargin];
            
            self.bannerText = [bannerText string];
        }
        
    } else {
        
        [_installIconView setBannerAttributes:nil];
    }
    
    return success;
}

- (NSAttributedString*)currentBannerText
{
    NSString *fontName = [[_fontFaceButton selectedItem] representedObject];
    NSFont *bannerFont = [NSFont fontWithName:fontName size:0];
    if (!bannerFont) { bannerFont = [NSFont systemFontOfSize:0]; }
          
    NSAttributedString *bannerText = [[NSAttributedString alloc] initWithString:[_bannerTextField stringValue]
                                                                           font:bannerFont
                                                                foregroundColor:[_bannerTextColorWell color]
                                                                backgroundColor:[_bannerColorWell color]
    ];

    return bannerText;
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

- (void)updateBanner
{
    [_installIconView setBannerAttributes:[self currentBannerText]];
    [_installIconView setBannerPosition:(MTBannerPosition)[_userDefaults integerForKey:kMTDefaultsPositionDefaultKey]];
}

- (void)updateFontMenu
{
    [[_fontButton menu] removeAllItems];
    
    // create the font menu
    NSFontCollection *userFonts = [NSFontCollection fontCollectionWithName:NSFontCollectionUser];
    NSMutableSet *fontFamilies = [[NSMutableSet alloc] init];

    for (NSFontDescriptor *fontDescriptor in [userFonts matchingDescriptors]) {
        
        NSString *fontFamily = [fontDescriptor objectForKey:NSFontFamilyAttribute];
        [fontFamilies addObject:fontFamily];
    }
    
    for (NSString *familyName in [[fontFamilies allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
                
        NSMenuItem *menuItem = [[NSMenuItem alloc] init];
        [menuItem setAttributedTitle:[self attributedFontMenuTitle:familyName fontName:familyName]];
        [[_fontButton menu] addItem:menuItem];
    }
}

- (NSAttributedString*)attributedFontMenuTitle:(NSString*)fontTitle fontName:(NSString*)fontName
{
    CGFloat viewHeight = 20;
    CGFloat fontSize = [NSFont systemFontSize] + 2;
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSFont fontWithName:fontName size:fontSize] forKey:NSFontAttributeName];
    
    NSMutableAttributedString *attributedName = [[NSMutableAttributedString alloc] initWithString:fontTitle
                                                                                       attributes:attributes
    ];

    CGFloat adjustedFontSize = [attributedName fontSizeToFitInRect:NSMakeRect(0, 0, CGFLOAT_MAX, viewHeight)
                                                   minimumFontSize:3
                                                   maximumFontSize:fontSize
                                                    useImageBounds:NO
    ];
    [attributedName addAttribute:NSFontAttributeName
                           value:[[NSFontManager sharedFontManager] convertFont:[attributedName font] toSize:adjustedFontSize]
                           range:NSMakeRange(0, [attributedName length])
    ];
    
    return attributedName;
}

- (void)updateFontFacesForFamily:(NSString*)familyName
{
    [self.fontFaceButton removeAllItems];
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSArray *fontNames = [fontManager availableMembersOfFontFamily:familyName];
    
    for (NSArray *fontInfo in fontNames) {

        NSString *fontName = [fontInfo firstObject];
        NSString *fontFace = [fontInfo objectAtIndex:1];

        // if fontFace is empty, use "Regular" as the standard
        if ([fontFace length] == 0) { fontFace = @"Regular"; }

        NSMenuItem *menuItem = [[NSMenuItem alloc] init];
        [menuItem setAttributedTitle:[self attributedFontMenuTitle:[fontManager localizedNameForFamily:familyName face:fontFace]
                                                          fontName:fontName
                                     ]
        ];
        [menuItem setRepresentedObject:fontName];
        [[self.fontFaceButton menu] addItem:menuItem];
    }
    
    // select the first item if available
    if ([self.fontFaceButton numberOfItems] > 0) { [self.fontFaceButton selectItemAtIndex:0]; }
}

- (void)selectFontButtonsWithFamilyName:(NSString*)fontFamily fontFace:(NSString*)fontFace
{
    if (!fontFamily || [self.fontButton indexOfItemWithTitle:fontFamily] == -1) { fontFamily = [self.fontButton itemTitleAtIndex:0]; }
        
    [self.fontButton selectItemWithTitle:fontFamily];
    [self updateFontFacesForFamily:fontFamily];
        
    NSUInteger itemIndex = [self.fontFaceButton indexOfItemWithRepresentedObject:fontFace];

    if (itemIndex != -1) {
        
        [self.fontFaceButton selectItemAtIndex:itemIndex];
        
    } else {
        
        [self.fontFaceButton selectItemAtIndex:0];
    }
}

- (void)unselectSavedBanner
{
    [self.savedBannersController setSelectionIndexes:[NSIndexSet indexSet]];
}

#pragma mark - NSTableViewDelegate

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    NSDictionary *bannerDict = [[_savedBannersController arrangedObjects] objectAtIndex:row];

    if (bannerDict) {
        
        NSAttributedString *bannerText = [[NSAttributedString alloc] initWithRTF:[bannerDict valueForKey:kMTDefaultsBannerDataKey] documentAttributes:nil];
        
        if (bannerText) {
            [rowView setBackgroundColor:[bannerText backgroundColor]];
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = [notification object];
    NSInteger selectedRow = [tableView selectedRow];
    
    if (selectedRow >= 0) {
        
        NSDictionary *bannerDict = [[[tableView rowViewAtRow:selectedRow makeIfNecessary:NO] viewAtColumn:0] objectValue];
        [self applyBannerWithDictionary:bannerDict];
    }
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    NSColor *highlightColor = nil;
    NSDictionary *bannerDict = [[_savedBannersController arrangedObjects] objectAtIndex:row];

    if (bannerDict) {
        
        NSAttributedString *bannerText = [[NSAttributedString alloc] initWithRTF:[bannerDict valueForKey:kMTDefaultsBannerDataKey] documentAttributes:nil];
        if (bannerText) { highlightColor = [[bannerText backgroundColor] complementaryColor]; }
    }
    
    MTTableRowView *rowView = [[MTTableRowView alloc] init];
    if (highlightColor) { [rowView setHighlightColor:highlightColor]; }
    
    return rowView;
}

// we don't want automatic highlighting but do all the
// highlighting stuff in "selectRow:"
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return NO;
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTextField *textField = [notification object];

    if (textField == _bannerTextField) {

        // clear the array controllers current selection and update the banner
        [self unselectSavedBanner];
        [self updateBanner];
    }
}

#pragma mark - IBActions

- (IBAction)selectRow:(id)sender
{
    NSInteger selectedRow = [_savedBannersTable selectedRow];
    NSInteger clickedRow = [_savedBannersTable clickedRow];
    
    if (clickedRow >= 0) {
        
        if (clickedRow == selectedRow) {
            
            [_savedBannersTable deselectRow:selectedRow];
            
        } else {
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:clickedRow];
            [_savedBannersTable selectRowIndexes:indexSet byExtendingSelection:NO];
        }
    }
}

- (IBAction)saveBanner:(id)sender
{
    NSAttributedString *bannerText = [self currentBannerText];
    
    if (bannerText) {
        
        NSData *bannerData = [bannerText RTFFromRange:NSMakeRange(0, [bannerText length])
                                   documentAttributes:[NSDictionary dictionaryWithObject:NSRTFTextDocumentType forKey:NSDocumentTypeDocumentAttribute]
        ];
        
        if (bannerData) {
                        
            NSDictionary *bannerDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [bannerText string], kMTDefaultsBannerNameKey,
                                        bannerData, kMTDefaultsBannerDataKey,
                                        [NSNumber numberWithInteger:[_userDefaults integerForKey:kMTDefaultsPositionDefaultKey]], kMTDefaultsBannerPositionKey,
                                        [NSNumber numberWithFloat:[_userDefaults floatForKey:kMTDefaultsTextMarginDefaultKey]], kMTDefaultsBannerTextMarginKey,
                                        [NSNumber numberWithFloat:[_userDefaults floatForKey:kMTDefaultsBannerAngleDefaultKey]], kMTDefaultsBannerAngleKey,
                                        [NSNumber numberWithFloat:[_userDefaults floatForKey:kMTDefaultsBannerHeightDefaultKey]], kMTDefaultsBannerHeightKey,
                                        [NSNumber numberWithFloat:[_userDefaults floatForKey:kMTDefaultsBannerMarginDefaultKey]], kMTDefaultsBannerMarginKey,
                                        nil
            ];
            
            if ([[_savedBannersController content] containsObject:bannerDict]) {
                
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"bannerExistsDialogTitle", nil)];
                [alert setInformativeText:NSLocalizedString(@"bannerExistsDialogMessage", nil)];
                [alert addButtonWithTitle:NSLocalizedString(@"saveButton", nil)];
                [alert addButtonWithTitle:NSLocalizedString(@"cancelButton", nil)];
                [alert setAlertStyle:NSAlertStyleInformational];
                [alert beginSheetModalForWindow:[[self view] window] completionHandler:^(NSModalResponse returnCode) {
                    
                    if (returnCode == NSAlertFirstButtonReturn) {
                        
                        [self->_savedBannersController addObject:bannerDict];
                        [self->_savedBannersController rearrangeObjects];
                    }
                }];
                
            } else {
                
                [_savedBannersController addObject:bannerDict];
                [_savedBannersController rearrangeObjects];
            }
        }
    }
}

- (IBAction)setDefaultBanner:(id)sender
{
    NSInteger clickedRow = [_savedBannersTable clickedRow];
    
    if (clickedRow >= 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"IsDefault = %@", [NSNumber numberWithBool:YES]];
        NSMutableArray *arrangedObjects = [self mutableArrayValueForKeyPath:@"savedBannersController.arrangedObjects"];
        
        for (NSMutableDictionary *dict in [arrangedObjects filteredArrayUsingPredicate:predicate]) {
            [dict removeObjectForKey:kMTDefaultsBannerIsDefaultKey];
        }

        if ([sender state] == NSControlStateValueOff) {
            
            NSMutableDictionary *bannerDict = [arrangedObjects objectAtIndex:clickedRow];
            [bannerDict setValue:[NSNumber numberWithBool:YES] forKey:kMTDefaultsBannerIsDefaultKey];
        }

        [self.defaultsController setValue:[_savedBannersController content]
                               forKeyPath:[@"values." stringByAppendingString:kMTDefaultsSavedBannersKey]
        ];
    }
}

- (IBAction)removeSavedBanner:(id)sender
{    
    // we remove either all banners or just the one
    // the user selected
    if ([sender tag] == 3000) {
        
        NSRange range = NSMakeRange(0, [[_savedBannersController arrangedObjects] count]);
        [_savedBannersController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                
    } else {
        
        NSInteger clickedRow = [_savedBannersTable clickedRow];
       
        if (clickedRow >= 0 && clickedRow < [[_savedBannersController arrangedObjects] count]) {
            
            [_savedBannersController removeObjectAtArrangedObjectIndex:clickedRow];
        }
    }
    
    [_savedBannersController rearrangeObjects];
}

- (IBAction)updateBannerPosition:(id)sender
{
    NSInteger position = [sender tag];
    
    [_userDefaults setInteger:position forKey:kMTDefaultsPositionDefaultKey];
    [self enablePositionButtonAtIndex:position];
    [self unselectSavedBanner];
    [self updateBanner];
}

- (IBAction)changeBannerColor:(id)sender
{
    [self unselectSavedBanner];
    [self updateBanner];
}

- (IBAction)changeBannerFont:(id)sender
{
    NSString *selectedFamilyName = [_fontButton titleOfSelectedItem];
    if ([sender isEqualTo:_fontButton]) { [self updateFontFacesForFamily:selectedFamilyName]; }
    NSString *selectedFontFace = [[_fontFaceButton selectedItem] representedObject];

    [_userDefaults setObject:selectedFontFace forKey:kMTDefaultsSelectedFontKey];
    
    [self unselectSavedBanner];
    [self updateBanner];
}

- (IBAction)switchColors:(id)sender
{
    // switch the color well's colors
    NSColor *bannerColor = [_bannerColorWell color];
    NSColor *bannerTextColor = [_bannerTextColorWell color];
    [_bannerColorWell setColor:bannerTextColor];
    [_bannerTextColorWell setColor:bannerColor];
    
    // update the user defaults
    MTColorValueTransformer *valueTransformer = [[MTColorValueTransformer alloc] init];
    NSNumber *transformedBannerColor = [valueTransformer reverseTransformedValue:[_bannerColorWell color]];
    NSNumber *transformedBannerTextColor = [valueTransformer reverseTransformedValue:[_bannerTextColorWell color]];
    [_userDefaults setInteger:[transformedBannerColor integerValue] forKey:kMTDefaultsBannerColorKey];
    [_userDefaults setInteger:[transformedBannerTextColor integerValue] forKey:kMTDefaultsBannerTextColorKey];
    
    [self unselectSavedBanner];
    [self updateBanner];
}

- (IBAction)updateOverlaySliderToolTip:(id)sender
{
    NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
    [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [percentFormatter setMaximumFractionDigits:1];
    [percentFormatter setMultiplier:@100];
    [_overlaySlider setToolTip:[NSString localizedStringWithFormat:NSLocalizedString(@"overlaySliderTooltip", nil), [percentFormatter stringFromNumber:[NSNumber numberWithDouble:[_overlaySlider doubleValue]]]]];
}

- (IBAction)updateTextMarginSliderToolTip:(id)sender
{
    NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
    [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [percentFormatter setMaximumFractionDigits:1];
    [percentFormatter setMultiplier:@100];
    [_textMarginSlider setToolTip:[NSString localizedStringWithFormat:NSLocalizedString(@"textMarginSliderTooltip", nil), [percentFormatter stringFromNumber:[NSNumber numberWithDouble:[_textMarginSlider doubleValue]]]]];
    
    if (sender) {
        
        [_userDefaults setFloat:[_installIconView bannerTextMargin] forKey:kMTDefaultsTextMarginDefaultKey];
        [self unselectSavedBanner];
    }
}

- (IBAction)updateBannerAngleSliderToolTip:(id)sender
{
    CGFloat bannerAngle = [_installIconView bannerAngle];
    
    NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:bannerAngle
                                                                       unit:[NSUnitAngle degrees]
    ];
    NSMeasurementFormatter *angleFormatter = [[NSMeasurementFormatter alloc] init];
    [[angleFormatter numberFormatter] setMinimumFractionDigits:0];
    [[angleFormatter numberFormatter] setMaximumFractionDigits:0];
    [angleFormatter setUnitStyle:NSFormattingUnitStyleShort];
    
    NSString *angleString = [angleFormatter stringFromMeasurement:measurement];
    [_bannerAngleSlider setToolTip:[NSString localizedStringWithFormat:NSLocalizedString(@"bannerAngleSliderTooltip", nil), angleString]];
        
    if (sender) {
        
        [_userDefaults setFloat:bannerAngle forKey:kMTDefaultsBannerAngleDefaultKey];
        [self unselectSavedBanner];
    }
}

- (IBAction)updateBannerHeightSliderToolTip:(id)sender
{
    NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
    [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [percentFormatter setMaximumFractionDigits:1];
    [percentFormatter setMultiplier:@100];
    [_bannerHeightSlider setToolTip:[NSString localizedStringWithFormat:NSLocalizedString(@"bannerHeightSliderTooltip", nil), [percentFormatter stringFromNumber:[NSNumber numberWithDouble:[_bannerHeightSlider doubleValue]]]]];
    
    if (sender) {
        
        [_userDefaults setFloat:[_installIconView bannerHeight] forKey:kMTDefaultsBannerHeightDefaultKey];
        [self unselectSavedBanner];
    }
}

- (IBAction)updateBannerMarginSliderToolTip:(id)sender
{
    NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
    [percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    [percentFormatter setMaximumFractionDigits:1];
    [percentFormatter setMultiplier:@100];
    [_bannerMarginSlider setToolTip:[NSString localizedStringWithFormat:NSLocalizedString(@"bannerMarginSliderTooltip", nil), [percentFormatter stringFromNumber:[NSNumber numberWithDouble:[_bannerMarginSlider doubleValue]]]]];
    
    if (sender) {
        
        [_userDefaults setFloat:[_installIconView bannerMargin] forKey:kMTDefaultsBannerMarginDefaultKey];
        [self unselectSavedBanner];
    }
}

- (IBAction)clearTextField:(id)sender
{
    // clear the array controllers current selection and update the banner
    [self unselectSavedBanner];
    [self updateBanner];
}

#pragma mark - NSNotification handlers

- (void)imageChanged:(NSNotification*)aNotification
{
    if (![[aNotification object] isEqualTo:self]) {

        NSDictionary *userInfo = [aNotification userInfo];
        NSImage *image = [userInfo objectForKey:kMTNotificationKeyImage];
        
        if ([image isValid]) {
            
            BOOL isApplication = [[userInfo valueForKey:kMTNotificationKeyIsAppBundle] boolValue];
            [_installIconView setIsAppBundle:isApplication];
            [_installIconView setUsesOldIconShape:[_userDefaults boolForKey:kMTDefaultsUseOldIconShapeKey]];
            [_installIconView setDrawBannerInIconShape:(!isApplication && [_userDefaults boolForKey:kMTDefaultsDrawBannerInIconShapeKey])];
            [_installIconView setImage:image];
            
            [self updateBanner];
        }
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"IsDefault == %@", [NSNumber numberWithBool:YES]];
    NSArray *filteredBanners = [[_savedBannersController content] filteredArrayUsingPredicate:predicate];
    
    if ([filteredBanners count] > 0) {
        
        NSDictionary *bannerDict = [filteredBanners firstObject];
        [self applyBannerWithDictionary:bannerDict];
    }
}

- (void)overlayImageChanged:(NSNotification*)aNotification
{
    NSImage *image = [[aNotification userInfo] objectForKey:kMTNotificationKeyImage];
    
    if ([image isValid]) {
        
        [_installIconView setOverlayImage:image];
        
        // reset size and position
        if (![_userDefaults boolForKey:kMTDefaultsRememberOverlayPositionKey]) {
            
            [_installIconView setOverlayImageScalingFactor:kMTOverlayImageScalingDefault];
            [_installIconView setOverlayPosition:NSMakePoint(1, 1)];
        }
    }
    
    [self updateOverlaySliderToolTip:nil];
}

- (void)overlayPositionChanged:(NSNotification*)aNotification
{
    if ([_userDefaults boolForKey:kMTDefaultsRememberOverlayPositionKey]) {
        
        NSString *imagePosition = NSStringFromPoint([_installIconView overlayPosition]);
        [_userDefaults setObject:imagePosition forKey:kMTDefaultsOverlayPositionKey];
    }
}

- (void)overlayScalingChanged:(NSNotification*)aNotification
{
    if ([_userDefaults boolForKey:kMTDefaultsRememberOverlayPositionKey]) {
        
        [_userDefaults setFloat:[_installIconView overlayImageScalingFactor] forKey:kMTDefaultsOverlayScalingKey];
    }
}

- (void)rememberOverlayPosition:(NSNotification*)aNotification
{
    [self overlayPositionChanged:nil];
    [self overlayScalingChanged:nil];
}

- (void)bannerTextTruncated:(NSNotification*)aNotification
{
    NSInteger textLength = [_bannerText length];

    if (textLength > 0) {
        
        NSBeep();
        
        // we only change the text color if not already changed
        if (![[_bannerTextField textColor] isEqualTo:kMTBannerErrorColor]) {

            [_bannerTextField setTextColor:kMTBannerErrorColor];

            [NSTimer scheduledTimerWithTimeInterval:.1
                                            repeats:NO
                                              block:^(NSTimer *timer) {
                [self->_bannerTextField setTextColor:[NSColor labelColor]];
            }];
        }
    }
}

- (void)saveIcon:(NSNotification*)aNotification
{
    if ([_userDefaults boolForKey:kMTDefaultsSaveInstallIconKey]) {
        
        NSDictionary *userInfo = [aNotification userInfo];
        NSString *path = [userInfo objectForKey:kMTNotificationKeyFolderPath];
        
        if (path) {
            
            NSInteger outputSize = [_userDefaults integerForKey:kMTDefaultsOutputSizeKey];
            
            [NSImage imageWithView:[_installIconView icon]
                              size:NSMakeSize(outputSize, outputSize)
                 completionHandler:^(NSImage *image) {
                
                MTIconSet *iconSet = [[MTIconSet alloc] init];
                [iconSet setInstallIcon:image];
                [iconSet setFileNamePrefix:[userInfo objectForKey:kMTNotificationKeyFileNamePrefix]];
                [iconSet writeToFolder:path createFolder:NO animatedOnly:NO completionHandler:nil];
            }];
        }
    }
}

- (void)fontSetChanged:(NSNotification*)aNotification
{
    NSString *selectedFont = [self->_fontButton titleOfSelectedItem];
    NSString *selectedFontFace = [[self->_fontFaceButton selectedItem] representedObject];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        // create the font menu…
        [self updateFontMenu];
        
        // …and select the last font used
        [self selectFontButtonsWithFamilyName:selectedFont fontFace:selectedFontFace];
        
        [self updateBanner];
    });
}

- (void)copyIcon:(NSNotification*)aNotification
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:kMTDefaultsMainWindowSelectedTabKey] == 0) {
        
        [NSImage imageWithView:[_installIconView icon]
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
    BOOL renderInIconShape = [_userDefaults boolForKey:kMTDefaultsRenderImagesInIconShapeKey];
    
    [_installIconView setApplyIconShape:renderInIconShape];
    [_installIconView setUsesOldIconShape:[_userDefaults boolForKey:kMTDefaultsUseOldIconShapeKey]];
    [_installIconView setDrawBannerInIconShape:(renderInIconShape && [_userDefaults boolForKey:kMTDefaultsDrawBannerInIconShapeKey] && ![_installIconView isAppBundle])];
    [_installIconView setImage:[_installIconView unmodifiedImage]];
   
    [self updateBanner];
}

#pragma mark - MTDropViewDelegate

- (void)view:(MTDropView*)view didChangeImage:(NSImage *)image applicationBundle:(BOOL)application
{
    [_installIconView setDrawBannerInIconShape:(!application && [_userDefaults boolForKey:kMTDefaultsDrawBannerInIconShapeKey])];
    [self updateBanner];
    
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
        
        if (![_installIconView image]) {
            
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

#pragma mark - NSMenuItemValidation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    BOOL enableItem = YES;
    
    if ([menuItem tag] >= 1000) {
        
        NSInteger clickedRow = [_savedBannersTable clickedRow];
        enableItem = (clickedRow >= 0);
        BOOL hideAll = ([[_savedBannersController content] count] == 0);
        
        if ([menuItem tag] == 1000) {
            
            if (clickedRow >= 0) {
                
                NSDictionary *bannerDict = [[_savedBannersController arrangedObjects] objectAtIndex:clickedRow];
                
                if ([bannerDict objectForKey:kMTDefaultsBannerIsDefaultKey] && [[bannerDict valueForKey:kMTDefaultsBannerIsDefaultKey] boolValue]) {
                    [menuItem setState:NSControlStateValueOn];
                } else {
                    [menuItem setState:NSControlStateValueOff];
                }
            }
            
            [menuItem setHidden:hideAll];
            
        } else if ([menuItem tag] == 2000) {
            
            [menuItem setHidden:(hideAll || [_savedBannersTable clickedRow] < 0)];
            
        } else if ([menuItem tag] == 3000) {
            
            enableItem = YES;
            [menuItem setAlternate:(hideAll || [_savedBannersTable clickedRow] >= 0)];
        }
    }
    
    return enableItem;
}

- (void)dealloc
{
    // remove our observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameImageChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameOverlayImageChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameOverlayImagePositionChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameOverlayImageScalingChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameBannerTruncated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameSaveIcon object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFontSetChangedNotification object:nil];
}

@end
