/*
    MTUninstallIconView.m
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

#import "MTUninstallIconView.h"
#import "MTColorValueTransformer.h"

@interface MTUninstallIconView ()
@property (nonatomic, strong, readwrite) NSView *containerView;
@property (nonatomic, strong, readwrite) NSImageView *imageView;
@property (nonatomic, strong, readwrite) NSImage *image;
@property (assign) BOOL hasCustomDeleteBadge;
@end

@implementation MTUninstallIconView

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
    MTUninstallIconView *copiedView = [[[self class] allocWithZone:zone] initWithFrame:[self frame]];
    
    if (copiedView) {
        
        // to make sure we don't get an icon shape in an icon shape
        [copiedView setApplyIconShape:NO];
        [copiedView setImage:[_image copyWithZone:zone]];
        [copiedView setApplyIconShape:_applyIconShape];
        [copiedView setUsesOldIconShape:_usesOldIconShape];
        [copiedView setIsAppBundle:_isAppBundle];
        [copiedView setUnmodifiedImage:[_unmodifiedImage copyWithZone:zone]];
        
        [copiedView setImageInset:_imageInset];
        [copiedView setBadgeSize:_badgeSize];
        [copiedView setBadgePosition:_badgePosition];
        [copiedView setBadgeMargin:_badgeMargin];
        [copiedView setAutoInsetEnabled:_autoInsetEnabled];
        [copiedView setDeleteBadge:_deleteBadge];
    }
    
    return copiedView;
}

- (void)setUpViews
{    
    // add our container view that holds our images
    _containerView = [[NSView alloc] initWithFrame:[self bounds]];
    [_containerView setWantsLayer:YES];
    [_containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[_containerView layer] setMasksToBounds:YES];
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

    _deleteBadge = [[MTDeleteBadgeView alloc] initWithFrame:[_containerView bounds]];
    [self setDeleteBadge:nil];
    [_deleteBadge setHidden:YES];
    [_deleteBadge setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_deleteBadge setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_deleteBadge setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_deleteBadge setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationVertical];
    [_containerView addSubview:_deleteBadge];
    
    // add constraints for width and height
    NSLayoutConstraint *deleteBadgeWidth = [[_deleteBadge widthAnchor] constraintEqualToAnchor:[_containerView widthAnchor] multiplier:kMTBadgeIconSizeDefault];
    NSLayoutConstraint *deleteBadgeHeight = [[_deleteBadge heightAnchor] constraintEqualToAnchor:[_containerView heightAnchor] multiplier:kMTBadgeIconSizeDefault];
    [_containerView addConstraints:[NSArray arrayWithObjects:deleteBadgeWidth, deleteBadgeHeight, nil]];
    
    // add constraints for the badge position
    [self setBadgePosition:MTBadgePositionTopLeft];

    [self layoutSubtreeIfNeeded];
}

- (void)setImage:(NSImage *)image
{
    [super setImage:image];
    
    if ([_image isValid]) {
    
        [_imageView setImage:_image];
        [_deleteBadge setHidden:NO];
    
        // inset
        if (_autoInsetEnabled) { [self setImageInset:[self autoInset]]; }
    }
}

- (CGFloat)autoInset
{
    CGFloat imageInset = kMTImageInsetDefault;
    NSImage *sourceImage = [self image];
    
    if ([sourceImage isValid]) {
        
        NSBitmapImageRep *sourceImageRep = [[NSBitmapImageRep alloc] initWithData:[sourceImage TIFFRepresentation]];
        
        // check if the image has an alpha channel, otherwise
        // there's no transparency and we return kMTImageInsetDefault
        if ([sourceImageRep hasAlpha]) {
            
            // we scale large images down to speed up processing
            CGFloat maxImageSize = 512;
            if ([sourceImageRep pixelsWide] > maxImageSize || [sourceImageRep pixelsHigh] > maxImageSize) {
                sourceImage = [sourceImage imageScaledToSize:NSMakeSize(maxImageSize, maxImageSize) maintainAspectRatio:YES];
            }
            
            CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)[sourceImage TIFFRepresentation], NULL);
            
            if (imageSource) {
                                
                CGImageRef imageRef =  CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);

                if (imageRef) {
                    
                    size_t imageWidth = CGImageGetWidth(imageRef);
                    size_t imageHeight = CGImageGetHeight(imageRef);

                    CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
                    
                    if (imageData) {
                        
                        const UInt32 *pixels = (const UInt32*)CFDataGetBytePtr(imageData);
                        CGFloat minX = imageWidth;
                        CGFloat minY = imageHeight;
                        CGFloat maxX = 0;
                        CGFloat maxY = 0;

                        // loop through the image's pixels and check if
                        // they are transparent or not
                        for (int y = 0; y < imageHeight; y++) {
                            for (int x = 0; x < imageWidth; x++) {

                                // the pixel is not transparent
                                if (pixels[(y * imageWidth) + x] & 0xFF000000) {
                                    if (x < minX) { minX = x; }
                                    if (x > maxX) { maxX = x; }
                                    if (y < minY) { minY = y; }
                                    if (y > maxY) { maxY = y; }
                                }
                            }
                        }

                        CFRelease(imageData);

                        // calculate how many percent smaller the actual image is
                        CGFloat croppedWidth = imageWidth - (maxX + 1) + minX;
                        CGFloat croppedHeigth = imageHeight - (maxY + 1) + minY;
                        CGFloat insetInPercent = (croppedWidth < croppedHeigth) ? (1.0 / imageWidth) * croppedWidth : (1.0 / imageHeight) * croppedHeigth;
                        
                        // if the actual image is more than kMTImageInsetDefault percent
                        // smaller than the image size, we return 0. Otherwise we return
                        // how many percent additional inset is needed, to reach
                        // kMTImageInsetDefault percent.
                        imageInset = (insetInPercent > kMTImageInsetDefault) ? 0 : kMTImageInsetDefault - insetInPercent;
                    }
                    
                    CGImageRelease(imageRef);
                }
                
                CFRelease(imageSource);
            }
        }
    }
    
    return imageInset;
}

- (void)setImageInset:(CGFloat)imageInset
{
    _imageInset = imageInset;

    // update the image view
    NSArray *constraints = [_containerView constraints];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem == %@ AND (firstAttribute == %d OR firstAttribute == %d)", _imageView, NSLayoutAttributeWidth, NSLayoutAttributeHeight];
    NSArray *filteredArray = [constraints filteredArrayUsingPredicate:predicate];

    for (NSLayoutConstraint *existingConstraint in filteredArray) {

        NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:[existingConstraint firstItem]
                                                                         attribute:[existingConstraint firstAttribute]
                                                                         relatedBy:[existingConstraint relation]
                                                                            toItem:[existingConstraint secondItem]
                                                                         attribute:[existingConstraint secondAttribute]
                                                                        multiplier:1.0 - imageInset
                                                                          constant:[existingConstraint constant]
        ];
        [newConstraint setPriority:[existingConstraint priority]];
        [newConstraint setIdentifier:[existingConstraint identifier]];
        [newConstraint setShouldBeArchived:[existingConstraint shouldBeArchived]];

        // deactivate the existing contraint and activate the new one
        [NSLayoutConstraint deactivateConstraints:[NSArray arrayWithObject:existingConstraint]];
        [NSLayoutConstraint activateConstraints:[NSArray arrayWithObject:newConstraint]];
        
        [self layoutSubtreeIfNeeded];
    }
}

- (void)setBadgeSize:(CGFloat)badgeSize
{
    _badgeSize = badgeSize;

    NSArray *constraints = [_containerView constraints];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem == %@ AND (firstAttribute == %d OR firstAttribute == %d)", _deleteBadge, NSLayoutAttributeWidth, NSLayoutAttributeHeight];
    NSArray *filteredArray = [constraints filteredArrayUsingPredicate:predicate];

    for (NSLayoutConstraint *existingConstraint in filteredArray) {

        NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:[existingConstraint firstItem]
                                                                         attribute:[existingConstraint firstAttribute]
                                                                         relatedBy:[existingConstraint relation]
                                                                            toItem:[existingConstraint secondItem]
                                                                         attribute:[existingConstraint secondAttribute]
                                                                        multiplier:badgeSize
                                                                          constant:[existingConstraint constant]
        ];
        [newConstraint setPriority:[existingConstraint priority]];
        [newConstraint setIdentifier:[existingConstraint identifier]];
        [newConstraint setShouldBeArchived:[existingConstraint shouldBeArchived]];

        // deactivate the existing contraint and activate the new one
        [NSLayoutConstraint deactivateConstraints:[NSArray arrayWithObject:existingConstraint]];
        [NSLayoutConstraint activateConstraints:[NSArray arrayWithObject:newConstraint]];
        
        [self layoutSubtreeIfNeeded];
    }
}

- (void)setBadgeMargin:(CGFloat)badgeMargin
{
    _badgeMargin = badgeMargin;
    
    NSArray *constraints = [_containerView constraints];
    NSArray *filteredArray = [constraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSLayoutConstraint *constraint, NSDictionary *bindings) {
        return ([[constraint firstItem] isKindOfClass:[NSLayoutGuide class]] &&
                ([constraint firstAttribute] == NSLayoutAttributeWidth || [constraint firstAttribute] == NSLayoutAttributeHeight));
     }]];

    for (NSLayoutConstraint *existingConstraint in filteredArray) {

        NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:[existingConstraint firstItem]
                                                                         attribute:[existingConstraint firstAttribute]
                                                                         relatedBy:[existingConstraint relation]
                                                                            toItem:[existingConstraint secondItem]
                                                                         attribute:[existingConstraint secondAttribute]
                                                                        multiplier:badgeMargin
                                                                          constant:[existingConstraint constant]
        ];
        [newConstraint setPriority:[existingConstraint priority]];
        [newConstraint setIdentifier:[existingConstraint identifier]];
        [newConstraint setShouldBeArchived:[existingConstraint shouldBeArchived]];

        // deactivate the existing contraint and activate the new one
        [NSLayoutConstraint deactivateConstraints:[NSArray arrayWithObject:existingConstraint]];
        [NSLayoutConstraint activateConstraints:[NSArray arrayWithObject:newConstraint]];
        
        [self layoutSubtreeIfNeeded];
    }
}

- (void)setBadgePosition:(MTBadgePosition)badgePosition
{
    _badgePosition = badgePosition;
    
    // remove all position constraints
    NSArray *constraints = [_containerView constraints];
    NSArray *filteredArray = [constraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSLayoutConstraint *constraint, NSDictionary *bindings) {
        return ([[constraint firstItem] isKindOfClass:[NSLayoutGuide class]] ||
                ([constraint firstItem] == self->_deleteBadge && ([constraint firstAttribute] != NSLayoutAttributeWidth && [constraint firstAttribute] != NSLayoutAttributeHeight)));
     }]];
    [_containerView removeConstraints:filteredArray];
    
    // layout guide
    NSLayoutGuide *marginGuide = [[NSLayoutGuide alloc] init];
    [_containerView addLayoutGuide:marginGuide];
    
    // width/height = multiplier * width/height of the container
    NSLayoutConstraint *layoutGuideWidth = [[marginGuide widthAnchor] constraintEqualToAnchor:[_containerView widthAnchor]
                                                                                   multiplier:(_badgeMargin >= kMTBadgeIconMarginMin) ? _badgeMargin : kMTBadgeIconMarginMin];
    NSLayoutConstraint *layoutGuideHeight = [[marginGuide heightAnchor] constraintEqualToAnchor:[_containerView heightAnchor]
                                                                                     multiplier:(_badgeMargin >= kMTBadgeIconMarginMin) ? _badgeMargin : kMTBadgeIconMarginMin];
    [_containerView addConstraints:[NSArray arrayWithObjects:layoutGuideWidth, layoutGuideHeight, nil]];
    
    switch (badgePosition) {
            
        case MTBadgePositionTopLeft:
        default: {
            
            NSLayoutConstraint *layoutGuideLeading = [[marginGuide leadingAnchor] constraintEqualToAnchor:[_containerView leadingAnchor]];
            NSLayoutConstraint *layoutGuideTop = [[marginGuide topAnchor] constraintEqualToAnchor:[_containerView topAnchor]];
            NSLayoutConstraint *deleteBadgeLeading = [[_deleteBadge leadingAnchor] constraintEqualToAnchor:[marginGuide trailingAnchor]];
            NSLayoutConstraint *deleteBadgeTop = [[_deleteBadge topAnchor] constraintEqualToAnchor:[marginGuide bottomAnchor]];
            [_containerView addConstraints:[NSArray arrayWithObjects:layoutGuideLeading, layoutGuideTop, deleteBadgeLeading, deleteBadgeTop, nil]];
            
            break;
        }
            
        case MTBadgePositionTopRight: {
            
            NSLayoutConstraint *layoutGuideTrailing = [[marginGuide trailingAnchor] constraintEqualToAnchor:[_containerView trailingAnchor]];
            NSLayoutConstraint *layoutGuideTop = [[marginGuide topAnchor] constraintEqualToAnchor:[_containerView topAnchor]];
            NSLayoutConstraint *deleteBadgeTrailing = [[_deleteBadge trailingAnchor] constraintEqualToAnchor:[marginGuide leadingAnchor]];
            NSLayoutConstraint *deleteBadgeTop = [[_deleteBadge topAnchor] constraintEqualToAnchor:[marginGuide bottomAnchor]];
            [_containerView addConstraints:[NSArray arrayWithObjects:layoutGuideTrailing, layoutGuideTop, deleteBadgeTrailing, deleteBadgeTop, nil]];
            
            break;
        }
            
        case MTBadgePositionBottomLeft: {
            
            NSLayoutConstraint *layoutGuideLeading = [[marginGuide leadingAnchor] constraintEqualToAnchor:[_containerView leadingAnchor]];
            NSLayoutConstraint *layoutGuideBottom = [[marginGuide bottomAnchor] constraintEqualToAnchor:[_containerView bottomAnchor]];
            NSLayoutConstraint *deleteBadgeLeading = [[_deleteBadge leadingAnchor] constraintEqualToAnchor:[marginGuide trailingAnchor]];
            NSLayoutConstraint *deleteBadgeBottom = [[_deleteBadge bottomAnchor] constraintEqualToAnchor:[marginGuide topAnchor]];
            [_containerView addConstraints:[NSArray arrayWithObjects:layoutGuideLeading, layoutGuideBottom, deleteBadgeLeading, deleteBadgeBottom, nil]];
            
            break;
        }
            
        case MTBadgePositionBottomRight: {
            
            NSLayoutConstraint *layoutGuideTrailing = [[marginGuide trailingAnchor] constraintEqualToAnchor:[_containerView trailingAnchor]];
            NSLayoutConstraint *layoutGuideBottom = [[marginGuide bottomAnchor] constraintEqualToAnchor:[_containerView bottomAnchor]];
            NSLayoutConstraint *deleteBadgeTrailing = [[_deleteBadge trailingAnchor] constraintEqualToAnchor:[marginGuide leadingAnchor]];
            NSLayoutConstraint *deleteBadgeBottom = [[_deleteBadge bottomAnchor] constraintEqualToAnchor:[marginGuide topAnchor]];
            [_containerView addConstraints:[NSArray arrayWithObjects:layoutGuideTrailing, layoutGuideBottom, deleteBadgeTrailing, deleteBadgeBottom, nil]];
            
            break;
        }
    }
    
    [self layoutSubtreeIfNeeded];
}

- (void)animateWithDuration:(NSTimeInterval)duration repeatCount:(NSInteger)repeatCount
{
    if (duration > 0) {
    
        // let the image shake
        CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        [shakeAnimation setValueFunction:[CAValueFunction functionWithName:kCAValueFunctionRotateZ]];
        [shakeAnimation setDuration:duration];
        [shakeAnimation setAutoreverses:NO];
        [shakeAnimation setRemovedOnCompletion:NO];
        [shakeAnimation setRepeatCount:repeatCount];

        // define the rotation
        CGFloat rotationAngle = 2.0;
        NSArray *animationValues = [NSArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0],
                                    [NSNumber numberWithFloat:(-rotationAngle / 180.0) * M_PI],
                                    [NSNumber numberWithFloat:0.0],
                                    [NSNumber numberWithFloat:(rotationAngle / 180.0) * M_PI],
                                    [NSNumber numberWithFloat:0.0],
                                    nil];
        [shakeAnimation setValues:animationValues];

        CGPoint rotationPoint = CGPointMake(
                                            NSMidX([_containerView frame]),
                                            NSMidY([_containerView frame])
                                            );
        CGPoint anchorPoint =  CGPointMake(
                                           (rotationPoint.x - NSMinX([_containerView frame])) / NSWidth([_containerView frame]),
                                            (rotationPoint.y - NSMinY([_containerView frame])) / NSHeight([_containerView frame])
                                            );
        [[_containerView layer] setAnchorPoint:anchorPoint];
        [[_containerView layer] setPosition:rotationPoint];
        [[_containerView layer] addAnimation:shakeAnimation forKey:nil];
    }
}

- (void)setDeleteBadge:(MTDeleteBadgeView*)deleteBadge
{
    self.hasCustomDeleteBadge = [[deleteBadge image] isValid];
    
    if (_hasCustomDeleteBadge) {
        
        [_deleteBadge setImage:[deleteBadge image]];
        [_deleteBadge setShowsShadow:[deleteBadge showsShadow]];
        [_deleteBadge setShadowOffset:[deleteBadge shadowOffset]];
        [_deleteBadge setShadowAngle:[deleteBadge shadowAngle]];
        [_deleteBadge setShadowColor:[deleteBadge shadowColor]];
        [_deleteBadge setShadowRadius:[deleteBadge shadowRadius]];
        
        [self layoutSubtreeIfNeeded];

    } else {
        
        NSImage *defaultImage = [[NSBundle containerBundleForClass:[self class]] imageForResource:@"DeleteBadge"];
        [_deleteBadge setImage:defaultImage];
        [_deleteBadge setShowsShadow:YES];
        [_deleteBadge setShadowOffset:kMTBadgeShadowOffsetDefault];
        [_deleteBadge setShadowAngle:kMTBadgeShadowAngleDefault];
        [_deleteBadge setShadowColor:nil];
        [_deleteBadge setShadowRadius:kMTBadgeShadowRadiusDefault];
        [self setBadgeSize:kMTBadgeIconSizeDefault];
        [self setBadgeMargin:kMTBadgeIconMarginDefault];
    }
}

- (NSView*)icon
{
    // make sure we use an off-screen copy of the view
    return [[self copy] containerView];
}

@end
