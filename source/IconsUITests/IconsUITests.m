/*
     IconsUITests.m
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

#import <XCTest/XCTest.h>

@interface IconsUITests : XCTestCase

@end

@implementation IconsUITests

- (void)setUp {

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// this should select the Icons app's AppIcon.icns, use auto output
// size, auto image size and save the icon set to ~/Desktop
- (void)test01IconSetFromImage
{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    
    // make sure the install tab is selected
    XCUIElement *iconsWindow = app.windows[@"Icons"];
    XCTAssert([iconsWindow exists]);
    XCUIElement *installTab = iconsWindow.tabs[@"Install"];
    [installTab click];
    
    XCUIElement *saveButton = app.buttons[@"Save Icon Set"];
    XCTAssert(![saveButton isEnabled]);
    
    // bring up the open panel
    [iconsWindow typeKey:@"o" modifierFlags:XCUIKeyModifierCommand];
    XCUIElement *openDialog = [[app sheets] firstMatch];
    XCTAssert([openDialog waitForExistenceWithTimeout:5.0]);
    
    // select an image
    [app typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    XCUIElement *gotoSheet = [[openDialog sheets] firstMatch];
    XCTAssert([gotoSheet waitForExistenceWithTimeout:5.0]);
    
    XCUIElement *pathField = [[gotoSheet textFields] firstMatch];
    XCTAssert([pathField exists]);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"Icons" ofType:@"app"];
    path = [path stringByAppendingPathComponent:@"Contents/Resources/AppIcon.icns"];
    [pathField typeText:[path stringByAppendingString:@"\n"]];

    // open the image
    XCUIElement *openButton = openDialog.buttons[@"Open"];
    XCTAssert([openButton exists]);
    [openButton click];
    
    XCTAssert([saveButton isEnabled]);
    
    // remove all saved banners
    XCUIElement *savedBannersTable = iconsWindow.tables[@"Saved Banners Table"];
    XCTAssert([savedBannersTable exists]);
    
    if (savedBannersTable.cells.count > 0) {
        
        [[[[savedBannersTable childrenMatchingType:XCUIElementTypeTableRow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeCell].element rightClick];
        [XCUIElement performWithKeyModifiers:XCUIKeyModifierOption block:^{
            [savedBannersTable.menuItems[@"Remove All"] click];
        }];
    }
    
    XCTAssert(savedBannersTable.cells.count == 0);
    
    // create a banner
    XCUIElement *bannerTextField = iconsWindow.textFields[@"Banner Text"];
    XCTAssert([bannerTextField exists]);
    [bannerTextField click];
    [bannerTextField typeText:@"Text should end here and not here"];
    XCTAssertTrue([[bannerTextField value] isEqualToString:@"Text should end here"]);
    
    // left position
    XCUIElement *leftPositionButton = iconsWindow.radioButtons[@"left"];
    XCTAssert([leftPositionButton exists]);
    [leftPositionButton click];
    
    // change the banner's colors
    XCUIElement *bannerTextColor = iconsWindow.colorWells[@"Banner Text Color"];
    XCTAssert([bannerTextColor exists]);
    XCUIElement *bannerColor = iconsWindow.colorWells[@"Banner Color"];
    XCTAssert([bannerColor exists]);
    
    [bannerTextColor click];
    
    XCUIElement *colorsWindow = app.windows[@"Colors"];
    [colorsWindow.toolbars.buttons[@"Color Sliders"] click];
    [[colorsWindow.splitGroups childrenMatchingType:XCUIElementTypePopUpButton].element click];
    [colorsWindow/*@START_MENU_TOKEN@*/.menuItems[@"showRGBView:"]/*[[".splitGroups",".popUpButtons",".menus",".menuItems[@\"RGB Sliders\"]",".menuItems[@\"showRGBView:\"]"],[[[-1,4],[-1,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,4],[-1,3],[-1,2,3],[-1,1,2]],[[-1,4],[-1,3],[-1,2,3]],[[-1,4],[-1,3]]],[0]]@END_MENU_TOKEN@*/ click];
       
    XCUIElement *hexTextField = colorsWindow.textFields[@"hex"];
    [hexTextField doubleClick];
    [hexTextField typeText:@"FEC309\n"];
    
    // close the color well by clicking its close button
    [colorsWindow.buttons[XCUIIdentifierCloseWindow] click];
    XCTAssert(![colorsWindow exists]);

    [bannerColor click];
    
    colorsWindow = app.windows[@"Colors"];
    [colorsWindow.toolbars.buttons[@"Color Sliders"] click];
    [[colorsWindow.splitGroups childrenMatchingType:XCUIElementTypePopUpButton].element click];
    [colorsWindow/*@START_MENU_TOKEN@*/.menuItems[@"showRGBView:"]/*[[".splitGroups",".popUpButtons",".menus",".menuItems[@\"RGB Sliders\"]",".menuItems[@\"showRGBView:\"]"],[[[-1,4],[-1,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,4],[-1,3],[-1,2,3],[-1,1,2]],[[-1,4],[-1,3],[-1,2,3]],[[-1,4],[-1,3]]],[0]]@END_MENU_TOKEN@*/ click];
       
    hexTextField = colorsWindow.textFields[@"hex"];
    [hexTextField doubleClick];
    [hexTextField typeText:@"FF2600\n"];
    
    // close the color well by clicking the color well button in the main window
    [bannerColor click];
    XCTAssert(![colorsWindow exists]);
    
    // save the banner
    XCUIElement *saveBannerButton = iconsWindow.buttons[@"Save Banner"];
    XCTAssert([saveBannerButton exists]);
    [saveBannerButton click];
        
    // check if the banner has been saved
    XCTAssert(savedBannersTable.cells.count == 1);
    
    // swap the banner's colors and position and save another banner
    XCUIElement *swapColorsButton = iconsWindow.buttons[@"Swap Banner Colors"];
    XCTAssert([swapColorsButton exists]);
    [swapColorsButton click];
    XCUIElement *rightPositionButton = iconsWindow.radioButtons[@"right"];
    XCTAssert([rightPositionButton exists]);
    [rightPositionButton click];
    [saveBannerButton click];
    
    // check if the banner has been saved
    XCTAssert(savedBannersTable.cells.count == 2);
    
    // select the banner we created first
    [[[[savedBannersTable childrenMatchingType:XCUIElementTypeTableRow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeCell].element click];
    
    // make sure the uninstall tab is selected
    XCUIElement *uninstallTab = iconsWindow/*@START_MENU_TOKEN@*/.tabs[@"Uninstall"]/*[[".tabGroups.tabs[@\"Uninstall\"]",".tabs[@\"Uninstall\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/;
    [uninstallTab click];

    // move the speed slider to 0.5 to make sure
    // the animated uninstall image is created
    XCUIElement *durationSlider = iconsWindow.sliders[@"Animation Speed Slider"];
    XCTAssert([durationSlider exists]);
    
    [durationSlider adjustToNormalizedSliderPosition:.5];
    
    // set output size to auto
    XCUIElement *autoSizeCheckbox = iconsWindow.checkBoxes[@"Auto Output Size"];
    XCTAssert([autoSizeCheckbox exists]);
    
    if (![[autoSizeCheckbox value] boolValue]) { [autoSizeCheckbox click]; }
    XCTAssert([[autoSizeCheckbox value] boolValue] == YES);
    
    // set image size to auto
    XCUIElement *autoInsetCheckbox = iconsWindow.checkBoxes[@"Auto Image Size"];
    XCTAssert([autoInsetCheckbox exists]);
    
    if (![[autoInsetCheckbox value] boolValue]) { [autoInsetCheckbox click]; }
    XCTAssert([[autoInsetCheckbox value] boolValue] == YES);
    
    // bring up the save panel by clicking the save button
    [saveButton click];
    
    XCUIElement *saveDialog = [[app sheets] firstMatch];
    XCTAssert([saveDialog waitForExistenceWithTimeout:5.0]);
    
    // try to write to a read-only location
    [app typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    gotoSheet = [[saveDialog sheets] firstMatch];
    XCTAssert([gotoSheet waitForExistenceWithTimeout:5.0]);
    
    pathField = [[gotoSheet textFields] firstMatch];
    XCTAssert([pathField exists]);
    
    [pathField typeText:@"/\n"];
    
    // try to save the icon set
    XCUIElement *chooseButton = saveDialog.buttons[@"Choose"];
    XCTAssert([chooseButton exists]);
    [chooseButton click];
    
    XCUIElement *errorDialog = iconsWindow.sheets[@"alert"];
    XCTAssert([errorDialog waitForExistenceWithTimeout:5.0]);
    [errorDialog.buttons[@"OK"] click];
    
    // bring up the save panel by clicking the save button
    [saveButton click];
    
    saveDialog = [[app sheets] firstMatch];
    XCTAssert([saveDialog waitForExistenceWithTimeout:5.0]);
    
    // select the user's Desktop
    [app typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    gotoSheet = [[saveDialog sheets] firstMatch];
    XCTAssert([gotoSheet waitForExistenceWithTimeout:5.0]);
    
    pathField = [[gotoSheet textFields] firstMatch];
    XCTAssert([pathField exists]);
    
    NSString *desktopPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask] firstObject] path];
    [pathField typeText:[desktopPath stringByAppendingString:@"\n"]];

    // save the icon set
    chooseButton = saveDialog.buttons[@"Choose"];
    XCTAssert([chooseButton exists]);
    [chooseButton click];
    
    // quit the app by clicking the close button
    [iconsWindow.buttons[XCUIIdentifierCloseWindow] click];
}

// this should drag & drop the Icons app, set the animation duration
// to 0 to disable the creation of the animated uninstall icon, set
// the output size to 512 x 512, reduce the image size by 10 %
// and save the icon set to ~/Desktop
- (void)test02IconSetFromAppBundle
{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    XCUIElement *saveButton = app.buttons[@"Save Icon Set"];
    XCTAssert(![saveButton isEnabled]);
    
    // make sure there are no color wells open anymore
    XCUIElement *colorsWindow = app.windows[@"Colors"];
    if ([colorsWindow exists]) { [colorsWindow.buttons[XCUIIdentifierCloseWindow] click]; }
    
    // make sure the uninstall tab is selected
    XCUIElement *iconsWindow = app.windows[@"Icons"];
    XCTAssert([iconsWindow exists]);
    XCUIElement *uninstallTab = iconsWindow.tabs[@"Uninstall"];
    [uninstallTab click];
    
    // switch to Finder
    XCUIApplication *finder = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.finder"];
    [finder activate];

    // select an app
    [finder typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];

    XCUIElement *gotoSheet = finder.sheets[@"GoToWindow"];
    XCTAssert([gotoSheet waitForExistenceWithTimeout:5.0]);

    XCUIElement *pathField = [[gotoSheet textFields] firstMatch];
    XCTAssert([pathField exists]);

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"Icons" ofType:@"app"];
    [pathField typeText:[path stringByAppendingString:@"\n"]];
    
    // get the app
    XCUIElement *selectedApp = [[[finder descendantsMatchingType:XCUIElementTypeCell] elementMatchingPredicate:[NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]]] firstMatch];
    XCTAssert([selectedApp exists]);
    
    XCUIElement *dropView = iconsWindow.tabGroups.firstMatch.images.firstMatch;
    XCTAssert([dropView exists]);
    XCTAssert([dropView isHittable]);
    [selectedApp clickForDuration:.1 thenDragToElement:dropView];
    
    XCTAssert([saveButton isEnabled]);
    
    // move the speed slider to 0 to disable the creation
    // of the animated uninstall image
    XCUIElement *durationSlider = iconsWindow.sliders[@"Animation Speed Slider"];
    XCTAssert([durationSlider exists]);
    
    // unfortunately adjustToNormalizedSliderPosition:0 does
    // not work reliable here, so we move the slider another way
    XCUICoordinate *sliderStart = [durationSlider coordinateWithNormalizedOffset:CGVectorMake(0, .5)];
    [sliderStart click];
    XCTAssert([[durationSlider value] doubleValue] == 0);
    
    // set output size to 512 x 512
    XCUIElement *outputSizePopup = iconsWindow.popUpButtons[@"Icon Output Size"];
    XCTAssert([outputSizePopup exists]);
    
    [outputSizePopup click];
    XCUIElement *outputSize = iconsWindow.menuItems[@"512 x 512 pixels"];
    XCTAssert([outputSize exists]);
    
    [outputSize click];
    XCTAssertTrue([[outputSizePopup value] isEqualToString:@"512 x 512 pixels"]);
    
    // reduce image size by 10 %
    XCUIElement *scalingSlider = iconsWindow.sliders[@"Image Size Slider"];
    XCTAssert([scalingSlider exists]);
    
    [scalingSlider adjustToNormalizedSliderPosition:.5];
    
    // make sure the install tab is selected
    XCUIElement *installTab = iconsWindow.tabs[@"Install"];
    [installTab click];
    
    // select one of the banners we created in test01OpenImage
    XCUIElement *savedBannersTable = iconsWindow.tables[@"Saved Banners Table"];
    XCTAssert([savedBannersTable exists]);
    XCTAssert(savedBannersTable.cells.count == 2);
    
    // select the last banner
    [[[[savedBannersTable childrenMatchingType:XCUIElementTypeTableRow] elementBoundByIndex:1] childrenMatchingType:XCUIElementTypeCell].element click];
    
    // delete the first banner
    [[[savedBannersTable childrenMatchingType:XCUIElementTypeTableRow] elementBoundByIndex:0] rightClick];
    [savedBannersTable.menuItems[@"Remove"] click];
    XCTAssert(savedBannersTable.cells.count == 1);

    // bring up the save panel by typing command-s
    [iconsWindow typeKey:@"s" modifierFlags:XCUIKeyModifierCommand];
    
    XCUIElement *saveDialog = [[app sheets] firstMatch];
    XCTAssert([saveDialog waitForExistenceWithTimeout:5.0]);
    
    // select the user's Desktop
    [app typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    gotoSheet = [[saveDialog sheets] firstMatch];
    XCTAssert([gotoSheet waitForExistenceWithTimeout:5.0]);
    
    pathField = [[gotoSheet textFields] firstMatch];
    XCTAssert([pathField exists]);
    
    NSString *desktopPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask] firstObject] path];
    [pathField typeText:[desktopPath stringByAppendingString:@"\n"]];

    // save the icon set
    XCUIElement *chooseButton = saveDialog.buttons[@"Choose"];
    XCTAssert([chooseButton exists]);
    [chooseButton click];
    
    [app terminate];
}

// create another icon set using the Finder action extension.
// as the action extension respects some of the settings made
// in the main app, this should create an icon set using auto
// image size, auto output size, without a banner and without
// an animated uninstall icon (because we disabled the creation
// of animated uninstall icons in test02IconSetFromAppBundle).
- (void)test99FinderExtension
{
    // switch to Finder
    XCUIApplication *finder = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.finder"];
    [finder activate];
    
    // select an app
    [finder typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    XCUIElement *gotoSheet = finder.sheets[@"GoToWindow"];
    XCTAssert([gotoSheet waitForExistenceWithTimeout:5.0]);

    XCUIElement *pathField = [[gotoSheet textFields] firstMatch];
    XCTAssert([pathField exists]);

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"Icons" ofType:@"app"];
    [pathField typeText:[path stringByAppendingString:@"\n"]];
        
    XCUIElement *selectedApp = [[[finder descendantsMatchingType:XCUIElementTypeCell] elementMatchingPredicate:[NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]]] firstMatch];
    XCTAssert([selectedApp exists]);
    [selectedApp rightClick];
    XCUIElement *actionMenuEntry = finder.menuItems[@"Quick Actions"].menuItems[@"Make Icon Set"];
    XCTAssert([actionMenuEntry waitForExistenceWithTimeout:5.0]);
    [actionMenuEntry click];
}

@end
