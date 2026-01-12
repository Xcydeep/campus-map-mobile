# Configuration Google Maps

Ce guide vous explique comment configurer Google Maps dans votre application Flutter.

## 📋 Prérequis

1. Avoir une clé API Google Maps depuis [Google Cloud Console](https://console.cloud.google.com/apis/credentials?project=campusmap-un-ngaoundere)
2. Avoir activé les APIs suivantes dans Google Cloud Console :
   - Maps SDK for Android
   - Maps SDK for iOS

## 🔑 Configuration de la Clé API

### Étape 1 : Obtenir votre clé API

1. Allez sur [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials?project=campusmap-un-ngaoundere)
2. Créez une nouvelle clé API ou utilisez une existante
3. Copiez la clé API (elle ressemble à : `AIzaSy...`)

### Étape 2 : Configurer pour Android

**Fichier : `android/app/src/main/AndroidManifest.xml`**

Remplacez `VOTRE_CLE_API_GOOGLE_MAPS_ICI` par votre clé API :

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="VOTRE_CLE_API_GOOGLE_MAPS_ICI" />
```

### Étape 3 : Configurer pour iOS

**Fichier : `ios/Runner/AppDelegate.swift`**

Remplacez `VOTRE_CLE_API_GOOGLE_MAPS_ICI` par votre clé API :

```swift
GMSServices.provideAPIKey("VOTRE_CLE_API_GOOGLE_MAPS_ICI")
```

**Fichier : `ios/Runner/Info.plist`**

Remplacez `VOTRE_CLE_API_GOOGLE_MAPS_ICI` par votre clé API :

```xml
<key>GMSApiKey</key>
<string>VOTRE_CLE_API_GOOGLE_MAPS_ICI</string>
```

### Étape 4 : Configuration centralisée (Optionnel)

**Fichier : `lib/core/config/map_config.dart`**

Vous pouvez aussi centraliser votre clé ici pour référence :

```dart
static const String googleMapsApiKey = 'VOTRE_CLE_API_GOOGLE_MAPS_ICI';
```

## 🗺️ Utilisation de Google Maps

### Option 1 : Utiliser le widget Google Maps existant

Le fichier `lib/features/map/presentation/widgets/google_map_widget.dart` contient un widget Google Maps prêt à l'emploi.

Pour l'utiliser, remplacez dans `lib/features/map/presentation/screens/map_screen.dart` :

```dart
// Avant
const MapWidget(),

// Après
const GoogleMapWidget(),
```

### Option 2 : Continuer avec FlutterMap (OpenStreetMap)

Si vous préférez continuer avec OpenStreetMap (gratuit), vous n'avez pas besoin de configurer Google Maps.

## ✅ Vérification

1. Assurez-vous que votre clé API est correctement configurée dans les 3 fichiers
2. Exécutez :
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. Si vous voyez une carte Google Maps, la configuration est réussie !

## 🔒 Sécurité

⚠️ **Important** : Ne commitez jamais votre clé API dans Git si elle n'est pas restreinte.

Pour plus de sécurité :
- Utilisez des restrictions de clé API dans Google Cloud Console
- Limitez la clé à votre package Android/iOS
- Utilisez des variables d'environnement pour la production

## 🐛 Dépannage

### Erreur : "API key not valid"
- Vérifiez que la clé est correctement copiée (sans espaces)
- Vérifiez que les APIs Maps SDK sont activées dans Google Cloud Console
- Vérifiez que la facturation est activée sur votre projet Google Cloud

### La carte ne s'affiche pas
- Vérifiez les permissions Internet dans AndroidManifest.xml
- Vérifiez que vous testez sur un appareil réel ou un émulateur avec Google Play Services

## 📚 Ressources

- [Documentation Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Guide de configuration Google Maps](https://developers.google.com/maps/documentation/android-sdk/get-api-key)

