/*
    MTIconSetViewController.m
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

#import "MTIconSetViewController.h"
#import "MTSavePanelAccessoryController.h"
#import "Icons-Swift.h"
#import "MTGroupDefaults.h"
#import <UniformTypeIdentifiers/UTCoreTypes.h>

@interface MTIconSetViewController ()
@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readwrite) MTSavePanelAccessoryController *accessoryController;
@property (nonatomic, strong, readwrite) NSImage *currentImage;
@property (nonatomic, strong, readwrite) NSURL *imageURL;
@property (nonatomic, strong, readwrite) NSWindowController *settingsWindowController;

#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 150100
@property (nonatomic, strong, readwrite) MTImagePlayground *imagePlayground API_AVAILABLE(macos(15.1));
#endif
@end

#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 150100
@interface MTIconSetViewController (ImageGenerationDelegate) <ImageGenerationViewControllerDelegate>
@end
#endif

@implementation MTIconSetViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _userDefaults = [MTGroupDefaults sharedDefaults];
    
    // get notified if one of the images changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageChanged:)
                                                 name:kMTNotificationNameImageChanged
                                               object:nil
    ];
    
    // get noticed if Image Playground should be shown
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showImagePlayground:)
                                                 name:kMTNotificationNameShowImagePlayground
                                               object:nil
    ];
}

- (void)dealloc
{
    // remove our observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameImageChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMTNotificationNameShowImagePlayground object:nil];
}

#pragma mark Notifications

- (void)imageChanged:(NSNotification*)aNotification
{
    NSImage *image = [[aNotification userInfo] objectForKey:kMTNotificationKeyImage];
    if ([image isValid]) { self.currentImage = image; }
}

#pragma mark NSMenuItemValidation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    // make sure the "Save Icon Set" entry in Main Menu is
    // only enabled if the "Save Icon Set" button in our
    // view is also enabled
    BOOL enableItem = YES;
    
    // Add Overlay, Save & Copy Icon
    if ([menuItem tag] == 1500 || [menuItem tag] == 2000 || [menuItem tag] == 4000) {
        
        enableItem = (_currentImage != nil);
        
    // Image Playground
    } else if ([menuItem tag] == 3000) {
        
        if (@available(macOS 15.1, *)) {
            
            enableItem = YES;
            
        } else {
            
            enableItem = NO;
        }
        
    // Paste Image
    } else if ([menuItem tag] == 5000) {
        
        // check clipboard contents
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        enableItem = ([pasteboard canReadObjectForClasses:[NSArray arrayWithObject:[NSImage class]] options:nil]);
    }
    
    return enableItem;
}

#pragma mark IBActions

- (IBAction)openFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanCreateDirectories:NO];
    [panel setAllowedContentTypes:[NSArray arrayWithObjects:UTTypeImage, UTTypePDF, UTTypeApplicationBundle, nil]];
    [panel setPrompt:NSLocalizedString(@"openButton", nil)];
    [panel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            NSURL *imageURL = [panel URL];
            NSImage *image = [NSImage imageWithFileAtURL:imageURL];
        
            if ([image isValid]) {
                
                id utiValue = nil;
                [imageURL getResourceValue:&utiValue forKey:NSURLTypeIdentifierKey error:nil];
                BOOL isApplication = [utiValue isEqualTo:[UTTypeApplicationBundle identifier]];
                
                // post notifications so the install and uninstall
                // views can update the source image
                [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameImageChanged
                                                                    object:self
                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                            image, kMTNotificationKeyImage,
                                                                            [NSNumber numberWithBool:isApplication], kMTNotificationKeyIsAppBundle,
                                                                            nil
                                                                           ]
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
    [panel setAllowedContentTypes:[NSArray arrayWithObjects:UTTypeImage, UTTypePDF, nil]];
    [panel setPrompt:NSLocalizedString(@"openButton", nil)];
    [panel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            NSImage *sourceImage = [[NSImage alloc] initWithContentsOfURL:[panel URL]];
        
            if ([sourceImage isValid]) {
                
                // post a notification so the install and uninstall
                // views can update the source image
                [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameOverlayImageChanged
                                                                    object:self
                                                                  userInfo:([sourceImage isValid]) ? [NSDictionary dictionaryWithObject:sourceImage
                                                                                                                                 forKey:kMTNotificationKeyImage
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
                    
                    if (fileNamePrefix) {
                        [userInfo setObject:fileNamePrefix forKey:kMTNotificationKeyFileNamePrefix];
                    }
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

- (IBAction)showImagePlayground:(id)sender
{
    if (@available(macOS 15.1, *)) {
        
        if (!_imagePlayground) {
            
            _imagePlayground = [[MTImagePlayground alloc] init];
            [_imagePlayground setDelegate:self];
        }
        
        [_imagePlayground showWithPresenter:self];
    }
}

- (IBAction)copyIcon:(id)sender
{
    // post a notification so the current view
    // can copy the icon to the clipboard
    [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameCopyIcon
                                                        object:self
                                                      userInfo:nil
    ];
}

- (IBAction)pasteImage:(id)sender
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSImage *image = [[NSImage alloc] initWithPasteboard:pasteboard];
    
    if ([image isValid]) {

        [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameImageChanged
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    image, kMTNotificationKeyImage,
                                                                    [NSNumber numberWithBool:NO], kMTNotificationKeyIsAppBundle,
                                                                    nil
                                                                    ]
        ];
    }
}

#pragma mark - ImageGenerationViewControllerDelegate

#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 150100
- (void)imagePlaygroundViewController:(ImagePlaygroundViewController*)controller didCreateImageAt:(NSURL*)imageURL
{
    if (@available(macOS 15.1, *)) {
        
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
        
        // delete the image file as we don't need it anymore
        [[NSFileManager defaultManager] removeItemAtURL:imageURL error:nil];
        
        if ([image isValid]) {
                
            [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameImageChanged
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                        image, kMTNotificationKeyImage,
                                                                        [NSNumber numberWithBool:NO], kMTNotificationKeyIsAppBundle,
                                                                        nil
                                                                        ]
            ];
        }
    }
}
#endif

@end

