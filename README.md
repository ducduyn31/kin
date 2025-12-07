# Kin

A Flutter mobile app for staying connected with your friends and family through voice and video calls.

## About

Kin makes it easy to keep in touch with the people who matter most.

Ever wanted to call someone but weren't sure if it was a good time? Kin solves this by letting you share your availability with friends and family. When you're free to talk, your loved ones will know - no more missed calls or awkward interruptions. Just real conversations when the timing is right.

## Features

- **Availability Status** - Let friends and family know when you're free to talk
- **Voice Calls** - Crystal-clear audio calls with your contacts
- **Video Calls** - Face-to-face conversations with friends and family
- **Contact Management** - Easily manage your circle of loved ones
- **Call History** - Keep track of your recent conversations
- **Cross-Platform** - Available on both iOS and Android

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- [Task](https://taskfile.dev/) - Task runner
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/kin.git
   cd kin
   ```

2. Set up the project:
   ```bash
   task setup
   ```
   This installs dependencies and creates `.env.local` from the example template.

3. Configure your environment:

   Edit `.env.local` with your Auth0 credentials (see `.env.example` for details).

4. Run the app:
   ```bash
   task run
   ```

### Available Tasks

Run `task --list` to see all available tasks. Common ones:

| Task | Description |
|------|-------------|
| `task setup` | Install dependencies and create local env file |
| `task run` | Run app with local environment |
| `task generate` | Run build_runner to generate code |
| `task test` | Run tests |
| `task analyze` | Run Dart analyzer |
| `task format` | Format Dart code |
| `task clean` | Clean build artifacts |

### Building for Production

**Android APK:**
```bash
task build:apk:prod
```

**Android App Bundle (Play Store):**
```bash
task build:appbundle:prod
```

**iOS:**
```bash
task build:ios:prod
```

For staging builds, use `task build:apk:staging` or `task build:ios:staging`.

Note: Production builds require `.env.production` and staging builds require `.env.staging`. Copy from `.env.example` and configure accordingly.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is unlicensed.
