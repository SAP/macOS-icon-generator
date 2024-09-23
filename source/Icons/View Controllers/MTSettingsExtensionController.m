/*
     MTSettingsExtensionController.m
     Copyright 2023-2024 SAP SE
     
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

#import "MTSettingsExtensionController.h"
#import "Constants.h"

@interface MTSettingsExtensionController ()
@property (weak) IBOutlet NSButton *useDefaultSettingsCheckbox;

@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readwrite) NSUserDefaultsController *defaultsController;
@end

@implementation MTSettingsExtensionController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
    _defaultsController = [[NSUserDefaultsController alloc] initWithDefaults:_userDefaults initialValues:nil];
    
    [_useDefaultSettingsCheckbox bind:NSValueBinding
                             toObject:_defaultsController
                          withKeyPath:[@"values." stringByAppendingString:kMTDefaultsExtensionDefaultSettingsKey]
                              options:nil
     ];
}

@end