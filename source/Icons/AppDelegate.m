/*
     AppDelegate.m
     Copyright 2016-2022 SAP SE
     
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

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   
}

- (void)application:(NSApplication *)application openURLs:(nonnull NSArray<NSURL *> *)urls
{
    NSURL *droppedFile = [urls firstObject];
    
    NSImage *sourceImage = [NSImage imageWithFileAtPath:[droppedFile path]];

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

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
    return YES;
}

@end
