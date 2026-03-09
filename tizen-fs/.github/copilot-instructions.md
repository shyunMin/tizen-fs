# Tizen Homescreen Flutter App - AI Coding Guidelines

## Architecture Overview

This is a **Flutter/Dart application for Samsung Tizen devices** (TV/embedded systems). Key architectural components:

### Dependency Injection (GetIt)
- All services/models are registered as **lazy singletons** in [lib/locator.dart](lib/locator.dart)
- Setup functions: `setupAppModel()`, `setupSettingProvider()`, `setupVideoController()`, `setupAdditionalFeatureProvider()`
- Access via: `getIt<ServiceType>()` - never create new instances directly
- Widget layer uses Provider for reactive updates; service layer uses GetIt for access

### State Management (Provider)
- **Two-tier pattern**: Native/core services use GetIt → Provider wraps them for UI reactivity
- Models extend `ChangeNotifier` and call `notifyListeners()` when state changes
- Example: [AppDataModel](lib/models/app_data_model.dart) manages apps, [LocaleProvider](lib/providers/locale_provider.dart) manages language
- MultiProvider in [main.dart](lib/main.dart) wraps entire app - **always add new providers here**

### Routing (go_router)
- Routes defined in [lib/router.dart](lib/router.dart) - add routes to `AppRouter.router`
- Screen path constants: `ScreenPaths.main`, `ScreenPaths.settings`, etc.
- **Never use Navigator directly** - use `RouterService.instance.safePush(location)` to prevent navigation conflicts
- Page caching via `PageCache.getPage()` keeps widgets in memory across navigation

### Native Integration
- FFI-based managers in [lib/native/](lib/native/) wrap Tizen C libraries
- Pattern: Define FFI bindings → lookup functions → wrap in manager class
- Managers are singletons registered in locator, accessed by providers
- Examples: `NotificationManager` (libnotification.so.0), `AppManager` (app control callbacks)
- **Don't call native code directly** - use manager classes

## Project-Specific Patterns

### Adding New Features
1. **Create model/provider pair**: `MyFeatureModel` extends `ChangeNotifier`, register in `setupAppModel()`
2. **Create provider wrapper** (if UI reactive): `MyFeatureProvider` with `ChangeNotifier`
3. **Add to MultiProvider** in [main.dart](lib/main.dart)
4. **Add route** to [router.dart](lib/router.dart) if it's a new screen
5. **Create UI in [lib/screen/](lib/screen/) or [lib/widgets/](lib/widgets/)**

### Tizen Native Access Pattern
```dart
// In native manager:
final DynamicLibrary _libName = DynamicLibrary.open('libname.so.0');
typedef _NativeFunc = ReturnType Function(ParamTypes);
final _dartFunc = _libName.lookupFunction<_NativeFunc, _DartFunc>('c_func_name');

// Register in locator:
getIt.registerLazySingleton<MyManager>(() => MyManager());

// Use in provider:
final _manager = getIt<MyManager>();
```

### Asset Load Patterns
- JSON configs: `rootBundle.loadString('assets/config.json')`
- Images: declared in pubspec.yaml assets section
- Gauss AI config: loaded from device at `/opt/usr/home/owner/apps_rw/org.tizen.homescreen/data/gauss_config.json`

### Localization (l10n)
- ARB files in [lib/l10n/](lib/l10n/): `app_en.arb`, `app_ko.arb`
- Generated accessor: `AppLocalizations.of(context)?.key`
- Supported: English (en), Korean (ko)
- When adding strings: add to both ARB files, regenerate with `flutter gen-l10n`

## Critical Workflows

### Building & Running
```bash
# Development build for Tizen
flutter pub get
flutter run -d <tizen_device_id>

# Release build
flutter build tpk --release

# Check connected devices
flutter devices
```

### Testing Native Integration
- `content_manager_test.dart` shows FFI testing patterns
- Use `dartpadgen` for testing FFI code
- Tizen devices require proper app manifest permissions in `tizen/tizen-manifest.xml`

### Adding AI Service
- AI services extend `AIService` abstract class: [lib/ai/ai_service.dart](lib/ai/ai_service.dart)
- Implementations: `GaussService` (Samsung), `GeminiService` (Google)
- Register in `setupAdditionalFeatureProvider()` in locator
- Config loaded from gauss_config.json with: `client_key`, `pass_key`, `email`, `endpoint_url`

## Key Dependencies & Constraints

- **go_router**: ⚠️ Version **12.1.3** only (v13.x has PopScope conflicts)
- **Provider**: ^6.1.2 - reactive state management
- **GetIt**: ^8.2.0 - service locator
- **tizen_interop**: Samsung internal package, git dependency
- **tizen_bluetooth**: Local package in [packages/tizen_bluetooth/](packages/tizen_bluetooth/)
- Flutter SDK: ^3.7.2

## Common Pitfalls

1. **Direct native calls**: Always use manager classes, don't call FFI directly
2. **Creating new instances**: Use `getIt<Type>()`, never `Type()`
3. **Navigator conflicts**: Use `RouterService.safePush()` not `Navigator.push()`
4. **Missing provider setup**: Add all new providers to MultiProvider in main.dart
5. **FFI type mismatches**: Match DartType/NativeType signatures exactly (use IntPtr for pointer handles)
6. **Locale parsing**: Tizen uses underscore format (en_US) - split and create Locale correctly

## File Organization

- **lib/ai/**: AI service implementations (Gauss, Gemini)
- **lib/models/**: Data models + ChangeNotifier models (AppDataModel, etc.)
- **lib/native/**: FFI managers wrapping Tizen C libraries
- **lib/providers/**: ChangeNotifier providers for UI reactivity
- **lib/screen/**: Full-screen pages (main, settings, etc.)
- **lib/actions/**: Quick action widgets (WiFi, Bluetooth, volume)
- **lib/media/**: Media browsing (images, videos, music)
- **lib/live/**: Streaming video features
- **lib/l10n/**: Localization files
- **lib/widgets/**: Reusable UI components
- **tizen/**: Tizen manifest, permissions, native resources

When in doubt about architecture, check how `AppDataModel` and `LocaleProvider` are implemented - they exemplify the standard patterns.
