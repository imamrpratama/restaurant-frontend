class GoogleConfig {
  // Web Client ID - Used for backend token verification
  static const String webClientId =
      '66365629604-crlgadsq85qpferomec3rilq6bg4f2m8.apps.googleusercontent.com';

  // Android Client ID - Optional, used for Android-specific signing
  static const String androidClientId =
      '66365629604-lb615jr3anj7mb9js5q2fm7f3b4712pd.apps.googleusercontent.com';

  // iOS Client ID - Optional, used for iOS-specific signing
  /* static const String iosClientId =
      'YOUR_IOS_CLIENT_ID_HERE.apps.googleusercontent.com'; */

  // OAuth Scopes requested
  static const List<String> scopes = [
    'email',
    'profile',
  ];

  static bool useWebOnlyMode = false;
}
