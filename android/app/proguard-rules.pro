# ============================================================
# ProGuard / R8 Rules — Bitacora Stepway Fleet Manager
# ============================================================

# Flutter: conservar clases del engine y el entrypoint
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# sqflite: el plugin usa reflection para cargar el driver SQLite
-keep class com.tekartik.sqflite.** { *; }

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# google_sign_in
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.android.gms.**

# share_plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Conservar anotaciones de Kotlin (reflection)
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Evitar advertencias por clases de plataforma no incluidas
-dontwarn javax.annotation.**
-dontwarn org.checkerframework.**
