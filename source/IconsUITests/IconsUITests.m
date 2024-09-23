/*
     IconsUITests.m
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
// size, auto image size and save a complete icon set to ~/Desktop
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
    
    // make sure the window has the smallest possible size
    XCUICoordinate *windowBottomRight = [iconsWindow coordinateWithNormalizedOffset:CGVectorMake(1, 1)];
    XCUICoordinate *windowTopLeft = [iconsWindow coordinateWithNormalizedOffset:CGVectorMake(0, 0)];
    [windowBottomRight clickForDuration:.1 thenDragToCoordinate:windowTopLeft];
    
    // bring up the open panel
    [iconsWindow typeKey:@"o" modifierFlags:XCUIKeyModifierCommand];
    XCUIElement *openDialog = app.sheets.firstMatch;
    XCTAssert([openDialog waitForExistenceWithTimeout:1.0]);
    
    // select an image
    [app typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    XCUIElement *gotoSheet = openDialog.sheets.firstMatch;
    XCTAssert([gotoSheet waitForExistenceWithTimeout:2.0]);
    
    XCUIElement *pathField = gotoSheet.textFields.firstMatch;
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
    
    if (savedBannersTable.tableRows.count > 0) {
        
        XCUICoordinate *tableRow = [savedBannersTable coordinateWithNormalizedOffset:CGVectorMake(.1, .1)];
        [tableRow rightClick];
        [XCUIElement performWithKeyModifiers:XCUIKeyModifierOption block:^{
            [savedBannersTable.menuItems[@"Remove All"] click];
        }];
    }
    
    XCTAssert(savedBannersTable.tableRows.count == 0);
    
    // create a banner
    XCUIElement *bannerTextField = iconsWindow.textFields[@"Banner Text"];
    XCTAssert([bannerTextField exists]);
    [bannerTextField click];
    [bannerTextField typeText:@" "];
    
    XCUIElement *fontMenu = iconsWindow.popUpButtons[@"Font Menu"];
    XCTAssert([fontMenu exists]);
    [fontMenu click];
    XCUIElement *fontMenuEntry = fontMenu.menuItems[@"Helvetica"];
    [fontMenuEntry click];
    
    XCUIElement *positionButton = iconsWindow.buttons[@"Top Left Corner"];
    XCTAssert([positionButton exists]);
    [positionButton click];
    
    XCUIElement *marginSlider = iconsWindow.sliders[@"Text Margin Slider"];
    XCTAssert([marginSlider exists]);
    XCUICoordinate *marginSliderStart = [marginSlider coordinateWithNormalizedOffset:CGVectorMake(.5, .5)];
    [marginSliderStart click];
    XCTAssert(round([[marginSlider value] doubleValue] * 10) / 10 == .2);
    
    [bannerTextField click];
    [bannerTextField typeKey:@"a" modifierFlags:XCUIKeyModifierCommand];
    [bannerTextField typeText:@"Text should end here ----------->!"];
    sleep(2);
    XCTAssertTrue([[bannerTextField value] isEqualToString:@"Text should end here ----------->"]);
    
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
    XCTAssert(savedBannersTable.tableRows.count == 1);
    
    // swap the banner's colors and position and save another banner
    XCUIElement *swapColorsButton = iconsWindow.buttons[@"Swap Banner Colors"];
    XCTAssert([swapColorsButton exists]);
    [swapColorsButton click];
    positionButton = iconsWindow.buttons[@"Top Right Corner"];
    XCTAssert([positionButton exists]);
    [positionButton click];
    [saveBannerButton click];
    
    // check if the banner has been saved
    XCTAssert(savedBannersTable.tableRows.count == 2);
    
    // select the banner we created first
    XCUICoordinate *tableRow = [savedBannersTable coordinateWithNormalizedOffset:CGVectorMake(.1, .1)];
    [tableRow click];
    
    // make sure the uninstall tab is selected
    XCUIElement *uninstallTab = iconsWindow/*@START_MENU_TOKEN@*/.tabs[@"Uninstall"]/*[[".tabGroups.tabs[@\"Uninstall\"]",".tabs[@\"Uninstall\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/;
    [uninstallTab click];

    // move the duration slider to the center position
    XCUIElement *durationSlider = iconsWindow.sliders[@"Animation Duration Slider"];
    XCTAssert([durationSlider exists]);
    XCUICoordinate *durationSliderMiddle = [durationSlider coordinateWithNormalizedOffset:CGVectorMake(.5, .5)];
    [durationSliderMiddle click];
    XCTAssert(round([[durationSlider value] doubleValue] * 100) / 100 == .45);
        
    // set image size to auto
    XCUIElement *autoInsetCheckbox = iconsWindow.checkBoxes[@"Auto Image Size"];
    XCTAssert([autoInsetCheckbox exists]);
    
    if (![[autoInsetCheckbox value] boolValue]) { [autoInsetCheckbox click]; }
    XCTAssert([[autoInsetCheckbox value] boolValue] == YES);
    
    // bring up the save panel by clicking the save button
    [saveButton click];
    
    XCUIElement *saveDialog = [[app sheets] firstMatch];
    XCTAssert([saveDialog waitForExistenceWithTimeout:2.0]);
    
    // try to write to a read-only location
    [app typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    gotoSheet = [[saveDialog sheets] firstMatch];
    XCTAssert([gotoSheet waitForExistenceWithTimeout:2.0]);
    
    pathField = [[gotoSheet textFields] firstMatch];
    XCTAssert([pathField exists]);
    
    [pathField typeText:@"/\n"];
    
    // set output size to auto
    XCUIElement *autoSizeCheckbox = saveDialog.checkBoxes[@"Auto Output Size"];
    XCTAssert([autoSizeCheckbox exists]);
    
    if (![[autoSizeCheckbox value] boolValue]) { [autoSizeCheckbox click]; }
    XCTAssert([[autoSizeCheckbox value] boolValue] == YES);
    
    // try to save the icon set
    XCUIElement *selectButton = saveDialog.buttons[@"Save"];
    XCTAssert([selectButton exists]);
    [selectButton click];
    
    XCUIElement *errorDialog = iconsWindow.sheets[@"alert"];
    XCTAssert([errorDialog waitForExistenceWithTimeout:2.0]);
    [errorDialog.buttons[@"OK"] click];
    
    // bring up the save panel by clicking the save button
    [saveButton click];
    
    saveDialog = [[app sheets] firstMatch];
    XCTAssert([saveDialog waitForExistenceWithTimeout:2.0]);
    
    // make sure all icons are saved
    XCUIElement *checkbox = saveDialog.checkBoxes[@"Install Icon"];
    if (![checkbox.value boolValue]) { [checkbox click]; }
    checkbox = saveDialog.checkBoxes[@"Uninstall Icon"];
    if (![checkbox.value boolValue]) { [checkbox click]; }
    checkbox = saveDialog.checkBoxes[@"Animated Uninstall Icon"];
    if (![checkbox.value boolValue]) { [checkbox click]; }
    
    // select the user's Desktop
    [app typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    gotoSheet = [[saveDialog sheets] firstMatch];
    XCTAssert([gotoSheet waitForExistenceWithTimeout:2.0]);
    
    pathField = [[gotoSheet textFields] firstMatch];
    XCTAssert([pathField exists]);
    [pathField typeText:@"~/Desktop\n"];

    // save the icon set
    selectButton = saveDialog.buttons[@"Save"];
    XCTAssert([selectButton exists]);
    [selectButton click];
    
    // quit the app by clicking the close button
    [iconsWindow.buttons[XCUIIdentifierCloseWindow] click];
    
    // switch to Finder
    XCUIApplication *finder = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.finder"];
    [finder activate];
    
    // select an app
    [finder typeKey:@"w" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierOption)];
    [finder typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    XCUIElement *gotoWindow = finder.windows[@"GoToWindow"];
    XCTAssert([gotoWindow waitForExistenceWithTimeout:2.0]);

    pathField = [[gotoWindow textFields] firstMatch];
    XCTAssert([pathField exists]);
    [pathField typeText:@"~/Desktop/icons_"];
    [finder typeKey:XCUIKeyboardKeyReturn modifierFlags:XCUIKeyModifierNone];
    [finder typeKey:@"2" modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:@"a" modifierFlags:XCUIKeyModifierCommand];
        
    XCUIElementQuery *savedIcons = [[finder descendantsMatchingType:XCUIElementTypeOutlineRow] matchingPredicate:[NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]]];
    XCTAssert([savedIcons count] == 3);
    XCTAssert([app state] == XCUIApplicationStateNotRunning);
    
    // move the folder to trash
    [finder typeKey:XCUIKeyboardKeyUpArrow modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:XCUIKeyboardKeyDelete modifierFlags:XCUIKeyModifierCommand];
}

// this should drag & drop the Icons app, set the animation duration
// to 0 to disable the creation of the animated uninstall icon, set
// the output size to 512 x 512, reduce the image size by 10 %, also
// disable the creation of the uninstall icon and save the only the
// install icon set to ~/Desktop.
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

    // select the first app in /Applications
    [finder typeKey:@"w" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierOption)];
    [finder typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    [finder typeKey:@"a" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    [finder typeKey:@"2" modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:XCUIKeyboardKeyDownArrow modifierFlags:XCUIKeyModifierNone];
    
    // get the app
    [finder typeKey:@"g" modifierFlags:XCUIKeyModifierCommand];
    XCUIElement *selectedApp = [[[finder descendantsMatchingType:XCUIElementTypeCell] elementMatchingPredicate:[NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]]] firstMatch];
    XCTAssert([selectedApp exists]);
    
    XCUIElement *dropView = iconsWindow.tabGroups.firstMatch.images.firstMatch;
    XCTAssert([dropView exists]);
    XCTAssert([dropView isHittable]);
    [selectedApp clickForDuration:.1 thenDragToElement:dropView];
    
    XCTAssert([saveButton isEnabled]);
    
    // move the duration slider to 0 to disable the creation
    // of the animated uninstall image
    XCUIElement *durationSlider = iconsWindow.sliders[@"Animation Duration Slider"];
    XCTAssert([durationSlider exists]);
    
    // unfortunately adjustToNormalizedSliderPosition:0 does
    // not work reliable here, so we move the slider another way
    XCUICoordinate *sliderStart = [durationSlider coordinateWithNormalizedOffset:CGVectorMake(0, .5)];
    [sliderStart click];
    XCTAssert([[durationSlider value] doubleValue] == 0);
    
    // reduce image size by 10 %
    XCUIElement *scalingSlider = iconsWindow.sliders[@"Image Size Slider"];
    XCTAssert([scalingSlider exists]);
    
    XCUICoordinate *scalingSliderMiddle = [scalingSlider coordinateWithNormalizedOffset:CGVectorMake(.5, .5)];
    [scalingSliderMiddle click];
    XCTAssert(round([[scalingSlider value] doubleValue] * 10) / 10 == .1);
    
    // make sure the install tab is selected
    XCUIElement *installTab = iconsWindow.tabs[@"Install"];
    [installTab click];
    
    // select one of the banners we created in test01IconSetFromImage
    XCUIElement *savedBannersTable = iconsWindow.tables[@"Saved Banners Table"];
    XCTAssert([savedBannersTable exists]);
    XCTAssert(savedBannersTable.cells.count == 2);
    
    // select the last banner
    XCUICoordinate *tableRow = [savedBannersTable coordinateWithNormalizedOffset:CGVectorMake(.1, .5)];
    [tableRow click];
    
    // delete the first banner
    tableRow = [savedBannersTable coordinateWithNormalizedOffset:CGVectorMake(.1, .1)];
    [tableRow rightClick];
    [savedBannersTable.menuItems[@"Remove"] click];
    XCTAssert(savedBannersTable.cells.count == 1);

    // bring up the save panel by typing command-s
    [iconsWindow typeKey:@"s" modifierFlags:XCUIKeyModifierCommand];
    
    XCUIElement *saveDialog = [[app sheets] firstMatch];
    XCTAssert([saveDialog waitForExistenceWithTimeout:2.0]);
    
    // set output size to 512 x 512
    XCUIElement *outputSizePopup = saveDialog.popUpButtons[@"Icon Output Size"];
    XCTAssert([outputSizePopup exists]);
    
    [outputSizePopup click];
    XCUIElement *outputSize = saveDialog.menuItems[@"512 x 512 pixels"];
    XCTAssert([outputSize exists]);
    
    [outputSize click];
    XCTAssertTrue([[outputSizePopup value] isEqualToString:@"512 x 512 pixels"]);
    
    // exclude the uninstall icon
    XCUIElement *checkbox = saveDialog.checkBoxes[@"Uninstall Icon"];
    if ([checkbox.value boolValue]) { [checkbox click]; }
    
    // check if the animated uninstall icon is disabled
    checkbox = saveDialog.checkBoxes[@"Animated Uninstall Icon"];
    XCTAssertFalse([checkbox isEnabled]);
    
    // select the user's Desktop
    [app typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    XCUIElement *gotoSheet = [[saveDialog sheets] firstMatch];
    XCTAssert([gotoSheet waitForExistenceWithTimeout:2.0]);
    
    XCUIElement *pathField = [[gotoSheet textFields] firstMatch];
    XCTAssert([pathField exists]);
    
    [pathField typeText:@"~/Desktop\n"];

    // save the icon set
    XCUIElement *selectButton = saveDialog.buttons[@"Save"];
    XCTAssert([selectButton exists]);
    [selectButton click];
    
    [app terminate];
    
    // switch to Finder
    [finder activate];
    
    // select an app
    [finder typeKey:@"w" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierOption)];
    [finder typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    XCUIElement *gotoWindow = finder.windows[@"GoToWindow"];
    XCTAssert([gotoWindow waitForExistenceWithTimeout:2.0]);

    pathField = [[gotoWindow textFields] firstMatch];
    XCTAssert([pathField exists]);
    [pathField typeText:@"~/Desktop/icons_"];
    [finder typeKey:XCUIKeyboardKeyReturn modifierFlags:XCUIKeyModifierNone];
    [finder typeKey:@"2" modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:@"a" modifierFlags:XCUIKeyModifierCommand];
        
    XCUIElementQuery *savedIcons = [[finder descendantsMatchingType:XCUIElementTypeOutlineRow] matchingPredicate:[NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]]];
    XCTAssert([savedIcons count] == 1);
    
    // move the folder to trash
    [finder typeKey:XCUIKeyboardKeyUpArrow modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:XCUIKeyboardKeyDelete modifierFlags:XCUIKeyModifierCommand];
}

// create another icon set using the Finder action extension.
// as the action extension respects some of the settings made
// in the main app, this should create an icon set using auto
// image size, auto output size, without a banner and without
// the two uninstall icons.
- (void)test03FinderExtension
{
    // make sure the Finder extension uses the app's settings
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    
    [app typeKey:@"," modifierFlags:XCUIKeyModifierCommand];
    XCUIElement *settingsWindow = app.windows[@"Settings Window"];
    XCTAssert([settingsWindow waitForExistenceWithTimeout:2.0]);
    XCUIElement *settingsToolbar = settingsWindow.toolbars.firstMatch;
    XCTAssert([settingsToolbar exists]);
    XCUIElement *extensionButton = settingsToolbar.buttons[@"Extension"];
    XCTAssert([extensionButton exists]);
    [extensionButton click];
    
    XCUIElement *extensionDefaultsCheckbox = settingsWindow.checkBoxes[@"Use default settings for Finder extension"];
    XCTAssert([extensionDefaultsCheckbox exists]);
    if ([extensionDefaultsCheckbox.value boolValue]) { [extensionDefaultsCheckbox click]; }
    
    [app terminate];
    
    // switch to Finder
    XCUIApplication *finder = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.finder"];
    [finder activate];
    
    // select an app
    [finder typeKey:@"w" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierOption)];
    [finder typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    XCUIElement *gotoWindow = finder.windows[@"GoToWindow"];
    XCTAssert([gotoWindow waitForExistenceWithTimeout:2.0]);

    XCUIElement *pathField = [[gotoWindow textFields] firstMatch];
    XCTAssert([pathField exists]);

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"Icons" ofType:@"app"];
    [pathField typeText:[path stringByAppendingString:@"\n"]];
    sleep(1);

    XCUIElement *selectedApp = [[[finder descendantsMatchingType:XCUIElementTypeCell] elementMatchingPredicate:[NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]]] firstMatch];
    XCTAssert([selectedApp exists]);
    [selectedApp rightClick];
    XCUIElement *actionMenuEntry = finder.menuItems[@"Quick Actions"].menuItems[@"Make Icon Set"];
    XCTAssert([actionMenuEntry waitForExistenceWithTimeout:2.0]);
    [actionMenuEntry click];
    sleep(2);
    
    [finder typeKey:@"o" modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:@"2" modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:@"a" modifierFlags:XCUIKeyModifierCommand];
    XCUIElementQuery *savedIcons = [[finder descendantsMatchingType:XCUIElementTypeOutlineRow] matchingPredicate:[NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]]];
    XCTAssert([savedIcons count] == 1);
    
    // move the folder to trash
    [finder typeKey:XCUIKeyboardKeyUpArrow modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:XCUIKeyboardKeyDelete modifierFlags:XCUIKeyModifierCommand];
}

// this should drag & drop the AppIcon.icns, set the animation duration
// to XXXX , set
// the output size to automatic, reduce the image size by 10 %, and save a full icon set to ~/Desktop.
- (void)test04FullIconSetWithOverlayFromImage
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

    // select the icon
    [finder typeKey:@"w" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierOption)];
    [finder typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    XCUIElement *gotoWindow = finder.windows[@"GoToWindow"];
    XCTAssert([gotoWindow waitForExistenceWithTimeout:2.0]);

    XCUIElement *pathField = [[gotoWindow textFields] firstMatch];
    XCTAssert([pathField exists]);

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"Icons" ofType:@"app"];
    path = [path stringByAppendingPathComponent:@"Contents/Resources/AppIcon.icns"];
    [pathField typeText:[path stringByAppendingString:@"\n"]];
    sleep(1);

    XCUIElement *selectedIcon = [[[finder descendantsMatchingType:XCUIElementTypeCell] elementMatchingPredicate:[NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]]] firstMatch];
    XCTAssert([selectedIcon exists]);
    
    XCUIElement *dropView = iconsWindow.tabGroups.firstMatch.images.firstMatch;
    XCTAssert([dropView exists]);
    XCTAssert([dropView isHittable]);
    [selectedIcon clickForDuration:.1 thenDragToElement:dropView];
    
    XCTAssert([saveButton isEnabled]);
    
    // move the duration slider to 50% to disable the creation
    // of the animated uninstall image
    XCUIElement *durationSlider = iconsWindow.sliders[@"Animation Duration Slider"];
    XCTAssert([durationSlider exists]);
    
    // unfortunately adjustToNormalizedSliderPosition:0 does
    // not work reliable here, so we move the slider another way
    XCUICoordinate *sliderStart = [durationSlider coordinateWithNormalizedOffset:CGVectorMake(.5, .5)];
    [sliderStart click];
    XCTAssert([[durationSlider value] doubleValue] == .45);
    
    // set image size to auto
    XCUIElement *autoSizeCheckbox = iconsWindow.checkBoxes[@"Auto-adjust image size"];
    XCTAssert([autoSizeCheckbox exists]);
    if (![autoSizeCheckbox.value boolValue]) { [autoSizeCheckbox click]; }
    
    // make sure the install tab is selected
    XCUIElement *installTab = iconsWindow.tabs[@"Install"];
    [installTab click];
    
    // remove all banners
    XCUIElement *savedBannersTable = iconsWindow.tables[@"Saved Banners Table"];
    XCTAssert([savedBannersTable exists]);
    
    if (savedBannersTable.cells.count > 0) {
        XCUICoordinate *tableRow = [savedBannersTable coordinateWithNormalizedOffset:CGVectorMake(.1, .9)];
        [tableRow rightClick];
        [savedBannersTable.menuItems[@"Remove All"] click];
        XCTAssert(savedBannersTable.cells.count == 0);
    }
    
    XCTAssert(savedBannersTable.tableRows.count == 0);
        
    // create a banner
    XCUIElement *bannerTextField = iconsWindow.textFields[@"Banner Text"];
    XCTAssert([bannerTextField exists]);
    [bannerTextField click];
    [bannerTextField typeKey:@"a" modifierFlags:XCUIKeyModifierCommand];
    [bannerTextField typeText:@"BETA"];
    sleep(2);
    
    XCTAssertTrue([[bannerTextField value] isEqualToString:@"BETA"]);
    
    XCUIElement *fontMenu = iconsWindow.popUpButtons[@"Font Menu"];
    XCTAssert([fontMenu exists]);
    [fontMenu click];
    XCUIElement *fontMenuEntry = fontMenu.menuItems[@"Zapfino"];
    [fontMenuEntry click];
    
    XCUIElement *positionButton = iconsWindow.buttons[@"Top Left Corner"];
    XCTAssert([positionButton exists]);
    [positionButton click];
    
    XCUIElement *marginSlider = iconsWindow.sliders[@"Text Margin Slider"];
    XCTAssert([marginSlider exists]);
    XCUICoordinate *marginSliderStart = [marginSlider coordinateWithNormalizedOffset:CGVectorMake(0, .5)];
    [marginSliderStart click];
    XCTAssert(round([[marginSlider value] doubleValue] * 10) / 10 == 0);
    
    // save the banner
    XCUIElement *saveBannerButton = iconsWindow.buttons[@"Save Banner"];
    XCTAssert([saveBannerButton exists]);
    [saveBannerButton click];
        
    // check if the banner has been saved
    XCTAssert(savedBannersTable.tableRows.count == 1);
    
    // make it the default banner
    XCUICoordinate *tableRow = [savedBannersTable coordinateWithNormalizedOffset:CGVectorMake(.1, .1)];
    [tableRow rightClick];
    [savedBannersTable.menuItems[@"Use as Default"] click];
    
#pragma mark add overlay image
    
    // make sure the app does not store the image position
    [app typeKey:@"," modifierFlags:XCUIKeyModifierCommand];
    XCUIElement *settingsWindow = app.windows[@"Settings Window"];
    XCTAssert([settingsWindow waitForExistenceWithTimeout:2.0]);
    XCUIElement *settingsToolbar = settingsWindow.toolbars.firstMatch;
    XCTAssert([settingsToolbar exists]);
    XCUIElement *generalButton = settingsToolbar.buttons[@"General"];
    XCTAssert([generalButton exists]);
    [generalButton click];
    
    XCUIElement *rememberOverlayCheckbox = settingsWindow.checkBoxes[@"Remember size and position of the overlay image"];
    XCTAssert([rememberOverlayCheckbox exists]);
    if ([rememberOverlayCheckbox.value boolValue]) { [rememberOverlayCheckbox click]; }
    [settingsWindow typeKey:@"w" modifierFlags:XCUIKeyModifierCommand];
    
    [iconsWindow typeKey:@"o" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    XCUIElement *openDialog = app.sheets.firstMatch;
    XCTAssert([openDialog waitForExistenceWithTimeout:1.0]);
    
    // select an image
    [app typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    XCUIElement *gotoSheet = openDialog.sheets.firstMatch;
    XCTAssert([gotoSheet waitForExistenceWithTimeout:2.0]);
    
    pathField = gotoSheet.textFields.firstMatch;
    XCTAssert([pathField exists]);
    [pathField typeKey:XCUIKeyboardKeyReturn modifierFlags:XCUIKeyModifierNone];

    // open the image
    XCUIElement *openButton = openDialog.buttons[@"Open"];
    XCTAssert([openButton exists]);
    [openButton click];
    
    // change size of overlay image
    XCUIElement *overlaySlider = iconsWindow.sliders[@"Overlay Image Size Slider"];
    XCTAssert([overlaySlider exists]);
    XCUICoordinate *overlaySlider40 = [overlaySlider coordinateWithNormalizedOffset:CGVectorMake(.5, .5)];
    [overlaySlider40 click];
    XCTAssert(round([[overlaySlider value] doubleValue] * 10) / 10 == .6);
    
    // move the overlay image to bottom right
    XCUIElementQuery *overlayQuery = [[iconsWindow descendantsMatchingType:XCUIElementTypeAny] matchingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", @"Overlay Image View"]];
    XCUIElement *overlayImageView = overlayQuery.firstMatch;
    XCTAssert([overlayImageView exists]);
    
    XCUICoordinate *imageViewCenter = [overlayImageView coordinateWithNormalizedOffset:CGVectorMake(.5, .5)];
    XCUICoordinate *dropViewBottomLeft = [dropView coordinateWithNormalizedOffset:CGVectorMake(1, 1)];
    [imageViewCenter clickForDuration:.1 thenDragToCoordinate:dropViewBottomLeft];
    
    // bring up the save panel by typing command-s
    [iconsWindow typeKey:@"s" modifierFlags:XCUIKeyModifierCommand];
    
    XCUIElement *saveDialog = [[app sheets] firstMatch];
    XCTAssert([saveDialog waitForExistenceWithTimeout:2.0]);
    
    // set output size to auto
    XCUIElement *outputSizeCheckbox = saveDialog.checkBoxes[@"Auto-select output size"];
    XCTAssert([outputSizeCheckbox exists]);
    if (![outputSizeCheckbox.value boolValue]) { [outputSizeCheckbox click]; }
    
    // select all icons
    XCUIElement *checkbox = saveDialog.checkBoxes[@"Install Icon"];
    XCTAssert([checkbox exists]);
    if (![checkbox.value boolValue]) { [checkbox click]; }
    checkbox = saveDialog.checkBoxes[@"Uninstall Icon"];
    XCTAssert([checkbox exists]);
    if (![checkbox.value boolValue]) { [checkbox click]; }
    checkbox = saveDialog.checkBoxes[@"Animated Uninstall Icon"];
    XCTAssert([checkbox exists]);
    if (![checkbox.value boolValue]) { [checkbox click]; }
    
    // select the user's Desktop
    [app typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    gotoSheet = [[saveDialog sheets] firstMatch];
    XCTAssert([gotoSheet waitForExistenceWithTimeout:2.0]);
    
    pathField = [[gotoSheet textFields] firstMatch];
    XCTAssert([pathField exists]);
    
    [pathField typeText:@"~/Desktop\n"];

    // save the icon set
    XCUIElement *selectButton = saveDialog.buttons[@"Save"];
    XCTAssert([selectButton exists]);
    [selectButton click];
    
    [app terminate];
    
    // switch to Finder
    [finder activate];
    
    // select an app
    [finder typeKey:@"w" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierOption)];
    [finder typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    gotoWindow = finder.windows[@"GoToWindow"];
    XCTAssert([gotoWindow waitForExistenceWithTimeout:2.0]);

    pathField = [[gotoWindow textFields] firstMatch];
    XCTAssert([pathField exists]);
    [pathField typeText:@"~/Desktop/icons_"];
    [finder typeKey:XCUIKeyboardKeyReturn modifierFlags:XCUIKeyModifierNone];
    [finder typeKey:@"2" modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:@"a" modifierFlags:XCUIKeyModifierCommand];
        
    XCUIElementQuery *savedIcons = [[finder descendantsMatchingType:XCUIElementTypeOutlineRow] matchingPredicate:[NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]]];
    XCTAssert([savedIcons count] == 3);
    
    // move the folder to trash
    [finder typeKey:XCUIKeyboardKeyUpArrow modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:XCUIKeyboardKeyDelete modifierFlags:XCUIKeyModifierCommand];
}

- (void)test99FinderExtension
{
    // make sure the Finder extension does not use the app's settings
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    
    [app typeKey:@"," modifierFlags:XCUIKeyModifierCommand];
    XCUIElement *settingsWindow = app.windows[@"Settings Window"];
    XCTAssert([settingsWindow waitForExistenceWithTimeout:2.0]);
    XCUIElement *settingsToolbar = settingsWindow.toolbars.firstMatch;
    XCTAssert([settingsToolbar exists]);
    XCUIElement *extensionButton = settingsToolbar.buttons[@"Extension"];
    XCTAssert([extensionButton exists]);
    [extensionButton click];
    
    XCUIElement *extensionDefaultsCheckbox = settingsWindow.checkBoxes[@"Use default settings for Finder extension"];
    XCTAssert([extensionDefaultsCheckbox exists]);
    if (![extensionDefaultsCheckbox.value boolValue]) { [extensionDefaultsCheckbox click]; }
    
    [app terminate];
    
    // switch to Finder
    XCUIApplication *finder = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.finder"];
    [finder activate];
    
    // select an app
    [finder typeKey:@"w" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierOption)];
    [finder typeKey:@"g" modifierFlags:(XCUIKeyModifierCommand|XCUIKeyModifierShift)];
    
    XCUIElement *gotoWindow = finder.windows[@"GoToWindow"];
    XCTAssert([gotoWindow waitForExistenceWithTimeout:2.0]);

    XCUIElement *pathField = [[gotoWindow textFields] firstMatch];
    XCTAssert([pathField exists]);

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"Icons" ofType:@"app"];
    [pathField typeText:[path stringByAppendingString:@"\n"]];
    sleep(1);

    XCUIElement *selectedApp = [[[finder descendantsMatchingType:XCUIElementTypeCell] elementMatchingPredicate:[NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]]] firstMatch];
    XCTAssert([selectedApp exists]);
    [selectedApp rightClick];
    XCUIElement *actionMenuEntry = finder.menuItems[@"Quick Actions"].menuItems[@"Make Icon Set"];
    XCTAssert([actionMenuEntry waitForExistenceWithTimeout:2.0]);
    [actionMenuEntry click];
    sleep(2);
    
    [finder typeKey:@"o" modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:@"2" modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:@"a" modifierFlags:XCUIKeyModifierCommand];
    XCUIElementQuery *savedIcons = [[finder descendantsMatchingType:XCUIElementTypeOutlineRow] matchingPredicate:[NSPredicate predicateWithFormat:@"isSelected == %@", [NSNumber numberWithBool:YES]]];
    XCTAssert([savedIcons count] == 3);
    
    // move the folder to trash
    [finder typeKey:XCUIKeyboardKeyUpArrow modifierFlags:XCUIKeyModifierCommand];
    [finder typeKey:XCUIKeyboardKeyDelete modifierFlags:XCUIKeyModifierCommand];
}

@end
