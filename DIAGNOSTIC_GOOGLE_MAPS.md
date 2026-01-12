# Diagnostic - Carte Google Maps ne s'affiche pas

## 🔍 Problème identifié

La carte Google Maps ne s'affiche pas et vous voyez des erreurs `ImageReader_JNI` dans les logs.

## ⚠️ Problème probable : Clé API invalide

La clé API que vous utilisez (`6a35104d-1dee-5cfc-867d-b937567a3c74`) ressemble à un **UUID**, pas à une clé API Google Maps typique.

**Les clés API Google Maps commencent généralement par : `AIzaSy...`**

## ✅ Solutions à vérifier

### 1. Vérifier la clé API dans Google Cloud Console

1. Allez sur : https://console.cloud.google.com/apis/credentials?project=campusmap-un-ngaoundere
2. Vérifiez que vous avez bien une **clé API** (pas un UUID)
3. La clé doit ressembler à : `AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567`

### 2. Activer les APIs nécessaires

Dans Google Cloud Console, assurez-vous que ces APIs sont **ACTIVÉES** :
- ✅ **Maps SDK for Android**
- ✅ **Maps SDK for iOS**

Pour activer :
1. Allez dans "APIs & Services" > "Library"
2. Recherchez "Maps SDK for Android" et activez-le
3. Recherchez "Maps SDK for iOS" et activez-le

### 3. Vérifier la facturation

Google Maps nécessite une **facturation activée** (même avec le crédit gratuit de $200/mois).

1. Allez dans "Billing" dans Google Cloud Console
2. Vérifiez qu'un compte de facturation est lié à votre projet

### 4. Vérifier les restrictions de la clé API

Si votre clé API a des restrictions :
- Vérifiez que votre package Android (`campus_map_mobile`) est autorisé
- Vérifiez que votre bundle ID iOS est autorisé

### 5. Vérifier les logs

Exécutez l'application et regardez les logs pour voir :
- `✅ Google Maps créé avec succès` = La carte s'est initialisée
- `❌ Erreur lors de la création de la carte` = Problème de clé API ou de configuration

## 🔧 Test rapide

Pour tester si c'est un problème de clé API, essayez temporairement avec une clé de test :

1. Créez une nouvelle clé API dans Google Cloud Console
2. Remplacez la clé dans les 3 fichiers :
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/AppDelegate.swift`
   - `ios/Runner/Info.plist`
3. Relancez l'application

## 📝 Format correct d'une clé API Google Maps

Une clé API Google Maps valide :
- Commence par `AIzaSy`
- Fait environ 39 caractères
- Exemple : `AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567`

Votre clé actuelle (`6a35104d-1dee-5cfc-867d-b937567a3c74`) :
- ❌ Ne commence pas par `AIzaSy`
- ❌ Ressemble à un UUID
- ❌ Probablement pas une clé API Google Maps

## 🚀 Prochaines étapes

1. **Vérifiez dans Google Cloud Console** que vous avez bien copié la **clé API** (pas un ID de projet ou autre)
2. **Activez les APIs** Maps SDK for Android et iOS
3. **Vérifiez la facturation**
4. **Relancez l'application** avec `flutter clean && flutter run`

## 💡 Alternative temporaire

Si vous voulez tester l'application pendant que vous corrigez la clé API, vous pouvez temporairement réactiver FlutterMap (OpenStreetMap) :

Dans `lib/features/map/presentation/screens/map_screen.dart`, remplacez :
```dart
const GoogleMapWidget(),
```
par :
```dart
// const GoogleMapWidget(),
const MapWidget(), // FlutterMap (OpenStreetMap) - temporaire
```

Et décommentez l'import dans `map_widget.dart`.

