/*
     MTInstallViewController.m
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

#import "MTInstallViewController.h"

@interface MTInstallViewController ()
@property (weak) IBOutlet MTInstallIconView *installIconView;
@property (weak) IBOutlet NSTextField *bannerTextField;
@property (weak) IBOutlet NSColorWell *bannerColorWell;
@property (weak) IBOutlet NSColorWell *bannerTextColorWell;
@property (weak) IBOutlet NSButton *positionLeftButton;
@property (weak) IBOutlet NSButton *positionRightButton;
@property (weak) IBOutlet NSTableView *savedBannersTable;
@property (weak) IBOutlet NSArrayController *savedBannersController;

@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readwrite) NSUserDefaultsController *defaultsController;
@property (nonatomic, strong, readwrite) NSString *bannerText;
@property (nonatomic, assign) NSInteger selectedTag;
@property (readonly) BOOL enableRemoveBannerMenu;
@end

@implementation MTInstallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize some stuff
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
    _defaultsController = [[NSUserDefaultsController alloc] initWithDefaults:_userDefaults initialValues:nil];
    
    [_installIconView setDelegate:self];
    
#pragma mark bindings
    
    NSDictionary *bindingOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [[MTColorValueTransformer alloc] init], NSValueTransformerBindingOption,
                                    nil
    ];
    [_bannerColorWell bind:NSValueBinding
                  toObject:_defaultsController
               withKeyPath:[@"values." stringByAppendingString:kMTDefaultsBannerColor]
                   options:bindingOptions];
    
    [_bannerTextColorWell bind:NSValueBinding
                      toObject:_defaultsController
                   withKeyPath:[@"values." stringByAppendingString:kMTDefaultsBannerTextColor]
                       options:bindingOptions];

    [_positionLeftButton bind:NSValueBinding
                     toObject:_defaultsController
                  withKeyPath:[@"values." stringByAppendingString:kMTDefaultsFlippingEnabled]
                    options:[NSDictionary dictionaryWithObjectsAndKeys: [NSValueTransformer valueTransformerForName:NSNegateBooleanTransformerName], NSValueTransformerBindingOption, nil]
    ];
    
    [_positionRightButton bind:NSValueBinding
                      toObject:_defaultsController
                   withKeyPath:[@"values." stringByAppendingString:kMTDefaultsFlippingEnabled]
                       options:nil];
    
    [_savedBannersController bind:NSContentArrayBinding
                         toObject:_defaultsController
                      withKeyPath:[@"values." stringByAppendingString:kMTDefaultsSavedBanners]
                          options:nil];

    // sort the table view
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kMTDefaultsBannerName
                                                                                      ascending:YES
                                                                                       selector:@selector(localizedCaseInsensitiveCompare:)
                                                        ]];
    [_savedBannersController setSortDescriptors:sortDescriptors];

#pragma mark notifications

    // get notified if the image changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageChanged:)
                                                 name:@"corp.sap.Icons.uninstallImageChangedNotification"
                                               object:nil];
    
    // get notified if the banner's text was truncated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bannerTextTruncated:)
                                                 name:@"corp.sap.Icons.bannerTextTruncatedNotification"
                                               object:nil];
    
    // get notified if the icon should be saved
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveIcon:)
                                                 name:@"corp.sap.Icons.saveIconNotification"
                                               object:nil];
}

- (IBAction)saveBanner:(id)sender
{
    NSAttributedString *bannerText = [[_bannerTextField attributedStringValue] attributedStringWithTextColor:[_bannerTextColorWell color]];
    bannerText = [bannerText attributedStringWithBackgroundColor:[_bannerColorWell color]];

    NSData *bannerData = [bannerText RTFFromRange:NSMakeRange(0, [bannerText length])
                              documentAttributes:[NSDictionary dictionaryWithObject:NSRTFTextDocumentType forKey:NSDocumentTypeDocumentAttribute]];
    
    if (bannerData) {
   
        BOOL isFlipped = [_userDefaults boolForKey:kMTDefaultsFlippingEnabled];
        
        NSDictionary *banner = [NSDictionary dictionaryWithObjectsAndKeys:
                                [bannerText string], kMTDefaultsBannerName,
                                bannerData, kMTDefaultsBannerData,
                                [NSNumber numberWithBool:isFlipped], kMTDefaultsBannerIsFlipped,
                                nil];
        [_savedBannersController addObject:banner];
        [_savedBannersController rearrangeObjects];
    }
}

- (IBAction)removeSavedBanner:(id)sender
{
    NSInteger selectedRow = [_savedBannersTable selectedRow];
    
    // we remove either all banners or just the one
    // the user selected
    if ([sender tag] == 1) {
        
        NSRange range = NSMakeRange(0, [[_savedBannersController arrangedObjects] count]);
        [_savedBannersController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        
        if (selectedRow >= 0) { [_installIconView setBannerAttributes:nil]; }
        
    } else {
        
        NSInteger clickedRow = [_savedBannersTable clickedRow];
       
        if (clickedRow >= 0) {
            
            [_savedBannersController removeObjectAtArrangedObjectIndex:clickedRow];
            [_savedBannersController rearrangeObjects];
            
            if (clickedRow == selectedRow) { [_installIconView setBannerAttributes:nil]; }
        }
    }
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    NSDictionary *bannerDict = [[_savedBannersController arrangedObjects] objectAtIndex:row];

    if (bannerDict) {
        
        NSAttributedString *bannerText = [[NSAttributedString alloc] initWithRTF:[bannerDict valueForKey:kMTDefaultsBannerData] documentAttributes:nil];
        
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
        
        NSTableRowView *tableRow = [tableView rowViewAtRow:selectedRow makeIfNecessary:NO];

        if (tableRow) {

            NSDictionary *bannerDict = [[[tableView rowViewAtRow:selectedRow makeIfNecessary:NO] viewAtColumn:0] objectValue];
            NSData *bannerData = [bannerDict valueForKey:kMTDefaultsBannerData];
            NSAttributedString *bannerText = [[NSAttributedString alloc] initWithRTF:bannerData
                                                                  documentAttributes:nil];
            [_installIconView setBannerAttributes:bannerText];
            [_installIconView setBannerIsMirrored:[[bannerDict valueForKey:kMTDefaultsBannerIsFlipped] boolValue]];
            self.bannerText = @"";
        }
        
    } else {
        [_installIconView setBannerAttributes:nil];
    }
}

- (BOOL)enableRemoveBannerMenu
{
    return ([_savedBannersTable clickedRow] >= 0) ? YES : NO;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    NSColor *highlightColor = nil;
    NSDictionary *bannerDict = [[_savedBannersController arrangedObjects] objectAtIndex:row];

    if (bannerDict) {
        
        NSAttributedString *bannerText = [[NSAttributedString alloc] initWithRTF:[bannerDict valueForKey:kMTDefaultsBannerData] documentAttributes:nil];
        if (bannerText) { highlightColor = [[bannerText backgroundColor] complementaryColor]; }
    }
    
    MTTableRowView *rowView = [[MTTableRowView alloc] init];
    if (highlightColor) { [rowView setHighlightColor:highlightColor]; }
    
    return rowView;
}

// we don't want automatic highlighting but do all the
// highlighting stuff in "selectRow:"
-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return NO;
}

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

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTextField *textField = [notification object];
    
    if (textField == _bannerTextField) {

        // clear the array controllers current selection and update the banner
        [_savedBannersController setSelectionIndexes:[NSIndexSet indexSet]];
        [self updateBanner:nil];
    }
}

- (IBAction)updateBanner:(id)sender
{
    NSAttributedString *bannerText;
    
    if ([[_bannerTextField stringValue] length] > 0) {
        
        bannerText = [[NSAttributedString alloc] initWithString:[_bannerTextField stringValue]
                                                                               font:[NSFont systemFontOfSize:13.0]
                                                                    foregroundColor:[_bannerTextColorWell color]
                                                                    backgroundColor:[_bannerColorWell color]];
    }
        
    [self->_installIconView setBannerAttributes:bannerText];
    [self->_installIconView setBannerIsMirrored:[_userDefaults boolForKey:kMTDefaultsFlippingEnabled]];
}

- (void)view:(MTDropView*)view didChangeImage:(NSImage*)image
{
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"corp.sap.Icons.installImageChangedNotification"
                                                        object:image
                                                      userInfo:nil
    ];
}

- (void)imageChanged:(NSNotification*)aNotification
{
    NSImage *image = [aNotification object];
    if ([image isValid]) { [_installIconView setImage:image]; }
}

- (void)bannerTextTruncated:(NSNotification*)aNotification
{
    NSInteger textLength = [_bannerText length];

    if (textLength > 0) {
        
        self.bannerText = [_bannerText substringToIndex:textLength -1];
        dispatch_async(dispatch_get_main_queue(), ^{ [self updateBanner:nil]; });
        NSBeep();
        
        // we only change the text color if not already changed
        if (![[_bannerTextField textColor] isEqualTo:kMTBannerErrorColor]) {

            [_bannerTextField setTextColor:kMTBannerErrorColor];

            [NSTimer scheduledTimerWithTimeInterval:0.1
                                            repeats:NO
                                              block:^(NSTimer * _Nonnull timer) {
                [self->_bannerTextField setTextColor:[NSColor labelColor]];
            }];
        }
    }
}

- (void)saveIcon:(NSNotification*)aNotification
{
    NSString *path = [aNotification object];
    
    if (path) {
        
        NSInteger outputSize = [_userDefaults integerForKey:kMTDefaultsOutputSize];
        
        MTIconSet *iconSet = [[MTIconSet alloc] init];
        [iconSet setInstallIcon:[NSImage imageWithView:[_installIconView icon] size:NSMakeSize(outputSize, outputSize)]];
        [iconSet writeToFolder:path createFolder:NO completionHandler:nil];
    }
}

- (IBAction)switchColors:(id)sender
{
    NSColor *bannerColor = [_bannerColorWell color];
    NSColor *bannerTextColor = [_bannerTextColorWell color];
    
    MTColorValueTransformer *valueTransformer = [[MTColorValueTransformer alloc] init];
    [_defaultsController setValue:[valueTransformer reverseTransformedValue:bannerTextColor]
                       forKeyPath:[@"values." stringByAppendingString:kMTDefaultsBannerColor]];
    [_defaultsController setValue:[valueTransformer reverseTransformedValue:bannerColor]
                       forKeyPath:[@"values." stringByAppendingString:kMTDefaultsBannerTextColor]];
    
    [self updateBanner:nil];
}

- (IBAction)bannerPosition:(id)sender
{
    if ([sender tag] == 1) {
        [_installIconView setBannerIsMirrored:NO];
    } else if ([sender tag] == 2) {
        [_installIconView setBannerIsMirrored:YES];
    }
}

- (void)dealloc
{
    // remove our observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
