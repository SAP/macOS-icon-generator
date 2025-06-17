/*
     MTSavePanelAccessoryController.m
     Copyright 2023-2025 SAP SE
     
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

#import "MTSavePanelAccessoryController.h"
#import "Constants.h"
#import "MTImage.h"

@interface MTSavePanelAccessoryController ()
@property (nonatomic, strong, readwrite) NSUserDefaultsController *defaultsController;
@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;
@property (assign) NSInteger selectedTag;
@property (assign) BOOL upscaleWarning;

@property (weak) IBOutlet NSButton *saveInstallIconCheckbox;
@property (weak) IBOutlet NSButton *saveUninstallIconCheckbox;
@property (weak) IBOutlet NSButton *saveAnimatedUninstallIconCheckbox;
@property (weak) IBOutlet NSButton *autoOutputSizeCheckbox;
@property (weak) IBOutlet NSPopUpButton *outputSizeMenu;
@end

@implementation MTSavePanelAccessoryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"7R5ZEU67FQ.corp.sap.Icons"];
    _defaultsController = [[NSUserDefaultsController alloc] initWithDefaults:_userDefaults initialValues:nil];
    
    // output sizes menu
    [[_outputSizeMenu menu] removeAllItems];
    
    for (NSNumber *outputSize in kMTOutputSizes) {
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ x %@ %@", outputSize, outputSize, NSLocalizedString(@"outputSize", nil)]
                                                          action:nil
                                                   keyEquivalent:@""];
        [menuItem setTag:[outputSize integerValue]];
        [[_outputSizeMenu menu] addItem:menuItem];
    }
    
#pragma mark bindings
    
    [_saveInstallIconCheckbox bind:NSValueBinding
                          toObject:_defaultsController
                       withKeyPath:[@"values." stringByAppendingString:kMTDefaultsSaveInstallIconKey]
                           options:nil
    ];
    
    [_saveUninstallIconCheckbox bind:NSValueBinding
                            toObject:_defaultsController
                         withKeyPath:[@"values." stringByAppendingString:kMTDefaultsSaveUninstallIconKey]
                             options:nil
    ];
    
    [_saveAnimatedUninstallIconCheckbox bind:NSValueBinding
                                    toObject:_defaultsController
                                 withKeyPath:[@"values." stringByAppendingString:kMTDefaultsSaveAnimatedUninstallIconKey]
                                     options:nil
    ];
    
    [_autoOutputSizeCheckbox bind:NSValueBinding
                             toObject:_defaultsController
                          withKeyPath:[@"values." stringByAppendingString:kMTDefaultsAutoOutputSizeKey]
                              options:nil
    ];

    [_outputSizeMenu bind:NSSelectedTagBinding
                 toObject:_defaultsController
              withKeyPath:[@"values." stringByAppendingString:kMTDefaultsOutputSizeKey]
                  options:nil
    ];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    if ([_userDefaults floatForKey:kMTDefaultsAnimationDurationKey] > 0) {
        
        [_saveAnimatedUninstallIconCheckbox setAllowsMixedState:NO];
        [_saveAnimatedUninstallIconCheckbox setEnabled:YES];
        
    } else {
        
        BOOL animatedEnabled = [_userDefaults boolForKey:kMTDefaultsSaveAnimatedUninstallIconKey];
        
        [_saveAnimatedUninstallIconCheckbox setEnabled:NO];
        [_saveAnimatedUninstallIconCheckbox setAllowsMixedState:YES];
        [_saveAnimatedUninstallIconCheckbox setState:(animatedEnabled) ? NSControlStateValueMixed : NSControlStateValueOff];
    }
    
    // make sure at least the install icon is selected
    if (![self outputFileSelected]) { [_userDefaults setBool: YES forKey:kMTDefaultsSaveInstallIconKey]; }
    
    [self setAutoOutputSize:nil];
}

- (IBAction)setAutoOutputSize:(id)sender
{
    [_autoOutputSizeCheckbox setAllowsMixedState:NO];
    
    if ([_autoOutputSizeCheckbox state] == NSControlStateValueOn) {
                
        if ([_sourceImage isValid]) {
        
            for (NSNumber *anOutputSize in [kMTOutputSizes reverseObjectEnumerator]) {
                
                BOOL canBeScaled = [_sourceImage canBeScaledToSize:NSMakeSize([anOutputSize floatValue], [anOutputSize floatValue])];
                
                if (canBeScaled) {
                    
                    [_userDefaults setInteger:[anOutputSize integerValue] forKey:kMTDefaultsOutputSizeKey];
                    [_outputSizeMenu selectItemWithTag:[anOutputSize integerValue]];
                    self.upscaleWarning = NO;
                    break;
                }
            }
        }
    
    }
}

- (IBAction)setIconTypes:(id)sender
{
    if ([sender state] == NSControlStateValueOff) {
        
        if (![self outputFileSelected]) {
            
            if ([sender isEqualTo:_saveInstallIconCheckbox]) {
                
                [_userDefaults removeObjectForKey:kMTDefaultsSaveInstallIconKey];
                
            } else if ([sender isEqualTo:_saveUninstallIconCheckbox]) {
                
                [_userDefaults removeObjectForKey:kMTDefaultsSaveUninstallIconKey];
                
            } else if ([sender isEqualTo:_saveAnimatedUninstallIconCheckbox]) {
                
                [_userDefaults removeObjectForKey:kMTDefaultsSaveAnimatedUninstallIconKey];
            }
        }
    }
}

- (void)updateUpscaleWarningWithSize:(NSInteger)outputSize
{
    if ([_sourceImage isValid]) {
        
        self.upscaleWarning = ![_sourceImage canBeScaledToSize:NSMakeSize(outputSize, outputSize)];
    }
}

- (BOOL)outputFileSelected
{
    BOOL selected = NO;
    
    if ([_saveInstallIconCheckbox state] == NSControlStateValueOn ||
        [_saveUninstallIconCheckbox state] == NSControlStateValueOn ||
        [_saveAnimatedUninstallIconCheckbox state] == NSControlStateValueOn) {
        selected = YES;
    }
    
    return selected;
}

#pragma mark NSMenuDelegate

- (void)menuWillOpen:(NSMenu*)menu
{
    _selectedTag = [_outputSizeMenu selectedTag];
}

- (void)menuDidClose:(NSMenu*)menu
{
    NSInteger newSelectedTag = [_outputSizeMenu selectedTag];
    [self updateUpscaleWarningWithSize:newSelectedTag];

    if (newSelectedTag != _selectedTag && [_autoOutputSizeCheckbox state] == NSControlStateValueOn) {
        [_autoOutputSizeCheckbox setAllowsMixedState:YES];
        [_autoOutputSizeCheckbox setState:NSControlStateValueMixed];
    }
}

@end
