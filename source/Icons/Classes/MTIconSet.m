/*
     MTIconSet.m
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

#import "MTIconSet.h"
#import "Constants.h"

@implementation MTIconSet

- (void)uninstallAPNGWithCompletionHandler:(void (^) (NSData *imageData))completionHandler
{
    NSData *imageData = nil;
    
    if ([_uninstallIcon isValid] && _animationDuration > 0) {
    
        // define the actual animation
        NSArray *rotationPath = [NSArray arrayWithObjects:
                                 [NSNumber numberWithFloat:0.0],
                                 [NSNumber numberWithFloat:-1.0],
                                 [NSNumber numberWithFloat:-2.0],
                                 [NSNumber numberWithFloat:-1.0],
                                 [NSNumber numberWithFloat:0.0],
                                 [NSNumber numberWithFloat:1.0],
                                 [NSNumber numberWithFloat:2.0],
                                 [NSNumber numberWithFloat:1.0],
                                 nil];
        
        // define the loop
        NSDictionary *fileProperties = [NSDictionary dictionaryWithObject:
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:0], (__bridge NSString*)kCGImagePropertyAPNGLoopCount,
                                         nil]
                                                                   forKey:(__bridge NSString*)kCGImagePropertyPNGDictionary];
        
        // define the delay between the frames
        CGFloat delayTime = _animationDuration / [rotationPath count];
        NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:
                                         [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithFloat:delayTime], (__bridge NSString*)kCGImagePropertyAPNGDelayTime,
                                          nil]
                                                                    forKey:(__bridge NSString*)kCGImagePropertyPNGDictionary];
        
        CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, 0);
        
        if (data) {
            CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData(
                                                                                      data,
                                                                                      kUTTypePNG,
                                                                                      [rotationPath count],
                                                                                      (__bridge CFDictionaryRef)fileProperties
                                                                                      );
            
            if (imageDestination) {
                
                CGImageDestinationSetProperties(imageDestination, NULL);
                
                for (NSNumber *degrees in rotationPath) {
                    NSImage *rotatedImage = [_uninstallIcon imageRotatedByDegrees:[degrees floatValue]];
                    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)[rotatedImage TIFFRepresentation], NULL);
                    
                    if (imageSource) {
                        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
                        CGImageDestinationAddImage(imageDestination, imageRef, (__bridge CFDictionaryRef)frameProperties);
                        CGImageRelease(imageRef);
                        CFRelease(imageSource);
                    }
                }
                
                if  (CGImageDestinationFinalize(imageDestination)) {
                    imageData = (__bridge NSData *)(data);
                }
                
                CFRelease(imageDestination);
            }
            
            CFRelease(data);
        }
    }

    if (completionHandler) { completionHandler(imageData); }
}

+ (NSString*)createFolderAtPath:(NSString*)path
                     folderName:(NSString*)folderName
                appendTimestamp:(BOOL)timestamp
{
    NSString *folderPath = nil;
    
    if (path && folderName) {
        
        if (timestamp) {
            
            // create a timestamp for the folder
            NSDateFormatter *dateformate = [[NSDateFormatter alloc] init];
            [dateformate setDateFormat:@"yyyy-MM-dd HH-mm-ss.SSS"];
            NSString *dateString = [dateformate stringFromDate:[NSDate date]];
            folderName = [folderName stringByAppendingString:dateString];
        }
        
        path = [path stringByAppendingPathComponent:folderName];
        
        // create the folder
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:nil];
        if (success) { folderPath = path; }
    }
    
    return folderPath;
}

- (void)writeToFolder:(NSString *)path
         createFolder:(BOOL)createFolder
    completionHandler:(void (^) (BOOL success, NSString* path, NSError *error))completionHandler
{
    BOOL success = YES;
    NSString *folderPath = path;
    __block NSError *error = nil;
        
    if (createFolder) {
        
        folderPath = [MTIconSet createFolderAtPath:path
                                        folderName:@"icons_"
                                   appendTimestamp:YES
        ];
        if (!folderPath) { success = NO; }
    }
    
    if (success) {
        
        error = [NSError errorWithDomain:NSOSStatusErrorDomain code:writErr userInfo:nil];
        
        // save the install image
        if ([_installIcon isValid]) {
            success = [[_installIcon pngData] writeToFile:[folderPath stringByAppendingPathComponent:kMTFileNameInstall] atomically:YES];
        }
        
        // save the uninstall image
        if (success && [_uninstallIcon isValid]) {
            success = [[_uninstallIcon pngData] writeToFile:[folderPath stringByAppendingPathComponent:kMTFileNameUninstall] atomically:YES];
            
            if (success) {
                    
                if (_animationDuration > 0) {
                
                    // save the animated uninstall image
                    [self uninstallAPNGWithCompletionHandler:^(NSData *imageData) {
                        
                        BOOL success = [imageData writeToFile:[folderPath stringByAppendingPathComponent:kMTFileNameUninstallAnimated] atomically:YES];
                    
                        if (completionHandler) {
                            if (success) { error = [NSError errorWithDomain:NSOSStatusErrorDomain code:noErr userInfo:nil]; }
                            completionHandler(success, folderPath, error);
                        }
                    }];
                
                } else {
                    if (completionHandler) { completionHandler(success, folderPath, error); }
                }
                
            } else {
                if (completionHandler) { completionHandler(success, folderPath, error); }
            }
        }
        
    } else {
        if (completionHandler) { completionHandler(success, folderPath, error); }
    }
}

@end
