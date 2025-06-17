/*
     MTUninstallIconView.m
     Copyright 2022-2025 SAP SE
     
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

@interface MTUninstallIconView ()
@property (nonatomic, strong, readwrite) NSView *containerView;
@property (nonatomic, strong, readwrite) NSImageView *imageView;
@property (nonatomic, strong, readwrite) NSImageView *closeBoxView;
@property (nonatomic, strong, readwrite) NSImage *image;
@end

@implementation MTUninstallIconView

@dynamic image;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) { [self setUpViews]; }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) { [self setUpViews]; }

    return self;
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
    NSLayoutConstraint *containerLeft = [NSLayoutConstraint constraintWithItem:_containerView
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1
                                                                      constant:7];
        
    NSLayoutConstraint *containerRight = [NSLayoutConstraint constraintWithItem:_containerView
                                                                      attribute:NSLayoutAttributeTrailing
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeTrailing
                                                                     multiplier:1
                                                                       constant:-7];
    
    NSLayoutConstraint *containerTop = [NSLayoutConstraint constraintWithItem:_containerView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1
                                                                     constant:7];

    NSLayoutConstraint *containerBottom = [NSLayoutConstraint constraintWithItem:_containerView
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1
                                                                        constant:-7];

    [self addConstraints:[NSArray arrayWithObjects:containerLeft, containerRight, containerTop, containerBottom, nil]];
    
    // create the icon image
    _imageView = [[NSImageView alloc] initWithFrame:[_containerView bounds]];
    [_imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_imageView unregisterDraggedTypes];
    [_imageView setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_imageView setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationVertical];
        
    // add the view
    [_containerView addSubview:_imageView];
    
    // add constraints
    NSLayoutConstraint *imageCenterX = [NSLayoutConstraint constraintWithItem:_imageView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_containerView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1
                                                                     constant:0];
        
    NSLayoutConstraint *imageCenterY = [NSLayoutConstraint constraintWithItem:_imageView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_containerView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1
                                                                     constant:0];
    
    NSLayoutConstraint *imageWidth = [NSLayoutConstraint constraintWithItem:_imageView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_containerView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1
                                                                   constant:0];

    NSLayoutConstraint *imageHeight = [NSLayoutConstraint constraintWithItem:_imageView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_containerView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1
                                                                    constant:0];

    [_containerView addConstraints:[NSArray arrayWithObjects:imageCenterX, imageCenterY, imageWidth, imageHeight, nil]];

    NSImage *closeBoxImage = [[NSBundle containerBundleForClass:[self class]] imageForResource:@"closebox"];

    _closeBoxView = [[NSImageView alloc] initWithFrame:[_containerView bounds]];
    [_closeBoxView setImage:closeBoxImage];
    [_closeBoxView setHidden:YES];
    [_closeBoxView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_closeBoxView setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_closeBoxView setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationVertical];
    [_containerView addSubview:_closeBoxView];
    
    // add constraints
    NSLayoutConstraint *overlayLeft = [NSLayoutConstraint constraintWithItem:_closeBoxView
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_containerView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1
                                                                    constant:0];
    
    NSLayoutConstraint *overlayTop = [NSLayoutConstraint constraintWithItem:_closeBoxView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_containerView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1
                                                                   constant:0];

    NSLayoutConstraint *overlayWidth = [NSLayoutConstraint constraintWithItem:_closeBoxView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_containerView
                                                                    attribute:NSLayoutAttributeWidth
                                                                   multiplier:0.23
                                                                     constant:0];
    
    NSLayoutConstraint *overlayHeight = [NSLayoutConstraint constraintWithItem:_closeBoxView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_containerView
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:0.23
                                                                      constant:0];

    [_containerView addConstraints:[NSArray arrayWithObjects:overlayLeft, overlayTop, overlayWidth, overlayHeight, nil]];
    
    [self layoutSubtreeIfNeeded];
}

- (void)setImage:(NSImage *)image
{
    _image = image;
    
    if ([_image isValid]) {
        
        // make sure the MTDropView's layer with tag 1 is hidden
        [[self viewWithTag:1] setHidden:YES];
    
        [_imageView setImage:_image];
        [_closeBoxView setHidden:NO];
    
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
    NSArray *imageViewConstraints = [_containerView constraints];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem == %@ AND (firstAttribute = %d OR firstAttribute = %d)", _imageView, NSLayoutAttributeWidth, NSLayoutAttributeHeight];
    NSArray *filteredArray = [imageViewConstraints filteredArrayUsingPredicate:predicate];
    CGFloat newMultiplier = 1.0 - imageInset;

    for (NSLayoutConstraint *existingConstraint in filteredArray) {

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
        
        [self layoutSubtreeIfNeeded];
    }
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

- (void)setCloseBox:(NSImage *)closeBox
{
    [_closeBoxView setImage:closeBox];
}

- (NSImage*)closeBox
{
    return [_closeBoxView image];
}

- (NSView*)icon
{
    return _containerView;
}

@end
