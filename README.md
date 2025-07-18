# MicroRealEstate

A modern, cross-platform property management application built with Flutter. MicroRealEstate helps landlords and property managers efficiently manage properties, tenants, rent payments, and maintenance requests.

## Features

- Property listing and management
- Tenant management
- Rent payment tracking
- Maintenance request tracking
- Search and filter properties
- Add, edit, and delete properties
- Multi-platform: Android, iOS, Web (Flutter)
- Modern UI with responsive design
- Localization support (English, French)

## Screenshots
<!-- Add screenshots here if available -->

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code (recommended)
- Dart (comes with Flutter)

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/KhetanSaini/microrealeaste.git
   cd microrealeaste
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the app:**
   - For Android:
     ```bash
     flutter run -d android
     ```
   - For iOS:
     ```bash
     flutter run -d ios
     ```
   - For Web:
     ```bash
     flutter run -d chrome
     ```

### Folder Structure
```
lib/
  database/         # Data models and services
  pages/            # UI pages/screens
  providers/        # State management (Riverpod)
  widgets/          # Reusable widgets
  theme.dart        # App theming
assets/
  i18n/             # Localization files
  icons/            # SVG and image assets
android/            # Android native code
ios/                # iOS native code
```

## Localization
- English and French translations are available in `assets/i18n/`.

## Contributing
Contributions are welcome! Please open issues and submit pull requests for new features, bug fixes, or improvements.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

## License
This project is licensed under the MIT License.

## Contact
For questions or support, please open an issue on GitHub. 