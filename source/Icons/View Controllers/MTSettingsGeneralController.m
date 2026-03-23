/*
    MTSettingsGeneralController.m
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

#import "MTSettingsGeneralController.h"
#import "MTIconSet.h"
#import "Constants.h"
#import "MTGroupDefaults.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface MTSettingsGeneralController ()
@property (weak) IBOutlet NSButton *rememberOverlayCheckbox;
@property (weak) IBOutlet NSButton *usePrefixCheckbox;
@property (weak) IBOutlet NSTextField *userDefinedPrefix;
@property (weak) IBOutlet NSTextField *sfSymbolsText;
@property (weak) IBOutlet NSPopUpButton *deleteBadgeIconButton;

@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readwrite) NSUserDefaultsController *defaultsController;
@end

@implementation MTSettingsGeneralController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userDefaults = [MTGroupDefaults sharedDefaults];
    _defaultsController = [MTGroupDefaults sharedDefaultsController];
    
    [_usePrefixCheckbox bind:NSValueBinding
                    toObject:_defaultsController
                 withKeyPath:[@"values." stringByAppendingString:kMTDefaultsUsePrefixKey]
                     options:nil
     ];
    
    [_rememberOverlayCheckbox bind:NSValueBinding
                          toObject:_defaultsController
                       withKeyPath:[@"values." stringByAppendingString:kMTDefaultsRememberOverlayPositionKey]
                           options:nil
     ];
    
    [_userDefinedPrefix bind:NSValueBinding
                    toObject:_defaultsController
                 withKeyPath:[@"values." stringByAppendingString:kMTDefaultsUserDefinedPrefixKey]
                     options:[NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"prefixSetAutomatically", nil), NSNullPlaceholderBindingOption,
                              NSLocalizedString(@"prefixSetAutomatically", nil), NSNoSelectionPlaceholderBindingOption,
                              nil
                             ]
     ];
    
    [_userDefinedPrefix setAccessibilityLabel:NSLocalizedString(@"accessibilityLabelPrefix", nil)];
    [self createBadgeMenu];
    
    // make the link in our text field clickable
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] initWithAttributedString:[_sfSymbolsText attributedStringValue]];
        
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *allMatches = [linkDetector matchesInString:[finalString string] options:0 range:NSMakeRange(0, [[finalString string] length])];
    
    for (NSTextCheckingResult *match in [allMatches reverseObjectEnumerator]) {
        [finalString addAttribute:NSLinkAttributeName value:[match URL] range:[match range]];
    }
   
    [_sfSymbolsText setAttributedStringValue:finalString];
}

- (void)viewWillDisappear
{
    [super viewWillDisappear];
    [[[self view] window] makeFirstResponder:nil];
}

- (void)createBadgeMenu
{
    // remove an existing item
    NSMenuItem *badgeItem = [[_deleteBadgeIconButton menu] itemWithTag:1000];
    if (badgeItem) { [[_deleteBadgeIconButton menu] removeItem:badgeItem]; }
    
    NSImage *selectedImage = nil;
    NSString *itemTitle = NSLocalizedString(@"sfSymbolMenuEntry", nil);
    
    NSData *sfSymbol = [_userDefaults objectForKey:kMTDefaultsDeleteBadgeSFSymbolKey];
    
    if (sfSymbol) {
        
        selectedImage = [[NSImage alloc] initWithData:sfSymbol];
        
    } else {
        
        NSData *bookmarkData = [_userDefaults objectForKey:kMTDefaultsDeleteBadgeIconBookmarkKey];
        BOOL stale = NO;
        
        NSURL *url = [NSURL URLByResolvingBookmarkData:bookmarkData
                                               options:0
                                         relativeToURL:nil
                                   bookmarkDataIsStale:&stale
                                                 error:nil
        ];
        
        if (stale) {
            
            NSData *newData = [url bookmarkDataWithOptions:0
                            includingResourceValuesForKeys:nil
                                             relativeToURL:nil
                                                     error:nil
            ];
            
            if (newData) { [self->_userDefaults setObject:newData forKey:kMTDefaultsDeleteBadgeIconBookmarkKey]; }
        }
        
        if (url) {
            
            // get the title for the menu item…
            itemTitle = [url lastPathComponent];
            
            if ([url startAccessingSecurityScopedResource]) {
                
                selectedImage = [[NSImage alloc] initWithContentsOfURL:url];
                [url stopAccessingSecurityScopedResource];
            }
        }
    }
         
    if ([selectedImage isValid]) {
           
        // resize the image to 16x16 pixels
        NSRect imageRect = NSMakeRect(0, 0, 16, 16);
        NSImageRep *imageRep = [selectedImage bestRepresentationForRect:imageRect context:nil hints:nil];
        NSImage *itemImage = [[NSImage alloc] initWithSize:imageRect.size];
        [itemImage addRepresentation:imageRep];
        
        // add the item…
        NSMenuItem *badgeItem = [[NSMenuItem alloc] initWithTitle:itemTitle
                                                           action:nil
                                                    keyEquivalent:@""
        ];
        [badgeItem setImage:itemImage];
        [badgeItem setTag:1000];
        [[_deleteBadgeIconButton menu] insertItem:badgeItem atIndex:2];
        
        // …and select it
        [_deleteBadgeIconButton selectItemAtIndex:2];
        
    } else {
        
        [_deleteBadgeIconButton selectItemAtIndex:0];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameDeleteBadgeIconChanged
                                                        object:self
                                                      userInfo:nil
    ];
}

#pragma mark - IBActions

- (IBAction)setRememberImagePosition:(id)sender
{
    if ([_userDefaults boolForKey:kMTDefaultsRememberOverlayPositionKey]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameRememberOverlayPosition
                                                            object:self
                                                          userInfo:nil
        ];
        
    } else {
        
        [_userDefaults removeObjectForKey:kMTDefaultsOverlayPositionKey];
        [_userDefaults removeObjectForKey:kMTDefaultsOverlayScalingKey];
    }
}

- (IBAction)selectBadgeIcon:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setPrompt:NSLocalizedString(@"selectButton", nil)];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanCreateDirectories:NO];
    [panel setAllowedContentTypes:[NSArray arrayWithObjects:UTTypeImage, UTTypePDF, nil]];
    [panel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSModalResponse result) {
        
        BOOL success = NO;
        
        if (result == NSModalResponseOK) {
            
            NSImage *selectedImage = [[NSImage alloc] initWithContentsOfURL:[panel URL]];
            
            if ([selectedImage isValid]) {
                
                NSData *bookmarkData = [[panel URL] bookmarkDataWithOptions:0 //(NSURLBookmarkCreationWithSecurityScope | NSURLBookmarkCreationSecurityScopeAllowOnlyReadAccess)
                                             includingResourceValuesForKeys:nil
                                                              relativeToURL:nil
                                                                      error:nil
                ];
                
                if (bookmarkData) {
                    
                    [self->_userDefaults setObject:bookmarkData forKey:kMTDefaultsDeleteBadgeIconBookmarkKey];
                    [self->_userDefaults removeObjectForKey:kMTDefaultsDeleteBadgeSFSymbolKey];
                }
                
                [self createBadgeMenu];
                
                success = YES;
                
            } else {
                
                NSAlert *imageAlert = [[NSAlert alloc] init];
                [imageAlert setMessageText:NSLocalizedString(@"imageErrorTitle", nil)];
                [imageAlert setInformativeText:NSLocalizedString(@"imageErrorInfo", nil)];
                [imageAlert addButtonWithTitle:NSLocalizedString(@"okButton", nil)];
                [imageAlert setAlertStyle:NSAlertStyleWarning];
                [imageAlert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            }
        }
        
        if (!success) {
            
            if ([[self->_deleteBadgeIconButton menu] itemWithTag:1000]) {
                [self->_deleteBadgeIconButton selectItemWithTag:1000];
            } else {
                [self->_deleteBadgeIconButton selectItemAtIndex:0];
            }
        }
    }];
}

- (IBAction)removeBadgeIcon:(id)sender
{
    [_userDefaults removeObjectForKey:kMTDefaultsDeleteBadgeIconBookmarkKey];
    [_userDefaults removeObjectForKey:kMTDefaultsDeleteBadgeSFSymbolKey];
    
    [self createBadgeMenu];
}

- (IBAction)pasteFromSFSymbols:(id)sender
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSImage *selectedImage = [[NSImage alloc] initWithPasteboard:pasteboard];
    
    if ([selectedImage isValid]) {
        
        // get the string from clipboard
        NSString *clipboardString = [pasteboard stringForType:NSPasteboardTypeString];
        
        [_userDefaults removeObjectForKey:kMTDefaultsDeleteBadgeIconBookmarkKey];
        [_userDefaults setObject:[clipboardString dataUsingEncoding:NSUTF8StringEncoding] forKey:kMTDefaultsDeleteBadgeSFSymbolKey];
        
        [self createBadgeMenu];
    
    } else {
        
        NSAlert *symbolAlert = [[NSAlert alloc] init];
        [symbolAlert setMessageText:NSLocalizedString(@"symbolErrorTitle", nil)];
        [symbolAlert setInformativeText:NSLocalizedString(@"symbolErrorInfo", nil)];
        [symbolAlert addButtonWithTitle:NSLocalizedString(@"okButton", nil)];
        [symbolAlert setAlertStyle:NSAlertStyleWarning];
        [symbolAlert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
    
        if ([[_deleteBadgeIconButton menu] itemWithTag:1000]) {
            [_deleteBadgeIconButton selectItemWithTag:1000];
        } else {
            [_deleteBadgeIconButton selectItemAtIndex:0];
        }
    }
}

# pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification*)aNotification
{
    if ([aNotification object] == _userDefinedPrefix) {
        
        [_userDefinedPrefix setStringValue:[MTIconSet fileNamePrefixWithString:[_userDefinedPrefix stringValue]]];
    }
}

#pragma mark - NSMenuItemValidation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    BOOL enableItem = YES;

    if ([menuItem tag] == 300) {

        // check clipboard contents
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        NSString *pasteboardString = [pasteboard stringForType:NSPasteboardTypeString];
        
        if (pasteboardString) {
            
            NSString *pattern = @"<!DOCTYPE\\s+svg.*</svg>";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                   options:(NSRegularExpressionCaseInsensitive |
                                                                                            NSRegularExpressionDotMatchesLineSeparators)
                                                                                     error:nil
            ];
            
            NSRange range = [regex rangeOfFirstMatchInString:pasteboardString
                                                     options:0
                                                       range:NSMakeRange(0, [pasteboardString length])];
            
            enableItem = (range.location != NSNotFound);
            
        } else {
            
            enableItem = NO;
        }
    }
    
    return enableItem;
}

@end
