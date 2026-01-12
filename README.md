# campus_map_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Google Maps (setup rapide)

Pour utiliser `google_maps_flutter` dans cette app:

- Ajoute la clé API Google Maps (activer Maps SDK for Android/iOS dans Google Cloud, configurer facturation).
- Android: dans `android/app/src/main/AndroidManifest.xml` ajoute dans `<application>`:
	`<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY"/>`
- iOS: fournis la clé via `AppDelegate` (ex: `GMSServices.provideAPIKey("YOUR_API_KEY")`) ou configure dans `Info.plist`.
- N'oublie pas d'ajouter les permissions de localisation (`ACCESS_FINE_LOCATION`, etc.) et de tester sur vrai appareil.

Après cela, lance `flutter pub get` pour récupérer la dépendance ajoutée.
