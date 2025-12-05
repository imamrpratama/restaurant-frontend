# Restaurant Frontend - Flutter

Flutter mobile application for restaurant management system with Two-Factor Authentication (2FA), Google Sign-In, and real-time order management.

## Features

- ✅ Login/Register with Email & Password
- ✅ Google Sign-In Integration
- ✅ Two-Factor Authentication (2FA) with QR Code Setup
- ✅ Category Management (CRUD)
- ✅ Menu Management (CRUD with Image Upload)
- ✅ Table Management (CRUD with Status)
- ✅ Order Management (Create, Track, Update Status)
- ✅ Kitchen Display System (Real-time Order Tracking)
- ✅ Settings (2FA Enable/Disable)
- ✅ Image Caching from MinIO

## Requirements

- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Android Emulator or Physical Device

## Installation

### 1. Clone Repository

```bash
git clone <your-repo-url>
cd restaurant_frontend
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Endpoint

Edit `lib/config/app_config.dart`:

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000/api';

// For iOS Simulator
// static const String baseUrl = 'http://localhost:8000/api';

// For Real Device (replace with your computer's IP)
// static const String baseUrl = 'http://192.168.1. 100:8000/api';
```

### 4. Configure Google Sign-In

**Android:**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google Sign-In API
4. Create OAuth 2.0 Client ID for Android
5. Get SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/. android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
6. Add SHA-1 to Google Cloud Console
7. Download `google-services.json` and place in `android/app/`

**Update `app_config.dart`:**

```dart
static const String googleClientId = 'YOUR_CLIENT_ID. apps.googleusercontent.com';
```

### 5. Run Application

```bash
# Check devices
flutter devices

# Run on connected device
flutter run

# Run in release mode
flutter run --release
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   └── app_config.dart         # API & app configuration
├── models/                     # Data models
├── providers/                  # State management (Provider)
├── services/                   # API & storage services
├── screens/                    # UI screens
│   ├── auth/                   # Login, Register, 2FA
│   ├── home/                   # Dashboard
│   ├── categories/             # Category management
│   ├── menus/                  # Menu management
│   ├── tables/                 # Table management
│   ├── orders/                 # Order management
│   ├── kitchen/                # Kitchen display
│   └── settings/               # Settings & 2FA
└── widgets/                    # Reusable widgets
```

## Key Features Implementation

### 1. Two-Factor Authentication (2FA)

**Setup Flow:**

1. User enables 2FA in Settings
2. QR code is generated and displayed
3. User scans with authenticator app (Google Authenticator, Authy)
4. User enters 6-digit code to confirm
5. 2FA is enabled

**Login Flow with 2FA:**

1. User enters email & password
2. If 2FA enabled, verification screen appears
3. User enters 6-digit code from authenticator app
4. Access granted upon successful verification

### 2. Google Sign-In

**Flow:**

1. User taps "Sign in with Google"
2. Google account selection
3. ID token sent to backend for verification
4. If 2FA enabled, verification required
5. Access granted

### 3. Kitchen Display System

**Features:**

- Auto-refresh every 10 seconds
- Color-coded by status (pending/processing)
- Urgency indicator (red for orders > 15 minutes)
- Search by order number or table
- Quick status update buttons
- Real-time order tracking

### 4. Image Upload (Menu)

**Flow:**

1. Select image from gallery
2. Image preview shown
3. Image uploaded to MinIO during menu creation
4. Image URL returned and cached for display

## Testing

### Test Login

```
Email: test@example.com
Password: password123
```

### Test 2FA Flow

1. Register new account
2. Go to Settings
3. Enable 2FA
4. Scan QR code with Google Authenticator
5. Enter verification code
6. Logout and login again
7. 2FA verification required

### Test Kitchen Display

1. Create multiple orders
2. Navigate to Kitchen Display
3. Orders appear in real-time
4. Update order status (Pending → Processing → Done)
5. Auto-refresh active

## API Endpoints Used

```
POST   /api/register
POST   /api/login
POST   /api/google-signin
POST   /api/verify-2fa
POST   /api/2fa/enable
POST   /api/2fa/confirm
POST   /api/2fa/disable
GET    /api/categories
POST   /api/categories
GET    /api/menus
POST   /api/menus
GET    /api/tables
POST   /api/tables
GET    /api/orders
POST   /api/orders
PATCH  /api/orders/{id}/status
GET    /api/kitchen-display
```

## Troubleshooting

### Cannot connect to API

- **Android Emulator:** Use `http://10.0.2. 2:8000/api`
- **iOS Simulator:** Use `http://localhost:8000/api`
- **Real Device:** Use your computer's local IP `http://192.168.x.x:8000/api`
- Check Laravel server is running: `php artisan serve`

### Google Sign-In not working

- Verify SHA-1 fingerprint is added to Google Console
- Check `google-services.json` is in `android/app/`
- Ensure Google Client ID matches in both frontend and backend

### Images not loading

- Ensure MinIO is running on `http://localhost:9000`
- Check MinIO bucket `restaurant` exists and is public
- Verify backend returns correct image URLs

### 2FA QR Code not showing

- Check backend 2FA secret generation
- Ensure QR code URL format is correct
- Verify `qr_flutter` package is installed

## Build for Release

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release. aab`

## Screenshots

Include these screenshots in your video demonstration:

1. ✅ Login Screen with Google Sign-In button
2. ✅ 2FA Setup with QR Code
3. ✅ 2FA Verification Screen (REQUIRED)
4. ✅ Home Dashboard
5. ✅ Menu List with Images from MinIO
6. ✅ Create Order Screen
7. ✅ Kitchen Display System
8. ✅ Order Status Update

## License

This project is for assessment purposes.

```

```
