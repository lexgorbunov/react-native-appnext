#import "RNAppNext.h"
#import "IntersitialDelegate.h"
#import "NativeAdsDelegate.h"
#import "RewardedVideoDelegate.h"
#import "FullScreenVideoDelegate.h"
#import <AppnextNativeAdsSDK/AppnextNativeAdsSDKApi.h>
#import <AppnextLib/AppnextInterstitialAd.h>
#import <AppnextLib/AppnextFullScreenVideoAd.h>
#import <AppnextLib/AppnextRewardedVideoAd.h>
#import <AppnextNativeAdsSDK/AppnextNativeAdsRequest.h>

@interface RNAppNext ()
@end

@implementation RNAppNext
{
    AppnextNativeAdsSDKApi *api;
    
    IntersitialDelegate *intersitialDelegate;
    NativeAdsDelegate *nativeAdsDelegate;
    RewardedVideoDelegate *rewardedVideoDelegate;
    FullScreenVideoDelegate *fullScreenVideoDelegate;
    
    AppnextInterstitialAd *interstitial;
    AppnextFullScreenVideoAd *fullScreen;
    AppnextRewardedVideoAd *rewarded;
}

@synthesize bridge = _bridge;

- (RNAppNext *)init {
    
    self = [super init];
    if (self) {
        NSLog(@"init RNAppNext");
        intersitialDelegate = [[IntersitialDelegate alloc] initWithAppNext:self];
        nativeAdsDelegate = [[NativeAdsDelegate alloc] initWithAppNext:self];
        rewardedVideoDelegate = [[RewardedVideoDelegate alloc] initWithAppNext:self];
        fullScreenVideoDelegate = [[FullScreenVideoDelegate alloc] initWithAppNext:self];        
    }
    return self;
}
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setupAd:(NSString *)placementID)
{
    api = [[AppnextNativeAdsSDKApi alloc] initWithPlacementID:placementID withViewController:nil];
}

RCT_EXPORT_METHOD(privacyClicked:(NSString *)adID)
{
    id ad = [nativeAdsDelegate getAd:adID];
    if(ad!=nil){
        [api privacyClicked:ad withPrivacyClickedDelegate:nil];
    }
}

RCT_EXPORT_METHOD(videoEnded:(NSString *)adID)
{
    id ad = [nativeAdsDelegate getAd:adID];
    if(ad!=nil){
        [api videoEnded:ad];
    }
}

RCT_EXPORT_METHOD(videoStarted:(NSString *)adID)
{
    id ad = [nativeAdsDelegate getAd:adID];
    if(ad!=nil){
        [api videoStarted:ad];
    }
}

RCT_EXPORT_METHOD(adImpression:(NSString *)adID)
{
    id ad = [nativeAdsDelegate getAd:adID];
    if(ad!=nil){
        [api adImpression:ad];
    }
}

RCT_EXPORT_METHOD(adClicked:(NSString *)adID)
{
    id ad = [nativeAdsDelegate getAd:adID];
    if(ad!=nil){
        [api adClicked:ad withAdOpenedDelegate:nil];
    }
}

RCT_EXPORT_METHOD(removeAd:(NSString *)adID)
{
    [nativeAdsDelegate removeAd:adID];
}

RCT_REMAP_METHOD(loadAd,
                 loadAdWithCategory: (NSString *)category
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    AppnextNativeAdsRequest *request = [[AppnextNativeAdsRequest alloc] init];
    request.count = 1;
    //request.postback = @"REPLACE_WITH_POSTBACK";
    request.categories = category;
    request.creativeType= ANCreativeTypeManaged;
    request.clickInApp = YES;
    
    [nativeAdsDelegate setResolver: resolve];
    [nativeAdsDelegate setRejecter: reject];
    [api loadAds:request withRequestDelegate:nativeAdsDelegate];
    resolve(@"ok");

}

RCT_REMAP_METHOD(showInterstitial,
                 showInterstitialWithPlacementID: (NSString *)placementID
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    
    interstitial = [[AppnextInterstitialAd alloc] initWithPlacementID:placementID];
    [intersitialDelegate setResolver: resolve];
    [intersitialDelegate setRejecter: reject];
    interstitial.delegate = intersitialDelegate;
    [interstitial loadAd];
}

RCT_REMAP_METHOD(showRewardedVideo,
                 showRewardedVideoWithPlacementID: (NSString *)placementID
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    
    rewarded = [[AppnextRewardedVideoAd alloc] initWithPlacementID:placementID];
    [rewardedVideoDelegate setResolver: resolve];
    [rewardedVideoDelegate setRejecter: reject];
    rewarded.delegate = rewardedVideoDelegate;
    [rewarded loadAd];
}

RCT_REMAP_METHOD(showFullScreenVideo,
                 showFullScreenVideoWithPlacementID: (NSString *)placementID
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    
    fullScreen = [[AppnextFullScreenVideoAd alloc] initWithPlacementID:placementID];
    [fullScreenVideoDelegate setResolver: resolve];
    [fullScreenVideoDelegate setRejecter: reject];
    fullScreen.delegate = fullScreenVideoDelegate;
    [fullScreen loadAd];
}

- (void)sendEvent:(NSString *)name body:(id)body {
    [self sendEventWithName:name body:body];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onAdLoaded",
             @"onRewardedVideoEnded",
             @"onRewardedVideoClicked",
             @"onRewardedVideoClosed",
             @"onInterstitialClicked",
             @"onInterstitialClosed",
             @"onFullScreenVideoEnded",
             @"onFullScreenVideoClicked",
             @"onFullScreenVideoClosed"];

}

@synthesize description;

@synthesize superclass;

@synthesize hash;

@end
  
