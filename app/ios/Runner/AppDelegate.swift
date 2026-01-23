import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    print("📱 AppDelegate: didFinishLaunchingWithOptions STARTED")
    GeneratedPluginRegistrant.register(with: self)
    print("📱 AppDelegate: Plugins Registered")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
