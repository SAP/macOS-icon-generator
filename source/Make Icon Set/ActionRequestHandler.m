/*
     ActionRequestHandler.m
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

#import "ActionRequestHandler.h"
#import "MTInstallIconView.h"
#import "MTUninstallIconView.h"
#import "MTIconSet.h"
#import "Constants.h"

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
        
            [attachment loadItemForTypeIdentifier:(NSString *)kUTTypeItem
                                          options:nil
                                completionHandler:^(__kindof id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {

                if (item) {

                    NSURL *inputFileURL = (NSURL*)item;
                    NSImage *sourceImage = [NSImage imageWithFileAtPath:[inputFileURL path]];

                    if ([sourceImage isValid]) {
                       
                        // get a path to write our files to
                        NSURL *itemReplacementDirectory = [[NSFileManager defaultManager] URLForDirectory:NSItemReplacementDirectory
                                                                                                 inDomain:NSUserDomainMask
                                                                                        appropriateForURL:[NSURL fileURLWithPath:NSHomeDirectory()]
                                                                                                   create:YES
                                                                                                    error:nil
                        ];
                        
                        dispatch_group_enter(self->_attachmentsGroup);
                        
                        [self createIconSetFromImage:sourceImage
                                          outputPath:[itemReplacementDirectory path]
                                   completionHandler:^(BOOL success, NSString *path, NSError *error) {
                            
                            if (success) {
                                
                                NSItemProvider *itemProvider = [[NSItemProvider alloc] init];
                                [itemProvider registerFileRepresentationForTypeIdentifier:(NSString *)kUTTypeFolder
                                                                              fileOptions:NSItemProviderFileOptionOpenInPlace
                                                                               visibility:NSItemProviderRepresentationVisibilityAll
                                                                              loadHandler:^NSProgress * _Nullable(void (^ _Nonnull completionHandler)(NSURL * _Nullable, BOOL, NSError * _Nullable)) {
                                    completionHandler([NSURL fileURLWithPath:path], NO, nil);
                                    return nil;
                                }];
                                
                                [outputAttachments addObject:itemProvider];
                            }
                            
                            dispatch_group_leave(self->_attachmentsGroup);
                            
                        }];
                
                    }
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

- (void)createIconSetFromImage:(NSImage*)sourceImage
                    outputPath:(NSString*)outputFolderPath
             completionHandler:(void (^) (BOOL success, NSString *path, NSError *error))completionHandler
{
    if ([sourceImage isValid]) {
        
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
        NSDictionary *defaultSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:kMTOutputSizeDefault], kMTDefaultsOutputSize,
                                         [NSNumber numberWithDouble:kMTAnimationDurationDefault], kMTDefaultsAnimationDuration,
                                         [NSNumber numberWithBool:YES], kMTDefaultsAutoImageSize,
                                         [NSNumber numberWithBool:YES], kMTDefaultsAutoOutputSize,
                                         nil
                                         ];
        [userDefaults registerDefaults:defaultSettings];

        // get the source image's shortest side and calculate
        // the maximum output image size
        NSBitmapImageRep *sourceImageRep = [[NSBitmapImageRep alloc] initWithData:[sourceImage TIFFRepresentation]];
        NSInteger imageSize = ([sourceImageRep pixelsWide] >= [sourceImageRep pixelsHigh]) ? [sourceImageRep pixelsWide] : [sourceImageRep pixelsHigh];

        dispatch_async(dispatch_get_main_queue(), ^{
                       
            // create the install icon
            MTInstallIconView *installIconView = [[MTInstallIconView alloc] initWithFrame:NSMakeRect(0, 0, imageSize, imageSize)];
            [installIconView setImage:sourceImage];
            
            // create the uninstall icon
            MTUninstallIconView *uninstallIconView = [[MTUninstallIconView alloc] initWithFrame:NSMakeRect(0, 0, imageSize, imageSize)];
            [uninstallIconView setImage:sourceImage];
            
            // get the animation duration
            CGFloat animationDuration = [userDefaults floatForKey:kMTDefaultsAnimationDuration];
            animationDuration = (animationDuration >= kMTAnimationDurationMin && animationDuration <= kMTAnimationDurationMax) ? animationDuration : kMTAnimationDurationDefault;
            
            // calculate output size
            NSSize outputSize = NSZeroSize;
            
            if (![userDefaults boolForKey:kMTDefaultsAutoOutputSize]) {
                
                NSInteger imageOutputSize = [userDefaults integerForKey:kMTDefaultsOutputSize];
                if (![kMTOutputSizes containsObject:[NSNumber numberWithInteger:imageOutputSize]]) { imageOutputSize = kMTOutputSizeDefault; }
                outputSize = NSMakeSize(imageOutputSize, imageOutputSize);
                
            } else {
                
                // auto size
                for (NSNumber *anOutputSize in [kMTOutputSizes reverseObjectEnumerator]) {
                    NSSize tempOutputSize = NSMakeSize([anOutputSize floatValue], [anOutputSize floatValue]);
                    BOOL canBeScaled = [sourceImage canBeScaledToSize:tempOutputSize];
                        
                    if (canBeScaled) {
                        outputSize = tempOutputSize;
                        break;
                    }
                }
            }
            
            // calculate inset (if enabled)
            if ([userDefaults boolForKey:kMTDefaultsAutoImageSize]) {
                [uninstallIconView setImageInset:[uninstallIconView autoInset]];
            }
    
            // create the icon files
            MTIconSet *iconSet = [[MTIconSet alloc] init];
            [iconSet setInstallIcon:[NSImage imageWithView:[installIconView icon] size:outputSize]];
            [iconSet setUninstallIcon:[NSImage imageWithView:[uninstallIconView icon] size:outputSize]];
            [iconSet setAnimationDuration:animationDuration];
            
            [iconSet writeToFolder:outputFolderPath
                      createFolder:YES
                 completionHandler:^(BOOL success, NSString *path, NSError *error) {
                if (completionHandler) { completionHandler(success, path, error); }
            }];
       });
        
    } else {
        
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:paramErr userInfo:nil];
        if (completionHandler) { completionHandler(NO, nil, error); }
    }
}

@end
