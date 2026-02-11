# Firebase Configuration

This project uses Firebase for its backend services. To run the app, you need to configure Firebase with your own credentials.

## Setup Instructions

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

## Security Notice

⚠️ **IMPORTANT**: Never commit Firebase configuration files containing real API keys to version control. These files are included in `.gitignore` to prevent accidental commits.

If you accidentally committed sensitive credentials:
1. Remove them from git history
2. Regenerate your API keys in the Firebase Console
3. Update your local configuration files with the new keys
