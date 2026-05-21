# Building Poddr

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Dart SDK (bundled with Flutter)
- Platform-specific development tools (see [Flutter docs](https://docs.flutter.dev/get-started/install))

### Install Dependencies

```bash
flutter pub get
```

### Install fastforge (one-time)

Fastforge is a CLI tool used to package Poddr for distribution:

```bash
dart pub global activate fastforge
```

## Local Builds

### Windows

```bash
flutter build windows --release
fastforge release --name windows
```

### Linux

```bash
flutter build linux --release
fastforge release --name linux
```

### macOS

```bash
flutter build macos --release
fastforge release --name macos
```

### Android

```bash
flutter build apk --release
```

Note: This produces a debug-signed APK suitable for testing. For release builds, additional signing configuration is required.

### Snap

```bash
snapcraft --use-lxd
```

## Output Directories

- Flutter builds output to `build/`
- Fastforge packages output to `dist/`

## Troubleshooting

### Windows

- Ensure Visual Studio has "Desktop development with C++" workload installed

### Linux

- Ensure all GTK3 dependencies are installed

### macOS Gatekeeper warning

- Builds are unsigned by default
- Users can bypass by right-clicking the app and selecting "Open"
