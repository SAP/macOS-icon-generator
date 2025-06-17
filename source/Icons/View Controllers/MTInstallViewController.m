/*
     MTInstallViewController.m
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

#import "MTInstallViewController.h"
#import "MTAttributedString.h"

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
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
    _defaultsController = [[NSUserDefaultsController alloc] initWithDefaults:_userDefaults initialValues:nil];
    
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
    
    CGFloat margin = [_userDefaults floatForKey:kMTDefaultsTextMarginDefaultKey];
    [_textMarginSlider setMinValue:kMTBannerTextMarginMin];
    [_textMarginSlider setMaxValue:kMTBannerTextMarginMax];
    [_textMarginSlider setDoubleValue:(margin >= kMTBannerTextMarginMin && margin <= kMTBannerTextMarginMax) ? margin : kMTBannerTextMarginDefault];
    [_installIconView setBannerTextMargin:[_textMarginSlider doubleValue]];
    
    CGFloat scaling = [_userDefaults floatForKey:kMTDefaultsOverlayScalingKey];
    [_overlaySlider setMinValue:kMTOverlayImageScalingMin];
    [_overlaySlider setMaxValue:kMTOverlayImageScalingMax];
    [_overlaySlider setDoubleValue:(scaling >= kMTOverlayImageScalingMin && scaling <= kMTOverlayImageScalingMax) ? scaling : kMTOverlayImageScalingDefault];

    [_installIconView setDelegate:self];
    [_installIconView setAccessibilityChildren:nil];
    
    // enable the correct position button
    [self enablePositionButtonAtIndex:[_userDefaults integerForKey:kMTDefaultsPositionDefaultKey]];
    
#pragma mark bindings
    
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

#pragma mark notifications

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
    
    // update the slider's tooltips
    [self updateTextMarginSliderToolTip:nil];
    [self updateOverlaySliderToolTip:nil];
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
            [_userDefaults setInteger:bannerPosition forKey:kMTDefaultsPositionDefaultKey];
            
            // If the banner was saved with an older version of the application that does
            // not support the margin attribute, we will display the text with a default
            // margin to make sure the banner looks the same as in the old version.
            CGFloat textMargin = kMTBannerTextMarginDefault;
            
            if ([bannerDict objectForKey:kMTDefaultsBannerTextMarginKey]) {
                
                textMargin = [[bannerDict valueForKey:kMTDefaultsBannerTextMarginKey] floatValue];
            }
                
            [_installIconView setBannerTextMargin:textMargin];
            [_userDefaults setFloat:textMargin forKey:kMTDefaultsTextMarginDefaultKey];
            
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

#pragma mark NSTableViewDelegate

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
        
    } else {
        
        [_installIconView setBannerAttributes:nil];
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

#pragma mark NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTextField *textField = [notification object];
    
    if (textField == _bannerTextField) {

        // clear the array controllers current selection and update the banner
        [_savedBannersController setSelectionIndexes:[NSIndexSet indexSet]];
        [self updateBanner];
    }
}

#pragma mark IBActions

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
        
        if ([[sender title] isEqualToString:NSLocalizedString(@"setDefaultBanner", nil)]) {
            
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
    NSInteger selectedRow = [_savedBannersTable selectedRow];
    
    // we remove either all banners or just the one
    // the user selected
    if ([sender tag] == 3000) {
        
        NSRange range = NSMakeRange(0, [[_savedBannersController arrangedObjects] count]);
        [_savedBannersController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        
        if (selectedRow >= 0) { [_installIconView setBannerAttributes:nil]; }
        
    } else {
        
        NSInteger clickedRow = [_savedBannersTable clickedRow];
       
        if (clickedRow >= 0 && clickedRow < [[_savedBannersController arrangedObjects] count]) {
            
            [_savedBannersController removeObjectAtArrangedObjectIndex:clickedRow];
            
            if (clickedRow == selectedRow) { [_installIconView setBannerAttributes:nil]; }
        }
    }
    
    [_savedBannersController rearrangeObjects];
}

- (IBAction)updateBannerPosition:(id)sender
{
    [_userDefaults setInteger:[sender tag] forKey:kMTDefaultsPositionDefaultKey];
    [self enablePositionButtonAtIndex:[sender tag]];
    [self updateBanner];
}

- (IBAction)changeBannerColor:(id)sender
{
    [self updateBanner];
}

- (IBAction)changeBannerFont:(id)sender
{
    NSString *selectedFamilyName = [_fontButton titleOfSelectedItem];
    if ([sender isEqualTo:_fontButton]) { [self updateFontFacesForFamily:selectedFamilyName]; }
    NSString *selectedFontFace = [[_fontFaceButton selectedItem] representedObject];

    [_userDefaults setObject:selectedFontFace forKey:kMTDefaultsSelectedFontKey];
    
    [self updateBanner];
}

- (IBAction)switchColors:(id)sender
{
    NSColor *bannerColor = [_bannerColorWell color];
    NSColor *bannerTextColor = [_bannerTextColorWell color];
    
    MTColorValueTransformer *valueTransformer = [[MTColorValueTransformer alloc] init];
    [_defaultsController setValue:[valueTransformer reverseTransformedValue:bannerTextColor]
                       forKeyPath:[@"values." stringByAppendingString:kMTDefaultsBannerColorKey]];
    [_defaultsController setValue:[valueTransformer reverseTransformedValue:bannerColor]
                       forKeyPath:[@"values." stringByAppendingString:kMTDefaultsBannerTextColorKey]];
    
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
    
    [_userDefaults setFloat:[_textMarginSlider doubleValue] forKey:kMTDefaultsTextMarginDefaultKey];
}

#pragma mark NSNotification handlers

- (void)imageChanged:(NSNotification*)aNotification
{
    if (![[aNotification object] isEqualTo:self]) {

        NSURL *imageURL = [[aNotification userInfo] objectForKey:kMTNotificationKeyImageURL];
        NSImage *image = [NSImage imageWithFileAtURL:imageURL];
        
        if ([image isValid]) { [_installIconView setImage:image]; }
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
    NSURL *imageURL = [[aNotification userInfo] objectForKey:kMTNotificationKeyImageURL];
    NSImage *image = [NSImage imageWithFileAtURL:imageURL];
    
    if ([image isValid]) { [_installIconView setOverlayImage:image]; }
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
        
        NSNumber *imageScaling = [NSNumber numberWithFloat:[_installIconView overlayImageScalingFactor]];
        [_userDefaults setObject:imageScaling forKey:kMTDefaultsOverlayScalingKey];
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
        
        self.bannerText = [_bannerText substringToIndex:textLength - 1];
        dispatch_async(dispatch_get_main_queue(), ^{ [self updateBanner]; });
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
            
            MTIconSet *iconSet = [[MTIconSet alloc] init];
            [iconSet setInstallIcon:[NSImage imageWithView:[_installIconView icon] size:NSMakeSize(outputSize, outputSize)]];
            [iconSet setFileNamePrefix:[userInfo objectForKey:kMTNotificationKeyFileNamePrefix]];
            [iconSet writeToFolder:path createFolder:NO animatedOnly:NO completionHandler:nil];
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

#pragma mark MTDropViewDelegate

- (void)view:(MTDropView*)view didChangeImageAtURL:(NSURL *)url
{
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameImageChanged
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:url
                                                                                           forKey:kMTNotificationKeyImageURL
                                                               ]
    ];
}

#pragma mark NSMenuItemValidation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    BOOL enable = YES;
    
    if ([menuItem tag] >= 1000) {
        
        NSInteger clickedRow = [_savedBannersTable clickedRow];
        enable = (clickedRow >= 0);
        BOOL hideAll = ([[_savedBannersController content] count] == 0);
        
        if ([menuItem tag] == 1000) {
            
            if (clickedRow >= 0) {
                
                NSDictionary *bannerDict = [[_savedBannersController arrangedObjects] objectAtIndex:clickedRow];
                
                if ([bannerDict objectForKey:kMTDefaultsBannerIsDefaultKey] && [[bannerDict valueForKey:kMTDefaultsBannerIsDefaultKey] boolValue]) {
                    [menuItem setTitle:NSLocalizedString(@"unsetDefaultBanner", nil)];
                } else {
                    [menuItem setTitle:NSLocalizedString(@"setDefaultBanner", nil)];
                }
            }
            
            [menuItem setHidden:hideAll];
            
        } else if ([menuItem tag] == 2000) {
            
            [menuItem setHidden:(hideAll || [_savedBannersTable clickedRow] < 0)];
            
        } else if ([menuItem tag] == 3000) {
            
            enable = YES;
            [menuItem setAlternate:(hideAll || [_savedBannersTable clickedRow] >= 0)];
        }
    }
    
    return enable;
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
