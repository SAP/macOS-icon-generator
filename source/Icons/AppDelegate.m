/*
     AppDelegate.m
     Copyright 2016-2017 SAP SE
     
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

#import "AppDelegate.h"
#import "MTDragDropView.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet MTDragDropView *dragDropView;
@property (weak) IBOutlet NSImageView *processedImageView;
@property (weak) IBOutlet NSPopUpButton *imageSizesMenu;

@property (nonatomic, strong, readwrite) NSArray *imageSizes;
@property (nonatomic, assign) NSInteger imageOutputSize;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // fill the popup menu
    self.imageSizes = [[NSArray alloc] initWithObjects:
                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:64],  @"value", @"64 x 64 pixels", @"name", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:128], @"value", @"128 x 128 pixels", @"name", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:256], @"value", @"256 x 256 pixels", @"name", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:512], @"value", @"512 x 512 pixels", @"name", nil],
                       nil];
    
    // define the standard output size
    _imageOutputSize = 128;
    
    // get the currently selected size or set the standard size
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"imageSize"]) {
        _imageOutputSize = [[[NSUserDefaults standardUserDefaults] objectForKey:@"imageSize"] integerValue];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:_imageOutputSize] forKey:@"imageSize"];
    }
    
    // select the correct value in the popup menu
    NSUInteger sizeIndex = [self.imageSizes indexOfObjectPassingTest:^BOOL(NSDictionary *dict, NSUInteger idx, BOOL *stop)
                               {
                                   return [[dict objectForKey:@"value"] isEqual:[NSNumber numberWithInteger:_imageOutputSize]];
                               }];
    if (sizeIndex != NSNotFound) { [_imageSizesMenu selectItemAtIndex:sizeIndex]; }

    // restore the window position
    NSString *windowPosition = [[NSUserDefaults standardUserDefaults] objectForKey:@"WindowPosition"];
    
    if (windowPosition) {
        [_window setFrameFromString:windowPosition];
    } else {
        [_window center];
    }
    
    // show up the main window
    [_window makeKeyAndOrderFront:self];
    
    // add an observer to the main window to save position and size changes to the prefs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserDefaults:) name:NSWindowDidResizeNotification object:_window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserDefaults:) name:NSWindowDidMoveNotification object:_window];

    // observe our drop view for image changes
    [_dragDropView addObserver:self forKeyPath:@"image" options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString *)path ofObject:(id) object change:(NSDictionary *) change context:(void *)context
{
    if (object == _dragDropView && [path isEqualToString:@"image"]) {
        
        // create the uninstall image
        NSImage *originalImage = [[_dragDropView image] copy];
        NSSize imageSize = [originalImage size];
        
        float boxDiameter = imageSize.height * .23;
        NSImage *removeOverlay = [self getCloseBoxWithDiameter:boxDiameter];
        
        // we scale the new image a bit down to make sure our close box is a bit outside the icon
        NSImage *sizedImage = [[NSImage alloc] initWithSize:imageSize];
        [sizedImage lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [originalImage drawInRect:NSMakeRect(imageSize.width * .04, 0, imageSize.width * .96, imageSize.height * .96)
                         fromRect:NSMakeRect(0, 0, originalImage.size.width, originalImage.size.height)
                        operation:NSCompositeCopy
                         fraction:1.0];
        
        [removeOverlay drawAtPoint:NSMakePoint(0, imageSize.height - boxDiameter) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        [sizedImage unlockFocus];
        [_processedImageView setImage:sizedImage];
        
        // let the icon shake once
        [_processedImageView setWantsLayer:YES];
        [[_processedImageView layer] addAnimation:[self shakeIcon] forKey:@"transform.rotation.z"];
    }
}

- (IBAction)popupButtonPressed:(id)sender
{
    // update the preference file for the selected timeout
    NSInteger selectedIndex = [sender indexOfSelectedItem];
    NSDictionary *sizeDict = [self.imageSizes objectAtIndex:selectedIndex];
    NSInteger imageSize = [[sizeDict valueForKey:@"value"] integerValue];
    
    if (imageSize > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:imageSize] forKey:@"imageSize"];
        _imageOutputSize = imageSize;
    }
}

- (NSImage*)getCloseBoxWithDiameter:(float)diameter
{
    NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(diameter, diameter)];
    [newImage lockFocus];
    [NSGraphicsContext saveGraphicsState];
    
    // define the shadow
    float shadowSize = diameter * .03;
    float shadowBlurRadius = shadowSize;
    NSShadow *theShadow = [[NSShadow alloc] init];
    [theShadow setShadowOffset:NSMakeSize(shadowSize, -shadowSize)];
    [theShadow setShadowBlurRadius:shadowBlurRadius];
    [theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
    [theShadow set];
    
    // draw the outer white circle
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, shadowSize, diameter - shadowSize - shadowBlurRadius, diameter - shadowSize - shadowBlurRadius)];
    [[NSColor whiteColor] setFill];
    [circlePath fill];
    
    [NSGraphicsContext restoreGraphicsState];
    
    // draw the inner black circle
    float lineWith = diameter * .17;
    NSRect innerCircleRect = NSMakeRect(lineWith/2, lineWith/2 + shadowSize, diameter - lineWith - shadowSize - shadowBlurRadius, diameter - lineWith - shadowSize - shadowBlurRadius);
    circlePath = [NSBezierPath bezierPathWithOvalInRect:innerCircleRect];
    [[NSColor blackColor] setFill];
    [circlePath fill];
   
    // draw the crossing lines
    NSBezierPath *linePath = [NSBezierPath bezierPath];
    [linePath setLineWidth:lineWith/2];
    lineWith = lineWith * 1.3;
    [[NSColor whiteColor] setStroke];
    [linePath moveToPoint:NSMakePoint(innerCircleRect.origin.x + lineWith, innerCircleRect.origin.y + lineWith)];
    [linePath lineToPoint:NSMakePoint(innerCircleRect.origin.x + innerCircleRect.size.width - lineWith, innerCircleRect.origin.y + innerCircleRect.size.height - lineWith)];
    [linePath stroke];
    
    [linePath moveToPoint:NSMakePoint(innerCircleRect.origin.x + lineWith, innerCircleRect.origin.y + innerCircleRect.size.height - lineWith)];
    [linePath lineToPoint:NSMakePoint(innerCircleRect.origin.x + innerCircleRect.size.width - lineWith, innerCircleRect.origin.y + lineWith)];
    [linePath stroke];
    
    [newImage unlockFocus];

    return newImage;
}

- (CAKeyframeAnimation*)shakeIcon
{
    // animate the icon as the user knows it from Apple's launchpad
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animation setDuration:.2];
    [animation setRepeatCount:1];
    [animation setDelegate:self];
    
    // define the rotation
    NSArray *values = [NSArray arrayWithObjects:
                       [NSNumber numberWithFloat:(-2.0 / 180.0) * M_PI],
                       [NSNumber numberWithFloat:(2.0 / 180.0) * M_PI],
                       [NSNumber numberWithFloat:(-2.0 / 180.0) * M_PI],
                       nil];
    [animation setValues:values];

    return animation;
}

- (NSImage*)rotateImage:(NSImage*)sourceImage byDegrees:(CGFloat)degrees
{
    NSSize imageSize = [sourceImage size];
    NSImage *rotatedImage = [[NSImage alloc] initWithSize:imageSize];
    
    [rotatedImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    NSAffineTransform *rotateTF = [NSAffineTransform transform];
    
    // rotate from center
    NSPoint centerPoint = NSMakePoint(imageSize.width/2, imageSize.height/2);
    [rotateTF translateXBy:centerPoint.x yBy:centerPoint.y];
    [rotateTF rotateByDegrees:degrees];
    [rotateTF translateXBy:-centerPoint.x yBy:-centerPoint.y];
    [rotateTF concat];
    
    [sourceImage drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, imageSize.width, imageSize.height) operation:NSCompositeSourceOver
                    fraction:1.0];
    [rotatedImage unlockFocus];
    
    return rotatedImage;
}

- (NSImage*)scaleImage:(NSImage*)sourceImage to:(NSSize)newSize
{
    NSImage *sizedImage = [[NSImage alloc] initWithSize:newSize];
    [sizedImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
                   fromRect:NSMakeRect(0, 0, sourceImage.size.width, sourceImage.size.height)
                  operation:NSCompositeCopy
                   fraction:1.0];
    [sizedImage unlockFocus];

    return sizedImage;
}

- (IBAction)saveFiles:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanCreateDirectories:YES];
    [panel setPrompt:@"Choose"];
    [panel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
        
        if (result == NSFileHandlingPanelOKButton) {
            
            // create a date string for the folder
            NSDateFormatter *dateformate = [[NSDateFormatter alloc] init];
            [dateformate setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
            NSString *dateString = [dateformate stringFromDate:[NSDate date]];
            
            NSString *folderParentPath = [[[panel URLs] firstObject] path];
            NSString *folderPath = [folderParentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"icons_%@", dateString]];
            
            // create a new subfolder
            BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath
                                                     withIntermediateDirectories:YES
                                                                      attributes:nil
                                                                           error:nil];
            if (success) {
                
                // scale and save the install image
                NSImage *installImage = [_dragDropView image];
                installImage = [self scaleImage:installImage to:NSMakeSize(_imageOutputSize, _imageOutputSize)];
                NSData *imageData = [installImage TIFFRepresentation];
                NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
                NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:NSImageInterlaced];
                imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
                [imageData writeToFile:[folderPath stringByAppendingPathComponent:@"install.png"] atomically:YES];
                
                // scale and save the uninstall image
                NSImage *uninstallImage = [_processedImageView image];
                uninstallImage = [self scaleImage:uninstallImage to:NSMakeSize(_imageOutputSize, _imageOutputSize)];
                imageData = [uninstallImage TIFFRepresentation];
                imageRep = [NSBitmapImageRep imageRepWithData:imageData];
                imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
                [imageData writeToFile:[folderPath stringByAppendingPathComponent:@"uninstall.png"] atomically:YES];
                
                // create and save the animated uninstall image
                
                // define an infinite loop
                NSDictionary *fileProperties = [NSDictionary dictionaryWithObject:
                                                [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithInt:0], (__bridge id)kCGImagePropertyAPNGLoopCount,
                                                 nil] forKey:(__bridge id)kCGImagePropertyPNGDictionary];
                
                // define the delay between the frames
                NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:
                                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithFloat:.03], (__bridge id)kCGImagePropertyAPNGDelayTime,
                                                  nil] forKey:(__bridge id)kCGImagePropertyPNGDictionary];
                
                NSURL *fileURL = [[NSURL fileURLWithPath:folderPath] URLByAppendingPathComponent:@"uninstall_animated.png"];
                
                // define the actual animation
                NSArray *rotationPath = [NSArray arrayWithObjects:
                                         [NSNumber numberWithInt:0],
                                         [NSNumber numberWithInt:-1],
                                         [NSNumber numberWithInt:-2],
                                         [NSNumber numberWithInt:-1],
                                         [NSNumber numberWithInt:0],
                                         [NSNumber numberWithInt:1],
                                         [NSNumber numberWithInt:2],
                                         [NSNumber numberWithInt:1], nil];
                
                CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypePNG, [rotationPath count], (__bridge CFDictionaryRef)fileProperties);
                CGImageDestinationSetProperties(imageDestination, NULL);
                
                for (NSNumber *degrees in rotationPath) {
                    NSImage *rotatedImage = [self rotateImage:uninstallImage byDegrees:[degrees intValue]];
                    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)[rotatedImage TIFFRepresentation], NULL);
                    CGImageDestinationAddImage(imageDestination, CGImageSourceCreateImageAtIndex(imageSource, 0, NULL), (__bridge CFDictionaryRef)frameProperties);
                }
                
                if  (!CGImageDestinationFinalize(imageDestination)) { NSLog(@"Failed to write image"); }
                CFRelease(imageDestination);
                
            }
        }
        
    }];
    
}

- (void)updateUserDefaults:(NSNotification*)aNotification
{
    // update user prefs
    if ([[aNotification object] isKindOfClass:[NSWindow class]]) {
       [[NSUserDefaults standardUserDefaults] setValue:[_window stringWithSavedFrame] forKey:@"WindowPosition"];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    // remove our observers
    [_dragDropView removeObserver:self forKeyPath:@"image"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
    return YES;
}

@end
