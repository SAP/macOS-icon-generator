/*
     MTSettingsGeneralController.m
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

#import "MTSettingsGeneralController.h"
#import "MTIconSet.h"
#import "Constants.h"

@interface MTSettingsGeneralController ()
@property (weak) IBOutlet NSButton *rememberOverlayCheckbox;
@property (weak) IBOutlet NSButton *usePrefixCheckbox;
@property (weak) IBOutlet NSTextField *userDefinedPrefix;

@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readwrite) NSUserDefaultsController *defaultsController;
@end

@implementation MTSettingsGeneralController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
    _defaultsController = [[NSUserDefaultsController alloc] initWithDefaults:_userDefaults initialValues:nil];
    
    [_usePrefixCheckbox bind:NSValueBinding
                    toObject:_defaultsController
                 withKeyPath:[@"values." stringByAppendingString:kMTDefaultsUsePrefixKey]
                     options:nil
     ];
    
    [_rememberOverlayCheckbox bind:NSValueBinding
                          toObject:_defaultsController
                       withKeyPath:[@"values." stringByAppendingString:kMTDefaultsRememberOverlayPositionKey]
                           options:nil
     ];
    
    [_userDefinedPrefix bind:NSValueBinding
                    toObject:_defaultsController
                 withKeyPath:[@"values." stringByAppendingString:kMTDefaultsUserDefinedPrefixKey]
                     options:[NSDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"prefixSetAutomatically", nil), NSNullPlaceholderBindingOption,
                              NSLocalizedString(@"prefixSetAutomatically", nil), NSNoSelectionPlaceholderBindingOption,
                              nil
                             ]
     ];
    
    [_userDefinedPrefix setAccessibilityLabel:@"Prefix"];
}

- (void)viewWillDisappear
{
    [super viewWillDisappear];
    [[[self view] window] makeFirstResponder:nil];
}

- (IBAction)setRememberImagePosition:(id)sender
{
    if ([_userDefaults boolForKey:kMTDefaultsRememberOverlayPositionKey]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMTNotificationNameRememberOverlayPosition
                                                            object:self
                                                          userInfo:nil
        ];
        
    } else {
        
        [_userDefaults removeObjectForKey:kMTDefaultsOverlayPositionKey];
        [_userDefaults removeObjectForKey:kMTDefaultsOverlayScalingKey];
    }
}

- (void)controlTextDidChange:(NSNotification*)aNotification
{
    if ([aNotification object] == _userDefinedPrefix) {
        
        [_userDefinedPrefix setStringValue:[MTIconSet fileNamePrefixWithString:[_userDefinedPrefix stringValue]]];
    }
}


@end
