@echo off
echo Building APK...
flutter build apk --release
if not exist releases mkdir releases
copy build\app\outputs\flutter-apk\app-release.apk releases\app-release.apk

echo Building AAB...
flutter build appbundle --release
copy build\app\outputs\bundle\release\app-release.aab releases\app-release.aab

echo Done! Both files saved to releases folder:
dir releases\app-release.* 