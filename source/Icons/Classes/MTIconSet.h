/*
     MTIconSet.h
     Copyright 2022-2024 SAP SE
     
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

#import <Foundation/Foundation.h>
#import "MTImage.h"

@interface MTIconSet : NSObject

/*!
 @property      animationDuration
 @abstract      The duration for the animated uninstall image's animation.
 @discussion    The value of this property is a float value, specifying the duration of the animation.
 */
@property (assign) CGFloat animationDuration;

/*!
 @property      fileNamePrefix
 @abstract      The prefix that should be used for the icon files.
 @discussion    The value of this property is NSString.
 */
@property (nonatomic, strong, readwrite) NSString *fileNamePrefix;

/*!
 @property      installIcon
 @abstract      An image representing the install icon.
 @discussion    The value of this property is a NSImage object. May be nil.
*/
@property (nonatomic, strong, readwrite) NSImage *installIcon;

/*!
 @property      uninstallIcon
 @abstract      An image representing the uninstall icon.
 @discussion    The value of this property is a NSImage object. May be nil.
*/
@property (nonatomic, strong, readwrite) NSImage *uninstallIcon;

/*!
 @method        createFolderAtPath:folderName:appendTimestamp:
 @abstract      Create a folder at the given path and include an optional timestamp.
 @param         path A path string identifying the directory where to create the new folder.
 @param         folderName A string containing the name of the folder to create.
 @param         timestamp A boolean value specifying if a timestamp should be added to the folder name.
 @discussion    Returns a NSString object containing the path string of the created folder or nil, if an error occurred.
 */
+ (NSString*)createFolderAtPath:(NSString*)path
                     folderName:(NSString*)folderName
                appendTimestamp:(BOOL)timestamp;

/*!
 @method        writeToFolder:createFolder:completionHandler:
 @abstract      Write the icon set (install, uninstall and animated uninstall icon) to file.
 @param         path The path where the images should be created at.
 @param         createFolder If set to YES, a folder (containing the images) is created at the given path.
 @param         animatedOnly If set to YES and a valid uninstall image is set, only the animated version of the uninstall
                image is written and the regular uninstall image is skipped.
 @param         completionHandler The completion handler to call when the request is complete.
 @discussion    Returns a boolean indicating if the request was successful, the path where the images have been actually
                created and a NSError object containing the underlying error if the request failed.
 */
- (void)writeToFolder:(NSString *)path
         createFolder:(BOOL)createFolder
         animatedOnly:(BOOL)animatedOnly
    completionHandler:(void (^) (BOOL success, NSString* path, NSError *error))completionHandler;

/*!
 @method        fileNamePrefixWithString:
 @abstract      Returns the given string but removes charactes not allowed in file names.
 @param         prefix A string specifying the prefix that should be used.
 @discussion    Returns a NSString object containing a given string, but with invalid characters removed.
 */
+ (NSString*)fileNamePrefixWithString:(NSString*)prefix;

@end
