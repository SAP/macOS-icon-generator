/*
     MTDropView.m
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

#import "MTDropView.h"
#import "MTImage.h"
#import <UniformTypeIdentifiers/UTCoreTypes.h>

@interface MTDropView ()
@property (nonatomic, strong, readwrite) NSImage *image;
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
    NSLayoutConstraint *bezelViewLeft = [NSLayoutConstraint constraintWithItem:bezelImageView
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1
                                                                      constant:2];
        
    NSLayoutConstraint *bezelViewRight = [NSLayoutConstraint constraintWithItem:bezelImageView
                                                                      attribute:NSLayoutAttributeTrailing
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeTrailing
                                                                     multiplier:1
                                                                       constant:-2];
    
    NSLayoutConstraint *bezelViewTop = [NSLayoutConstraint constraintWithItem:bezelImageView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1
                                                                     constant:2];

    NSLayoutConstraint *bezelViewBottom = [NSLayoutConstraint constraintWithItem:bezelImageView
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1
                                                                        constant:-2];

    [self addConstraints:[NSArray arrayWithObjects:bezelViewLeft, bezelViewRight, bezelViewTop, bezelViewBottom, nil]];
    
    NSTextField *dropLabelText = [NSTextField wrappingLabelWithString:NSLocalizedString(@"dropViewLabel", nil)];
    [dropLabelText setAlignment:NSTextAlignmentCenter];
    [dropLabelText setTag:1];
    [dropLabelText setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:dropLabelText];
    
    // add constraints
    NSLayoutConstraint *labelCenterX = [NSLayoutConstraint constraintWithItem:dropLabelText
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1
                                                                     constant:0];
        
    NSLayoutConstraint *labelCenterY = [NSLayoutConstraint constraintWithItem:dropLabelText
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1
                                                                     constant:0];
    
    NSLayoutConstraint *labelRatio = [NSLayoutConstraint constraintWithItem:dropLabelText
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:.6
                                                                   constant:0];

    [self addConstraints:[NSArray arrayWithObjects:labelCenterX, labelCenterY, labelRatio, nil]];
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
    [[self viewWithTag:1] setHidden:YES];
    _image = image;
}


#pragma mark dragging methods

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSDragOperation dragOperation = NSDragOperationNone;
    _highlight = NO;
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *supportedFileTypes = [NSArray arrayWithObjects:UTTypeImage, UTTypeApplicationBundle, nil];

    if ([[pboard types] containsObject:NSPasteboardTypeFileURL]) {
        
        NSURL *imageURL = [NSURL URLFromPasteboard:pboard];
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

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
    BOOL success = NO;
    
    NSURL *imageURL = [NSURL URLFromPasteboard:[sender draggingPasteboard]];
    NSImage *currentImage = [NSImage imageWithFileAtURL:imageURL];

    if ([currentImage isValid]) {
        
        [self setImage:currentImage];
        
        if (_delegate && [_delegate respondsToSelector:@selector(view:didChangeImageAtURL:)]) {
            [_delegate view:self didChangeImageAtURL:imageURL];
        }
        
        [self setNeedsDisplay:YES];
        success = YES;
    }
    
    return success;
}

@end
