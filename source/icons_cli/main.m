/*
    main.m
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

#import <Foundation/Foundation.h>
#import "MTInstallIconView.h"
#import "MTUninstallIconView.h"
#import "MTIconSet.h"
#import "MTColor.h"
#import "MTAttributedString.h"
#import "Constants.h"
#import "MTProcessInfo.h"
#import "DeleteBadge.svg.h"

@interface Main : NSObject

@end

@implementation Main

- (int)run
{
    __block int exitCode = 0;
    
    MTProcessInfo *appArguments = [[MTProcessInfo alloc] init];
    
    if ([appArguments showVersion]) {
        
        NSString *versionString = @"unknown version";
        NSURL *launchURL = [appArguments launchURL];
        
        if (launchURL) {
            
            NSDictionary *infoDict = CFBridgingRelease(CFBundleCopyInfoDictionaryForURL((CFURLRef)launchURL));
            NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
            NSString *appBuild = [infoDict objectForKey:@"CFBundleVersion"];
            
            if (appVersion && appBuild) {
                
                versionString = [NSString stringWithFormat:@"%@ (%@)", appVersion, appBuild];
            }
        }
        
        [self writeConsole:[NSString stringWithFormat:@"icons_cli %@", versionString]];
        
    } else {
                
        NSString *argInputFilePath = [appArguments inputFilePath];
        NSString *argOutputFolderPath = [appArguments outputFolderPath];
        
        if (!argInputFilePath || !argOutputFolderPath) {
            
            [self writeConsole:@"ERROR! Please specify at least an input file and an output folder"];
            [self printUsage];
            
            exitCode = 255;
            
        } else {
            
            NSImage *sourceImage = [NSImage imageWithFileAtURL:[NSURL fileURLWithPath:argInputFilePath]];
            
            if ([sourceImage isValid]) {
                
                // get the source image's shortest side and calculate
                // the maximum output image size
                NSBitmapImageRep *sourceImageRep = [[NSBitmapImageRep alloc] initWithData:[sourceImage TIFFRepresentation]];
                NSInteger imageSize = ([sourceImageRep pixelsWide] >= [sourceImageRep pixelsHigh]) ? [sourceImageRep pixelsWide] : [sourceImageRep pixelsHigh];
                
                NSString *argExcludeFromCreation = [appArguments excludeFromCreation];
                
#pragma mark Install icon
                
                MTInstallIconView *installIconView = nil;
                
                if (![argExcludeFromCreation containsString:@"i"]) {
                    
                    installIconView = [[MTInstallIconView alloc] initWithFrame:NSMakeRect(0, 0, imageSize, imageSize)];
                    [installIconView setImage:sourceImage];
                    
                    // banner
                    NSString *argBannerText = [appArguments bannerText];

                    if ([argBannerText length] > 0) {
                        
                        NSAttributedString *bannerText = [[NSAttributedString alloc] initWithString:argBannerText
                                                                                               font:[NSFont systemFontOfSize:0.0]
                                                                                    foregroundColor:[NSColor colorFromInteger:[appArguments textColor]]
                                                                                    backgroundColor:[NSColor colorFromInteger:[appArguments bannerColor]]];
                        [installIconView setBannerAttributes:bannerText];
                        [installIconView setBannerTextMargin:[appArguments textMargin]];
                        [installIconView setBannerAngle:[appArguments bannerAngle]];
                        [installIconView setBannerHeight:[appArguments bannerHeight]];
                        [installIconView setBannerMargin:[appArguments bannerMargin]];
                        
                        // banner position
                        MTBannerPosition position = MTBannerPositionTopLeft;
                        NSString *bannerPosition = [appArguments bannerPosition];
                        
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
                    [self writeConsole:@"Skipping creation of install icon"];
                }
                
#pragma mark Uninstall icon
                
                MTUninstallIconView *uninstallIconView = nil;
                CGFloat argAnimationDuration = ([argExcludeFromCreation containsString:@"a"]) ? 0 : [appArguments animationDuration];
                
                if (!([argExcludeFromCreation containsString:@"u"] && [argExcludeFromCreation containsString:@"a"])) {
                    
                    uninstallIconView = [[MTUninstallIconView alloc] initWithFrame:NSMakeRect(0, 0, imageSize, imageSize)];
                    [uninstallIconView setImage:sourceImage];
                    [uninstallIconView setBadgeSize:kMTBadgeIconSizeDefault];
                    [uninstallIconView setBadgeMargin:kMTBadgeIconMarginDefault];
                    
                    MTDeleteBadgeView *deleteBadge = [[MTDeleteBadgeView alloc] initWithFrame:[uninstallIconView bounds]];
                    NSString *customDeleteBadgePath = [appArguments deleteBadgeFilePath];

                    if (customDeleteBadgePath) {
                        
                        NSImage *customDeleteBadge = [[NSImage alloc] initByReferencingFile:customDeleteBadgePath];
                    
                        if ([customDeleteBadge isValid]) {
                            
                            [deleteBadge setImage:customDeleteBadge];
                            [deleteBadge setShowsShadow:NO];
                            
                            [uninstallIconView setBadgeSize:[appArguments deleteBadgeSize]];
                            [uninstallIconView setBadgeMargin:[appArguments deleteBadgeMargin]];
                            
                            // badge position
                            MTBadgePosition position = MTBadgePositionTopLeft;
                            NSString *badgePosition = [appArguments deleteBadgePosition];
                                                    
                            if ([badgePosition length] > 0) {
                                                        
                                if ([badgePosition containsString:@"t"]) {
                                    
                                    if ([badgePosition containsString:@"l"]) {
                                        position = MTBadgePositionTopLeft;
                                    } else if ([badgePosition containsString:@"r"]) {
                                        position = MTBadgePositionTopRight;
                                    }
                                    
                                } else if ([badgePosition containsString:@"b"]) {
                                                                                                
                                    if ([badgePosition containsString:@"l"]) {
                                        position = MTBadgePositionBottomLeft;
                                    } else if ([badgePosition containsString:@"r"]) {
                                        position = MTBadgePositionBottomRight;
                                    }
                                }
                            }
                                                    
                            [uninstallIconView setBadgePosition:position];
                            
                        } else {
                            
                            [self writeConsole:@"ERROR! Ignoring invalid custom delege badge"];
                        }
                    }
                    
                    if (![[deleteBadge image] isValid]) {
                        
                        NSData *svgData = [NSData dataWithBytesNoCopy:DeleteBadge_svg
                                                               length:DeleteBadge_svg_len
                                                         freeWhenDone:NO
                        ];
                        
                        if (svgData) {
                            
                            [deleteBadge setImage:[[NSImage alloc] initWithData:svgData]];
                            [deleteBadge setShowsShadow:YES];
                            [deleteBadge setShadowOffset:kMTBadgeShadowOffsetDefault];
                            [deleteBadge setShadowAngle:kMTBadgeShadowAngleDefault];
                            [deleteBadge setShadowColor:nil];
                            [deleteBadge setShadowRadius:kMTBadgeShadowRadiusDefault];
                        }
                    }
                    
                    [uninstallIconView setDeleteBadge:deleteBadge];
                    
                    if ([argExcludeFromCreation containsString:@"u"]) {
                        [self writeConsole:@"Skipping creation of uninstall icon"];
                    }
                    
                    // get the duration
                    if (argAnimationDuration > 0) {
                        argAnimationDuration = (argAnimationDuration >= kMTAnimationDurationMin && argAnimationDuration <= kMTAnimationDurationMax) ? argAnimationDuration : kMTAnimationDurationDefault;
                    } else {
                        [self writeConsole:@"Skipping creation of animated uninstall icon"];
                    }
                    
                } else {
                    [self writeConsole:@"Skipping creation of uninstall icon and animated uninstall icon"];
                }
                
                if (installIconView || uninstallIconView) {
                    
                    // calculate output size
                    NSSize outputSize = NSZeroSize;
                    NSInteger argOutputSize = [appArguments outputSize];

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
                    
                    [self writeConsole:[NSString stringWithFormat:@"Output size is %ld x %ld pixels", (long)outputSize.width, (long)outputSize.height]];
                    
                    // calculate inset
                    CGFloat argImageInset = [appArguments imageInset];

                    if (argImageInset != 0) {
                        
                        CGFloat imageInset = argImageInset / 100;
                        
                        if (imageInset > kMTImageInsetMin && imageInset <= kMTImageInsetMax) {
                            [uninstallIconView setImageInset:imageInset];
                        } else {
                            imageInset = [uninstallIconView autoInset];
                            [uninstallIconView setImageInset:imageInset];
                        }
                        
                        [self writeConsole:[NSString stringWithFormat:@"Reducing uninstall image size by %.1f percent", imageInset * 100]];
                    }
                    
                    // process the file name prefix
                    NSString *argFileNamePrefix = [appArguments fileNamePrefix];

                    if (argFileNamePrefix && [argFileNamePrefix length] == 0) {
                        argFileNamePrefix = [[argInputFilePath lastPathComponent] stringByDeletingPathExtension];
                    } else {
                        argFileNamePrefix = [MTIconSet fileNamePrefixWithString:argFileNamePrefix];
                    }
                    
                    // create the icon files
                    if (![sourceImage canBeScaledToSize:outputSize]) { [self writeConsole:@"Source file is too small for the selected output size and has been upscaled"]; }
                    
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
                            [self writeConsole:@"Output files have been successfully written"];
                        } else {
                            [self writeConsole:@"ERROR! Failed to write output file(s)"];
                            exitCode = 3;
                        }
                    }];
                    
                } else {
                    [self writeConsole:@"All icons have been excluded from creation. Nothing to do"];
                }
                
            } else {
                [self writeConsole:@"ERROR! Unable to open source image"];
                exitCode = 2;
            }
            
        }
    }
    
    return exitCode;
}

- (void)writeConsole:(NSString*)consoleMessage
{
    fprintf(stderr, "%s\n", [consoleMessage UTF8String]);
}

- (void)printUsage
{
    fprintf(stderr, "\nUsage: icons_cli [options] -i <path> -o <path>\n\n");
    fprintf(stderr, "  -d, --duration <number>              The duration of the animation in seconds (defaults to\n");
    fprintf(stderr, "                                       %.1f, maximum is %.1f). Setting the duration to 0 disables\n", kMTAnimationDurationDefault, kMTAnimationDurationMax);
    fprintf(stderr, "                                       the creation of an animated icon.\n\n");
    fprintf(stderr, "  -s, --size <number>                  The size of the output image in pixels (maximum is %d).\n", kMTOutputSizeMax);
    fprintf(stderr, "                                       If not provided or if the provided size is invalid, the\n");
    fprintf(stderr, "                                       app calculates the best possible output size based on \n");
    fprintf(stderr, "                                       the size of the source image.\n\n");
    fprintf(stderr, "  -r, --reduce <number>                Reduce the size of the input image by the given percentage\n");
    fprintf(stderr, "                                       to avoid cropping during animation. If not provided, this\n");
    fprintf(stderr, "                                       value is calculated automatically (maximum is %.0f).\n\n", kMTImageInsetMax * 100);
    fprintf(stderr, "  -b, --bannertext <text>              Set a banner with the given text for the install icon.\n\n");
    fprintf(stderr, "  -t, --textcolor <color>              The text color. Color must be provided as a 6 character\n");
    fprintf(stderr, "                                       (3 byte) hexadecimal number (defaults to %06x).\n\n", kMTBannerTextColorDefault);
    fprintf(stderr, "  -c, --bannercolor <color>            The banner's color. Color must be provided as a 6 character\n");
    fprintf(stderr, "                                       (3 byte) hexadecimal number (defaults to %06x).\n\n", kMTBannerColorDefault);
    fprintf(stderr, "  -p, --position <(t|b)[l|r]>          The position of the banner. Specify if the banner should be\n");
    fprintf(stderr, "                                       displayed on top (\"t\") or at the bottom (\"b\") of the image.\n");
    fprintf(stderr, "                                       Optionally specify if the banner should be displayed on the\n");
    fprintf(stderr, "                                       left side (\"l\") or on the right side (\"r\") of the image.\n");
    fprintf(stderr, "                                       If not specified or if the specified arguments are invalid,\n");
    fprintf(stderr, "                                       it defaults to \"tl\".\n\n");
    fprintf(stderr, "  -a, --bannerangle <number>           Specifies the angle of the banner in degrees. Defaults to %.0lf\n", kMTBannerAngleDefault);
    fprintf(stderr, "                                       if not specified (maximum is %.0f).\n\n", kMTBannerAngleMax);
    fprintf(stderr, "  -h, --bannerheight <number>          Specifies the height of the banner as a percentage. Defaults\n");
    fprintf(stderr, "                                       to %.0lf if not specified (maximum is %.0f).\n\n", kMTBannerHeightDefault * 100, kMTBannerHeightMax * 100);
    fprintf(stderr, "  -n, --bannermargin <number>          Specifies the margin between the banner and the corner of the\n");
    fprintf(stderr, "                                       icon as a percentage. Defaults to %.0lf if not specified\n", kMTBannerMarginDefault * 100);
    fprintf(stderr, "                                       (maximum is %.0f).\n\n", kMTBannerMarginMax * 100);
    fprintf(stderr, "  -m, --textmargin <number>            Specifies the minimum margin between the edge of the banner\n");
    fprintf(stderr, "                                       and the text as a percentage. Defaults to %.0lf if not specified\n", kMTBannerTextMarginDefault * 100);
    fprintf(stderr, "                                       (maximum is %.0f).\n\n", kMTBannerTextMarginMax * 100);
    fprintf(stderr, "  -g, --deletebadge <path>             Path to an image file that should be used as a custom delete\n");
    fprintf(stderr, "                                       badge for the uninstall icon instead of the built-in one.\n\n");
    fprintf(stderr, "  -l, --badgesize <number>             Specifies the size of the custom delete badge as a percentage.\n");
    fprintf(stderr, "                                       Defaults to %.0lf if not specified (maximum is %.0f).\n\n", kMTBadgeIconSizeDefault * 100, kMTBadgeIconSizeMax * 100);
    fprintf(stderr, "  -t, --badgeposition <(t|b)(l|r)>     The position of the custom delete badge. Specify if the badge\n");
    fprintf(stderr, "                                       should be displayed on top (\"t\") or at the bottom (\"b\") of\n");
    fprintf(stderr, "                                       the image and if it should be displayed on the left side (\"l\")\n");
    fprintf(stderr, "                                       or on the right side (\"r\"). If not specified or if the specified\n");
    fprintf(stderr, "                                       arguments are invalid, it defaults to \"tl\".\n\n");
    fprintf(stderr, "  -k, --badgemargin <number>           Specifies the margin between the custom delete badge and the edge\n");
    fprintf(stderr, "                                       of the icon as a percentage. Defaults to %.0lf if not specified\n", kMTBadgeIconMarginDefault * 100);
    fprintf(stderr, "                                       (maximum is %.0f).\n\n", kMTBadgeIconMarginMax * 100);
    fprintf(stderr, "  -n, --nameprefix <name>              A base name to be used as a prefix for the file name. If an\n");
    fprintf(stderr, "                                       empty string (\"\") is specified, the prefix is automatically\n");
    fprintf(stderr, "                                       set, based on the name of the input file.\n\n");
    fprintf(stderr, "  -x, --exclude <(i|u|a)>              The icons to exclude from icon creation. Valid arguments\n");
    fprintf(stderr, "                                       are \"i\" (install), \"u\" (uninstall) and \"a\" (animated)\n");
    fprintf(stderr, "                                       or any combination of these three arguments (like \"ua\").\n\n");
    fprintf(stderr, "  -i, --input <path>                   Path to the source image file or application bundle.\n\n");
    fprintf(stderr, "  -o, --output <path>                  Path to a folder to write the generated images to.\n\n");
    fprintf(stderr, "  -v, --version                        Displays version information.\n\n");
}

@end

int main(int argc, const char * argv[])
{
#pragma unused(argc)
#pragma unused(argv)
    
    int exitCode = 0;
        
    @autoreleasepool {
            
        Main *m = [[Main alloc] init];
        exitCode = [m run];
    }
    
    return exitCode;
}
