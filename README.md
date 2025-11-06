# Unifi Task - Flutter Developer Exam

A comprehensive Flutter application demonstrating modern development practices with GoREST API integration and native platform channel implementation.

## Features

### Section 1: Flutter Coding (GoREST API)
- ✅ User management with GoREST API
- ✅ Add new users with validation
- ✅ Paginated user list with infinite scroll
- ✅ Pull-to-refresh functionality
- ✅ Error handling for duplicate emails, invalid tokens, network errors
- ✅ Beautiful Material 3 UI with animations

### Section 2: Native Integration
- ✅ Device storage information (Android & iOS)
  - StatFs API for Android
  - FileManager with URLResourceValues for iOS
- ✅ Camera permission handling (Android & iOS)
  - ActivityCompat for Android
  - AVCaptureDevice for iOS

## Architecture

This project follows **Domain-Driven Design (DDD)** principles with clean architecture:

```
lib/
├── core/
│   ├── constants/       # API and app constants
│   ├── di/             # Dependency injection setup
│   ├── error/          # Error handling (failures & exceptions)
│   ├── network/        # Dio HTTP client with interceptors
│   ├── router/         # Go Router configuration
│   └── theme/          # Material 3 theme configuration
└── features/
    ├── users/
    │   ├── data/       # Models, API service, repository impl
    │   ├── domain/     # Entities, repository interface, use cases
    │   └── presentation/ # Bloc, screens, widgets
    └── device_info/
        ├── data/       # Platform channels, repository impl
        ├── domain/     # Entities, repository interface, use cases
        └── presentation/ # Bloc, screens
```

## Tech Stack

### State Management
- **flutter_bloc** (^8.1.3) - BLoC pattern for state management

### Dependency Injection
- **get_it** (^7.6.4) - Service locator
- **injectable** (^2.3.2) - Code generation for DI

### Navigation
- **go_router** (^13.0.0) - Declarative routing

### Networking
- **dio** (^5.4.0) - HTTP client with interceptors

### Code Generation
- **freezed** (^2.4.6) - Immutable models
- **json_serializable** (^6.7.1) - JSON serialization
- **injectable_generator** (^2.4.1) - DI code generation

### UI
- **flutter_screenutil** (^5.9.0) - Responsive UI
- **pull_to_refresh** (^2.0.0) - Pull to refresh functionality

### Utilities
- **dartz** (^0.10.1) - Functional programming (Either type)
- **equatable** (^2.0.5) - Value equality

## Setup Instructions

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.8.1 or higher)
- Android Studio / Xcode for native development
- An IDE (VS Code or Android Studio)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd unifi_task
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios
   ```

## Code Generation

This project uses code generation for:
- **Freezed**: Immutable models with copyWith, equality, etc.
- **JSON Serializable**: JSON serialization/deserialization
- **Injectable**: Dependency injection registration

### Generate code:
```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generates on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

## API Configuration

The app uses GoREST API with the following configuration:
- **Base URL**: `https://gorest.co.in/public/v2`
- **Bearer Token**: Already configured in `lib/core/constants/api_constants.dart`

## Project Structure Details

### Core Layer
- **Network Client**: Dio with interceptors for logging and error handling
- **Theme**: Material 3 design with custom colors and typography
- **Router**: Go Router with custom page transitions
- **DI**: Injectable annotations for automatic dependency registration

### Features

#### Users Feature
**Domain Layer:**
- `User` entity
- `UserRepository` interface
- `GetUsersUseCase` - Fetch paginated users
- `AddUserUseCase` - Create new user with validation

**Data Layer:**
- `UserModel` - Freezed model with JSON serialization
- `UserApiService` - API calls
- `UserRepositoryImpl` - Repository implementation with error handling

**Presentation Layer:**
- `UserBloc` - State management with events/states
- `UserListScreen` - List with pagination and pull-to-refresh
- `AddUserScreen` - Form with validation
- Custom widgets: UserCard, LoadingShimmer, EmptyState, ErrorWidget

#### Device Info Feature
**Domain Layer:**
- `StorageInfo` entity
- `PermissionStatus` enum
- Use cases for storage and permissions

**Data Layer:**
- Platform channel services (MethodChannel)
- Repository implementations

**Presentation Layer:**
- `DeviceInfoBloc` - State management
- `DeviceInfoScreen` - Display storage and permission status

### Native Implementation

#### Android (MainActivity.kt)
- Method channels for storage and permissions
- StatFs API for storage information
- ActivityCompat for camera permissions
- Permission result handling

#### iOS (AppDelegate.swift)
- Method channels for storage and permissions
- FileManager with URLResourceValues for storage
- AVCaptureDevice for camera permissions
- Async permission request handling

## Key Features Demonstrated

### 1. Dio with Interceptors
- Bearer token authentication
- Request/response logging
- Error handling for various HTTP status codes

### 2. Dependency Injection
- Injectable annotations (@injectable, @lazySingleton)
- @module for third-party dependencies (Dio)
- Automatic registration with build_runner

### 3. Bloc State Management
- Event-driven architecture
- Separate states for different scenarios
- Proper error handling and loading states

### 4. Go Router
- Declarative routing
- Custom page transitions (fade, slide)
- Type-safe navigation

### 5. Clean Architecture
- Separation of concerns (Domain, Data, Presentation)
- Repository pattern
- Use case pattern for business logic
- Dependency inversion

### 6. Error Handling
- Network errors (timeout, no connection)
- API errors (400, 401, 404, 422)
- Platform channel errors
- User-friendly error messages

### 7. Pagination
- Infinite scroll with automatic loading
- Page tracking
- Pull-to-refresh to reset

### 8. Native Integration
- MethodChannel for bi-directional communication
- Platform-specific implementations
- Proper error handling across platforms

## Testing the App

### User Management
1. App launches with user list
2. Pull down to refresh
3. Scroll to bottom to load more users
4. Tap "Add User" FAB
5. Fill in user details (test validation)
6. Submit to create user
7. Try adding duplicate email to test error handling

### Device Info
1. Tap info icon in user list
2. View storage information with visual progress
3. Tap "Request Permission" for camera
4. Grant/deny permission to test different states

## Build for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Design Decisions

1. **DDD Architecture**: Clear separation between domain, data, and presentation layers
2. **Injectable**: Cleaner dependency injection with annotations vs manual registration
3. **Freezed**: Immutable models with built-in equality and copyWith
4. **Dartz Either**: Functional error handling instead of try-catch
5. **Bloc**: Predictable state management with clear event/state separation
6. **Go Router**: Declarative routing with better web support
7. **ScreenUtil**: Responsive UI that adapts to different screen sizes

## Performance Optimizations

- Lazy loading with pagination
- ListView.builder for efficient list rendering
- Const constructors where possible
- Proper disposal of controllers and blocs
- Debouncing for scroll events

## Accessibility

- Semantic labels for screen readers
- Proper contrast ratios
- Touch targets sized appropriately
- Error messages are clear and helpful

## Known Limitations

1. No offline support (future enhancement)
2. No unit tests included (as per requirements)
3. Limited error recovery options

## Future Enhancements

- [ ] Unit and widget tests
- [ ] Offline caching with local database
- [ ] User search functionality
- [ ] User detail screen
- [ ] Edit/delete user functionality
- [ ] Dark theme toggle
- [ ] Localization support

## Author

Mustafa Hasria

## License

This project is for evaluation purposes as part of the Unifi Solution Flutter Developer Exam.
