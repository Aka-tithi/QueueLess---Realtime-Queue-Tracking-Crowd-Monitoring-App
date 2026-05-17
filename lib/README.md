# QueueLess - Flutter Mobile App UI

A modern and professional Flutter UI for a real-time queue tracking mobile application.

## 📱 Project Structure

```
lib/
├── main.dart                 # Application entry point
├── theme/
│   └── app_theme.dart       # Centralized theme configuration
└── screens/
    ├── splash_screen.dart   # Splash screen with gradient and animation
    ├── login_screen.dart    # Login screen with form validation
    └── registration_screen.dart  # Registration screen with form validation
```

## 🎨 Design System

### Color Palette
- **Primary**: #1E3A8A (Deep Blue)
- **Secondary**: #3B82F6 (Sky Blue)
- **Accent**: #14B8A6 (Teal)
- **Background**: #F9FAFB (Light Gray)
- **Surface**: #FFFFFF (White)
- **Text Primary**: #111827 (Dark Gray)
- **Text Secondary**: #6B7280 (Medium Gray)
- **Error**: #EF4444 (Red)

### Typography
- **Font Family**: Poppins (with fallback to system sans-serif)
- **Heading Sizes**: 48px, 24px, 20px, 18px
- **Body Sizes**: 16px, 14px
- **Font Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)

### Spacing & Sizing
- **Small**: 8px
- **Medium**: 16px
- **Large**: 20px
- **Extra Large**: 24px
- **Border Radius**: 8px (small), 12px (medium), 16px (large)

## 🎯 Screens Overview

### 1. Splash Screen (`splash_screen.dart`)
- **Duration**: 3 seconds before navigation
- **Features**:
  - Gradient background (Deep Blue → Sky Blue)
  - Centered app icon with semi-transparent background
  - App name with tagline
  - Smooth fade-in animation (1.5s duration)
  - Auto-navigation to Login screen

**Key Components**:
- `AnimationController` for fade-in effect
- `LinearGradient` for background
- Delayed navigation using `Future.delayed()`

### 2. Login Screen (`login_screen.dart`)
- **Features**:
  - Email input field with validation
  - Password input field with visibility toggle
  - "Forgot Password?" link
  - Login button with loading state
  - Navigation link to Registration screen
  - Form validation with custom error messages

**Validation Rules**:
- Email: Required, valid email format
- Password: Required, minimum 6 characters
- Shows error messages below invalid fields

**Interactions**:
- Password visibility toggle
- Loading indicator during login
- Success/error notifications via SnackBar
- Navigation to Registration screen

### 3. Registration Screen (`registration_screen.dart`)
- **Features**:
  - Full Name input field
  - Email input field with validation
  - Password input field with visibility toggle
  - Confirm Password field with match validation
  - Terms & Conditions checkbox
  - Register button with loading state
  - Navigation link to Login screen
  - Back button to return to Login

**Validation Rules**:
- Name: Required, minimum 2 characters
- Email: Required, valid email format
- Password: Required, minimum 6 characters
- Confirm Password: Must match password field
- Terms: Must be agreed to

**Interactions**:
- Dual password visibility toggles
- Loading indicator during registration
- Success/error notifications
- Checkbox for terms acceptance

## 🔐 Form Features

### Input Fields
- **Styling**: Rounded borders (12px radius), subtle shadows
- **Focus State**: Primary color border (2px width)
- **Error State**: Red border with error message below
- **Content Padding**: 16px horizontal, 12px vertical
- **Icon Support**: Prefix and suffix icons with secondary color

### Validation
- Real-time validation trigger on form submission
- Clear error messages for user guidance
- Custom validators for each field type
- Password matching validation for registration

## 🎬 Animations & Transitions

### Splash Screen
- Fade-in animation (Curves.easeIn)
- Duration: 1.5 seconds
- Linear gradient background

### Screen Navigation
- Material page route transitions
- Route replacement to prevent back navigation
- Smooth transitions between screens

## 🔄 Navigation Flow

```
Splash Screen (3s delay)
        ↓
    Login Screen
    /          \
  ↙            ↘
Forgot        Register
Password      (Registration Screen)
              \         /
               Login   ↙
```

## 💾 State Management

Each screen uses `StatefulWidget` with `setState()` for:
- Form field management
- Password visibility toggling
- Loading state during form submission
- Error message display

**Future Enhancement**: Consider using Provider or Riverpod for complex state management.

## 🛠️ Theme Configuration (`app_theme.dart`)

### ThemeData Setup
- Material Design 3 enabled (`useMaterial3: true`)
- Custom ColorScheme with all required colors
- InputDecorationTheme for consistent text fields
- ElevatedButtonTheme for button styling
- TextTheme with proper hierarchy

### Shadow Definition
- `softShadow`: Used for subtle depth (4px offset, 12px blur, 8% black opacity)
- Applied to cards and elevated elements

## 🚀 Getting Started

### Prerequisites
- Flutter 3.11.0 or higher
- Dart SDK 3.11.0 or higher

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to launch the app

### Running the App
```bash
# Development mode
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device_id>
```

## 📝 Code Quality

### Best Practices Implemented
- Constant definitions for reusable values
- Separate widget files for each screen
- Centralized theme management
- Form validation with meaningful error messages
- Loading states for async operations
- Proper disposal of controllers
- Comments and documentation

### Linting
- Uses `flutter_lints` for code analysis
- Follows Dart style guide conventions
- No warnings or errors in analysis

## 🔄 Future Enhancements

1. **API Integration**
   - Connect login/registration to backend
   - Implement proper authentication

2. **Enhanced Animations**
   - Page transition animations
   - Button press feedback animations
   - Loading animation improvements

3. **State Management**
   - Migrate to Provider or Riverpod
   - Implement proper app state handling

4. **Features**
   - Password strength indicator
   - Social login options
   - Terms & Conditions modal
   - Biometric authentication

5. **Accessibility**
   - Semantic labels
   - Screen reader support
   - High contrast mode support

## 📄 License

This project is provided as-is for educational and development purposes.

## 👨‍💻 Code Style

- **Null Safety**: Full null safety implementation
- **const**: Used throughout for immutable objects
- **Documentation**: Comprehensive code comments
- **Naming**: Clear, descriptive naming conventions
- **Formatting**: Consistent with Dart conventions

---

**Created**: April 2026
**Version**: 1.0.0
