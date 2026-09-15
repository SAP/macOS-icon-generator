/*
    AppDelegate.m
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

#import "AppDelegate.h"
#import "MTImage.h"
#import "Constants.h"
#import "MTUpdateChecker.h"

@interface AppDelegate ()
@property (nonatomic, strong, readwrite) NSWindowController *settingsWindowController;
@end

@implementation AppDelegate

- (void)application:(NSApplication *)application openURLs:(nonnull NSArray<NSURL *> *)urls
{
    NSURL *droppedFile = [urls firstObject];
    NSImage *sourceImage = [NSImage imageWithFileAtURL:droppedFile];

    if ([sourceImage isValid]) {
        
        // post notifications so the install and uninstall
        // views can update the source image
        [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameImageChanged
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                        sourceImage, kMTNotificationKeyImage,
                                                                        droppedFile, kMTNotificationKeyImageURL,
                                                                        nil
                                                                       ]
        ];
    }
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app
{
    return YES;
}

#pragma mark - IBActions

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

- (IBAction)checkForUpdates:(id)sender
{
    MTUpdateChecker *updateChecker = [[MTUpdateChecker alloc] initWithBundleIdentifier:kMTUpdateCheckerBundleIdentifier];
    [updateChecker launch];
}

#pragma mark - NSMenuItemValidation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    BOOL enableItem = YES;
    
    if ([menuItem tag] == 9000) {
        
        enableItem = !([[NSUserDefaults standardUserDefaults] objectIsForcedForKey:kMTDefaultsUpdateCheckDisabledKey] &&
                       [[NSUserDefaults standardUserDefaults] boolForKey:kMTDefaultsUpdateCheckDisabledKey]);
        
        // if update checking has not been disabled, we check if the Patcher app is installed
        if (enableItem) {
            
            MTUpdateChecker *updateChecker = [[MTUpdateChecker alloc] initWithBundleIdentifier:kMTUpdateCheckerBundleIdentifier];
            enableItem = [updateChecker isAvailable];
        }
        
        [menuItem setHidden:!enableItem];
    }
    
    return enableItem;
}

@end
