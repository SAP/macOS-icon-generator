/*
     MTColor.m
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

#import "MTColor.h"

@implementation NSColor (MTColor)

+ (NSColor*)colorFromInteger:(NSInteger)integerValue
{
    NSInteger redComponent = (integerValue & 0xFF0000) >> 16;
    NSInteger greenComponent = (integerValue & 0x00FF00) >> 8;
    NSInteger blueComponent = (integerValue & 0x0000FF);
        
    NSColor *color = [NSColor colorWithRed:redComponent/255.0
                                     green:greenComponent/255.0
                                      blue:blueComponent/255.0
                                     alpha:1.0
    ];
    
    return color;
}

- (NSInteger)integerValue
{
    NSColor *convertedColor = [self colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    
    NSInteger redComponent = [convertedColor redComponent] * 255;
    NSInteger greenComponent = [convertedColor greenComponent] * 255;
    NSInteger blueComponent = [convertedColor blueComponent] * 255;

    return (redComponent << 16) | (greenComponent << 8) | blueComponent;
}

- (NSColor*)complementaryColor
{
    NSColor *convertedColor = [self colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    
    NSInteger redComponent = 1.0 - [convertedColor redComponent];
    NSInteger greenComponent = 1.0 - [convertedColor greenComponent];
    NSInteger blueComponent = 1.0 - [convertedColor blueComponent];
    
    NSColor *complementaryColor = [NSColor colorWithRed:redComponent
                                                  green:greenComponent
                                                   blue:blueComponent
                                                  alpha:1.0];
    
    return complementaryColor;
}

@end
