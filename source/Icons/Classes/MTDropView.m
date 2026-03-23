/*
    MTDropView.m
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

#import "MTDropView.h"
#import "MTImage.h"
#import "Constants.h"
#import <UniformTypeIdentifiers/UTCoreTypes.h>

@interface MTDropView ()
@property (nonatomic, strong, readwrite) NSView *dropZoneView;
@property (nonatomic, assign) BOOL highlight;

@end

@implementation MTDropView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) { [self setUpView]; }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) { [self setUpView]; }
    
    return self;
}

- (void)setUpView
{
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSPasteboardTypeFileURL]];
    
    // add our dummy image view to get the nice bezel
    NSImageView *bezelImageView = [[NSImageView alloc] initWithFrame:[self bounds]];
    [bezelImageView setImageFrameStyle:NSImageFrameGrayBezel];
    [bezelImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [bezelImageView unregisterDraggedTypes];
    [self addSubview:bezelImageView];
    
    // add constraints
    NSLayoutConstraint *bezelViewLeft = [[bezelImageView leadingAnchor] constraintEqualToAnchor:[self leadingAnchor] constant:2.0];
    NSLayoutConstraint *bezelViewRight = [[bezelImageView trailingAnchor] constraintEqualToAnchor:[self trailingAnchor] constant:-2.0];
    NSLayoutConstraint *bezelViewTop = [[bezelImageView topAnchor] constraintEqualToAnchor:[self topAnchor] constant:2.0];
    NSLayoutConstraint *bezelViewBottom = [[bezelImageView bottomAnchor] constraintEqualToAnchor:[self bottomAnchor] constant:-2.0];
    [self addConstraints:[NSArray arrayWithObjects:bezelViewLeft, bezelViewRight, bezelViewTop, bezelViewBottom, nil]];
    
    _dropZoneView = [[NSView alloc] initWithFrame:[self bounds]];
    [_dropZoneView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_dropZoneView unregisterDraggedTypes];
    
    NSImage *dropImage = [NSImage imageWithSystemSymbolName:@"photo.on.rectangle.angled" accessibilityDescription:nil];
    NSImageView *dropImageView = [NSImageView imageViewWithImage:dropImage];
    [dropImageView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [dropImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [dropImageView unregisterDraggedTypes];
    [_dropZoneView addSubview:dropImageView];
    
    // add constraints
    NSLayoutConstraint *imageTop = [[dropImageView topAnchor] constraintEqualToAnchor:[_dropZoneView topAnchor]];
    NSLayoutConstraint *imageWidth = [[dropImageView widthAnchor] constraintEqualToAnchor:[_dropZoneView widthAnchor] multiplier:.2];
    NSLayoutConstraint *imageHeight = [[dropImageView heightAnchor] constraintEqualToAnchor:[dropImageView widthAnchor]];
    NSLayoutConstraint *imageCenterX = [[dropImageView centerXAnchor] constraintEqualToAnchor:[_dropZoneView centerXAnchor]];
    [_dropZoneView addConstraints:[NSArray arrayWithObjects:imageTop, imageWidth, imageHeight, imageCenterX, nil]];
    
    NSTextField *dropLabelText = nil;
    
    if (@available(macOS 15.1, *)) {
        dropLabelText = [NSTextField wrappingLabelWithString:NSLocalizedString(@"dropViewLabelPlayground", nil)];
    } else {
        dropLabelText = [NSTextField wrappingLabelWithString:NSLocalizedString(@"dropViewLabel", nil)];
    }
    
    [dropLabelText setAlignment:NSTextAlignmentCenter];
    [dropLabelText setSelectable:NO];
    [dropLabelText setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_dropZoneView addSubview:dropLabelText];
    
    // add constraints
    NSLayoutConstraint *labelTop = [[dropLabelText topAnchor] constraintEqualToAnchor:[dropImageView bottomAnchor]];
    NSLayoutConstraint *labelBottom = [[dropLabelText bottomAnchor] constraintEqualToAnchor:[_dropZoneView bottomAnchor]];
    NSLayoutConstraint *labelLeading = [[dropLabelText leadingAnchor] constraintEqualToAnchor:[_dropZoneView leadingAnchor]];
    NSLayoutConstraint *labelTrailing = [[dropLabelText trailingAnchor] constraintEqualToAnchor:[_dropZoneView trailingAnchor]];
    [_dropZoneView addConstraints:[NSArray arrayWithObjects:labelTop, labelBottom, labelLeading, labelTrailing, nil]];
    
    [self addSubview:_dropZoneView];
    
    NSLayoutConstraint *dropZoneViewCenterX = [[_dropZoneView centerXAnchor] constraintEqualToAnchor:[self centerXAnchor]];
    NSLayoutConstraint *dropZoneViewCenterY = [[_dropZoneView centerYAnchor] constraintEqualToAnchor:[self centerYAnchor]];
    NSLayoutConstraint *dropZoneViewWidthRatio = [[_dropZoneView widthAnchor] constraintEqualToAnchor:[self widthAnchor] multiplier:.6];
    [self addConstraints:[NSArray arrayWithObjects:dropZoneViewCenterX, dropZoneViewCenterY, dropZoneViewWidthRatio, nil]];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (_highlight) {
        
        [[[NSColor blackColor] colorWithAlphaComponent:0.3] set];
        [NSBezierPath setDefaultLineWidth:5];
        NSBezierPath *roundedPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds], 3, 3) xRadius:5 yRadius:5];
        [roundedPath fill];
    }
}

- (void)setImage:(NSImage *)image
{
    [_dropZoneView setHidden:YES];
    _unmodifiedImage = image;
    
    if (!_isAppBundle && _applyIconShape) {
        
        MTIconView *iconView = [[MTIconView alloc] initWithFrame:NSMakeRect(0, 0, kMTOutputSizeMax, kMTOutputSizeMax)];
        [iconView setUsesOldIconShape:_usesOldIconShape];
        [iconView setImage:image];
                
        _image = [NSImage imageWithView:iconView size:NSMakeSize(kMTOutputSizeMax, kMTOutputSizeMax)];
       
    } else {
        
        _image = image;
    }
}

- (void)mouseDown:(NSEvent *)event
{
    if (_delegate && [_delegate respondsToSelector:@selector(view:hasBeenClickedAtLocation:)]) {
        [_delegate view:self hasBeenClickedAtLocation:[event locationInWindow]];
    }
}

#pragma mark dragging methods

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSDragOperation dragOperation = NSDragOperationNone;
    _highlight = NO;
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *supportedFileTypes = [NSArray arrayWithObjects:UTTypeImage, UTTypePDF, UTTypeApplicationBundle, nil];

    if ([[pboard types] containsObject:NSPasteboardTypeFileURL]) {
        
        NSURL *imageURL = [NSURL URLFromPasteboard:pboard];
        imageURL = [imageURL URLByResolvingSymlinksInPath];
        
        id utiValue = nil;
        [imageURL getResourceValue:&utiValue forKey:NSURLTypeIdentifierKey error:nil];

        if (utiValue) {
            
            BOOL isSupported = NO;
            UTType *fileType = [UTType typeWithIdentifier:utiValue];

            for (UTType *type in supportedFileTypes) {
                
                if ([fileType conformsToType:type]) {
                    
                    isSupported = YES;
                    break;
                }
            }

            if (isSupported){
                
                dragOperation = NSDragOperationCopy;
                _highlight = YES;
            }
        }
        
    } else if ([[pboard types] containsObject:NSPasteboardTypeTIFF]) {
        
        [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationConcurrent
                                          forView:self
                                          classes:[NSArray arrayWithObject:[NSPasteboardItem class]]
                                    searchOptions:[NSDictionary new]
                                       usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
            
            // make sure our dragging item's image remains the correct size
            [draggingItem setDraggingFrame:[[[draggingItem imageComponents] firstObject] frame]];
        }];
        
        dragOperation = NSDragOperationMove;
    }
    
    [self setNeedsDisplay:YES];
   
    return dragOperation;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    _highlight = NO;
    [self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    _highlight = NO;
    [self setNeedsDisplay:YES];
    
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    BOOL success = NO;
    
    NSURL *imageURL = [NSURL URLFromPasteboard:[sender draggingPasteboard]];
    NSImage *currentImage = [NSImage imageWithFileAtURL:imageURL];

    if ([currentImage isValid]) {
        
        id utiValue = nil;
        [imageURL getResourceValue:&utiValue forKey:NSURLTypeIdentifierKey error:nil];
        _isAppBundle = [utiValue isEqualTo:[UTTypeApplicationBundle identifier]];
        
        [self setImage:currentImage];
        
        if (_delegate && [_delegate respondsToSelector:@selector(view:didChangeImage:applicationBundle:)]) {
            [_delegate view:self didChangeImage:[currentImage copy] applicationBundle:_isAppBundle];
        }
                
        [self setNeedsDisplay:YES];
        success = YES;
    }
    
    return success;
}

@end
