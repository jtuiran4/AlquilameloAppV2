# Firebase and ImageKit Configuration

This project uses Firebase for its backend services and ImageKit for image management. To run the app, you need to configure both services with your own credentials.

## Firebase Setup

### Android Configuration

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Navigate to Project Settings → General
4. Under "Your apps", click on the Android app (or add one if it doesn't exist)
5. Download the `google-services.json` file
6. Place the file in: `android/app/google-services.json`

**Note:** The file `android/app/google-services.json.example` is provided as a template. DO NOT commit your actual `google-services.json` file with real API keys to version control.

### iOS Configuration (if needed)

1. In the Firebase Console, click on the iOS app (or add one if it doesn't exist)
2. Download the `GoogleService-Info.plist` file
3. Place the file in: `ios/Runner/GoogleService-Info.plist`

**Note:** DO NOT commit your actual `GoogleService-Info.plist` file to version control.

## ImageKit Setup

ImageKit is used for image upload and management in the app.

1. Go to [ImageKit Registration](https://imagekit.io/registration)
2. Sign up for a free account (no credit card required)
3. In your dashboard, navigate to "Developer options" → "API Keys"
4. Copy your API keys
5. Open `lib/core/imagekit_config.dart.example` and save it as `lib/core/imagekit_config.dart`
6. Replace the placeholder values with your actual ImageKit credentials:
   - `publicKey`: Your ImageKit public key
   - `urlEndpoint`: Your ImageKit URL endpoint
   - `privateKey`: Your ImageKit private key

**Note:** The file `lib/core/imagekit_config.dart.example` is provided as a template. DO NOT commit your actual `imagekit_config.dart` file to version control.

## Security Notice

⚠️ **IMPORTANT**: Never commit configuration files containing real API keys to version control. These files are included in `.gitignore` to prevent accidental commits:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/core/imagekit_config.dart`

If you accidentally committed sensitive credentials:
1. Remove them from git history
2. Regenerate your API keys in the respective service console (Firebase/ImageKit)
3. Update your local configuration files with the new keys
