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

  // 카카오 로그인 콜백 처리
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    print("📱 AppDelegate: openURL called with \(url)")
    return super.application(app, open: url, options: options)
  }
}
