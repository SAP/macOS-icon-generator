/*
     MTTabViewController.m
     Copyright 2025 SAP SE
     
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

#import "MTTabViewController.h"
#import "Constants.h"

@interface MTTabViewController ()
@property (retain) id imageObserver;
@property (assign) BOOL skipSelection;
@end

@implementation MTTabViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
        
        _skipSelection = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // make sure all tab views are loaded
    for (int index = 0; index < [[self tabViewItems] count]; index++) {
        [self setSelectedTabViewItemIndex:index];
    }
    
    // select the last tab the user selected
    NSInteger selectedTabIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kMTDefaultsMainWindowSelectedTab];
    
    if (selectedTabIndex != [self selectedTabViewItemIndex]) {
        
        if (selectedTabIndex >= 0 && selectedTabIndex < [[self tabViewItems] count]) {
            [self setSelectedTabViewItemIndex:selectedTabIndex];
        } else {
            [self setSelectedTabViewItemIndex:0];
        }
    }
    
    _skipSelection = NO;
    
    // get notified if one of the images changed
    _imageObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kMTNotificationNameOverlayImageChanged
                                                                       object:nil
                                                                        queue:nil
                                                                   usingBlock:^(NSNotification *notification) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self selectedTabViewItemIndex] != 0) {
                [self setSelectedTabViewItemIndex:0];
            }
        });
    }];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [super tabView:tabView didSelectTabViewItem:tabViewItem];
    
    if (!_skipSelection) {
        
        [[NSUserDefaults standardUserDefaults] setInteger:[tabView indexOfTabViewItem:[tabView selectedTabViewItem]] forKey:kMTDefaultsMainWindowSelectedTab];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_imageObserver];
    _imageObserver = nil;
}

@end
