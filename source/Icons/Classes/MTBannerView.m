/*
     MTBannerView.m
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

#import "MTBannerView.h"

@interface MTBannerView ()
@property (nonatomic, strong, readwrite) NSAttributedString *bannerText;
@end

@implementation MTBannerView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    if ([[_bannerText string] length] > 0) {

#pragma mark banner drawing
        
        // calculate size and position of the banner
        CGFloat bannerHeight = NSHeight([self frame]) * .18;
        CGFloat yPos = NSHeight([self frame]) * .333334;
        CGFloat xPosMax = NSWidth([self frame]) * .666667;
        CGFloat bannerWidth = sqrt(pow((NSHeight([self frame]) - yPos), 2.0) + pow(xPosMax, 2.0));
        CGFloat angleBeta = atanf((NSHeight([self frame]) - yPos) / xPosMax) * 180 / M_PI;
        
        // draw the banner
        NSRect bannerRect = NSMakeRect(0, 0, bannerWidth, bannerHeight);
        NSBezierPath *bannerPath = [NSBezierPath bezierPathWithRect:bannerRect];
        NSAffineTransform *transform = [NSAffineTransform transform];

        if (_isMirrored) {
            [transform translateXBy:NSWidth([self frame]) * .333334 yBy:NSHeight([self frame])];
            [transform rotateByDegrees:-angleBeta];
        } else {
            [transform translateXBy:0 yBy:yPos];
            [transform rotateByDegrees:angleBeta];
        }
        
        [transform concat];

        // fill the banner with color
        NSColor *bannerColor = [_bannerText backgroundColor];
        [bannerColor setFill];
        [bannerPath fill];
        
#pragma mark text drawing
            
        // create a container to make sure the text does not clip
        // line c of the triangle is bannerHeight, angleAlpha is 90 degrees
        CGFloat angleGamma = 90 - angleBeta;
        CGFloat lineA = bannerHeight / sin(angleGamma / 180 * M_PI);
        CGFloat lineB1 = sqrt(pow(lineA, 2.0) + pow(bannerHeight, 2.0) - 2 * lineA * bannerHeight * cos(angleBeta / 180 * M_PI));

        lineA = bannerHeight / sin(angleBeta / 180 * M_PI);
        CGFloat lineB2 = sqrt(pow(lineA, 2.0) + pow(bannerHeight, 2.0) - 2 * lineA * bannerHeight * cos(angleGamma / 180 * M_PI));
        CGFloat lineB = (_isMirrored) ? lineB2 : lineB1;
        
        NSRect container = NSMakeRect(NSMinX(bannerRect) + lineB, NSMinY(bannerRect), NSWidth(bannerRect) - lineB1 - lineB2, NSHeight(bannerRect));
       
        // create a new attributed string with only the needed attributes
        NSString *bannerString = [_bannerText string];
        NSFont *bannerFont = [_bannerText font];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentCenter];
        [style setLineBreakMode:NSLineBreakByClipping];
                
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        bannerFont, NSFontAttributeName,
                                        style, NSParagraphStyleAttributeName,
                                        [_bannerText textColor], NSForegroundColorAttributeName,
                                        nil
        ];
        
        NSMutableAttributedString *strippedString = [[NSMutableAttributedString alloc] initWithString:bannerString attributes:textAttributes];
        
        // get the best font size
        CGFloat minFontSize = NSHeight(container) * .33;
        CGFloat fontSize = [strippedString fontSizeToFitInRect:container withMinimumFontSize:minFontSize];
        [strippedString addAttribute:NSFontAttributeName
                               value:[[NSFontManager sharedFontManager] convertFont:bannerFont toSize:fontSize]
                               range:NSMakeRange(0, [strippedString length])];
                
        // get the bounding rect for the text and make sure it is centered in our container
        NSRect stringRect = [strippedString boundingRectWithSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading];
        NSRect insetRect = NSInsetRect(container, 0, (NSHeight(container) < NSHeight(stringRect)) ? 0 : (NSHeight(container) - NSHeight(stringRect)) / 2);

        // draw the text
        [strippedString drawInRect:insetRect];

        // check if we are already truncating the text
        _isTruncatingText = (NSWidth(stringRect) > NSWidth(insetRect));
        
        if (_isTruncatingText) {

            // post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"corp.sap.Icons.bannerTextTruncatedNotification"
                                                                object:nil
                                                              userInfo:nil
            ];
        }
    }
}

- (void)setAttributes:(NSAttributedString*)attributedString
{
    _bannerText = attributedString;
    [self setNeedsDisplay:YES];
}

- (void)setIsMirrored:(BOOL)isMirrored
{
    _isMirrored = isMirrored;
    [self setNeedsDisplay:YES];
}

@end
