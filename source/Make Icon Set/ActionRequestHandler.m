/*
     ActionRequestHandler.m
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

#import "ActionRequestHandler.h"
#import "MTInstallIconView.h"
#import "MTUninstallIconView.h"
#import "MTIconSet.h"
#import "Constants.h"
#import <UniformTypeIdentifiers/UTCoreTypes.h>

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
                                completionHandler:^(__kindof id<NSSecureCoding>  item, NSError *error) {

                if (item) {

                    NSURL *inputFileURL = (NSURL*)item;
                    
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
        
        NSImage *sourceImage = [NSImage imageWithFileAtURL:url];
           
        if ([sourceImage isValid]) {
                        
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
            BOOL useDefaultSettings = [userDefaults boolForKey:kMTDefaultsExtensionDefaultSettingsKey];
            
            NSDictionary *defaultSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInteger:kMTOutputSizeDefault], kMTDefaultsOutputSizeKey,
                                             [NSNumber numberWithDouble:kMTAnimationDurationDefault], kMTDefaultsAnimationDurationKey,
                                             [NSNumber numberWithBool:YES], kMTDefaultsAutoImageSizeKey,
                                             [NSNumber numberWithBool:YES], kMTDefaultsAutoOutputSizeKey,
                                             [NSNumber numberWithFloat:kMTBannerTextMarginDefault], kMTDefaultsTextMarginDefaultKey,
                                             [NSNumber numberWithBool:YES], kMTDefaultsSaveInstallIconKey,
                                             [NSNumber numberWithBool:YES], kMTDefaultsSaveUninstallIconKey,
                                             [NSNumber numberWithBool:YES], kMTDefaultsSaveAnimatedUninstallIconKey,
                                             nil
                                             ];
            [userDefaults registerDefaults:defaultSettings];
            
            // get the source image's shortest side and calculate
            // the maximum size of the output image
            NSBitmapImageRep *sourceImageRep = [[NSBitmapImageRep alloc] initWithData:[sourceImage TIFFRepresentation]];
            NSInteger imageSize = ([sourceImageRep pixelsWide] >= [sourceImageRep pixelsHigh]) ? [sourceImageRep pixelsWide] : [sourceImageRep pixelsHigh];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                // create the install icon
                MTInstallIconView *installIconView = nil;
                
                if (useDefaultSettings || [userDefaults boolForKey:kMTDefaultsSaveInstallIconKey]) {
                    
                    installIconView = [[MTInstallIconView alloc] initWithFrame:NSMakeRect(0, 0, imageSize, imageSize)];
                    [installIconView setImage:sourceImage];
                    
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
                                
                                if ([bannerDict objectForKey:kMTDefaultsBannerTextMarginKey]) {
                                    
                                    [installIconView setBannerTextMargin:[[bannerDict valueForKey:kMTDefaultsBannerTextMarginKey] floatValue]];
                                    
                                } else {
                                    
                                    [installIconView setBannerTextMargin:[userDefaults floatForKey:kMTDefaultsTextMarginDefaultKey]];
                                }
                            }
                        }
                    }
                }
                
                // create the uninstall icon
                CGFloat animationDuration = 0;
                MTUninstallIconView *uninstallIconView = nil;
                
                if (useDefaultSettings || [userDefaults boolForKey:kMTDefaultsSaveUninstallIconKey] || [userDefaults boolForKey:kMTDefaultsSaveAnimatedUninstallIconKey]) {
                    
                    uninstallIconView = [[MTUninstallIconView alloc] initWithFrame:NSMakeRect(0, 0, imageSize, imageSize)];
                    [uninstallIconView setImage:sourceImage];
                    
                    // calculate inset (if enabled)
                    if (useDefaultSettings || [userDefaults boolForKey:kMTDefaultsAutoImageSizeKey]) {
                        [uninstallIconView setImageInset:[uninstallIconView autoInset]];
                    } else {
                        [uninstallIconView setImageInset:[userDefaults floatForKey:kMTDefaultsImageSizeAdjustmentKey]];
                    }
                    
                    // get the animation duration
                    animationDuration = (useDefaultSettings) ? kMTAnimationDurationDefault : [userDefaults floatForKey:kMTDefaultsAnimationDurationKey];
                    animationDuration = (animationDuration >= kMTAnimationDurationMin && animationDuration <= kMTAnimationDurationMax) ? animationDuration : kMTAnimationDurationDefault;
                }
                
                // calculate output size
                NSSize outputSize = NSZeroSize;
                
                if (useDefaultSettings || [userDefaults boolForKey:kMTDefaultsAutoOutputSizeKey]) {
                    
                    // auto size
                    for (NSNumber *anOutputSize in [kMTOutputSizes reverseObjectEnumerator]) {
                        NSSize tempOutputSize = NSMakeSize([anOutputSize floatValue], [anOutputSize floatValue]);
                        BOOL canBeScaled = [sourceImage canBeScaledToSize:tempOutputSize];
                            
                        if (canBeScaled) {
                            outputSize = tempOutputSize;
                            break;
                        }
                    }
                    
                } else {
                    
                    NSInteger imageOutputSize = [userDefaults integerForKey:kMTDefaultsOutputSizeKey];
                    if (![kMTOutputSizes containsObject:[NSNumber numberWithInteger:imageOutputSize]]) { imageOutputSize = kMTOutputSizeDefault; }
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
