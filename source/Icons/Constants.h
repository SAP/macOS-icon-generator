/*
    Constants.h
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

#define kMTAnimationDurationMin         0
#define kMTAnimationDurationMax         .9
#define kMTAnimationDurationDefault     .5

#define kMTImageInsetMin                0
#define kMTImageInsetMax                .2
#define kMTImageInsetDefault            .085

#define kMTOutputSizeMin                64
#define kMTOutputSizeMax                1024
#define kMTOutputSizeDefault            512
#define kMTOutputSizes                  @[@64, @128, @256, @512, @1024]

#define kMTBannerTextMarginMin          0
#define kMTBannerTextMarginMax          .4
#define kMTBannerTextMarginDefault      .2      // ***

#define kMTBannerAngleMin               30.0
#define kMTBannerAngleMax               60.0
#define kMTBannerAngleDefault           45.0    // ***

#define kMTBannerHeightMin              .1
#define kMTBannerHeightMax              .3
#define kMTBannerHeightDefault          .18     // ***

#define kMTBannerMarginMin              .00001
#define kMTBannerMarginMax              .5
#define kMTBannerMarginDefault          .292    // ***

#define kMTOverlayImageScalingMin       .1
#define kMTOverlayImageScalingMax       1
#define kMTOverlayImageScalingDefault   .3

#define kMTBadgeShadowAngleMin          0
#define kMTBadgeShadowAngleMax          360.0
#define kMTBadgeShadowAngleDefault      135.0   // ***

#define kMTBadgeShadowRadiusMin         0
#define kMTBadgeShadowRadiusMax         .2
#define kMTBadgeShadowRadiusDefault     .026    // ***

#define kMTBadgeShadowOffsetMin         0
#define kMTBadgeShadowOffsetMax         .2
#define kMTBadgeShadowOffsetDefault     .05     // ***

#define kMTBadgeShadowColorDefault      0x80000000

#define kMTBadgeIconSizeMin             .05
#define kMTBadgeIconSizeMax             .3
#define kMTBadgeIconSizeDefault         .198    // ***

#define kMTBadgeIconMarginMin           .00001
#define kMTBadgeIconMarginMax           .2
#define kMTBadgeIconMarginDefault       .01     // ***

#define kMTBannerColorDefault           0xFFCC00
#define kMTBannerTextColorDefault       0x000000
#define kMTBannerErrorColor             [NSColor redColor]

// value marked with "***" ensure the same position, size, etc. as in previous
// versions of this app where these values couldn't be changed

#define kMTGitHubURL                            @"https://github.com/SAP/macOS-icon-generator"

// NSUserDefaults
#define kMTDefaultsAutoImageSizeKey             @"autoAdjustImageSize"
#define kMTDefaultsImageSizeAdjustmentKey       @"ImageSizeAdjustment"
#define kMTDefaultsAnimationDurationKey         @"animationDuration"
#define kMTDefaultsOutputSizeKey                @"outputSize"
#define kMTDefaultsAutoOutputSizeKey            @"autoOutputSize"
#define kMTDefaultsPositionDefaultKey           @"DefaultPosition"
#define kMTDefaultsTextMarginDefaultKey         @"DefaultTextMargin"
#define kMTDefaultsBannerAngleDefaultKey        @"DefaultBannerAngle"
#define kMTDefaultsBannerHeightDefaultKey       @"DefaultBannerHeight"
#define kMTDefaultsBannerMarginDefaultKey       @"DefaultBannerMargin"
#define kMTDefaultsSelectedFontKey              @"SelectedFont"
#define kMTDefaultsSavedBannersKey              @"savedBanners"
#define kMTDefaultsBannerNameKey                @"bannerName"
#define kMTDefaultsBannerDataKey                @"bannerData"
#define kMTDefaultsBannerColorKey               @"bannerColor"
#define kMTDefaultsBannerTextColorKey           @"bannerTextColor"
#define kMTDefaultsBannerIsFlippedKey           @"IsFlipped"
#define kMTDefaultsBannerPositionKey            @"BannerPosition"
#define kMTDefaultsBannerTextMarginKey          @"BannerTextMargin"
#define kMTDefaultsBannerAngleKey               @"BannerAngle"
#define kMTDefaultsBannerHeightKey              @"BannerHeight"
#define kMTDefaultsBannerMarginKey              @"BannerMargin"
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
#define kMTDefaultsSettingsSelectedTabKey       @"SettingsSelectedTab"
#define kMTDefaultsMainWindowSelectedTabKey     @"MainWindowSelectedTab"
#define kMTDefaultsDeleteBadgeIconBookmarkKey   @"DeleteBadgeIconBookmark"
#define kMTDefaultsDeleteBadgeSFSymbolKey       @"DeleteBadgeSFSymbol"
#define kMTDefaultsBadgeIconAddShadowKey        @"BadgeIconAddShadow"
#define kMTDefaultsBadgeIconShadowRadiusKey     @"BadgeIconShadowRadius"
#define kMTDefaultsBadgeIconShadowOffsetKey     @"BadgeIconShadowOffset"
#define kMTDefaultsBadgeIconShadowAngleKey      @"BadgeIconShadowAngle"
#define kMTDefaultsBadgeIconShadowColorKey      @"BadgeIconShadowColor"
#define kMTDefaultsBadgeIconSizeKey             @"BadgeIconSize"
#define kMTDefaultsBadgeIconMarginKey           @"BadgeIconMargin"
#define kMTDefaultsBadgePositionDefaultKey      @"DefaultBadgePosition"
#define kMTDefaultsUseOldIconShapeKey           @"UseOldIconShape"
#define kMTDefaultsRenderImagesInIconShapeKey   @"RenderImagesInIconShape"
#define kMTDefaultsDrawBannerInIconShapeKey     @"DrawBannerInIconShape"

#define kMTFileNameInstall                      @"install.png"
#define kMTFileNameUninstall                    @"uninstall.png"
#define kMTFileNameUninstallAnimated            @"uninstall_animated.png"

// NSNotification
#define kMTNotificationNameImageChanged                 @"corp.sap.Icons.ImageChangedNotification"
#define kMTNotificationNameOverlayImageChanged          @"corp.sap.Icons.OverlayImageChangedNotification"
#define kMTNotificationNameOverlayImagePositionChanged  @"corp.sap.Icons.OverlayImagePositionChangedNotification"
#define kMTNotificationNameOverlayImageScalingChanged   @"corp.sap.Icons.OverlayImageScalingChangedNotification"
#define kMTNotificationNameRememberOverlayPosition      @"corp.sap.Icons.RememberOverlayPositionChangedNotification"
#define kMTNotificationNameIconShapeSettings            @"corp.sap.Icons.IconShapeSettingsChangedNotification"
#define kMTNotificationNameDeleteBadgeIconChanged       @"corp.sap.Icons.DeleteBadgeIconChangedNotification"
#define kMTNotificationNameBannerTruncated              @"corp.sap.Icons.BannerTextTruncatedNotification"
#define kMTNotificationNameSaveIcon                     @"corp.sap.Icons.SaveIconNotification"
#define kMTNotificationNameCopyIcon                     @"corp.sap.Icons.CopyIconNotification"
#define kMTNotificationNameShowImagePlayground          @"corp.sap.Icons.ShowImagePlaygroundNotification"
#define kMTNotificationNameOpenFile                     @"corp.sap.Icons.OpenFileNotification"
#define kMTNotificationNameAddOverlayImage              @"corp.sap.Icons.AddOverlayImageNotification"
#define kMTNotificationNameSaveFiles                    @"corp.sap.Icons.SaveFilesNotification"

// NSNotification user info keys
#define kMTNotificationKeyImage                 @"Image"
#define kMTNotificationKeyIsAppBundle           @"IsAppBundle"
#define kMTNotificationKeyFileNamePrefix        @"FileNamePrefix"
#define kMTNotificationKeyFolderPath            @"FolderPath"
