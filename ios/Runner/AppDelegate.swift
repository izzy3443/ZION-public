import UIKit
import Flutter
import FirebaseCore
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()  // Initialize Firebase
    
    // Initialize Google Maps with your API key
    GMSServices.provideAPIKey("AIzaSyAt5xvALjgMQLJEYcVlQC7ZFYn2Vi5qrMY")
   
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
