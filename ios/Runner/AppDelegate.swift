import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      FlutterMethodChannel(
        name: "com.plant.common/social_auth",
        binaryMessenger: controller.binaryMessenger
      ).setMethodCallHandler { call, result in
        guard call.method == "isAppleLoginSupported" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard Bundle.main.object(forInfoDictionaryKey: "CommonPlantAppleSignInEnabled") as? String == "YES" else {
          result(false)
          return
        }
        if #available(iOS 14.0, *), ProcessInfo.processInfo.isiOSAppOnMac {
          result(false)
          return
        }
        result(UIDevice.current.userInterfaceIdiom == .phone)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
