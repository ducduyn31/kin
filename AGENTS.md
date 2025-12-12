# Kin - Technical Guide

This document provides technical context for AI agents and developers working on the Kin codebase.

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** Riverpod
- **Architecture:** Feature-First (layers inside features)
- **Design:** Material 3
- **Backend:** [TBD]

## Architecture Overview

Kin uses a **feature-first** project structure based on [Code with Andrea's Flutter Project Structure](https://codewithandrea.com/articles/flutter-project-structure/). Features are organized by functional requirements, not by UI screens.

### Core Principles

1. **Features represent functionality** - A feature is a functional requirement that helps the user complete a task (e.g., authentication, messaging, contacts), not individual screens
2. **Layers inside features** - Each feature contains its own presentation, application, domain, and data layers
3. **Minimal shared code** - Only truly reusable code goes in top-level folders; keep these lean
4. **Domain-driven boundaries** - Start from domain models to establish clear component boundaries

### Project Structure

```text
lib/
├── main.dart                           # App entry point
├── src/
│   ├── features/                       # Feature modules
│   │   ├── feature_name/
│   │   │   ├── presentation/           # UI widgets, screens, controllers
│   │   │   ├── application/            # Services, providers, business logic
│   │   │   ├── domain/                 # Models, entities, business rules
│   │   │   └── data/                   # Repositories, data sources, DTOs
│   │   │
│   │   ├── conversations/              # Chat list feature
│   │   ├── chat/                       # Individual chat feature
│   │   ├── contacts/                   # Contacts/friends feature
│   │   ├── profile/                    # User profile feature
│   │   ├── availability/               # Availability status feature [TBD]
│   │   └── calling/                    # Voice/video calling feature [TBD]
│   │
│   ├── common_widgets/                 # Shared UI components
│   ├── constants/                      # App-wide constants, theme
│   ├── routing/                        # Navigation/routing
│   ├── localization/                   # i18n (when needed)
│   ├── utils/                          # Utility functions
│   └── exceptions/                     # Custom exceptions
```

### Feature Layers

Each feature folder should contain these layers as needed:

| Layer | Purpose | Contents |
|-------|---------|----------|
| **presentation/** | UI and state | Screens, widgets, controllers |
| **application/** | Business logic | Services, providers, use cases |
| **domain/** | Core models | Entities, value objects, business rules |
| **data/** | Data access | Repositories, data sources, DTOs |

### Adding a New Feature

1. Create a directory under `lib/src/features/`
2. Add layer subdirectories as needed (presentation, application, domain, data)
3. Start with domain models to define the feature's data
4. Build out from domain → application → presentation
5. Add routes in `lib/src/routing/app_router.dart`

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
- Use Riverpod for state management (NotifierProvider pattern)
- Use Material 3 theming (`useMaterial3: true`)
- Follow Dart/Flutter naming conventions
- Keep features small and focused on a single functional area
- Mirror `lib/src/` structure in `test/` folder

## Development Notes

This project uses [Taskfile](https://taskfile.dev/) for all development commands. **Always use `task` commands instead of running `flutter` or `dart` commands directly.**

### Setup

```bash
task setup         # Install dependencies and create .env.local
```

### Running the App

```bash
task run           # Run app with local environment (handles env + code generation)
```

### Essential Commands

```bash
task generate      # Generate l10n and build_runner code (REQUIRED after changing .arb files or models)
task analyze       # Run Dart analyzer
task test          # Run tests
task format        # Format Dart code
task format:check  # Check formatting without modifying
task clean         # Clean build artifacts
```

### Build Commands

```bash
# Staging
task build:apk:staging   # Build APK for staging
task build:ios:staging   # Build iOS for staging

# Production
task build:apk:prod      # Build APK for production
task build:appbundle:prod # Build App Bundle for Play Store
task build:ios:prod      # Build iOS for production
```

### Why Taskfile?

- Ensures consistent environment setup (copies correct .env file)
- Runs code generation automatically before builds
- Validates prerequisites before running commands
- Single source of truth for all development workflows
