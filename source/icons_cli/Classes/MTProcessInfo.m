/*
    MTProcessInfo.m
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

#import "MTProcessInfo.h"
#import "Constants.h"

@implementation MTProcessInfo

- (BOOL)floatWithArgument:(NSString*)argument outValue:(CGFloat*)outValue
{
    BOOL success = NO;
    
    if (argument != nil && outValue != NULL) {
        
        CGFloat value = 0.0f;
        NSScanner *scanner = [NSScanner scannerWithString:argument];
        
        if ([scanner scanDouble:&value] && [scanner isAtEnd]) {
            
            *outValue = value;
            success = YES;
        }
    }

    return success;
}

- (BOOL)integerWithArgument:(NSString*)argument outValue:(NSInteger*)outValue
{
    BOOL success = NO;
    
    if (argument != nil && outValue != NULL) {
        
        NSInteger value = 0;
        NSScanner *scanner = [NSScanner scannerWithString:argument];
        
        if ([scanner scanInteger:&value] && [scanner isAtEnd]) {
            
            *outValue = value;
            success = YES;
        }
    }

    return success;
}

- (CGFloat)animationDuration
{
    CGFloat duration = kMTAnimationDurationDefault;
    
    NSInteger index = [[self arguments] indexOfObject:@"-d"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--duration"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        CGFloat value = 0.0;
        if ([self floatWithArgument:[[self arguments] objectAtIndex:index + 1] outValue:&value]) {
            
            CGFloat animationDuration = value;
            CGFloat clampedDuration = fminf(fmaxf(animationDuration, kMTAnimationDurationMin), kMTAnimationDurationMax);
            duration = clampedDuration;
        }
    }
    
    return duration;
}

- (NSUInteger)outputSize
{
    NSUInteger size = 0;
    
    NSInteger index = [[self arguments] indexOfObject:@"-s"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--size"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        NSInteger value = 0;
        if ([self integerWithArgument:[[self arguments] objectAtIndex:index + 1] outValue:&value] && value > 0) { size = value; }
    }
    
    return size;
}

- (CGFloat)imageInset
{
    CGFloat inset = -1.0;
    
    NSInteger index = [[self arguments] indexOfObject:@"-r"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--reduce"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        CGFloat value = 0.0;
        if ([self floatWithArgument:[[self arguments] objectAtIndex:index + 1] outValue:&value]) {
            
            CGFloat imageInset = value;
            CGFloat clampedInset = fminf(fmaxf(imageInset, kMTImageInsetMin), kMTImageInsetMax);
            inset = clampedInset;
        }
    }
    
    return inset;
}

- (NSString*)bannerText
{
    NSString *text = nil;
    
    NSInteger index = [[self arguments] indexOfObject:@"-b"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--bannertext"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        text = [[self arguments] objectAtIndex:index + 1];
    }
    
    return text;
}

- (NSUInteger)textColor
{
    NSUInteger color = kMTBannerTextColorDefault;
    
    NSInteger index = [[self arguments] indexOfObject:@"-t"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--textcolor"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
            
        color = (UInt64)strtoull([[[self arguments] objectAtIndex:index + 1] UTF8String], NULL, 16);
    }
    
    return color;
}

- (NSUInteger)bannerColor
{
    NSUInteger color = kMTBannerColorDefault;
    
    NSInteger index = [[self arguments] indexOfObject:@"-c"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--bannercolor"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
            
        color = (UInt64)strtoull([[[self arguments] objectAtIndex:index + 1] UTF8String], NULL, 16);
    }
    
    return color;
}

- (NSString*)bannerPosition
{
    NSString *position = nil;
    
    NSInteger index = [[self arguments] indexOfObject:@"-p"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--position"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        position = [[[self arguments] objectAtIndex:index + 1] lowercaseString];
    }
    
    return position;
}

- (NSString*)inputFilePath
{
    NSString *path = nil;
    
    NSInteger index = [[self arguments] indexOfObject:@"-i"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--input"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        path = [[self arguments] objectAtIndex:index + 1];
    }
    
    return path;
}

- (NSString*)outputFolderPath
{
    NSString *path = nil;
    
    NSInteger index = [[self arguments] indexOfObject:@"-o"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--output"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        NSString *tempPath = [[self arguments] objectAtIndex:index + 1];
        
        BOOL isDirectory = NO;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath
                                                 isDirectory:&isDirectory] && isDirectory) {
            path = tempPath;
        }
    }
    
    return path;
}

- (CGFloat)textMargin
{
    CGFloat margin = kMTBannerTextMarginDefault;
    
    NSInteger index = [[self arguments] indexOfObject:@"-m"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--textmargin"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        CGFloat value = 0.0;
        if ([self floatWithArgument:[[self arguments] objectAtIndex:index + 1] outValue:&value]) {
            
            CGFloat textMargin = value * .01;
            CGFloat clampedMargin = fminf(fmaxf(textMargin, kMTBannerTextMarginMin), kMTBannerTextMarginMax);
            margin = clampedMargin;
        }
    }
    
    return margin;
}

- (CGFloat)bannerAngle
{
    CGFloat angle = kMTBannerAngleDefault;
    
    NSInteger index = [[self arguments] indexOfObject:@"-a"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--bannerangle"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        CGFloat value = 0.0;
        if ([self floatWithArgument:[[self arguments] objectAtIndex:index + 1] outValue:&value]) {
            
            CGFloat bannerAngle = value;
            CGFloat clampedAngle = fminf(fmaxf(bannerAngle, kMTBannerAngleMin), kMTBannerAngleMax);
            angle = clampedAngle;
        }
    }
    
    return angle;
}

- (CGFloat)bannerHeight
{
    CGFloat height = kMTBannerHeightDefault;
    
    NSInteger index = [[self arguments] indexOfObject:@"-h"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--bannerheight"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        CGFloat value = 0.0;
        if ([self floatWithArgument:[[self arguments] objectAtIndex:index + 1] outValue:&value]) {
            
            CGFloat bannerHeight = value * .01;
            CGFloat clampedHeight = fminf(fmaxf(bannerHeight, kMTBannerHeightMin), kMTBannerHeightMax);
            height = clampedHeight;
        }
    }
    
    return height;
}

- (CGFloat)bannerMargin
{
    CGFloat margin = kMTBannerMarginDefault;
    
    NSInteger index = [[self arguments] indexOfObject:@"-n"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--bannermargin"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        CGFloat value = 0.0;
        if ([self floatWithArgument:[[self arguments] objectAtIndex:index + 1] outValue:&value]) {
            
            CGFloat bannerMargin = value * .01;
            CGFloat clampedMargin = fminf(fmaxf(bannerMargin, kMTBannerMarginMin), kMTBannerMarginMax);
            margin = clampedMargin;
        }
    }
    
    return margin;
}

- (NSString*)fileNamePrefix
{
    NSString *prefix = nil;
    
    NSInteger index = [[self arguments] indexOfObject:@"-n"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--nameprefix"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        if (index != NSNotFound && index + 1 < [[self arguments] count]) {
            
            prefix = [[self arguments] objectAtIndex:index + 1];
        }
    }
    
    return prefix;
}

- (NSString*)excludeFromCreation
{
    NSString *exclude = nil;
    
    NSInteger index = [[self arguments] indexOfObject:@"-x"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--exclude"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        if (index != NSNotFound && index + 1 < [[self arguments] count]) {
            
            exclude = [[[self arguments] objectAtIndex:index + 1] lowercaseString];
        }
    }
    
    return exclude;
}

- (NSString*)deleteBadgeFilePath
{
    NSString *path = nil;
    
    NSInteger index = [[self arguments] indexOfObject:@"-g"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--deletebadge"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        path = [[self arguments] objectAtIndex:index + 1];
    }
    
    return path;
}

- (CGFloat)deleteBadgeSize
{
    CGFloat size = kMTBadgeIconSizeDefault;
    
    NSInteger index = [[self arguments] indexOfObject:@"-l"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--badgesize"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        CGFloat value = 0.0;
        if ([self floatWithArgument:[[self arguments] objectAtIndex:index + 1] outValue:&value]) {
            
            CGFloat badgeSize = value * .01;
            CGFloat clampedSize = fminf(fmaxf(badgeSize, kMTBadgeIconSizeMin), kMTBadgeIconSizeMax);
            size = clampedSize;
        }
    }
    
    return size;
}

- (CGFloat)deleteBadgeMargin
{
    CGFloat margin = kMTBadgeIconMarginDefault;
    
    NSInteger index = [[self arguments] indexOfObject:@"-k"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--badgemargin"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        CGFloat value = 0.0;
        if ([self floatWithArgument:[[self arguments] objectAtIndex:index + 1] outValue:&value]) {
            
            CGFloat badgeMargin = value * .01;
            CGFloat clampedMargin = fminf(fmaxf(badgeMargin, kMTBadgeIconMarginMin), kMTBadgeIconMarginMax);
            margin = clampedMargin;
        }
    }
    
    return margin;
}

- (NSString*)deleteBadgePosition
{
    NSString *position = nil;
    
    NSInteger index = [[self arguments] indexOfObject:@"-t"];
    if (index == NSNotFound) { index = [[self arguments] indexOfObject:@"--badgeposition"]; }
    
    if (index != NSNotFound && index + 1 < [[self arguments] count]) {
        
        position = [[[self arguments] objectAtIndex:index + 1] lowercaseString];
    }
    
    return position;
}

- (BOOL)showVersion
{
    BOOL show = [[self arguments] containsObject:@"-v"] || [[self arguments] containsObject:@"--version"];
    return show;
}

- (NSURL*)launchURL
{
    NSURL *url = nil;
    
    NSString *launchPath = [[self arguments] firstObject];
    if (launchPath) { url = [NSURL fileURLWithPath:launchPath]; }

    return url;
}

@end
