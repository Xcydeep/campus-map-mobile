# Solution Rapide - Erreurs ImageReader_JNI

## 🚨 Problème

Vous voyez des centaines d'erreurs `ImageReader_JNI` et la carte ne s'affiche pas.

## ✅ Solution Immédiate : Utiliser FlutterMap temporairement

Pendant que vous corrigez votre clé API Google Maps, vous pouvez temporairement utiliser FlutterMap (OpenStreetMap) qui fonctionne sans clé API.

### Étape 1 : Réactiver FlutterMap

Dans le fichier `lib/features/map/presentation/screens/map_screen.dart`, ligne 86-89 :

**Remplacez :**
```dart
// Carte principale - Google Maps
const GoogleMapWidget(),
// Ancienne carte OpenStreetMap (désactivée)
// const MapWidget(),
```

**Par :**
```dart
// Carte principale - FlutterMap (OpenStreetMap) - TEMPORAIRE
const MapWidget(),
// Google Maps (désactivé temporairement - problème de clé API)
// const GoogleMapWidget(),
```

### Étape 2 : Réactiver l'import

Dans le même fichier, ligne 6-7 :

**Remplacez :**
```dart
// import '../widgets/map_widget.dart'; // FlutterMap (OpenStreetMap) - désactivé
import '../widgets/google_map_widget.dart'; // Google Maps - activé
```

**Par :**
```dart
import '../widgets/map_widget.dart'; // FlutterMap (OpenStreetMap) - activé temporairement
// import '../widgets/google_map_widget.dart'; // Google Maps - désactivé temporairement
```

### Étape 3 : Décommenter le code FlutterMap

Dans le fichier `lib/features/map/presentation/widgets/map_widget.dart`, supprimez les `/*` et `*/` qui entourent tout le code (lignes 1-180 environ).

### Étape 4 : Relancer l'application

```bash
flutter clean
flutter pub get
flutter run
```

## 🔧 Corriger la clé API Google Maps

Une fois que FlutterMap fonctionne, corrigez votre clé API :

1. Allez sur : https://console.cloud.google.com/apis/credentials?project=campusmap-un-ngaoundere
2. Créez ou copiez une **vraie clé API** (qui commence par `AIzaSy...`)
3. Remplacez `6a35104d-1dee-5cfc-867d-b937567a3c74` dans :
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/AppDelegate.swift`
   - `ios/Runner/Info.plist`
4. Activez les APIs "Maps SDK for Android" et "Maps SDK for iOS"
5. Vérifiez que la facturation est activée
6. Revenez à `GoogleMapWidget()` dans `map_screen.dart`

## 📝 Note

FlutterMap (OpenStreetMap) est **gratuit** et fonctionne sans clé API, mais :
- Moins de détails que Google Maps
- Pas de navigation intégrée
- Dépend d'Internet pour charger les tuiles

Google Maps offre :
- Meilleure qualité d'image
- Navigation intégrée
- Plus de fonctionnalités
- Mais nécessite une clé API valide et facturation

