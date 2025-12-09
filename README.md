# Restaurant Management System - Frontend Setup Guide

## Table of Contents

1. [Overview](#overview)
2. [System Requirements](#system-requirements)
3. [Installation Steps](#installation-steps)
4. [Configuration](#configuration)
5. [Environment Variables](#environment-variables)
6. [Building and Running](#building-and-running)
7. [Project Structure](#project-structure)
8. [State Management](#state-management)
9. [Caching Strategy](#caching-strategy)
10. [Troubleshooting](#troubleshooting)

---

## Overview

The Restaurant Management System frontend is a Flutter-based mobile and web application providing staff with real-time order management, kitchen display system, and menu browsing capabilities. The application features Google Sign-In authentication, two-factor authentication support, and intelligent local caching for offline-friendly operations.

Key features include:

- Cross-platform support (Android, iOS, Web, Windows, macOS, Linux)
- Google OAuth 2.0 sign-in integration
- Two-factor authentication support
- Real-time order tracking and kitchen display
- Local data caching with SharedPreferences
- Provider-based state management
- Email/password and Google account linking

---

## System Requirements

- Flutter 3.10 or higher
- Dart 3.10 or higher
- Android Studio (for Android development)
- Xcode 14+ (for iOS development)
- Git
- A text editor or IDE (VS Code, Android Studio, or IntelliJ)

Platform-specific requirements:

Android:

- Android SDK 21 or higher
- Android API level 28+

iOS:

- iOS 11.0 or higher
- CocoaPods

Web:

- Chrome, Firefox, Safari, or Edge browser

---

## Installation Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/imamrpratama/restaurant-frontend.git
cd restaurant_frontend
```

### Step 2: Install Flutter Packages

```bash
flutter pub get
```

### Step 3: Set Up Platform-Specific Dependencies

For Android:

```bash
cd android
./gradlew clean
cd ..
```

For iOS (Mac only):

```bash
cd ios
pod install
cd ..
```

### Step 4: Create Configuration Files

The app requires Google credentials configuration. Create or update the file:

```
lib/config/google_config.dart
```

### Step 5: Run the Application

For development with hot reload:

```bash
flutter run
```

Specify a particular platform:

```bash
flutter run -d android          # Run on Android device/emulator
flutter run -d ios              # Run on iOS simulator
flutter run -d chrome           # Run on web
flutter run -d windows          # Run on Windows
```

---

## Configuration

### Google Sign-In Configuration

The application requires Google OAuth 2.0 credentials for authentication.

File: `lib/config/google_config.dart`

```dart
class GoogleConfig {
  // Web Client ID - Used for backend token verification
  static const String webClientId =
      '66365629604-crlgadsq85qpferomec3rilq6bg4f2m8.apps.googleusercontent.com';

  // Android Client ID - Used for Android-specific signing
  static const String androidClientId =
      '66365629604-lb615jr3anj7mb9js5q2fm7f3b4712pd.apps.googleusercontent.com';

  // iOS Client ID - Used for iOS-specific signing
  static const String iosClientId =
      'YOUR_IOS_CLIENT_ID_HERE.apps.googleusercontent.com';

  // OAuth Scopes
  static const List<String> scopes = [
    'email',
    'profile',
  ];

  // Set to false for Android/iOS deployment
  static bool useWebOnlyMode = false;
}
```

Obtaining Google Credentials:

1. Go to Google Cloud Console: https://console.cloud.google.com
2. Create a new project
3. Enable Google+ API
4. Create OAuth 2.0 credentials for Web, Android, and iOS
5. Copy Client IDs to google_config.dart

For Android, you must also:

1. Get your app's SHA-1 fingerprint:

```bash
./gradlew signingReport
```

2. Add this fingerprint in Google Cloud Console under Android credentials
3. Update build.gradle with your Client ID

### Application Configuration

File: `lib/config/app_config.dart`

```dart
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const String appName = 'Restaurant Manager';
  static const String appVersion = '1.0.0';
}
```

Update apiBaseUrl for different environments:

- Development: http://localhost:8000/api
- Staging: https://staging-api.restaurant.com/api
- Production: https://api.restaurant.com/api

---

## Environment Variables

Create a `.env` file in the project root (optional):

```env
API_BASE_URL=http://localhost:8000/api
GOOGLE_WEB_CLIENT_ID=66365629604-crlgadsq85qpferomec3rilq6bg4f2m8.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=66365629604-lb615jr3anj7mb9js5q2fm7f3b4712pd.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=your_ios_client_id.apps.googleusercontent.com
APP_ENV=development
```

---

## Building and Running

### Development Mode

Run with hot reload enabled:

```bash
flutter run
```

Run with debug output:

```bash
flutter run -v
```

### Release Build

For production deployment:

Android APK:

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Android App Bundle:

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

iOS App:

```bash
flutter build ios --release
```

Web Build:

```bash
flutter build web --release
```

Output: `build/web`

Windows Build:

```bash
flutter build windows --release
```

### Running Tests

The frontend uses integration tests:

```bash
flutter test
```

Run specific test file:

```bash
flutter test test/widget_test.dart
```

---

## Project Structure

```
restaurant_frontend/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── config/
│   │   ├── app_config.dart       # App configuration
│   │   └── google_config.dart    # Google OAuth configuration
│   ├── models/
│   │   ├── user.dart             # User model
│   │   ├── order.dart            # Order model
│   │   ├── menu.dart             # Menu model
│   │   └── table.dart            # Table model
│   ├── providers/
│   │   ├── auth_provider.dart    # Authentication state management
│   │   ├── order_provider.dart   # Order state management
│   │   └── menu_provider.dart    # Menu state management
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── verify_2fa_screen.dart
│   │   ├── home_screen.dart
│   │   ├── orders_screen.dart
│   │   ├── kitchen_display_screen.dart
│   │   └── menu_screen.dart
│   ├── services/
│   │   ├── api_service.dart      # HTTP API client
│   │   ├── storage_service.dart  # Token storage
│   │   └── cache_service.dart    # Local caching service
│   └── widgets/
│       ├── order_card.dart
│       ├── menu_item.dart
│       └── kitchen_order_item.dart
├── android/
│   ├── app/
│   │   └── build.gradle          # Android build configuration
│   └── build.gradle
├── ios/
│   └── Podfile                   # iOS dependencies
├── web/
│   └── index.html
├── pubspec.yaml                  # Package dependencies
├── pubspec.lock                  # Lock file for dependencies
└── README.md
```

---

## State Management

The application uses Provider for state management.

### Auth Provider

Handles user authentication and session management.

File: `lib/providers/auth_provider.dart`

Key methods:

- `login()` - Email/password authentication
- `register()` - User registration
- `googleLogin()` - Google OAuth authentication
- `verify2FA()` - Two-factor authentication
- `logout()` - User logout
- `checkEmailExists()` - Check if email already registered
- `checkAuth()` - Verify current user session

Usage in widgets:

```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (authProvider.isAuthenticated) {
      return HomeScreen();
    }
    return LoginScreen();
  },
)
```

### Order Provider

Manages order state and caching.

File: `lib/providers/order_provider.dart`

Key methods:

- `fetchOrders()` - Get all orders
- `createOrder()` - Create new order
- `updateOrderStatus()` - Update order status

Caching behavior:

- Returns cached orders immediately
- Fetches fresh data in background
- Auto-refreshes every 30 seconds

### Menu Provider

Handles menu and category management.

Key methods:

- `fetchMenus()` - Get all menu items
- `fetchCategories()` - Get food categories

---

## Caching Strategy

The application implements a multi-layer caching strategy for optimal performance.

### Local Caching (SharedPreferences)

File: `lib/services/cache_service.dart`

Cached data with 30-second TTL:

- Orders list
- Kitchen display items
- User preferences

Implementation:

```dart
// Save data
await CacheService.cacheOrders(orders);

// Retrieve data
final cachedOrders = await CacheService.getCachedOrders();

// Check if data is still valid
if (cachedOrders != null && !CacheService.isExpired('orders')) {
  return cachedOrders;
}
```

### Redis Server-Side Caching

The backend caches data for 30-60 seconds. See backend documentation for details.

### Cache Invalidation

Caches are automatically cleared when:

- User creates a new order
- User updates an order status
- Menu items are modified
- User logs out

Manual cache clearing:

```dart
await CacheService.clearCache();
```

---

## Dependencies

Key packages used in the application:

- Provider: State management
- Google Sign In: OAuth 2.0 authentication
- HTTP: HTTP client for API requests
- Shared Preferences: Local data storage
- Path Provider: File system access
- Image Picker: Image selection
- Image Gallery Saver: Save images to gallery
- Flutter SVG: SVG image support

Install all dependencies:

```bash
flutter pub get
```

Update dependencies:

```bash
flutter pub upgrade
```

---

## Troubleshooting

### Common Issues

Issue: "Flutter not found" after installation

Solution: Add Flutter to PATH environment variable or use full path:

```bash
/path/to/flutter/bin/flutter run
```

Issue: "Android SDK not found"

Solution: Install Android Studio and configure Android SDK:

```bash
flutter doctor
```

Follow the prompts to install missing components.

Issue: Google Sign-In not working

Solution: Verify Google credentials and configuration:

1. Check google_config.dart has correct Client IDs
2. For Android, verify SHA-1 fingerprint is registered
3. Ensure internet connection is available
4. Check App Manifest permissions (Android)

Issue: Emulator/Device not detected

Solution: List connected devices:

```bash
flutter devices
```

Start an emulator:

```bash
flutter emulators --launch <emulator_name>
```

Issue: Hot reload not working

Solution: Use hot restart instead:

```bash
r       # Hot reload
R       # Hot restart
q       # Quit
```

Issue: Cache not clearing

Solution: Clear app data and reinstall:

```bash
flutter clean
flutter pub get
flutter run
```

### Debugging

Enable verbose logging:

```bash
flutter run -v
```

Inspect logs from device/emulator:

```bash
flutter logs
```

Use Flutter DevTools:

```bash
flutter pub global activate devtools
devtools
```

Then run app with DevTools enabled:

```bash
flutter run --start-paused
```

---

## Platform-Specific Setup

### Android Setup

Required configuration in `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.test.restaurant"
        minSdkVersion 21
        targetSdkVersion 34

        manifestPlaceholders = [
            'googleServerClientId': 'YOUR_WEB_CLIENT_ID',
            'applicationName': 'io.flutter.app.FlutterApplication'
        ]
    }
}
```

### iOS Setup

Update `ios/Runner/Info.plist`:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs access to your local network to communicate with the restaurant API server</string>
```

### Web Setup

Web builds are available at `build/web`. Deploy to any static hosting service:

```bash
firebase hosting:deploy
```

or use a simple HTTP server:

```bash
python -m http.server 8080 -d build/web
```

---

## Performance Optimization

### Build Optimization

Profile build performance:

```bash
flutter build apk --analyze-size --release
```

### Runtime Optimization

- Enable AOT compilation for release builds
- Use ProGuard/R8 for Android (automatic in Flutter)
- Minimize rebuild of widgets using Consumer
- Cache network responses aggressively

### Memory Management

- Dispose providers when unused
- Clear cache periodically
- Monitor memory usage with DevTools

---

## Production Deployment

### Pre-Deployment Checklist

- Verify all Google credentials are correct
- Update API base URL to production server
- Disable debug mode
- Test all authentication flows
- Verify caching works correctly
- Test on real devices

### Code Signing

Android:

```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

iOS: Handled through Xcode

### Deployment Steps

1. Update version in pubspec.yaml
2. Build release APK/IPA
3. Test on device/emulator
4. Upload to App Store/Play Store
5. Monitor crash logs and user feedback

---

## Support and Contribution

For issues or contributions, please submit a pull request or contact the development team.

Documentation last updated: December 9, 2025
