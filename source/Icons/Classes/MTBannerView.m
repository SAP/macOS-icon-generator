/*
    MTBannerView.m
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

#import "MTBannerView.h"
#import "MTIconView.h"
#import "Constants.h"

@interface MTBannerView ()
@property (nonatomic, strong, readwrite) NSAttributedString *bannerText;
@end

typedef struct { CGFloat x, y; } MTPolygon;

static MTPolygon intersect(MTPolygon A, MTPolygon B, CGFloat edge, int type)
{
    CGFloat dx = B.x - A.x;
    CGFloat dy = B.y - A.y;
    CGFloat t = 0;
    
    switch (type) {
            
        case 0: t = (edge - A.x) / dx; break; // left
        case 1: t = (edge - A.x) / dx; break; // right
        case 2: t = (edge - A.y) / dy; break; // bottom
        case 3: t = (edge - A.y) / dy; break; // top
    }
    
    return (MTPolygon){ A.x + t*dx, A.y + t*dy };
}

static int clipEdge(MTPolygon *in, int inCount, MTPolygon *out, CGFloat edge, int type)
{
    int outCount = 0;
    
    for (int i = 0; i < inCount; i++) {
        
        MTPolygon A = in[i];
        MTPolygon B = in[(i + 1)%inCount];
        BOOL Ain = false, Bin = false;
        
        switch (type) {
                
            case 0: Ain=A.x>=edge; Bin=B.x>=edge; break;
            case 1: Ain=A.x<=edge; Bin=B.x<=edge; break;
            case 2: Ain=A.y>=edge; Bin=B.y>=edge; break;
            case 3: Ain=A.y<=edge; Bin=B.y<=edge; break;
        }

        if (Ain && Bin) {
            
            out[outCount++] = B;
            
        } else if (Ain && !Bin) {
            
            out[outCount++] = intersect(A,B,edge,type);
            
        } else if (!Ain && Bin) {
            
            out[outCount++] = intersect(A,B,edge,type);
            out[outCount++] = B;
        }
    }
    
    return outCount;
}

static int clipPolygonToRect(MTPolygon *poly, int count, NSRect r)
{
    MTPolygon tmp1[16], tmp2[16];
    int c;

    c = clipEdge(poly, count, tmp1, NSMinX(r), 0);
    c = clipEdge(tmp1, c, tmp2, NSMaxX(r), 1);
    c = clipEdge(tmp2, c, tmp1, NSMinY(r), 2);
    c = clipEdge(tmp1, c, tmp2, NSMaxY(r), 3);

    memcpy(poly, tmp2, sizeof(MTPolygon)*c);
    return c;
}

static CGFloat polygonArea(MTPolygon *pts, int n)
{
    CGFloat a = 0;
    
    for (int i = 0; i < n; i++) {
        
        MTPolygon p0 = pts[i], p1 = pts[(i + 1)%n];
        a += p0.x * p1.y - p1.x * p0.y;
    }
    
    return a * .5;
}

static MTPolygon polygonCentroid(MTPolygon *pts, int n)
{
    CGFloat A = polygonArea(pts, n);
    CGFloat cx = 0, cy = 0;
    
    for (int i = 0; i < n; i++) {
        
        MTPolygon p0 = pts[i], p1 = pts[(i + 1)%n];
        CGFloat cross = p0.x * p1.y - p1.x * p0.y;
        cx += (p0.x + p1.x) * cross;
        cy += (p0.y + p1.y) * cross;
    }
    cx /= (6*A);
    cy /= (6*A);
    
    return (MTPolygon){cx, cy};
}

@implementation MTBannerView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self) { [self setUpView]; }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self) { [self setUpView]; }
    
    return self;
}

- (void)setUpView
{
    _angle = kMTBannerAngleDefault;
    _height = kMTBannerHeightDefault;
    _margin = kMTBannerMarginDefault;
    _minimumTextMargin = kMTBannerTextMarginDefault;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    if ([[_bannerText string] length] > 0) {
        
#pragma mark banner drawing
        
        // calculate size and position of the banner
        NSRect viewBounds = [self bounds];
        CGFloat viewHeight = NSHeight(viewBounds);
        CGFloat viewWidth = NSWidth(viewBounds);
        CGFloat bannerHeight = viewHeight * _height;
        CGFloat bannerWidth = viewWidth * 2.0;
        CGFloat bannerOffset = viewHeight * _margin;
        
        if (_minimumTextMargin < 0) { _minimumTextMargin = 0; } else if (_minimumTextMargin > .4) { _minimumTextMargin = .4; }
        CGFloat textPadding = bannerHeight * _minimumTextMargin;
        
        if (_bannerPosition == MTBannerPositionTop || _bannerPosition == MTBannerPositionBottom) {
            
            bannerOffset = (bannerOffset + bannerHeight > viewHeight / 2.0) ? viewHeight / 2.0 - bannerHeight : bannerOffset;
        }
            
        // draw the banner
        CGFloat xPos = 0;
        CGFloat yPos = 0;
        CGFloat rotationAngle = 0;
        
        switch (_bannerPosition) {
                
            case MTBannerPositionTopLeft:
                
                yPos = viewHeight;
                rotationAngle = _angle;
                break;
                
            case MTBannerPositionTopRight:
                
                xPos = viewWidth;
                yPos = viewHeight;
                rotationAngle = -_angle;
                break;
                
            case MTBannerPositionBottomLeft:
                
                rotationAngle = -_angle;
                break;
                
            case MTBannerPositionBottomRight:
                
                xPos = viewWidth;
                rotationAngle = _angle;
                break;
                
            case MTBannerPositionTop:
                
                yPos = viewHeight - bannerHeight - bannerOffset;
                break;
                
            case MTBannerPositionBottom:
                
                yPos = bannerOffset;
                break;
                
            default:
                break;
        }
        
        NSRect bannerRect = NSMakeRect(0, 0, bannerWidth, bannerHeight);
        NSPoint rectCenter = NSMakePoint(NSMidX(bannerRect), (yPos > 0) ? NSMaxY(bannerRect) : NSMinY(bannerRect));
        
        NSPoint viewCenter = NSMakePoint(NSMidX(viewBounds), NSMidY(viewBounds));
        NSPoint dirVec = NSMakePoint(viewCenter.x - xPos, viewCenter.y - yPos);
        CGFloat len = sqrt(dirVec.x * dirVec.x + dirVec.y * dirVec.y);
        NSPoint offsetVec = NSMakePoint(dirVec.x / len * bannerOffset, dirVec.y / len * bannerOffset);
        NSPoint pivot = NSMakePoint(xPos + offsetVec.x, yPos + offsetVec.y);
        
        NSAffineTransform *transform = [NSAffineTransform transform];
        
        if (_bannerPosition == MTBannerPositionTop || _bannerPosition == MTBannerPositionBottom) {
            
            [transform translateXBy:xPos yBy:yPos];
            
        } else {
            
            [transform translateXBy:xPos yBy:yPos];
            [transform translateXBy:offsetVec.x yBy:offsetVec.y];
            [transform rotateByDegrees:rotationAngle];
            [transform translateXBy:-rectCenter.x yBy:-rectCenter.y];
        }
        
        if (_clipToIconShape) {
            
            MTIconView *iconView = [[MTIconView alloc] initWithFrame:viewBounds];
            [[NSBezierPath bezierPathWithRoundedRect:[iconView boundingRect]
                                             xRadius:[iconView cornerRadius]
                                             yRadius:[iconView cornerRadius]
             ] addClip];
            
        } else {
            
            [[NSBezierPath bezierPathWithRect:viewBounds] addClip];
        }

#pragma mark text drawing

        // create a polygon from the visible banner
        NSPoint rp[4] = {
            [transform transformPoint:NSMakePoint(NSMinX(bannerRect), NSMinY(bannerRect))],
            [transform transformPoint:NSMakePoint(NSMaxX(bannerRect), NSMinY(bannerRect))],
            [transform transformPoint:NSMakePoint(NSMaxX(bannerRect), NSMaxY(bannerRect))],
            [transform transformPoint:NSMakePoint(NSMinX(bannerRect), NSMaxY(bannerRect))]
        };

        MTPolygon poly[16] = {
            {rp[0].x,rp[0].y}, {rp[1].x,rp[1].y},
            {rp[2].x,rp[2].y}, {rp[3].x,rp[3].y}
        };
        
        int count = clipPolygonToRect(poly, 4, viewBounds);
        if (count < 3) return;

        MTPolygon centroid = polygonCentroid(poly, count);
        NSPoint visibleCenter = NSMakePoint(centroid.x, centroid.y);

        NSAffineTransform *invertTransform = [transform copy];
        [invertTransform invert];
        NSPoint centerInRectSpace = [invertTransform transformPoint:visibleCenter];

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
        
        // banner direction for projection
        NSPoint dir = [transform transformPoint:NSMakePoint(bannerWidth, 0)];
        dir.x -= pivot.x;
        dir.y -= pivot.y;
        len = hypot(dir.x, dir.y);
        dir.x /= len;
        dir.y /= len;
        
        CGFloat minProj = CGFLOAT_MAX, maxProj = -CGFLOAT_MAX;
        
        for (int i = 0; i<count; i++) {
            
            CGFloat proj = (poly[i].x - pivot.x) * dir.x + (poly[i].y - pivot.y) * dir.y;
            minProj = MIN(minProj, proj);
            maxProj = MAX(maxProj, proj);
        }
        
        // dynamic horizontal padding to make sure we have more padding
        // on lower offsets and less padding on higher offsets
        CGFloat minPadding = viewWidth * .10; // 10%
        CGFloat maxPadding = viewWidth * .15; // 15%
        CGFloat maxOffset = hypot(viewWidth, viewHeight);
        CGFloat horizontalPadding = minPadding + (maxPadding - minPadding) * (1.0 - bannerOffset/maxOffset);

        CGFloat maxTextWidth = (maxProj - minProj) - 2 * horizontalPadding;
        CGFloat maxTextHeight = bannerHeight - 2 * textPadding; // vertical padding
        
        CGFloat minFontSize = bannerHeight * .3; // minimum font size is 30% of the banner height
        CGFloat fontSize = [strippedString fontSizeToFitInRect:NSMakeRect(0, 0, maxTextWidth, maxTextHeight)
                                               minimumFontSize:minFontSize
                                               maximumFontSize:0
                                                useImageBounds:YES
        ];
        
        // set the calculated font size
        [strippedString addAttribute:NSFontAttributeName
                               value:[[NSFontManager sharedFontManager] convertFont:[_bannerText font] toSize:fontSize]
                               range:NSMakeRange(0, [strippedString length])
        ];
        
        // get the bounding rect for the text and make sure it is centered in our container
        NSRect stringRect = [strippedString imageBounds];
        
        // check if we are already truncating the text
        _isTruncatingText = (NSWidth(stringRect) > maxTextWidth);
        if (_isTruncatingText) { stringRect.size.width = maxTextWidth; }
                
        [NSGraphicsContext saveGraphicsState];
        [transform concat];
        [[_bannerText backgroundColor] setFill];
        NSRectFill(bannerRect);
    
        if (_debugDrawingEnabled) {
            
            // highlight the string rect
            NSRect debugStringRect = NSMakeRect(
                                                centerInRectSpace.x - NSWidth(stringRect) / 2.0,
                                                ((bannerHeight - NSHeight(stringRect)) / 2.0),
                                                NSWidth(stringRect),
                                                NSHeight(stringRect)
                                                );
            [[NSColor lightGrayColor] setFill];
            NSRectFill(debugStringRect);
            
            // draw the banner's center point
            NSBezierPath *rectCenterPoint = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(
                                                                                              rectCenter.x - 4,
                                                                                              rectCenter.y - 4,
                                                                                              8,
                                                                                              8
                                                                                              )
            ];
            [[NSColor systemRedColor] setFill];
            [rectCenterPoint fill];
        }
        
        // draw the string
        CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)strippedString);
        
        if (line) {
            
            if (_isTruncatingText) {

                // post notification
                [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameBannerTruncated
                                                                    object:nil
                                                                  userInfo:nil
                ];

                NSDictionary *attributes = [strippedString attributesAtIndex:0 effectiveRange:NULL];
                NSAttributedString *ellipsisAttrString = [[NSAttributedString alloc] initWithString:@"…" attributes:attributes];
                CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)ellipsisAttrString);

                if (truncationToken) {
                    
                    // truncation line
                    CTLineRef originalLine = line;
                    CTLineRef truncated = CTLineCreateTruncatedLine(
                                                                    originalLine,
                                                                    maxTextWidth,
                                                                    kCTLineTruncationEnd,
                                                                    truncationToken
                                                                    );
                    
                    if (truncated) {
                        
                        CFRelease(originalLine);
                        line = truncated;
                    }
                    
                    CFRelease(truncationToken);
                }
            }
        
            // place the text so it is always visually centered
            CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
            CGContextSetTextPosition(
                                     context,
                                     (centerInRectSpace.x - NSWidth(stringRect) / 2.0) - stringRect.origin.x,
                                     ((bannerHeight - NSHeight(stringRect)) / 2.0) - stringRect.origin.y
                                     );
            CTLineDraw(line, context);
            CFRelease(line);
        }
        
        [NSGraphicsContext restoreGraphicsState];
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

- (void)setAngle:(CGFloat)angle
{
    _angle = angle;
    [self setNeedsDisplay:YES];
}

- (void)setHeight:(CGFloat)height
{
    _height = height;
    [self setNeedsDisplay:YES];
}

- (void)setMargin:(CGFloat)margin
{
    _margin = margin;
    [self setNeedsDisplay:YES];
}

@end

