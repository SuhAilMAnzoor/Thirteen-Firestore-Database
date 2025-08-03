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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDlh0TCfuve1gtQT7vGNrVEuqqr_rQ9MfY',
    appId: '1:157762622714:web:ba1b04a3166bff80102543',
    messagingSenderId: '157762622714',
    projectId: 'thirteen-firestore-data-base',
    authDomain: 'thirteen-firestore-data-base.firebaseapp.com',
    storageBucket: 'thirteen-firestore-data-base.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACwaTaZtQ4FOaQR-9Pinpsvc4ZlaqLkWg',
    appId: '1:157762622714:android:cba7f11f3f0dce8f102543',
    messagingSenderId: '157762622714',
    projectId: 'thirteen-firestore-data-base',
    storageBucket: 'thirteen-firestore-data-base.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMYlY9YGdM0ByVBrlCZ61pI5TE73dEisw',
    appId: '1:157762622714:ios:0f33604ec13018e1102543',
    messagingSenderId: '157762622714',
    projectId: 'thirteen-firestore-data-base',
    storageBucket: 'thirteen-firestore-data-base.firebasestorage.app',
    iosBundleId: 'com.sohail.thirteenFirestoreDatabase',
  );
}
