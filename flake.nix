{
  description = "Kin - Flutter app for staying connected with friends and family";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        # Android SDK configuration
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = ["34.0.0" "33.0.1"];
          platformVersions = ["34" "33"];
          abiVersions = ["arm64-v8a" "x86_64"];
          includeEmulator = true;
          emulatorVersion = "34.1.9";
          includeSystemImages = true;
          systemImageTypes = ["google_apis_playstore"];
          includeSources = false;
          includeNDK = true;
          ndkVersions = ["25.1.8937393"];
          cmakeVersions = ["3.22.1"];
          useGoogleAPIs = true;
          extraLicenses = [
            "android-googletv-license"
            "android-sdk-arm-dbt-license"
            "android-sdk-preview-license"
            "google-gdk-license"
            "intel-android-extra-license"
            "intel-android-sysimage-license"
            "mips-android-sysimage-license"
          ];
        };

        androidSdk = androidComposition.androidsdk;
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs;
            [
              # Flutter SDK
              flutter

              # Development tools
              go-task # Taskfile runner

              # Code generation (protobuf for connectrpc)
              protobuf
              buf
            ]
            ++ [
              # Git
              git

              # For iOS development (macOS only)
            ]
            ++ lib.optionals stdenv.isDarwin [
              cocoapods
              xcodes
            ]
            ++ lib.optionals stdenv.isLinux [
              # Android SDK for Linux
              androidSdk
              jdk17
            ];

          shellHook = ''
            echo "Kin Flutter Development Environment"
            echo "===================================="
            echo ""
            echo "Flutter version: $(flutter --version | head -1)"
            echo "Dart version: $(dart --version 2>&1)"
            echo ""
            echo "Available commands:"
            echo "  task --list    # Show all available tasks"
            echo "  task setup     # Initial project setup"
            echo "  task run       # Run the app"
            echo ""

            # Set up Flutter
            export PUB_CACHE="$HOME/.pub-cache"

            ${
              if pkgs.stdenv.isLinux
              then ''
                # Android SDK setup for Linux
                export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
                export ANDROID_SDK_ROOT="$ANDROID_HOME"
                export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$PATH"
              ''
              else ""
            }

            ${
              if pkgs.stdenv.isDarwin
              then ''
                # macOS-specific setup
                # CocoaPods and Xcode should be available in PATH
              ''
              else ""
            }
          '';

          # Environment variables
          FLUTTER_ROOT = "${pkgs.flutter}";
        };

        # Formatter for nix files
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
