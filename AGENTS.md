# Kin - Technical Guide

This document provides technical context for AI agents and developers working on the Kin codebase.

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** Riverpod
- **Architecture:** Dart Board (feature-based)
- **Backend:** [TBD]

## Architecture Overview

Kin uses [Dart Board](https://github.com/ahammer/dart_board), a feature-based architecture framework for Flutter. This enables modular, self-contained features that integrate through configuration.

### Core Concepts

**Features** are standalone modules that encapsulate functionality. Each feature can expose:
- **Routes** - Named paths and screens
- **Decorations** - UI/non-UI widgets injected at app or page level
- **Method Calls** - Decoupled inter-feature communication

### Project Structure

```
lib/
├── main.dart                    # App entry point with DartBoard initialization
├── features/                    # Feature modules
│   ├── home/                    # Home feature
│   │   ├── home_feature.dart    # Feature definition (routes, decorations)
│   │   └── home_screen.dart     # UI screen
│   ├── availability/            # Availability status feature [TBD]
│   └── calling/                 # Voice/video calling feature [TBD]
```

### Adding a New Feature

1. Create a directory under `lib/features/`
2. Create a feature class extending `IFeature`
3. Define routes, decorations, and dependencies
4. Register the feature in `main.dart`

## Key Concepts

### Availability Status

The core feature of Kin is the availability system that lets users signal when they're free to talk. This should be:
- Simple to toggle on/off
- Visible to contacts in real-time
- Respect user privacy preferences

### Calling

Voice and video calling functionality for connecting with friends and family.

## Code Conventions

- Features should be self-contained and loosely coupled
- Use Riverpod for state management within features
- Follow Dart/Flutter naming conventions
- Keep features small and focused

## Development Notes

### Running the App

```bash
flutter pub get
flutter run
```

### Useful Commands

```bash
flutter analyze    # Check for issues
flutter test       # Run tests
flutter build      # Build release
```
