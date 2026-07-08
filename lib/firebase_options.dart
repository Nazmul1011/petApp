// File generated from the project's Firebase config
// (android/app/google-services.json and ios/Runner/GoogleService-Info.plist).
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBcJDKy9XoWZ_LEThNA9W_Z4qNhPabhgGk',
    appId: '1:155042076164:android:5e508a453b324efd570751',
    messagingSenderId: '155042076164',
    projectId: 'petapp-e72d0',
    storageBucket: 'petapp-e72d0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDoJ_SDeA_3157Q22mNnZRb7vOnABSiEok',
    appId: '1:155042076164:ios:1d74e3a6965df868570751',
    messagingSenderId: '155042076164',
    projectId: 'petapp-e72d0',
    storageBucket: 'petapp-e72d0.firebasestorage.app',
    iosBundleId: 'com.nazmul.petapp1',
  );
}
