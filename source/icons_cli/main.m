/*
     main.m
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
    fprintf(stderr, "\nUsage: icons_cli [-dsrbtcm] -i <path> -o <path>\n\n");
    fprintf(stderr, "   -d <duration>     The duration of the animation in seconds (defaults to\n");
    fprintf(stderr, "                     %.1f, maximum is %.1f). Setting the duration to 0 disables\n", kMTAnimationDurationDefault, kMTAnimationDurationMax);
    fprintf(stderr, "                     the creation of an animated icon.\n\n");
    fprintf(stderr, "   -s <size>         The size of the output image in pixels (maximum is %d).\n", kMTOutputSizeMax);
    fprintf(stderr, "                     If notprovided or if the provided size is invalid, the\n");
    fprintf(stderr, "                     app calculates the best possible output size based on \n");
    fprintf(stderr, "                     the size of the source image.\n\n");
    fprintf(stderr, "   -r <percent>      Reduce the size of the input image by the given percentage\n");
    fprintf(stderr, "                     to avoid cropping during animation. If not provided, this\n");
    fprintf(stderr, "                     value is calculated automatically (maximum is %.0f).\n\n", kMTImageInsetMax * 100);
    fprintf(stderr, "   -b <text>         Set a banner with the given text for the install icon.\n\n");
    fprintf(stderr, "   -t <color>        The text color. Color must be provided as a 6 character\n");
    fprintf(stderr, "                     (3 byte) hexadecimal number (defaults to %06x).\n\n", kMTBannerTextColorDefault);
    fprintf(stderr, "   -c <color>        The banner's color. Color must be provided as a 6 character\n");
    fprintf(stderr, "                     (3 byte) hexadecimal number (defaults to %06x).\n\n", kMTBannerColorDefault);
    fprintf(stderr, "   -m <0|1>          Set to 1 to mirror the banner so it is displayed on the\n");
    fprintf(stderr, "                     upper right corner of the icon. If not specified or if\n");
    fprintf(stderr, "                     set to 0, the banner is displayed on the upper left corner.\n\n");
    fprintf(stderr, "   -i <file path>    Path to the source image file or application bundle.\n\n");
    fprintf(stderr, "   -o <folder path>  Path to a folder to write the generated images to.\n\n");
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
        BOOL mirrorBanner = [args boolForKey:@"m"];
        
        if (argInputFilePath && argOutputFolderPath) {
        
            BOOL isDirectory = NO;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:argOutputFolderPath isDirectory:&isDirectory] && isDirectory) {
                
                NSImage *closeBox = nil;
                NSData *pdfData = [NSData dataWithBytesNoCopy:closebox_pdf
                                                       length:closebox_pdf_len
                                                 freeWhenDone:NO];
                if (pdfData) { closeBox = [[NSImage alloc] initWithData:pdfData]; }
                NSImage *sourceImage = [NSImage imageWithFileAtPath:argInputFilePath];
            
                if ([sourceImage isValid] && [closeBox isValid]) {
                    
                    // get the source image's shortest side and calculate
                    // the maximum output image size
                    NSBitmapImageRep *sourceImageRep = [[NSBitmapImageRep alloc] initWithData:[sourceImage TIFFRepresentation]];
                    NSInteger imageSize = ([sourceImageRep pixelsWide] >= [sourceImageRep pixelsHigh]) ? [sourceImageRep pixelsWide] : [sourceImageRep pixelsHigh];
                    
#pragma mark install icon
                    
                    MTInstallIconView *installIconView = [[MTInstallIconView alloc] initWithFrame:NSMakeRect(0, 0, imageSize, imageSize)];
                    [installIconView setImage:sourceImage];
                    
                    // banner
                    if ([argBannerText length] > 0) {
                        
                        NSAttributedString *bannerText = [[NSAttributedString alloc] initWithString:argBannerText
                                                                                               font:[NSFont systemFontOfSize:13.0]
                                                                                    foregroundColor:[NSColor colorFromInteger:argBannerTextColor]
                                                                                    backgroundColor:[NSColor colorFromInteger:argBannerColor]];
                        [installIconView setBannerAttributes:bannerText];
                        [installIconView setBannerIsMirrored:mirrorBanner];
                    }
                    
#pragma mark uninstall icon
                    
                    MTUninstallIconView *uninstallIconView = [[MTUninstallIconView alloc] initWithFrame:NSMakeRect(0, 0, imageSize, imageSize)];
                    [uninstallIconView setImage:sourceImage];
                    [uninstallIconView setCloseBox:closeBox];

                    // get the duration
                    if (argAnimationDuration > 0) {
                        argAnimationDuration = (argAnimationDuration >= kMTAnimationDurationMin && argAnimationDuration <= kMTAnimationDurationMax) ? argAnimationDuration : kMTAnimationDurationDefault;
                    } else {
                        fprintf(stderr, "Skipping creation of animated image\n");
                    }
                    
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
                        outputSize = NSMakeSize(imageSize, imageSize);
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
                    
                    // create the icon files
                    if (![sourceImage canBeScaledToSize:outputSize]) { fprintf(stderr, "Source file is too small for the selected output size and has been upscaled\n"); }
                    
                    MTIconSet *iconSet = [[MTIconSet alloc] init];
                    [iconSet setInstallIcon:[NSImage imageWithView:[installIconView icon] size:outputSize]];
                    [iconSet setUninstallIcon:[NSImage imageWithView:[uninstallIconView icon] size:outputSize]];
                    [iconSet setAnimationDuration:argAnimationDuration];
                    
                    [iconSet writeToFolder:argOutputFolderPath
                              createFolder:NO
                         completionHandler:^(BOOL success, NSString *path, NSError *error) {
                        
                        if (success) {
                            fprintf(stderr, "Output files have been successfully written\n");
                        } else {
                            fprintf(stderr, "ERROR! Failed to write output file(s)");
                            returnValue = 3;
                        }
                    }];
                
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
