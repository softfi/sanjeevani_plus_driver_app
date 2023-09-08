import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
     GMSServices.provideAPIKey("AIzaSyDY6bCkW4uDURxfg6-NX0__8jVDrtsy20I")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
