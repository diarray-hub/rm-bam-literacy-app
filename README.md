# An be Kalan 📚
Flutter-based **Early Literacy Application** for the **Bambara Language**, developed by **RobotsMali**.

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Features](#features)
3. [Screenshots](#screenshots)
4. [Getting Started](#getting-started)
5. [Dependencies](#dependencies)
6. [Firebase Configuration](#firebase-configuration)
7. [Contributing](#contributing)
8. [License](#license)

---

## Project Overview

This project is a **Flutter mobile application** aimed at promoting early literacy in **Bambara**, leveraging a clean UI and Firebase-backed authentication.

---

## Features

- **User Authentication**  
  Firebase-based login and profile management.

- **Interactive Lessons**  
  Structured lesson screens for teaching Bambara reading skills.

- **Child-Friendly Interface**  
  Intuitive and colorful UI designed for young learners.

---

## Screenshots
TODO: *(Include screenshots of the app here.)*

---

## Getting Started

Follow these steps to run the app locally:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/diarray-hub/an-be-kalan.git
   cd an-be-kalan
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
    - Add the `GoogleService-Info.plist` for iOS and `firebase.json` for Android.
    - See the [Firebase Configuration](#firebase-configuration) section below.

4. **Run the application**:
   ```bash
   flutter run
   ```

---

## Dependencies

Key dependencies are listed in `pubspec.yaml`:

- **Firebase**:
    - `firebase_core`
    - `firebase_auth`
    - `firebase_app_check: ^0.2.1+17`
    - `firebase_storage: ^11.6.9`
    - `firebase_analytics: ^10.8.9`
    - `cloud_firestore: ^4.15.8`
- **UI**:
    - `flutter_launcher_icons`
- **Other Utilities**:
    - `collection: ^1.18.0`
    - `barcode_widget: ^2.0.4`
    - `image_picker: ^1.0.0`
    - `record: ^4.4.4`
    - `just_audio: ^0.9.32`
    - `http: ^1.2.0`
    - `path: ^1.8.3`
    - `path_provider: ^2.1.4`

Install all dependencies using:
```bash
flutter pub get
```

---

## Firebase Configuration

Ensure Firebase is properly set up for the app, if you wanna create the project on your own account:

1. Generate Firebase configuration files:
    - For **iOS**, download `GoogleService-Info.plist`.
    - For **Android**, download `google-services.json`.

2. Place the files:
    - iOS: `ios/Runner/GoogleService-Info.plist`
    - Android: `android/app/google-services.json`

3. Ensure `firebase_options.dart` is updated with the project details.

---

## Contributing

Contributions are welcome!  
Feel free to submit a pull request or open an issue for any improvements.

---

## License

This project is licensed under the MIT License.  
See the [LICENSE](LICENSE) file for details.

---
