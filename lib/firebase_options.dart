import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static String _requiredValue(String key, String value) {
    if (value.isEmpty) {
      throw UnsupportedError(
        'Missing Firebase config: $key. '
        'Provide it via --dart-define or --dart-define-from-file=.env.',
      );
    }
    return value;
  }

  static const _firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _firebaseMessagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _firebaseStorageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const _firebaseAuthDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _firebaseMeasurementId =
      String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

  static const _firebaseAndroidApiKey =
      String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
  static const _firebaseAndroidAppId =
      String.fromEnvironment('FIREBASE_ANDROID_APP_ID');

  static const _firebaseIosApiKey = String.fromEnvironment('FIREBASE_IOS_API_KEY');
  static const _firebaseIosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
  static const _firebaseIosBundleId =
      String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

  static const _firebaseMacosApiKey =
      String.fromEnvironment('FIREBASE_MACOS_API_KEY');
  static const _firebaseMacosAppId =
      String.fromEnvironment('FIREBASE_MACOS_APP_ID');
  static const _firebaseMacosBundleId =
      String.fromEnvironment('FIREBASE_MACOS_BUNDLE_ID');

  static const _firebaseWebApiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
  static const _firebaseWebAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');

  static const _firebaseWindowsApiKey =
      String.fromEnvironment('FIREBASE_WINDOWS_API_KEY');
  static const _firebaseWindowsAppId =
      String.fromEnvironment('FIREBASE_WINDOWS_APP_ID');

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
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _requiredValue('FIREBASE_IOS_API_KEY', _firebaseIosApiKey),
    appId: _requiredValue('FIREBASE_IOS_APP_ID', _firebaseIosAppId),
    messagingSenderId: _requiredValue(
      'FIREBASE_MESSAGING_SENDER_ID',
      _firebaseMessagingSenderId,
    ),
    projectId: _requiredValue('FIREBASE_PROJECT_ID', _firebaseProjectId),
    storageBucket: _requiredValue('FIREBASE_STORAGE_BUCKET', _firebaseStorageBucket),
    iosBundleId: _requiredValue('FIREBASE_IOS_BUNDLE_ID', _firebaseIosBundleId),
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: _requiredValue('FIREBASE_MACOS_API_KEY', _firebaseMacosApiKey),
    appId: _requiredValue('FIREBASE_MACOS_APP_ID', _firebaseMacosAppId),
    messagingSenderId: _requiredValue(
      'FIREBASE_MESSAGING_SENDER_ID',
      _firebaseMessagingSenderId,
    ),
    projectId: _requiredValue('FIREBASE_PROJECT_ID', _firebaseProjectId),
    storageBucket: _requiredValue('FIREBASE_STORAGE_BUCKET', _firebaseStorageBucket),
    iosBundleId: _requiredValue('FIREBASE_MACOS_BUNDLE_ID', _firebaseMacosBundleId),
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: _requiredValue('FIREBASE_WINDOWS_API_KEY', _firebaseWindowsApiKey),
    appId: _requiredValue('FIREBASE_WINDOWS_APP_ID', _firebaseWindowsAppId),
    messagingSenderId: _requiredValue(
      'FIREBASE_MESSAGING_SENDER_ID',
      _firebaseMessagingSenderId,
    ),
    projectId: _requiredValue('FIREBASE_PROJECT_ID', _firebaseProjectId),
    authDomain: _requiredValue('FIREBASE_AUTH_DOMAIN', _firebaseAuthDomain),
    storageBucket: _requiredValue('FIREBASE_STORAGE_BUCKET', _firebaseStorageBucket),
    measurementId: _requiredValue('FIREBASE_MEASUREMENT_ID', _firebaseMeasurementId),
  );

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _requiredValue('FIREBASE_WEB_API_KEY', _firebaseWebApiKey),
    appId: _requiredValue('FIREBASE_WEB_APP_ID', _firebaseWebAppId),
    messagingSenderId: _requiredValue(
      'FIREBASE_MESSAGING_SENDER_ID',
      _firebaseMessagingSenderId,
    ),
    projectId: _requiredValue('FIREBASE_PROJECT_ID', _firebaseProjectId),
    authDomain: _requiredValue('FIREBASE_AUTH_DOMAIN', _firebaseAuthDomain),
    storageBucket: _requiredValue('FIREBASE_STORAGE_BUCKET', _firebaseStorageBucket),
    measurementId: _requiredValue('FIREBASE_MEASUREMENT_ID', _firebaseMeasurementId),
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _requiredValue('FIREBASE_ANDROID_API_KEY', _firebaseAndroidApiKey),
    appId: _requiredValue('FIREBASE_ANDROID_APP_ID', _firebaseAndroidAppId),
    messagingSenderId: _requiredValue(
      'FIREBASE_MESSAGING_SENDER_ID',
      _firebaseMessagingSenderId,
    ),
    projectId: _requiredValue('FIREBASE_PROJECT_ID', _firebaseProjectId),
    storageBucket: _requiredValue('FIREBASE_STORAGE_BUCKET', _firebaseStorageBucket),
  );
}
