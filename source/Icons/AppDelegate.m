/*
     AppDelegate.m
     Copyright 2016-2024 SAP SE
     
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
                                                          userInfo:([sourceImage isValid]) ? [NSDictionary dictionaryWithObject:droppedFile
                                                                                                                         forKey:kMTNotificationKeyImageURL
                                                                                             ] : nil
        ];
    }
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app
{
    return YES;
}

@end
