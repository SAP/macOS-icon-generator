/*
    MTColor.m
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

#import "MTColor.h"

@implementation NSColor (MTColor)

+ (NSColor*)colorFromInteger:(NSInteger)integerValue
{
    CGFloat alphaComponent, redComponent, greenComponent, blueComponent;

    if (integerValue > 0xFFFFFF) {

        alphaComponent = ((integerValue & 0xFF000000) >> 24) / 255.0;
        redComponent   = ((integerValue & 0x00FF0000) >> 16) / 255.0;
        greenComponent = ((integerValue & 0x0000FF00) >> 8)  / 255.0;
        blueComponent  = (integerValue & 0x000000FF)         / 255.0;
        
    } else {

        alphaComponent = 1.0;
        redComponent   = ((integerValue & 0xFF0000) >> 16) / 255.0;
        greenComponent = ((integerValue & 0x00FF00) >> 8)  / 255.0;
        blueComponent  = (integerValue & 0x0000FF)         / 255.0;
    }

    NSColor *color = [NSColor colorWithRed:redComponent
                                     green:greenComponent
                                      blue:blueComponent
                                     alpha:alphaComponent
    ];
    
    return color;
}

- (NSInteger)integerValue
{
    NSColor *convertedColor = [self colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    
    NSInteger alphaComponent = (NSInteger)round([convertedColor alphaComponent] * 255.0);
    NSInteger redComponent = (NSInteger)round([convertedColor redComponent] * 255.0);
    NSInteger greenComponent = (NSInteger)round([convertedColor greenComponent] * 255.0);
    NSInteger blueComponent = (NSInteger)round([convertedColor blueComponent] * 255.0);

    return (alphaComponent << 24) | (redComponent << 16) | (greenComponent << 8) | blueComponent;
}

- (NSColor*)complementaryColor
{
    NSColor *convertedColor = [self colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    
    CGFloat alphaComponent = [convertedColor alphaComponent];
    CGFloat redComponent = 1.0 - [convertedColor redComponent];
    CGFloat greenComponent = 1.0 - [convertedColor greenComponent];
    CGFloat blueComponent = 1.0 - [convertedColor blueComponent];
    
    NSColor *complementaryColor = [NSColor colorWithRed:redComponent
                                                  green:greenComponent
                                                   blue:blueComponent
                                                  alpha:alphaComponent
    ];
    
    return complementaryColor;
}

@end
