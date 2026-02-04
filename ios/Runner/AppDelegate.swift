import Flutter
import UIKit
import Firebase
import awesome_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // Configure Firebase first
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }
    GeneratedPluginRegistrant.register(with: self)
        // This function registers the desired plugins to be used within a notification background action
    SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
      SwiftAwesomeNotificationsPlugin.register(
        with: registry.registrar(
          forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
