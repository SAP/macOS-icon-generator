/*
    MTSettingsComposingController.m
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

#import "MTSettingsComposingController.h"
#import "Constants.h"
#import "MTGroupDefaults.h"

@interface MTSettingsComposingController ()
@property (weak) IBOutlet NSButton *useOldIconShapeCheckbox;
@property (weak) IBOutlet NSButton *renderInIconShapeCheckbox;
@property (weak) IBOutlet NSButton *drawBannerInIconShapeCheckbox;

@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readwrite) NSUserDefaultsController *defaultsController;
@property (assign) BOOL iconShapeEnabled;
@end

@implementation MTSettingsComposingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userDefaults = [MTGroupDefaults sharedDefaults];
    _defaultsController = [MTGroupDefaults sharedDefaultsController];
    
    self.iconShapeEnabled = [_userDefaults boolForKey:kMTDefaultsRenderImagesInIconShapeKey];
    
    [_useOldIconShapeCheckbox bind:NSValueBinding
                          toObject:_defaultsController
                       withKeyPath:[@"values." stringByAppendingString:kMTDefaultsUseOldIconShapeKey]
                           options:nil
    ];
    
    [_renderInIconShapeCheckbox bind:NSValueBinding
                            toObject:_defaultsController
                         withKeyPath:[@"values." stringByAppendingString:kMTDefaultsRenderImagesInIconShapeKey]
                             options:nil
    ];
    
    [_drawBannerInIconShapeCheckbox bind:NSValueBinding
                                toObject:_defaultsController
                             withKeyPath:[@"values." stringByAppendingString:kMTDefaultsDrawBannerInIconShapeKey]
                                 options:nil
    ];
}

- (IBAction)changeIconShapeSettings:(id)sender
{
    self.iconShapeEnabled = [_userDefaults boolForKey:kMTDefaultsRenderImagesInIconShapeKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameIconShapeSettings
                                                        object:self
                                                      userInfo:nil
    ];
}

@end
