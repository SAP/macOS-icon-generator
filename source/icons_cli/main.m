/*
     main.m
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

#import <Foundation/Foundation.h>
#import "MTInstallIconView.h"
#import "MTUninstallIconView.h"
#import "MTIconSet.h"
#import "MTColor.h"
#import "MTAttributedString.h"
#import "Constants.h"
#import "closebox.pdf.h"

void printUsage(void)
{
    fprintf(stderr, "\nUsage: icons_cli [options] -i <path> -o <path>\n\n");
    fprintf(stderr, "  -d <number>       The duration of the animation in seconds (defaults to\n");
    fprintf(stderr, "                    %.1f, maximum is %.1f). Setting the duration to 0 disables\n", kMTAnimationDurationDefault, kMTAnimationDurationMax);
    fprintf(stderr, "                    the creation of an animated icon.\n\n");
    fprintf(stderr, "  -s <size>         The size of the output image in pixels (maximum is %d).\n", kMTOutputSizeMax);
    fprintf(stderr, "                    If not provided or if the provided size is invalid, the\n");
    fprintf(stderr, "                    app calculates the best possible output size based on \n");
    fprintf(stderr, "                    the size of the source image.\n\n");
    fprintf(stderr, "  -r <number>       Reduce the size of the input image by the given percentage\n");
    fprintf(stderr, "                    to avoid cropping during animation. If not provided, this\n");
    fprintf(stderr, "                    value is calculated automatically (maximum is %.0f).\n\n", kMTImageInsetMax * 100);
    fprintf(stderr, "  -b <text>         Set a banner with the given text for the install icon.\n\n");
    fprintf(stderr, "  -t <color>        The text color. Color must be provided as a 6 character\n");
    fprintf(stderr, "                    (3 byte) hexadecimal number (defaults to %06x).\n\n", kMTBannerTextColorDefault);
    fprintf(stderr, "  -c <color>        The banner's color. Color must be provided as a 6 character\n");
    fprintf(stderr, "                    (3 byte) hexadecimal number (defaults to %06x).\n\n", kMTBannerColorDefault);
    fprintf(stderr, "  -p <(t|b)[l|r]>   The position of the banner. Specify if the banner should be\n");
    fprintf(stderr, "                    displayed on top (\"t\") or at the bottom (\"b\") of the image.\n");
    fprintf(stderr, "                    Optionally specify if the banner should be displayed on the\n");
    fprintf(stderr, "                    left side (\"l\") or on the right side (\"r\") of the image.\n");
    fprintf(stderr, "                    If not specified or if the specified arguments are invalid,\n");
    fprintf(stderr, "                    it defaults to \"tl\".\n\n");
    fprintf(stderr, "  -m <number>       Specifies the minimum distance between the edge of the banner\n");
    fprintf(stderr, "                    and the text as a percentage. Defaults to %.0lf if not specified.\n\n", kMTBannerTextMarginDefault * 100);
    fprintf(stderr, "  -n <name>         A base name to be used as a prefix for the file name. If an\n");
    fprintf(stderr, "                    empty string (\"\") is specified, the prefix is automatically\n");
    fprintf(stderr, "                    set, based on the name of the input file.\n\n");
    fprintf(stderr, "  -x <(i|u|a)>      The icons to exclude from icon creation. Valid arguments\n");
    fprintf(stderr, "                    are \"i\" (install), \"u\" (uninstall) and \"a\" (animated)\n");
    fprintf(stderr, "                    or any combination of these three arguments (like \"ua\").\n\n");
    fprintf(stderr, "  -i <path>         Path to the source image file or application bundle.\n\n");
    fprintf(stderr, "  -o <path>         Path to a folder to write the generated images to.\n\n");
}

int main(int argc, const char * argv[]) {
    
    __block int returnValue = 0;
    
    @autoreleasepool {
                        
        NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
        
        CGFloat argAnimationDuration = ([args objectForKey:@"d"]) ? [args floatForKey:@"d"] : kMTAnimationDurationDefault;
        NSInteger argOutputSize = ([args objectForKey:@"s"]) ? [args floatForKey:@"s"] : 0;
        CGFloat argImageInset = ([args objectForKey:@"r"]) ? [args floatForKey:@"r"] : -1.0;
        NSString *argBannerText = [args stringForKey:@"b"];
        NSInteger argBannerTextColor = ([args objectForKey:@"t"]) ? (UInt64)strtoull([[args stringForKey:@"t"] UTF8String], NULL, 16) : kMTBannerTextColorDefault;
        NSInteger argBannerColor = ([args objectForKey:@"c"]) ? (UInt64)strtoull([[args stringForKey:@"c"] UTF8String], NULL, 16) : kMTBannerColorDefault;
        NSString *argInputFilePath = [args stringForKey:@"i"];
        NSString *argOutputFolderPath = [args stringForKey:@"o"];
        NSString *bannerPosition = [[args stringForKey:@"p"] lowercaseString];
        CGFloat bannerTextMargin = ([args objectForKey:@"m"]) ? [args floatForKey:@"m"] * .01 : kMTBannerTextMarginDefault;
        NSString *argFileNamePrefix = [args stringForKey:@"n"];
        NSString *argExcludeFromCreation = [[args stringForKey:@"x"] lowercaseString];
        
        if (argInputFilePath && argOutputFolderPath) {
        
            BOOL isDirectory = NO;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:argOutputFolderPath isDirectory:&isDirectory] && isDirectory) {
                
                NSImage *closeBox = nil;
                NSData *pdfData = [NSData dataWithBytesNoCopy:closebox_pdf
                                                       length:closebox_pdf_len
                                                 freeWhenDone:NO];
                if (pdfData) { closeBox = [[NSImage alloc] initWithData:pdfData]; }
                NSImage *sourceImage = [NSImage imageWithFileAtURL:[NSURL fileURLWithPath:argInputFilePath]];
            
                if ([sourceImage isValid] && [closeBox isValid]) {
                    
                    // get the source image's shortest side and calculate
                    // the maximum output image size
                    NSBitmapImageRep *sourceImageRep = [[NSBitmapImageRep alloc] initWithData:[sourceImage TIFFRepresentation]];
                    NSInteger imageSize = ([sourceImageRep pixelsWide] >= [sourceImageRep pixelsHigh]) ? [sourceImageRep pixelsWide] : [sourceImageRep pixelsHigh];
                    
#pragma mark install icon
                                            
                    MTInstallIconView *installIconView = nil;
                    
                    if (![argExcludeFromCreation containsString:@"i"]) {
                        
                        installIconView = [[MTInstallIconView alloc] initWithFrame:NSMakeRect(0, 0, imageSize, imageSize)];
                        [installIconView setImage:sourceImage];
                    
                        // banner
                        if ([argBannerText length] > 0) {
                            
                            NSAttributedString *bannerText = [[NSAttributedString alloc] initWithString:argBannerText
                                                                                                   font:[NSFont systemFontOfSize:0.0]
                                                                                        foregroundColor:[NSColor colorFromInteger:argBannerTextColor]
                                                                                        backgroundColor:[NSColor colorFromInteger:argBannerColor]];
                            [installIconView setBannerAttributes:bannerText];
                            [installIconView setBannerTextMargin:bannerTextMargin];
                            
                            // banner position
                            MTBannerPosition position = MTBannerPositionTopLeft;
                            
                            if ([bannerPosition length] > 0) {
                                
                                if ([bannerPosition containsString:@"t"]) {
                                    
                                    position = MTBannerPositionTop;
                                    
                                    if ([bannerPosition containsString:@"l"]) {
                                        position = MTBannerPositionTopLeft;
                                    } else if ([bannerPosition containsString:@"r"]) {
                                        position = MTBannerPositionTopRight;
                                    }
                                    
                                } else if ([bannerPosition containsString:@"b"]) {
                                    
                                    position = MTBannerPositionBottom;
                                    
                                    if ([bannerPosition containsString:@"l"]) {
                                        position = MTBannerPositionBottomLeft;
                                    } else if ([bannerPosition containsString:@"r"]) {
                                        position = MTBannerPositionBottomRight;
                                    }
                                }
                            }
                            
                            [installIconView setBannerPosition:position];
                        }
                        
                    } else {
                        fprintf(stderr, "Skipping creation of install icon\n");
                    }
                    
#pragma mark uninstall icon
                        
                    MTUninstallIconView *uninstallIconView = nil;
                    
                    if (!([argExcludeFromCreation containsString:@"u"] && [argExcludeFromCreation containsString:@"a"])) {
                        
                        uninstallIconView = [[MTUninstallIconView alloc] initWithFrame:NSMakeRect(0, 0, imageSize, imageSize)];
                        [uninstallIconView setImage:sourceImage];
                        [uninstallIconView setCloseBox:closeBox];
                        
                        if ([argExcludeFromCreation containsString:@"u"]) {
                            fprintf(stderr, "Skipping creation of uninstall icon\n");
                        }
                        
                        if ([argExcludeFromCreation containsString:@"a"]) {
                            argAnimationDuration = 0;
                        }
                        
                        // get the duration
                        if (argAnimationDuration > 0) {
                            argAnimationDuration = (argAnimationDuration >= kMTAnimationDurationMin && argAnimationDuration <= kMTAnimationDurationMax) ? argAnimationDuration : kMTAnimationDurationDefault;
                        } else {
                            fprintf(stderr, "Skipping creation of animated uninstall icon\n");
                        }
                        
                    } else {
                        fprintf(stderr, "Skipping creation of uninstall icon and animated uninstall icon\n");
                    }
                    
                    if (installIconView || uninstallIconView) {
                        
                        // calculate output size
                        NSSize outputSize = NSZeroSize;
                        
                        if (argOutputSize == 0 || argOutputSize > kMTOutputSizeMax) {
                            
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
                            outputSize = NSMakeSize(argOutputSize, argOutputSize);
                        }
                        
                        fprintf(stderr, "Output size is %ld x %ld pixels\n", (long)outputSize.width, (long)outputSize.height);
                        
                        // calculate inset
                        if (argImageInset != 0) {
                            
                            CGFloat imageInset = argImageInset / 100;
                            
                            if (imageInset > kMTImageInsetMin && imageInset <= kMTImageInsetMax) {
                                [uninstallIconView setImageInset:imageInset];
                            } else {
                                imageInset = [uninstallIconView autoInset];
                                [uninstallIconView setImageInset:imageInset];
                            }
                            
                            fprintf(stderr, "Insetting image by %.1f percent\n", imageInset * 100);
                        }
                        
                        // process the file name prefix
                        if (argFileNamePrefix && [argFileNamePrefix length] == 0) {
                            argFileNamePrefix = [[argInputFilePath lastPathComponent] stringByDeletingPathExtension];
                        } else {
                            argFileNamePrefix = [MTIconSet fileNamePrefixWithString:argFileNamePrefix];
                        }
                        
                        // create the icon files
                        if (![sourceImage canBeScaledToSize:outputSize]) { fprintf(stderr, "Source file is too small for the selected output size and has been upscaled\n"); }
                        
                        MTIconSet *iconSet = [[MTIconSet alloc] init];
                        [iconSet setInstallIcon:([installIconView icon]) ? [NSImage imageWithView:[installIconView icon] size:outputSize] : nil];
                        [iconSet setUninstallIcon:([uninstallIconView icon]) ? [NSImage imageWithView:[uninstallIconView icon] size:outputSize] : nil];
                        [iconSet setAnimationDuration:argAnimationDuration];
                        [iconSet setFileNamePrefix:argFileNamePrefix];
                        
                        [iconSet writeToFolder:argOutputFolderPath
                                  createFolder:NO
                                  animatedOnly:([argExcludeFromCreation containsString:@"u"])
                             completionHandler:^(BOOL success, NSString *path, NSError *error) {
                            
                            if (success) {
                                fprintf(stderr, "Output files have been successfully written\n");
                            } else {
                                fprintf(stderr, "ERROR! Failed to write output file(s)");
                                returnValue = 3;
                            }
                        }];
                        
                    } else {
                        fprintf(stderr, "All icons have been excluded from creation. Nothing to do\n");
                    }
                
                } else {
                    fprintf(stderr, "ERROR! Unable to open source image\n");
                    returnValue = 2;
                }
            
            } else {
                fprintf(stderr, "ERROR! Output folder does not exist\n");
                returnValue = 1;
            }
          
        } else {
            printUsage();
            returnValue = 255;
        }
    }
    
    return returnValue;
}
