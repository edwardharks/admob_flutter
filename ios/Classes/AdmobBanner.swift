import Foundation
import Flutter
import GoogleMobileAds

public class AdmobBanner : NSObject, FlutterPlatformView, GADBannerViewDelegate {
    private let messenger: FlutterBinaryMessenger
    private let channel: FlutterMethodChannel
    private let viewId: Int64
    
    private let adView = GADBannerView(adSize: kGADAdSizeBanner)
    
    init(messenger: FlutterBinaryMessenger, viewId: Int64, args: Any?) {
        self.messenger = messenger
        self.viewId = viewId
        self.channel = FlutterMethodChannel(name: "admob_flutter/banner_\(viewId)", binaryMessenger: messenger)
        
         super.init()
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            print("Loading ad")
            adView.adUnitID = (args as! [String: Any?])["adUnitId"] as? String
            adView.rootViewController = topController
            adView.load(GADRequest())
        } else {
            print("Not loading ad - no root view controller :(")
        }
        
        channel.setMethodCallHandler(handleMethodCall)
    }
    
    public func view() -> UIView {
        return adView
    }
    
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        channel.invokeMethod("loaded", arguments: nil)
    }
    
    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        channel.invokeMethod("failedToLoad", arguments: ["errorCode": error.code])
    }
    
    private func handleMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {
        case "setListener":
            adView.delegate = self
            break;
        case "dispose":
            dispose()
            break;
        default:
            break
        }
    }
    
    private func dispose() {
        adView.delegate = nil
        channel.setMethodCallHandler(nil)
    }
}
