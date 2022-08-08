/*
     MTInstallIconView.m
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

#import "MTInstallIconView.h"

@interface MTInstallIconView ()
@property (nonatomic, strong, readwrite) NSView *containerView;
@property (nonatomic, strong, readwrite) NSImageView *imageView;
@property (nonatomic, strong, readwrite) MTBannerView *bannerView;
@property (nonatomic, strong, readwrite) NSImage *image;
@end

@implementation MTInstallIconView

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

    // add the banner overlay
    _bannerView = [[MTBannerView alloc] initWithFrame:[_containerView bounds]];
    [_bannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_containerView addSubview:_bannerView];
    
    // add constraints
    NSLayoutConstraint *overlayLeft = [NSLayoutConstraint constraintWithItem:_bannerView
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_containerView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1
                                                                    constant:0];
    
    NSLayoutConstraint *overlayTop = [NSLayoutConstraint constraintWithItem:_bannerView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_containerView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1
                                                                   constant:0];

    NSLayoutConstraint *overlayWidth = [NSLayoutConstraint constraintWithItem:_bannerView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_containerView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1
                                                                     constant:0];
    
    NSLayoutConstraint *overlayHeight = [NSLayoutConstraint constraintWithItem:_bannerView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_containerView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:0];

    [_containerView addConstraints:[NSArray arrayWithObjects:overlayLeft, overlayTop, overlayWidth, overlayHeight, nil]];
    
    [self layoutSubtreeIfNeeded];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

- (void)setImage:(NSImage *)image
{
    // make sure the MTDropView's layer with tag 1 is hidden
    [[self viewWithTag:1] setHidden:YES];
    
    _image = image;
    [_imageView setImage:image];
}

- (void)setBannerAttributes:(NSAttributedString*)attributedString
{
    _bannerAttributes = attributedString;
    [_bannerView setAttributes:attributedString];
}

- (void)setBannerIsMirrored:(BOOL)isMirrored
{
    _bannerIsMirrored = isMirrored;
    [_bannerView setIsMirrored:isMirrored];
}

- (NSView*)icon
{
    return _containerView;
}

@end
