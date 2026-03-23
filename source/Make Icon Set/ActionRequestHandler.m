/*
    ActionRequestHandler.m
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

#import "ActionRequestHandler.h"
#import "MTInstallIconView.h"
#import "MTUninstallIconView.h"
#import "MTIconSet.h"
#import "Constants.h"
#import "MTColorValueTransformer.h"
#import <UniformTypeIdentifiers/UTCoreTypes.h>
#import <os/log.h>

@interface ActionRequestHandler ()
@property (nonatomic, strong, readwrite) dispatch_group_t attachmentsGroup;
@end

@implementation ActionRequestHandler

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context
{
    if ([[context inputItems] count] == 1) {
        
        NSExtensionItem *inputItem = [[context inputItems] firstObject];
        NSArray *inputAttachments = [inputItem attachments];
        
        _attachmentsGroup = dispatch_group_create();
        
        // the outputAttachments array must contain our input
        // attachments otherwise the input item would be deleted
        // after the action has been finished running.
        NSMutableArray *outputAttachments = [NSMutableArray arrayWithArray:inputAttachments];
        
        for (NSItemProvider *attachment in inputAttachments) {
            
            dispatch_group_enter(_attachmentsGroup);
        
            [attachment loadItemForTypeIdentifier:[UTTypeItem identifier]
                                          options:nil
                                completionHandler:^(NSURL *inputFileURL, NSError *error) {

                if (inputFileURL) {
                    
                    // get a path to write our files to
                    NSURL *itemReplacementDirectory = [[NSFileManager defaultManager] URLForDirectory:NSItemReplacementDirectory
                                                                                             inDomain:NSUserDomainMask
                                                                                    appropriateForURL:[NSURL fileURLWithPath:NSHomeDirectory()]
                                                                                               create:YES
                                                                                                error:nil
                    ];
                    
                    dispatch_group_enter(self->_attachmentsGroup);
                        
                    [self createIconSetFromImageAtURL:inputFileURL
                                           outputPath:[itemReplacementDirectory path]
                                    completionHandler:^(BOOL success, NSString *path, NSError *error) {
                            
                        if (success) {
                            
                            NSItemProvider *itemProvider = [[NSItemProvider alloc] init];
                            [itemProvider registerFileRepresentationForTypeIdentifier:[UTTypeFolder identifier]
                                                                          fileOptions:NSItemProviderFileOptionOpenInPlace
                                                                           visibility:NSItemProviderRepresentationVisibilityAll
                                                                          loadHandler:^NSProgress *(void (^ completionHandler)(NSURL *, BOOL, NSError *)) {
                                completionHandler([NSURL fileURLWithPath:path], NO, nil);
                                return nil;
                            }];
                            
                            [outputAttachments addObject:itemProvider];
                        }
                        
                        dispatch_group_leave(self->_attachmentsGroup);
                        
                    }];
                }
                
                dispatch_group_leave(self->_attachmentsGroup);
            }];
        }
        
        dispatch_group_notify(_attachmentsGroup, dispatch_get_main_queue(), ^{
            
            NSExtensionItem *outputItem = [[NSExtensionItem alloc] init];
            [outputItem setAttachments:outputAttachments];
            [context completeRequestReturningItems:[NSArray arrayWithObject:outputItem] completionHandler:nil];
        });
        
    } else {
        
        [context cancelRequestWithError:[NSError errorWithDomain:NSCocoaErrorDomain
                                                            code:NSFileReadUnknownError
                                                        userInfo:nil]];
    }
}

- (void)createIconSetFromImageAtURL:(NSURL*)url
                         outputPath:(NSString*)outputFolderPath
                  completionHandler:(void (^) (BOOL success, NSString *path, NSError *error))completionHandler
{
    if (url && [url isFileURL]) {
        
        NSImage *image = [NSImage imageWithFileAtURL:url];
           
        if ([image isValid]) {
                                    
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
            BOOL useDefaultSettings = [userDefaults boolForKey:kMTDefaultsExtensionDefaultSettingsKey];
            
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
            [userDefaults registerDefaults:defaultSettings];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                BOOL isApplicationBundle = YES;

                if (!useDefaultSettings && [userDefaults boolForKey:kMTDefaultsRenderImagesInIconShapeKey]) {
                    
                    id utiValue = nil;
                    [url getResourceValue:&utiValue forKey:NSURLTypeIdentifierKey error:nil];
                    isApplicationBundle = [utiValue isEqualTo:[UTTypeApplicationBundle identifier]];
                }
                
                // create the install icon
                MTInstallIconView *installIconView = nil;
                
                if (useDefaultSettings || [userDefaults boolForKey:kMTDefaultsSaveInstallIconKey]) {
                    
                    installIconView = [[MTInstallIconView alloc] initWithFrame:NSMakeRect(0, 0, kMTOutputSizeMax, kMTOutputSizeMax)];
                    [installIconView setApplyIconShape:(isApplicationBundle) ? NO : [userDefaults boolForKey:kMTDefaultsRenderImagesInIconShapeKey]];
                    [installIconView setUsesOldIconShape:[userDefaults boolForKey:kMTDefaultsUseOldIconShapeKey]];
                    [installIconView setDrawBannerInIconShape:(!isApplicationBundle && [userDefaults boolForKey:kMTDefaultsDrawBannerInIconShapeKey])];
                    [installIconView setImage:image];
                    
                    NSArray *savedBanners = [userDefaults objectForKey:kMTDefaultsSavedBannersKey];

                    if (!useDefaultSettings && savedBanners) {
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"IsDefault == %@", [NSNumber numberWithBool:YES]];
                        NSArray *filteredBanners = [savedBanners filteredArrayUsingPredicate:predicate];
                        
                        if ([filteredBanners count] > 0) {
                            
                            NSDictionary *bannerDict = [filteredBanners firstObject];
                            NSData *bannerData = [bannerDict objectForKey:kMTDefaultsBannerDataKey];
                            
                            if (bannerData) {
                                
                                NSAttributedString *bannerText = [[NSAttributedString alloc] initWithRTF:bannerData
                                                                                      documentAttributes:nil
                                ];
                                [installIconView setBannerAttributes:bannerText];
                                [installIconView setBannerPosition:(MTBannerPosition)[[bannerDict valueForKey:kMTDefaultsBannerPositionKey] integerValue]];
                                
                                // If the banner was saved with an older version of the application that does
                                // not support one or more of the following attributes, we will use the default
                                // values to make sure the banner looks the same as in the old version.
                                CGFloat textMargin = kMTBannerTextMarginDefault;
                                CGFloat bannerAngle = kMTBannerAngleDefault;
                                CGFloat bannerHeight = kMTBannerHeightDefault;
                                CGFloat bannerMargin = kMTBannerMarginDefault;
                                
                                if ([bannerDict objectForKey:kMTDefaultsBannerTextMarginKey]) { textMargin = [[bannerDict valueForKey:kMTDefaultsBannerTextMarginKey] floatValue]; }
                                if ([bannerDict objectForKey:kMTDefaultsBannerAngleKey]) { bannerAngle = [[bannerDict valueForKey:kMTDefaultsBannerAngleKey] floatValue]; }
                                if ([bannerDict objectForKey:kMTDefaultsBannerHeightKey]) { bannerHeight = [[bannerDict valueForKey:kMTDefaultsBannerHeightKey] floatValue]; }
                                if ([bannerDict objectForKey:kMTDefaultsBannerMarginKey]) { bannerMargin = [[bannerDict valueForKey:kMTDefaultsBannerMarginKey] floatValue]; }
                                    
                                [installIconView setBannerTextMargin:textMargin];
                                [installIconView setBannerAngle:bannerAngle];
                                [installIconView setBannerHeight:bannerHeight];
                                [installIconView setBannerMargin:bannerMargin];
                            }
                        }
                    }
                }
                
                // create the uninstall icon
                CGFloat animationDuration = 0;
                MTUninstallIconView *uninstallIconView = nil;
                
                if (useDefaultSettings || [userDefaults boolForKey:kMTDefaultsSaveUninstallIconKey] || [userDefaults boolForKey:kMTDefaultsSaveAnimatedUninstallIconKey]) {
                    
                    uninstallIconView = [[MTUninstallIconView alloc] initWithFrame:NSMakeRect(0, 0, kMTOutputSizeMax, kMTOutputSizeMax)];
                    [uninstallIconView setApplyIconShape:(isApplicationBundle) ? NO : [userDefaults boolForKey:kMTDefaultsRenderImagesInIconShapeKey]];
                    [uninstallIconView setUsesOldIconShape:[userDefaults boolForKey:kMTDefaultsUseOldIconShapeKey]];
                    [uninstallIconView setImage:image];
                    
                    // calculate inset (if enabled)
                    if (useDefaultSettings || [userDefaults boolForKey:kMTDefaultsAutoImageSizeKey]) {
                        [uninstallIconView setImageInset:[uninstallIconView autoInset]];
                    } else {
                        [uninstallIconView setImageInset:[userDefaults floatForKey:kMTDefaultsImageSizeAdjustmentKey]];
                    }
                    
                    // badge
                    NSImage *deleteBadgeImage = nil;
                    
                    if (!useDefaultSettings) {
                        
                        NSData *sfSymbol = [userDefaults objectForKey:kMTDefaultsDeleteBadgeSFSymbolKey];
                        
                        if (sfSymbol) {
                            
                            deleteBadgeImage = [[NSImage alloc] initWithData:sfSymbol];
                            
                        } else {
                            
                            NSData *bookmarkData = [userDefaults objectForKey:kMTDefaultsDeleteBadgeIconBookmarkKey];
                            
                            BOOL stale = NO;
                            NSError *error = nil;
                            
                            NSURL *deleteBadgeURL = [NSURL URLByResolvingBookmarkData:bookmarkData
                                                                              options:0
                                                                        relativeToURL:nil
                                                                  bookmarkDataIsStale:&stale
                                                                                error:&error
                            ];
                            
                            if (deleteBadgeURL) {
                                
                                if ([deleteBadgeURL startAccessingSecurityScopedResource]) {
                                    
                                    deleteBadgeImage = [[NSImage alloc] initWithContentsOfURL:deleteBadgeURL];
                                    [deleteBadgeURL stopAccessingSecurityScopedResource];
                                    
                                } else {
                                    os_log_error(OS_LOG_DEFAULT, "SAPCorp: Failed to access delete badge url %{public}@", deleteBadgeURL);
                                }
                                
                            } else {
                                os_log_error(OS_LOG_DEFAULT, "SAPCorp: Failed to get delete badge url: %{public}@", error);
                            }
                        }
                    }
                    
                    MTDeleteBadgeView *deleteBadge = [[MTDeleteBadgeView alloc] initWithFrame:[uninstallIconView bounds]];
                    
                    if ([deleteBadgeImage isValid]) {
                        
                        // get the badge shadow color
                        MTColorValueTransformer *valueTransformer = [[MTColorValueTransformer alloc] init];
                        NSNumber *transformedBannerColor = [userDefaults objectForKey:kMTDefaultsBadgeIconShadowColorKey];
                        NSColor *badgeShadowColor = [valueTransformer transformedValue:transformedBannerColor];
                        
                        CGFloat badgeSize = [userDefaults floatForKey:kMTDefaultsBadgeIconSizeKey];
                        CGFloat clampedBadgeSize = fminf(fmaxf(badgeSize, kMTBadgeIconSizeMin), kMTBadgeIconSizeMax);
                        if (fabs(badgeSize - clampedBadgeSize) > FLT_EPSILON) { [userDefaults setFloat:clampedBadgeSize forKey:kMTDefaultsBadgeIconSizeKey]; }
                        [uninstallIconView setBadgeSize:clampedBadgeSize];
                        
                        CGFloat badgeMargin = [userDefaults floatForKey:kMTDefaultsBadgeIconMarginKey];
                        CGFloat clampedBadgeMargin = fminf(fmaxf(badgeMargin, kMTBadgeIconMarginMin), kMTBadgeIconMarginMax);
                        if (fabs(badgeMargin - clampedBadgeMargin) > FLT_EPSILON) { [userDefaults setFloat:clampedBadgeMargin forKey:kMTDefaultsBadgeIconMarginKey]; }
                        [uninstallIconView setBadgeMargin:clampedBadgeMargin];
                        
                        CGFloat badgeShadowRadius = [userDefaults floatForKey:kMTDefaultsBadgeIconShadowRadiusKey];
                        CGFloat clampedRadius = fminf(fmaxf(badgeShadowRadius, kMTBadgeShadowRadiusMin), kMTBadgeShadowRadiusMax);
                        if (fabs(badgeShadowRadius - clampedRadius) > FLT_EPSILON) { [userDefaults setFloat:clampedRadius forKey:kMTDefaultsBadgeIconShadowRadiusKey]; }
                        
                        CGFloat badgeShadowOffset = [userDefaults floatForKey:kMTDefaultsBadgeIconShadowOffsetKey];
                        CGFloat clampedOffset = fminf(fmaxf(badgeShadowOffset, kMTBadgeShadowOffsetMin), kMTBadgeShadowOffsetMax);
                        if (fabs(badgeShadowOffset - clampedOffset) > FLT_EPSILON) { [userDefaults setFloat:clampedOffset forKey:kMTDefaultsBadgeIconShadowOffsetKey]; }
                        
                        CGFloat badgeShadowAngle = [userDefaults floatForKey:kMTDefaultsBadgeIconShadowAngleKey];
                        CGFloat clampedAngle = fminf(fmaxf(badgeShadowAngle, kMTBadgeShadowAngleMin), kMTBadgeShadowAngleMax);
                        if (fabs(badgeShadowAngle - clampedAngle) > FLT_EPSILON) { [userDefaults setFloat:clampedAngle forKey:kMTDefaultsBadgeIconShadowAngleKey]; }
                        
                        [deleteBadge setImage:deleteBadgeImage];
                        [deleteBadge setShowsShadow:[userDefaults boolForKey:kMTDefaultsBadgeIconAddShadowKey]];
                        [deleteBadge setShadowRadius:clampedRadius];
                        [deleteBadge setShadowOffset:clampedOffset];
                        [deleteBadge setShadowAngle:clampedAngle];
                        [deleteBadge setShadowColor:badgeShadowColor];
                        
                        [uninstallIconView setBadgePosition:(MTBadgePosition)[userDefaults integerForKey:kMTDefaultsBadgePositionDefaultKey]];
                    }
                        
                    [uninstallIconView setDeleteBadge:deleteBadge];
                                        
                    // get the animation duration
                    animationDuration = (useDefaultSettings) ? kMTAnimationDurationDefault : [userDefaults floatForKey:kMTDefaultsAnimationDurationKey];
                    animationDuration = fminf(fmaxf(animationDuration, kMTAnimationDurationMin), kMTAnimationDurationMax);
                }
                
                // calculate output size
                NSSize outputSize = NSZeroSize;
                
                if (useDefaultSettings || [userDefaults boolForKey:kMTDefaultsAutoOutputSizeKey]) {
                    
                    // auto size
                    for (NSNumber *anOutputSize in [kMTOutputSizes reverseObjectEnumerator]) {
                        NSSize tempOutputSize = NSMakeSize([anOutputSize floatValue], [anOutputSize floatValue]);
                        BOOL canBeScaled = [image canBeScaledToSize:tempOutputSize];
                            
                        if (canBeScaled) {
                            outputSize = tempOutputSize;
                            break;
                        }
                    }
                    
                } else {
                    
                    NSInteger imageOutputSize = [userDefaults integerForKey:kMTDefaultsOutputSizeKey];
                    if (![kMTOutputSizes containsObject:[NSNumber numberWithInteger:imageOutputSize]]) { imageOutputSize = kMTOutputSizeDefault; }
                    imageOutputSize = fminf(fmaxf(imageOutputSize, kMTOutputSizeMin), kMTOutputSizeMax);
                    outputSize = NSMakeSize(imageOutputSize, imageOutputSize);
                }
                
                NSString *fileNamePrefix = nil;
                
                if (!useDefaultSettings && [userDefaults boolForKey:kMTDefaultsUsePrefixKey]) {
                    
                    // get the prefix
                    fileNamePrefix = [userDefaults stringForKey:kMTDefaultsUserDefinedPrefixKey];
                    if (!fileNamePrefix) { fileNamePrefix = [[url lastPathComponent] stringByDeletingPathExtension]; }
                }
                        
                // create the icon files
                MTIconSet *iconSet = [[MTIconSet alloc] init];
                [iconSet setInstallIcon:[NSImage imageWithView:[installIconView icon] size:outputSize]];
                [iconSet setUninstallIcon:[NSImage imageWithView:[uninstallIconView icon] size:outputSize]];
                [iconSet setAnimationDuration:(useDefaultSettings || [userDefaults boolForKey:kMTDefaultsSaveAnimatedUninstallIconKey]) ? animationDuration : 0];
                [iconSet setFileNamePrefix:fileNamePrefix];

                [iconSet writeToFolder:outputFolderPath
                          createFolder:YES
                          animatedOnly:!(useDefaultSettings || [userDefaults boolForKey:kMTDefaultsSaveUninstallIconKey])
                     completionHandler:^(BOOL success, NSString *path, NSError *error) {
                    
                    if (completionHandler) { completionHandler(success, path, error); }
                }];
           });
            
        } else {
            
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:paramErr userInfo:nil];
            if (completionHandler) { completionHandler(NO, nil, error); }
        }
        
    } else {
        
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:paramErr userInfo:nil];
        if (completionHandler) { completionHandler(NO, nil, error); }
    }
}

@end
