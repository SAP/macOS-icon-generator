/*
    MTIconSetViewController.m
    Copyright 2022-2024 SAP SE
     
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

#import "MTIconSetViewController.h"
#import "MTSavePanelAccessoryController.h"
#import "Constants.h"
#import <UniformTypeIdentifiers/UTCoreTypes.h>

@interface MTIconSetViewController ()
@property (weak) IBOutlet NSButton *saveButton;

@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readwrite) NSUserDefaultsController *defaultsController;
@property (nonatomic, strong, readwrite) MTSavePanelAccessoryController *accessoryController;
@property (nonatomic, strong, readwrite) NSImage *currentImage;
@property (nonatomic, strong, readwrite) NSURL *imageURL;
@property (nonatomic, strong, readwrite) NSWindowController *settingsWindowController;
@end

@implementation MTIconSetViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // register defaults
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
    _defaultsController = [[NSUserDefaultsController alloc] initWithDefaults:_userDefaults initialValues:nil];

    NSDictionary *defaultSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:kMTOutputSizeDefault], kMTDefaultsOutputSizeKey,
                                     [NSNumber numberWithDouble:kMTAnimationDurationDefault], kMTDefaultsAnimationDurationKey,
                                     [NSNumber numberWithBool:YES], kMTDefaultsAutoImageSizeKey,
                                     [NSNumber numberWithBool:YES], kMTDefaultsAutoOutputSizeKey,
                                     [NSNumber numberWithInteger:kMTBannerColorDefault], kMTDefaultsBannerColorKey,
                                     [NSNumber numberWithInteger:kMTBannerTextColorDefault], kMTDefaultsBannerTextColorKey,
                                     [NSNumber numberWithBool:YES], kMTDefaultsSaveInstallIconKey,
                                     [NSNumber numberWithBool:YES], kMTDefaultsSaveUninstallIconKey,
                                     [NSNumber numberWithBool:YES], kMTDefaultsSaveAnimatedUninstallIconKey,
                                     [NSNumber numberWithInt:0], kMTDefaultsPositionDefaultKey,
                                     [NSNumber numberWithBool:NO], kMTDefaultsUsePrefixKey,
                                     [NSNumber numberWithBool:NO], kMTDefaultsRememberOverlayPositionKey,
                                     [NSNumber numberWithFloat:kMTBannerTextMarginDefault], kMTDefaultsTextMarginDefaultKey,
                                     nil
                                     ];
    [_userDefaults registerDefaults:defaultSettings];
    
#pragma mark notifications
    
    // get notified if one of the images changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageChanged:)
                                                 name:kMTNotificationNameImageChanged
                                               object:nil
    ];
}

- (void)imageChanged:(NSNotification*)aNotification
{
    NSURL *imageURL = [[aNotification userInfo] objectForKey:kMTNotificationKeyImageURL];
    NSImage *image = [NSImage imageWithFileAtURL:imageURL];
    
    if ([image isValid]) {
        
        // make sure our save button is enabled as soon
        // as we got a (new) source image
        [_saveButton setEnabled:YES];
        
        _currentImage = image;
        _imageURL = imageURL;
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    // make sure the "Save Icon Set" entry in Main Menu is
    // only enabled if the "Save Icon Set" button in our
    // view is also enabled
    BOOL enableItem = YES;
    
    if ([menuItem tag] == 2000 || [menuItem tag] == 1500) {
        enableItem = [_saveButton isEnabled];
    }
    
    return enableItem;
}

- (void)dealloc
{
    // remove our observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameImageChanged object:nil];
}

#pragma mark IBActions

- (IBAction)openFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanCreateDirectories:NO];
    [panel setAllowedContentTypes:[NSArray arrayWithObjects:UTTypeImage, UTTypeApplicationBundle, nil]];
    [panel setPrompt:NSLocalizedString(@"openButton", nil)];
    [panel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            NSImage *sourceImage = [NSImage imageWithFileAtURL:[panel URL]];
        
            if ([sourceImage isValid]) {
                
                // post notifications so the install and uninstall
                // views can update the source image
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameImageChanged
                                                                    object:self
                                                                  userInfo:([sourceImage isValid]) ? [NSDictionary dictionaryWithObject:[panel URL]
                                                                                                                                 forKey:kMTNotificationKeyImageURL
                                                                                                     ] : nil
                ];
            }
        }
    }];
}

- (IBAction)addOverlayImage:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanCreateDirectories:NO];
    [panel setAllowedContentTypes:[NSArray arrayWithObject:UTTypeImage]];
    [panel setPrompt:NSLocalizedString(@"openButton", nil)];
    [panel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            NSImage *sourceImage = [[NSImage alloc] initWithContentsOfURL:[panel URL]];
        
            if ([sourceImage isValid]) {
                
                // post notifications so the install and uninstall
                // views can update the source image
                [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameOverlayImageChanged
                                                                    object:self
                                                                  userInfo:([sourceImage isValid]) ? [NSDictionary dictionaryWithObject:[panel URL]
                                                                                                                                 forKey:kMTNotificationKeyImageURL
                                                                                                     ] : nil
                ];
            }
        }
    }];
}

- (IBAction)saveFiles:(id)sender
{
    // load the nib file
    if (!_accessoryController) {
        _accessoryController = [[MTSavePanelAccessoryController alloc] initWithNibName:@"MTSavePanelAccessory" bundle:nil];
    }
    
    [_accessoryController setSourceImage:_currentImage];

    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanCreateDirectories:YES];
    [panel setAccessoryView:[_accessoryController view]];
    [panel setAccessoryViewDisclosed:YES];
    [panel setMessage:NSLocalizedString(@"saveDialogMessage", nil)];
    [panel setPrompt:NSLocalizedString(@"saveButton", nil)];
    [panel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            NSString *folderPath = [MTIconSet createFolderAtPath:[[panel URL] path]
                                                      folderName:@"icons_"
                                                 appendTimestamp:YES
            ];

            if (folderPath) {
                
                // post a notification so the install and uninstall
                // views can save their respective icons
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:folderPath forKey:kMTNotificationKeyFolderPath];
                
                if ([self->_userDefaults boolForKey:kMTDefaultsUsePrefixKey]) {
                    
                    NSString *fileNamePrefix = [self->_userDefaults stringForKey:kMTDefaultsUserDefinedPrefixKey];
                    
                    if (!fileNamePrefix && self->_imageURL) {
                        fileNamePrefix = [[self->_imageURL lastPathComponent] stringByDeletingPathExtension];
                    }
                    
                    [userInfo setObject:fileNamePrefix forKey:kMTNotificationKeyFileNamePrefix];
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameSaveIcon
                                                                    object:self
                                                                  userInfo:userInfo
                ];
                
            } else {
                
                // show an error dialog if the folder could not be created
                NSAlert *theAlert = [[NSAlert alloc] init];
                [theAlert setMessageText:NSLocalizedString(@"saveErrorTitle", nil)];
                [theAlert setInformativeText:NSLocalizedString(@"saveErrorInfo", nil)];
                [theAlert addButtonWithTitle:NSLocalizedString(@"okButton", nil)];
                [theAlert setAlertStyle:NSAlertStyleInformational];
                [theAlert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            }
        }
    }];
}

#pragma mark IBActions

- (IBAction)openGitHub:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kMTGitHubURL]];
}

- (IBAction)showSettingsWindow:(id)sender
{
    if (!_settingsWindowController) {
        
        NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        _settingsWindowController = [storyboard instantiateControllerWithIdentifier:@"corp.sap.Icons.SettingsController"];
    }
    
    [_settingsWindowController showWindow:nil];
    [[_settingsWindowController window] makeKeyAndOrderFront:nil];
    
    [NSApp activateIgnoringOtherApps:YES];
}

@end
