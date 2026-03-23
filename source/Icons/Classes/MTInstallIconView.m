/*
    MTInstallIconView.m
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

#import "MTInstallIconView.h"
#import "Constants.h"

@interface MTInstallIconView ()
@property (nonatomic, strong, readwrite) NSView *containerView;
@property (nonatomic, strong, readwrite) NSImageView *imageView;
@property (nonatomic, strong, readwrite) MTOverlayImageView *overlayImageView;
@property (nonatomic, strong, readwrite) MTBannerView *bannerView;
@property (nonatomic, strong, readwrite) NSImage *image;
@end

@implementation MTInstallIconView

@dynamic image;

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) { [self setUpViews]; }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) { [self setUpViews]; }

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTInstallIconView *copiedView = [[[self class] allocWithZone:zone] initWithFrame:[self frame]];

    if (copiedView) {
        
        [copiedView setOverlayImageScalingFactor:_overlayImageScalingFactor];
        [copiedView setOverlayImageAspectRatio:_overlayImageAspectRatio];
        [copiedView setOverlayPosition:_overlayPosition];
        [copiedView setBannerAttributes:_bannerAttributes];
        [copiedView setBannerPosition:_bannerPosition];
        [copiedView setBannerTextMargin:_bannerTextMargin];
        [copiedView setBannerAngle:_bannerAngle];
        [copiedView setBannerHeight:_bannerHeight];
        [copiedView setBannerMargin:_bannerMargin];
        [copiedView setOverlayImage:[[_overlayImageView image] copyWithZone:zone]];
        
        // to make sure we don't get an icon shape in an icon shape
        [copiedView setApplyIconShape:NO];
        [copiedView setImage:[_image copyWithZone:zone]];
        [copiedView setApplyIconShape:_applyIconShape];
        [copiedView setUsesOldIconShape:_usesOldIconShape];
        [copiedView setIsAppBundle:_isAppBundle];
        [copiedView setDrawBannerInIconShape:_drawBannerInIconShape];
        [copiedView setUnmodifiedImage:[_unmodifiedImage copyWithZone:zone]];
    }
    
    return copiedView;
}

- (void)setUpViews
{
    // for the overlay image…
    [self registerForDraggedTypes:[NSImage imageTypes]];
    
    // add our container view that holds our images
    _containerView = [[NSView alloc] initWithFrame:[self bounds]];
    [_containerView setWantsLayer:YES];
    [_containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_containerView];
    
    // add constraints
    NSLayoutConstraint *containerLeft = [[_containerView leadingAnchor] constraintEqualToAnchor:[self leadingAnchor] constant:7];
    NSLayoutConstraint *containerRight = [[_containerView trailingAnchor] constraintEqualToAnchor:[self trailingAnchor] constant:-7];
    NSLayoutConstraint *containerTop = [[_containerView topAnchor] constraintEqualToAnchor:[self topAnchor] constant:7];
    NSLayoutConstraint *containerBottom = [[_containerView bottomAnchor] constraintEqualToAnchor:[self bottomAnchor] constant:-7];
    [self addConstraints:[NSArray arrayWithObjects:containerLeft, containerRight, containerTop, containerBottom, nil]];
    
    // create the icon image
    _imageView = [[NSImageView alloc] initWithFrame:[_containerView bounds]];
    [_imageView setWantsLayer:YES];
    [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_imageView unregisterDraggedTypes];
    [_imageView setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_imageView setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationVertical];
    
    // add the view
    [_containerView addSubview:_imageView];
    
    // add constraints
    NSLayoutConstraint *imageCenterX = [[_imageView centerXAnchor] constraintEqualToAnchor:[_containerView centerXAnchor]];
    NSLayoutConstraint *imageCenterY = [[_imageView centerYAnchor] constraintEqualToAnchor:[_containerView centerYAnchor]];
    NSLayoutConstraint *imageWidth = [[_imageView widthAnchor] constraintEqualToAnchor:[_containerView widthAnchor] multiplier:1];
    NSLayoutConstraint *imageHeight = [[_imageView heightAnchor] constraintEqualToAnchor:[_containerView heightAnchor] multiplier:1];
    [_containerView addConstraints:[NSArray arrayWithObjects:imageCenterX, imageCenterY, imageWidth, imageHeight, nil]];
    
    // add the overlay view
    _overlayImageView = [[MTOverlayImageView alloc] initWithFrame:[_containerView bounds]];
    [_overlayImageView setDelegate:self];
    [_overlayImageView setWantsLayer:YES];
    [_overlayImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_overlayImageView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_overlayImageView unregisterDraggedTypes];
    [_overlayImageView setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_overlayImageView setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationVertical];
    [_overlayImageView setToolTip:NSLocalizedString(@"overlayImageTooltip", nil)];
    [_overlayImageView setAccessibilityIdentifier:@"Overlay Image View"];
    
    _overlayPosition = NSMakePoint(1, 1);
    _overlayImageScalingFactor = kMTOverlayImageScalingDefault;
    _overlayImageAspectRatio = 1;
  
    // add constraints
    NSLayoutConstraint *overlayCenterX = [[_overlayImageView centerXAnchor] constraintEqualToAnchor:[_containerView centerXAnchor]];
    NSLayoutConstraint *overlayCenterY = [[_overlayImageView centerYAnchor] constraintEqualToAnchor:[_containerView centerYAnchor]];
    NSLayoutConstraint *overlayWidth = [[_overlayImageView widthAnchor] constraintEqualToAnchor:[_containerView widthAnchor] multiplier:_overlayImageScalingFactor];

    [_containerView addSubview:_overlayImageView];
    [_containerView addConstraints:[NSArray arrayWithObjects:overlayCenterX, overlayCenterY, overlayWidth, nil]];
    
    // add the banner overlay
    _bannerView = [[MTBannerView alloc] initWithFrame:[_containerView bounds]];
    [_bannerView setWantsLayer:YES];
    [_bannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_bannerView setMinimumTextMargin:kMTBannerTextMarginDefault];
    [_containerView addSubview:_bannerView];
    
    // add constraints
    NSLayoutConstraint *bannerLeft = [[_bannerView leadingAnchor] constraintEqualToAnchor:[_containerView leadingAnchor]];
    NSLayoutConstraint *bannerTop = [[_bannerView topAnchor] constraintEqualToAnchor:[_containerView topAnchor]];
    NSLayoutConstraint *bannerWidth = [[_bannerView trailingAnchor] constraintEqualToAnchor:[_containerView trailingAnchor]];
    NSLayoutConstraint *bannerHeight = [[_bannerView bottomAnchor] constraintEqualToAnchor:[_containerView bottomAnchor]];
    [_containerView addConstraints:[NSArray arrayWithObjects:bannerLeft, bannerTop, bannerWidth, bannerHeight, nil]];
    
    [self layoutSubtreeIfNeeded];
}

- (void)setImage:(NSImage *)image
{
    [super setImage:image];
    [_imageView setImage:_image];
}

- (NSImage*)overlayImage
{
    return [_overlayImageView image];
}

- (void)setOverlayImage:(NSImage *)image
{
    if ([image isValid]) {
    
        // calculate the aspect ratio
        CGFloat aspectRatio = [image size].width / [image size].height;
        
        [_overlayImageView setImage:image];
        [self setOverlayImageAspectRatio:aspectRatio];
    }
}

- (void)setBannerAttributes:(NSAttributedString*)attributedString
{
    _bannerAttributes = attributedString;
    [_bannerView setAttributes:attributedString];
}

- (void)setBannerPosition:(MTBannerPosition)bannerPosition
{
    _bannerPosition = bannerPosition;
    [_bannerView setBannerPosition:bannerPosition];
}

- (void)setBannerTextMargin:(CGFloat)margin
{
    _bannerTextMargin = margin;
    [_bannerView setMinimumTextMargin:margin];
}

- (void)setBannerHeight:(CGFloat)height
{
    _bannerHeight = height;
    [_bannerView setHeight:height];
}

- (void)setBannerAngle:(CGFloat)angle
{
    _bannerAngle = angle;
    [_bannerView setAngle:angle];
}

- (void)setBannerMargin:(CGFloat)margin
{
    _bannerMargin = margin;
    [_bannerView setMargin:margin];
}

- (void)setDrawBannerInIconShape:(BOOL)drawBannerInIconShape
{
    _drawBannerInIconShape = drawBannerInIconShape;
    [_bannerView setClipToIconShape:drawBannerInIconShape];
}

- (void)setOverlayImageScalingFactor:(CGFloat)scalingFactor
{
    _overlayImageScalingFactor = scalingFactor;

    // update the overlay image view
    NSArray *containerViewConstraints = [_containerView constraints];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem == %@ AND (firstAttribute == %d OR firstAttribute == %d)", _overlayImageView, NSLayoutAttributeWidth, NSLayoutAttributeHeight];
    NSArray *filteredArray = [containerViewConstraints filteredArrayUsingPredicate:predicate];

    for (NSLayoutConstraint *existingConstraint in filteredArray) {

        NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:[existingConstraint firstItem]
                                                                         attribute:[existingConstraint firstAttribute]
                                                                         relatedBy:[existingConstraint relation]
                                                                            toItem:[existingConstraint secondItem]
                                                                         attribute:[existingConstraint secondAttribute]
                                                                        multiplier:scalingFactor
                                                                          constant:[existingConstraint constant]
        ];
        [newConstraint setPriority:[existingConstraint priority]];
        [newConstraint setIdentifier:[existingConstraint identifier]];
        [newConstraint setShouldBeArchived:[existingConstraint shouldBeArchived]];

        // deactivate the existing contraint and activate the new one
        [NSLayoutConstraint deactivateConstraints:[NSArray arrayWithObject:existingConstraint]];
        [NSLayoutConstraint activateConstraints:[NSArray arrayWithObject:newConstraint]];
    }
    
    [self layoutSubtreeIfNeeded];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameOverlayImageScalingChanged
                                                        object:self
                                                      userInfo:nil
    ];
}

- (void)setOverlayImageAspectRatio:(CGFloat)aspectRatio
{
    _overlayImageAspectRatio = aspectRatio;
    
    // update the overlay image view
    [_overlayImageView removeConstraints:[_overlayImageView constraints]];
    
    NSLayoutConstraint *overlayAspect = [NSLayoutConstraint constraintWithItem:_overlayImageView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_overlayImageView
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:_overlayImageAspectRatio
                                                                      constant:0
    ];
    
    [_overlayImageView addConstraint:overlayAspect];
    
    // update the overlay image view
    NSArray *containerViewConstraints = [_containerView constraints];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem == %@ AND (firstAttribute == %d OR firstAttribute == %d)", _overlayImageView, NSLayoutAttributeWidth, NSLayoutAttributeHeight];
    NSArray *filteredArray = [containerViewConstraints filteredArrayUsingPredicate:predicate];

    for (NSLayoutConstraint *existingConstraint in filteredArray) {
        
        NSLayoutAttribute attribute = (_overlayImageAspectRatio < 1) ? NSLayoutAttributeHeight : NSLayoutAttributeWidth;

        NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:[existingConstraint firstItem]
                                                                         attribute:attribute
                                                                         relatedBy:[existingConstraint relation]
                                                                            toItem:[existingConstraint secondItem]
                                                                         attribute:attribute
                                                                        multiplier:[existingConstraint multiplier]
                                                                          constant:[existingConstraint constant]
        ];
        [newConstraint setPriority:[existingConstraint priority]];
        [newConstraint setIdentifier:[existingConstraint identifier]];
        [newConstraint setShouldBeArchived:[existingConstraint shouldBeArchived]];

        // deactivate the existing contraint and activate the new one
        [NSLayoutConstraint deactivateConstraints:[NSArray arrayWithObject:existingConstraint]];
        [NSLayoutConstraint activateConstraints:[NSArray arrayWithObject:newConstraint]];
    }
    
    [self layoutSubtreeIfNeeded];
}

- (void)setOverlayPosition:(NSPoint)position
{
    _overlayPosition = position;
    
    NSArray *imageViewConstraints = [_containerView constraints];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem == %@ AND (firstAttribute == %d OR firstAttribute == %d)", _overlayImageView, NSLayoutAttributeCenterX, NSLayoutAttributeCenterY];
    NSArray *filteredArray = [imageViewConstraints filteredArrayUsingPredicate:predicate];

    for (NSLayoutConstraint *existingConstraint in filteredArray) {
        
        CGFloat newMultiplier = ([existingConstraint firstAttribute] == NSLayoutAttributeCenterX) ? position.x : position.y;
        
        NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:[existingConstraint firstItem]
                                                                         attribute:[existingConstraint firstAttribute]
                                                                         relatedBy:[existingConstraint relation]
                                                                            toItem:[existingConstraint secondItem]
                                                                         attribute:[existingConstraint secondAttribute]
                                                                        multiplier:newMultiplier
                                                                          constant:[existingConstraint constant]
        ];
        [newConstraint setPriority:[existingConstraint priority]];
        [newConstraint setIdentifier:[existingConstraint identifier]];
        [newConstraint setShouldBeArchived:[existingConstraint shouldBeArchived]];
        
        // deactivate the existing contraint and activate the new one
        [NSLayoutConstraint deactivateConstraints:[NSArray arrayWithObject:existingConstraint]];
        [NSLayoutConstraint activateConstraints:[NSArray arrayWithObject:newConstraint]];
    }
    
    [self layoutSubtreeIfNeeded];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameOverlayImagePositionChanged
                                                        object:self
                                                      userInfo:nil
    ];
}

- (NSView*)icon
{
    // make sure we use an off-screen copy of the view
    return [[self copy] containerView];
}

#pragma mark MTOverlayImageViewDelegate

- (void)view:(MTOverlayImageView *)view didEndDraggingAtPoint:(NSPoint)point
{
    NSPoint newPoint = NSMakePoint(
                                   (point.x * 2.0 + NSWidth([view frame])) / NSWidth([_containerView frame]),
                                   (2 * (point.y - (NSHeight([_containerView frame]) - (NSHeight([view frame]) / 2.0)))) / -NSHeight([_containerView frame])
                                   );
    
    [self setOverlayPosition:newPoint];
}

- (void)view:(MTOverlayImageView *)view hasBeenRemovedFromSuperView:(NSView *)superview
{
    [self willChangeValueForKey:@"overlayImage"];
    [self setOverlayImage:nil];
    [self didChangeValueForKey:@"overlayImage"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameOverlayImageChanged
                                                        object:self
                                                      userInfo:nil
    ];
}

@end
