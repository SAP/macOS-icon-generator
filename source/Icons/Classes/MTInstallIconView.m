/*
     MTInstallIconView.m
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

#import "MTInstallIconView.h"
#import "Constants.h"

@interface MTInstallIconView ()
@property (nonatomic, strong, readwrite) NSView *containerView;
@property (nonatomic, strong, readwrite) NSImageView *imageView;
@property (nonatomic, strong, readwrite) MTOverlayImageView *overlayImageView;
@property (nonatomic, strong, readwrite) MTBannerView *bannerView;
@property (nonatomic, strong, readwrite) NSImage *image;
@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
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
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
    
    [self registerForDraggedTypes:[NSImage imageTypes]];
    
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
                                                                 multiplier:3
                                                                   constant:0];
    
    NSLayoutConstraint *imageHeight = [NSLayoutConstraint constraintWithItem:_imageView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_containerView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1
                                                                    constant:0];
    
    [_containerView addConstraints:[NSArray arrayWithObjects:imageCenterX, imageCenterY, imageWidth, imageHeight, nil]];
    
    // add the overlay view
    _overlayImageView = [[MTOverlayImageView alloc] initWithFrame:[_containerView bounds]];
    [_overlayImageView setDelegate:self];
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
    
    if ([_userDefaults boolForKey:kMTDefaultsRememberOverlayPositionKey]) {

        _overlayImageScalingFactor = ([_userDefaults floatForKey:kMTDefaultsOverlayScalingKey] > 0) ? [_userDefaults floatForKey:kMTDefaultsOverlayScalingKey] : _overlayImageScalingFactor;
        
        NSString *storedPositionString = [_userDefaults stringForKey:kMTDefaultsOverlayPositionKey];
        
        if (storedPositionString) {
            
            NSPoint storedPosition = NSPointFromString(storedPositionString);
            if (storedPosition.x > 0 && storedPosition.y > 0) { _overlayPosition = storedPosition; }
        }
    }
  
    // add constraints
    NSLayoutConstraint *overlayCenterX = [NSLayoutConstraint constraintWithItem:_overlayImageView
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:_containerView
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:_overlayPosition.x
                                                                       constant:0
    ];
    
    NSLayoutConstraint *overlayCenterY = [NSLayoutConstraint constraintWithItem:_overlayImageView
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:_containerView
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:_overlayPosition.y
                                                                       constant:0
    ];
    
    NSLayoutConstraint *overlayWidth = [NSLayoutConstraint constraintWithItem:_overlayImageView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_containerView
                                                                    attribute:NSLayoutAttributeWidth
                                                                   multiplier:_overlayImageScalingFactor
                                                                     constant:0
    ];
    

    [_containerView addSubview:_overlayImageView];
    [_containerView addConstraints:[NSArray arrayWithObjects:overlayCenterX, overlayCenterY, overlayWidth, nil]];
    
    // add the banner overlay
    _bannerView = [[MTBannerView alloc] initWithFrame:[_containerView bounds]];
    [_bannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_bannerView setMinimumTextMargin:kMTBannerTextMarginDefault];
    [_containerView addSubview:_bannerView];
    
    // add constraints
    NSLayoutConstraint *bannerLeft = [NSLayoutConstraint constraintWithItem:_bannerView
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_containerView
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1
                                                                   constant:0
    ];
    
    NSLayoutConstraint *bannerTop = [NSLayoutConstraint constraintWithItem:_bannerView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_containerView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:0
    ];
    
    NSLayoutConstraint *bannerWidth = [NSLayoutConstraint constraintWithItem:_bannerView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_containerView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                  multiplier:1
                                                                    constant:0
    ];
    
    NSLayoutConstraint *bannerHeight = [NSLayoutConstraint constraintWithItem:_bannerView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_containerView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1
                                                                     constant:0
    ];
    
    [_containerView addConstraints:[NSArray arrayWithObjects:bannerLeft, bannerTop, bannerWidth, bannerHeight, nil]];
    
    [self layoutSubtreeIfNeeded];
}

- (void)setImage:(NSImage *)image
{
    // make sure the MTDropView's layer with tag 1 is hidden
    [[self viewWithTag:1] setHidden:YES];
    
    _image = image;
    [_imageView setImage:image];
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
        
        // reset size and position
        if (![_userDefaults boolForKey:kMTDefaultsRememberOverlayPositionKey]) {
            
            [self setOverlayImageScalingFactor:kMTOverlayImageScalingDefault];
            
            CGFloat overlayInitialWidth = NSWidth([_containerView bounds]) * _overlayImageScalingFactor;
            NSPoint initialPosition = [self overlayMultiplierWithRect:NSMakeRect(
                                                                                 NSMidX([_containerView bounds]) - (overlayInitialWidth / 2),
                                                                                 NSMidY([_containerView bounds]) - (overlayInitialWidth / 2),
                                                                                 overlayInitialWidth,
                                                                                 overlayInitialWidth
                                                                                 )
            ];
            
            [self setOverlayPosition:(NSPoint)initialPosition];
        }
    }
}

- (NSPoint)overlayMultiplierWithRect:(NSRect)rect
{
    NSPoint multiplier = {1, 1};

    multiplier.x = (rect.origin.x * 2 + NSWidth(rect)) / NSWidth([_containerView frame]);
    multiplier.y = (2 * (rect.origin.y - (NSHeight([_containerView frame]) - (NSHeight(rect) / 2)))) / -NSHeight([_containerView frame]);

    return multiplier;
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

- (void)setOverlayImageScalingFactor:(CGFloat)scalingFactor
{
    _overlayImageScalingFactor = scalingFactor;

    // update the overlay image view
    NSArray *containerViewConstraints = [_containerView constraints];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstItem == %@ AND (firstAttribute == %d OR firstAttribute == %d)", _overlayImageView, NSLayoutAttributeWidth, NSLayoutAttributeHeight];
    NSArray *filteredArray = [containerViewConstraints filteredArrayUsingPredicate:predicate];
    CGFloat newMultiplier = scalingFactor;

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
    return _containerView;
}

#pragma mark MTOverlayImageViewDelegate

- (void)view:(MTOverlayImageView *)view didEndDraggingAtPoint:(NSPoint)point
{
    NSPoint newPoint = [self overlayMultiplierWithRect:NSMakeRect(point.x, point.y, NSWidth([view frame]), NSHeight([view frame]))];
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
