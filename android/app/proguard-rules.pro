# Flutter & Pondy Connect Matrimony Proguard/R8 Configuration

# Flutter Wrapper & Engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep native methods and JNI bindings
-keepclasseswithmembers class * {
    native <methods>;
}

# Flutter embedding v2
-keep class * implements io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback { *; }
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * implements io.flutter.embedding.engine.plugins.activity.ActivityAware { *; }

# Serialization and Data Model preservation
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
    void set*(***);
    *** get*();
}

# Keep attributes for debugging and stack traces
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses,EnclosingMethod

# Suppress warnings on third-party plugin optional dependencies
-dontwarn io.flutter.**
-dontwarn com.google.**
-dontwarn androidx.**
