/*
    Constants.h
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

#define kMTAnimationDurationMin         .0
#define kMTAnimationDurationMax         .9
#define kMTAnimationDurationDefault     .5

#define kMTImageInsetMin                .0
#define kMTImageInsetMax                .2
#define kMTImageInsetDefault            .085

#define kMTOutputSizeMax                1024
#define kMTOutputSizeDefault            512
#define kMTOutputSizes                  @[@64, @128, @256, @512, @1024]

#define kMTBannerTextMarginMin          0
#define kMTBannerTextMarginMax          .4
#define kMTBannerTextMarginDefault      .2

#define kMTOverlayImageScalingMin       .1
#define kMTOverlayImageScalingMax       1
#define kMTOverlayImageScalingDefault   .3

#define kMTBannerColorDefault           0xFFCC00
#define kMTBannerTextColorDefault       0x000000
#define kMTBannerErrorColor             [NSColor redColor]

#define kMTGitHubURL                    @"https://github.com/SAP/macOS-icon-generator"

// NSUserDefaults
#define kMTDefaultsAutoImageSizeKey             @"autoAdjustImageSize"
#define kMTDefaultsImageSizeAdjustmentKey       @"ImageSizeAdjustment"
#define kMTDefaultsAnimationDurationKey         @"animationDuration"
#define kMTDefaultsOutputSizeKey                @"outputSize"
#define kMTDefaultsAutoOutputSizeKey            @"autoOutputSize"
#define kMTDefaultsPositionDefaultKey           @"DefaultPosition"
#define kMTDefaultsTextMarginDefaultKey         @"DefaultTextMargin"
#define kMTDefaultsSelectedFontKey              @"SelectedFont"
#define kMTDefaultsSavedBannersKey              @"savedBanners"
#define kMTDefaultsBannerNameKey                @"bannerName"
#define kMTDefaultsBannerDataKey                @"bannerData"
#define kMTDefaultsBannerColorKey               @"bannerColor"
#define kMTDefaultsBannerTextColorKey           @"bannerTextColor"
#define kMTDefaultsBannerIsFlippedKey           @"IsFlipped"
#define kMTDefaultsBannerPositionKey            @"BannerPosition"
#define kMTDefaultsBannerTextMarginKey          @"BannerTextMargin"
#define kMTDefaultsBannerIsDefaultKey           @"IsDefault"
#define kMTDefaultsSaveInstallIconKey           @"SaveInstallIcon"
#define kMTDefaultsSaveUninstallIconKey         @"SaveUninstallIcon"
#define kMTDefaultsSaveAnimatedUninstallIconKey @"SaveAnimatedUninstallIcon"
#define kMTDefaultsRememberOverlayPositionKey   @"RememberOverlayPosition"
#define kMTDefaultsOverlayPositionKey           @"OverlayPosition"
#define kMTDefaultsOverlayScalingKey            @"OverlayScaling"
#define kMTDefaultsUsePrefixKey                 @"UsePrefix"
#define kMTDefaultsUserDefinedPrefixKey         @"UserDefinedPrefix"
#define kMTDefaultsExtensionDefaultSettingsKey  @"ExtensionUsesDefaultSettings"
#define kMTDefaultsSettingsSelectedTab          @"SettingsSelectedTab"
#define kMTDefaultsMainWindowSelectedTab        @"MainWindowSelectedTab"

#define kMTFileNameInstall                      @"install.png"
#define kMTFileNameUninstall                    @"uninstall.png"
#define kMTFileNameUninstallAnimated            @"uninstall_animated.png"

// NSNotification
#define kMTNotificationNameImageChanged                 @"corp.sap.Icons.ImageChangedNotification"
#define kMTNotificationNameOverlayImageChanged          @"corp.sap.Icons.OverlayImageChangedNotification"
#define kMTNotificationNameOverlayImagePositionChanged  @"corp.sap.Icons.OverlayImagePositionChangedNotification"
#define kMTNotificationNameOverlayImageScalingChanged   @"corp.sap.Icons.OverlayImageScalingChangedNotification"
#define kMTNotificationNameRememberOverlayPosition      @"corp.sap.Icons.RememberOverlayPosition"

#define kMTNotificationNameBannerTruncated      @"corp.sap.Icons.BannerTextTruncatedNotification"
#define kMTNotificationNameSaveIcon             @"corp.sap.Icons.SaveIconNotification"

// NSNotification user info keys
#define kMTNotificationKeyImageURL              @"ImageURL"
#define kMTNotificationKeyFileNamePrefix        @"FileNamePrefix"
#define kMTNotificationKeyFolderPath            @"FolderPath"
