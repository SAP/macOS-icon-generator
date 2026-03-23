/*
    MTGroupDefaults.m
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

#import "MTGroupDefaults.h"
#import "Constants.h"

@implementation MTGroupDefaults

+ (NSUserDefaults *)sharedDefaults
{
    static NSUserDefaults *sharedDefaults = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
        
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
                                         [NSNumber numberWithFloat:kMTBannerAngleDefault], kMTDefaultsBannerAngleDefaultKey,
                                         [NSNumber numberWithFloat:kMTBannerHeightDefault], kMTDefaultsBannerHeightDefaultKey,
                                         [NSNumber numberWithFloat:kMTBannerMarginDefault], kMTDefaultsBannerMarginDefaultKey,
                                         [NSNumber numberWithInteger:kMTBadgeShadowColorDefault], kMTDefaultsBadgeIconShadowColorKey,
                                         [NSNumber numberWithDouble:kMTBadgeShadowAngleDefault], kMTDefaultsBadgeIconShadowAngleKey,
                                         [NSNumber numberWithDouble:kMTBadgeShadowOffsetDefault], kMTDefaultsBadgeIconShadowOffsetKey,
                                         [NSNumber numberWithDouble:kMTBadgeShadowRadiusDefault], kMTDefaultsBadgeIconShadowRadiusKey,
                                         [NSNumber numberWithDouble:kMTBadgeIconSizeDefault], kMTDefaultsBadgeIconSizeKey,
                                         [NSNumber numberWithDouble:kMTBadgeIconMarginDefault], kMTDefaultsBadgeIconMarginKey,
                                         [NSNumber numberWithBool:YES], kMTDefaultsBadgeIconAddShadowKey,
                                         nil
                                         ];
        
        [sharedDefaults registerDefaults:defaultSettings];
    });
    
    return sharedDefaults;
}

+ (NSUserDefaultsController *)sharedDefaultsController
{
    static NSUserDefaultsController *controller = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        controller = [[NSUserDefaultsController alloc] initWithDefaults:[self sharedDefaults] initialValues:nil];
    });
    
    return controller;
}

@end
