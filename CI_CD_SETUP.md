# GitLab CI/CD Setup for Smart Locket Flutter

## Overview
This project includes a complete GitLab CI/CD pipeline with:
- Unit and widget tests
- Integration tests
- Code analysis
- Multi-platform builds (Android, iOS, Web)
- Automated deployment

## Pipeline Stages

### 1. Test Stage
- **Unit Tests**: `flutter test --coverage`
- **Code Analysis**: `flutter analyze --fatal-infos`
- **Integration Tests**: End-to-end testing with `integration_test`

### 2. Build Stage
- **Android APK**: Release build for Android
- **iOS Build**: Release build (requires macOS runner)
- **Web Build**: Progressive web app build

### 3. Deploy Stage
- **Staging**: Manual deployment to staging environment
- **Production**: Manual deployment to production

## Local Testing
Run all tests locally:
```bash
scripts\run_tests.bat
```

## GitLab Runner Requirements
- Docker executor for most jobs
- macOS runner for iOS builds (optional)
- Sufficient storage for Flutter SDK and dependencies

## Environment Variables
Configure in GitLab CI/CD settings:
- `FLUTTER_VERSION`: Flutter SDK version
- `ANDROID_COMPILE_SDK`: Android compile SDK version
- Deployment credentials (as needed)

## Coverage Reports
Test coverage is automatically generated and displayed in merge requests.

## Artifacts
- APK files (7 days retention)
- Test reports and coverage
- Build artifacts for deployment