/*
     MTIconSetViewController.m
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

#import "MTIconSetViewController.h"

@interface MTIconSetViewController ()
@property (weak) IBOutlet NSButton *saveButton;

@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readwrite) NSUserDefaultsController *defaultsController;
@end

@implementation MTIconSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // register defaults
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
    _defaultsController = [[NSUserDefaultsController alloc] initWithDefaults:_userDefaults initialValues:nil];

    NSDictionary *defaultSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:kMTOutputSizeDefault], kMTDefaultsOutputSize,
                                     [NSNumber numberWithDouble:kMTAnimationDurationDefault], kMTDefaultsAnimationDuration,
                                     [NSNumber numberWithBool:YES], kMTDefaultsAutoImageSize,
                                     [NSNumber numberWithBool:YES], kMTDefaultsAutoOutputSize,
                                     [NSNumber numberWithInteger:kMTBannerColorDefault], kMTDefaultsBannerColor,
                                     [NSNumber numberWithInteger:kMTBannerTextColorDefault], kMTDefaultsBannerTextColor,
                                     nil
                                     ];
    [_userDefaults registerDefaults:defaultSettings];
    
#pragma mark notifications
    
    // get notified if one of the images changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageChanged:)
                                                 name:@"corp.sap.Icons.installImageChangedNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageChanged:)
                                                 name:@"corp.sap.Icons.uninstallImageChangedNotification"
                                               object:nil];
}

- (IBAction)openFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanCreateDirectories:NO];
    [panel setAllowedFileTypes:[[NSImage imageTypes] arrayByAddingObject:(NSString*)kUTTypeApplicationBundle]];
    [panel setPrompt:NSLocalizedString(@"openButton", nil)];
    [panel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            NSImage *sourceImage = [NSImage imageWithFileAtPath:[[panel URL] path]];
        
            if ([sourceImage isValid]) {
                
                // post notifications so the install and uninstall
                // views can update the source image
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"corp.sap.Icons.installImageChangedNotification"
                                                                    object:sourceImage
                                                                  userInfo:nil
                ];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"corp.sap.Icons.uninstallImageChangedNotification"
                                                                    object:sourceImage
                                                                  userInfo:nil
                ];
            }
        }
    }];
}

- (IBAction)saveFiles:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanCreateDirectories:YES];
    [panel setPrompt:NSLocalizedString(@"chooseButton", nil)];
    [panel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            NSString *folderPath = [MTIconSet createFolderAtPath:[[panel URL] path]
                                                      folderName:@"icons_"
                                                 appendTimestamp:YES
            ];

            if (folderPath) {
                
                // post a notification so the install and uninstall
                // views can save their respective icons
                [[NSNotificationCenter defaultCenter] postNotificationName:@"corp.sap.Icons.saveIconNotification"
                                                                    object:folderPath
                                                                  userInfo:nil
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

- (void)imageChanged:(NSNotification*)aNotification
{
    // make sure our save button is enabled as soon
    // as we got a (new) source image
    [_saveButton setEnabled:YES];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    // make sure the "Save Icon Set" entry in Main Menu is
    // only enabled if the "Save Icon Set" button in our
    // view is also enabled
    BOOL enableItem = YES;
    
    if ([menuItem tag] == 2000) {
        enableItem = [_saveButton isEnabled];
    }
    
    return enableItem;
}

- (void)dealloc
{
    // remove our observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
