/*
     MTBannerView.m
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

#import "MTBannerView.h"
#import "Constants.h"

@interface MTBannerView ()
@property (nonatomic, strong, readwrite) NSAttributedString *bannerText;
@end

@implementation MTBannerView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    if ([[_bannerText string] length] > 0) {
        
#pragma mark banner drawing
        
        // calculate size and position of the banner
        CGFloat angleBeta = 0;
        CGFloat xPos = 0;
        CGFloat yPos = 0;
        CGFloat bannerHeight = NSHeight([self frame]) * .18;
        CGFloat bannerWidth = NSWidth([self frame]);
        
        if (_bannerPosition != MTBannerPositionTop && _bannerPosition != MTBannerPositionBottom) {
            
            yPos = NSHeight([self frame]) * .333334;
            CGFloat xPosMax = NSWidth([self frame]) * .666667;
            bannerWidth = sqrt(pow((NSHeight([self frame]) - yPos), 2.0) + pow(xPosMax, 2.0));
            angleBeta = atanf((NSHeight([self frame]) - yPos) / xPosMax) * 180 / M_PI;
            xPos = sinf(angleBeta / 180 * M_PI) * bannerHeight;
        }
        
        // draw the banner
        NSRect bannerRect = NSMakeRect(0, 0, bannerWidth, bannerHeight);
        NSBezierPath *bannerPath = [NSBezierPath bezierPathWithRect:bannerRect];
        NSAffineTransform *transform = [NSAffineTransform transform];

        switch (_bannerPosition) {
                
            case MTBannerPositionTopLeft:
                [transform translateXBy:0 yBy:yPos];
                [transform rotateByDegrees:angleBeta];
                break;
                
            case MTBannerPositionTopRight:
                [transform translateXBy:NSWidth([self frame]) * .333334 yBy:NSHeight([self frame])];
                [transform rotateByDegrees:-angleBeta];
                break;
                
            case MTBannerPositionBottomLeft:
                yPos = sinf(angleBeta / 180 * M_PI) * (bannerWidth - bannerHeight);
                [transform translateXBy:-xPos yBy:yPos];
                [transform rotateByDegrees:-angleBeta];
                break;
                
            case MTBannerPositionBottomRight:
                yPos = -(sinf(angleBeta / 180 * M_PI) * bannerHeight);
                [transform translateXBy:NSWidth([self frame]) * .333334 + xPos yBy:yPos];
                [transform rotateByDegrees:angleBeta];
                break;
                
            case MTBannerPositionTop:
                [transform translateXBy:0 yBy:NSHeight([self frame]) - bannerHeight];
                break;
                
            default:
                break;
        }
        
        [transform concat];

        // fill the banner with color
        NSColor *bannerColor = [_bannerText backgroundColor];
        [bannerColor setFill];
        [bannerPath fill];
        
#pragma mark text drawing
            
        NSRect container = NSZeroRect;

        if (_bannerPosition == MTBannerPositionTop || _bannerPosition == MTBannerPositionBottom) {
            
            container = NSInsetRect(
                                    NSMakeRect(
                                               0,
                                               0,
                                               NSWidth(bannerRect),
                                               NSHeight(bannerRect)
                                               ),
                                    
                                    NSHeight(bannerRect) / 2,
                                    0
                                    );
        } else {
            
            CGFloat angleGamma = 90 - angleBeta;
            CGFloat lineA = bannerHeight / sin(angleGamma / 180 * M_PI);
            CGFloat lineB1 = sqrt(pow(lineA, 2.0) + pow(bannerHeight, 2.0) - 2 * lineA * bannerHeight * cos(angleBeta / 180 * M_PI));
            
            lineA = bannerHeight / sin(angleBeta / 180 * M_PI);
            CGFloat lineB2 = sqrt(pow(lineA, 2.0) + pow(bannerHeight, 2.0) - 2 * lineA * bannerHeight * cos(angleGamma / 180 * M_PI));
            CGFloat lineB = (_bannerPosition == MTBannerPositionTopRight) ? lineB2 : lineB1;
            
            container = NSMakeRect(
                                   NSMinX(bannerRect) + lineB,
                                   NSMinY(bannerRect),
                                   NSWidth(bannerRect) - lineB1 - lineB2,
                                   NSHeight(bannerRect)
                                   );
        }

        if (_debugDrawingEnabled) {
            
            NSBezierPath *containerPath = [NSBezierPath bezierPathWithRect:container];
            NSColor *containerColor = [NSColor darkGrayColor];
            [containerColor setFill];
            [containerPath fill];
        }

        // create a new attributed string with only the needed attributes
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentCenter];
        [style setLineBreakMode:NSLineBreakByClipping];
        [style setLineSpacing:0];
                
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [_bannerText font], NSFontAttributeName,
                                        style, NSParagraphStyleAttributeName,
                                        [_bannerText textColor], NSForegroundColorAttributeName,
                                        nil
        ];

        NSMutableAttributedString *strippedString = [[NSMutableAttributedString alloc] initWithString:[_bannerText string]
                                                                                           attributes:textAttributes
        ];
        
        // get the best font size
        if (_minimumTextMargin < 0) { _minimumTextMargin = 0; } else if (_minimumTextMargin > .4) { _minimumTextMargin = .4; }
        NSRect insetRect = NSInsetRect(container, 0, NSHeight(container) * _minimumTextMargin);

        if (_debugDrawingEnabled) {
            
            NSBezierPath *insetPath = [NSBezierPath bezierPathWithRect:insetRect];
            NSColor *insetColor = [NSColor lightGrayColor];
            [insetColor setFill];
            [insetPath fill];
        }
        
        CGFloat minFontSize = NSHeight(container) * .25;
        CGFloat fontSize = [strippedString fontSizeToFitInRect:insetRect
                                               minimumFontSize:minFontSize
                                               maximumFontSize:0
                                                useImageBounds:YES
        ];

        [strippedString addAttribute:NSFontAttributeName
                               value:[[NSFontManager sharedFontManager] convertFont:[_bannerText font] toSize:fontSize]
                               range:NSMakeRange(0, [strippedString length])
        ];
        
        // get the bounding rect for the text and make sure it is centered in our container
        NSRect stringRect = [strippedString imageBounds];

        // draw the string
        CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)strippedString);
        
        if (line) {
            
            CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
            CGContextSetTextPosition(
                                     context,
                                     ((NSWidth(bannerRect) - NSWidth(stringRect)) / 2) - stringRect.origin.x,
                                     ((NSHeight(bannerRect) - NSHeight(stringRect)) / 2) - stringRect.origin.y
                                     );
            CTLineDraw(line, context);
            CFRelease(line);
        }

        // check if we are already truncating the text
        _isTruncatingText = (NSWidth(stringRect) > NSWidth(container));
        
        if (_isTruncatingText) {

            // post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameBannerTruncated
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

- (void)setBannerPosition:(MTBannerPosition)bannerPosition
{
    _bannerPosition = bannerPosition;
    [self setNeedsDisplay:YES];
}

- (void)setMinimumTextMargin:(CGFloat)minimumTextMargin
{
    _minimumTextMargin = minimumTextMargin;
    [self setNeedsDisplay:YES];
}

@end
