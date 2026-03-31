@echo off
echo Running Flutter tests locally...

echo.
echo === Running unit tests ===
flutter test --coverage

echo.
echo === Running widget tests ===
flutter test test/widget_test.dart

echo.
echo === Running integration tests ===
flutter test integration_test/

echo.
echo === Running code analysis ===
flutter analyze

echo.
echo All tests completed!