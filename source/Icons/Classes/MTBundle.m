/*
     MTBundle.m
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

#import "MTBundle.h"

@implementation NSBundle (MTBundle)

+ (NSBundle*)containerBundleForClass:(Class)aClass
{
    NSBundle *containerBundle = [NSBundle bundleForClass:aClass];
    NSArray *pathComponents = [[containerBundle bundlePath] pathComponents];
    
    if (![[pathComponents lastObject] hasSuffix:@"app"]) {
        
        NSInteger appIndex = [pathComponents indexOfObjectWithOptions:NSEnumerationReverse
                                                          passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj hasSuffix:@"app"];
        }];
        
        if (appIndex != NSNotFound) {
            NSArray *containerPathComponents = [pathComponents subarrayWithRange:NSMakeRange(0, appIndex + 1)];
            containerBundle = [NSBundle bundleWithPath:[NSString pathWithComponents:containerPathComponents]];
        } else {
            containerBundle = nil;
        }
    }
    
    return containerBundle;
}

@end
