# Flutter-specific rules.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.**  { *; }

# Rules for Stripe SDK
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Rules for react-native-stripe, which is a dependency of flutter_stripe
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# Rules for Google Play Core library
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Firebase rules to prevent crashes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep Firebase Auth and Firestore
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.firestore.** { *; }

# SharedPreferences and SQLite
-keep class android.content.SharedPreferences** { *; }
-keep class androidx.sqlite.** { *; }

# Prevent obfuscation of model classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# Prevent crashes from missing classes
-dontwarn okio.**
-dontwarn javax.annotation.** 