/*
    Constants.h
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

#define kMTAnimationDurationMin         0.0
#define kMTAnimationDurationMax         0.9
#define kMTAnimationDurationDefault     0.5

#define kMTImageInsetMin                0.0
#define kMTImageInsetMax                0.2
#define kMTImageInsetDefault            0.085

#define kMTOutputSizeMax                1024
#define kMTOutputSizeDefault            512
#define kMTOutputSizes                  @[@64, @128, @256, @512, @1024]

#define kMTBannerColorDefault           0xFFCC00
#define kMTBannerTextColorDefault       0x000000
#define kMTBannerErrorColor             [NSColor redColor]

#define kMTDefaultsAutoImageSize        @"autoAdjustImageSize"
#define kMTDefaultsAnimationDuration    @"animationDuration"
#define kMTDefaultsOutputSize           @"outputSize"
#define kMTDefaultsAutoOutputSize       @"autoOutputSize"
#define kMTDefaultsFlippingEnabled      @"enableFlipping"
#define kMTDefaultsSavedBanners         @"savedBanners"
#define kMTDefaultsBannerName           @"bannerName"
#define kMTDefaultsBannerData           @"bannerData"
#define kMTDefaultsBannerColor          @"bannerColor"
#define kMTDefaultsBannerTextColor      @"bannerTextColor"
#define kMTDefaultsBannerIsFlipped      @"isFlipped"

#define kMTFileNameInstall              @"install.png"
#define kMTFileNameUninstall            @"uninstall.png"
#define kMTFileNameUninstallAnimated    @"uninstall_animated.png"
