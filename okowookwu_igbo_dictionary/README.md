# Ọkọwookwu

## Android release builds

For Google Play, build an Android App Bundle so Play can deliver only the
native libraries required by each device:

```shell
flutter build appbundle --release
```

For direct distribution, build one APK per supported ABI instead of a large
universal APK:

```shell
flutter build apk --release --split-per-abi
```

The split APKs are written to `build/app/outputs/flutter-apk/`; install the
APK matching the device architecture. Configure a private release signing key
before publishing; the current Android release build uses the debug signing
configuration.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
