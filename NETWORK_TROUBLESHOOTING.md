# Guide de Résolution - Erreur de Connexion Réseau

## Erreur : "Connection failed... Network is unreachable"

Cette erreur signifie que l'application ne peut pas accéder à Internet pour charger les tuiles de la carte OpenStreetMap.

## Causes Possibles

1. **Pas de connexion Internet** sur l'appareil
2. **Émulateur Android** sans accès réseau configuré
3. **Firewall/Proxy** bloquant les connexions externes
4. **DNS** non configuré correctement

## Solutions

### ✅ Solution 1 : Activer Internet dans l'Émulateur Android

**Si vous utilisez l'Émulateur Android Studio :**

1. Ouvrez **Android Virtual Device (AVD) Manager**
2. Sélectionnez votre émulateur
3. Cliquez sur le bouton **...** (options avancées)
4. Vérifiez que **Network** est configuré sur :
   - **NAT** (recommandé) - pour l'accès Internet automatique
   - Ou **Bridge** - pour une connexion directe
5. Cliquez sur **Finish** et redémarrez l'émulateur

**Test :** Ouvrez Chrome dans l'émulateur et naviguez vers un site (ex: google.com)

### ✅ Solution 2 : Vérifier les Permissions Android

Les permissions suivantes sont requises dans `AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

✅ **Déjà configuré dans ce projet**

### ✅ Solution 3 : Forcer le Rechargement

Exécutez cette commande pour forcer le rechargement de l'app :

```bash
flutter clean
flutter pub get
flutter run
```

### ✅ Solution 4 : Test de Connectivité

Créez un test rapide pour diagnostiquer le problème :

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  final connectivity = Connectivity();
  final result = await connectivity.checkConnectivity();
  print('Connectivity: $result');
}
```

### ✅ Solution 5 : Utiliser un Appareil Physique

Si l'émulateur ne fonctionne pas :

1. Connectez un téléphone physique via USB
2. Activez le mode développeur et le débogage USB
3. Exécutez : `flutter run`

**L'appareil doit avoir une connexion WiFi ou 4G/5G active**

### ✅ Solution 6 : Vérifier le Serveur OpenStreetMap

Testez si OSM est accessible :

```bash
# Depuis votre ordinateur
curl -v https://tile.openstreetmap.org/16/35239/31599.png
```

Si la requête échoue, OSM peut être temporairement indisponible.

## Mode Hors-ligne Implémenté

L'application affiche maintenant un message si elle détecte qu'il n'y a pas de connexion :

```
⚠️ Mode hors ligne - Données en cache
```

## Dépannage Avancé

### Vérifier le DNS

```bash
adb shell getprop net.dns1
adb shell getprop net.dns2
```

### Réinitialiser la Connexion Réseau

```bash
adb shell cmd connectivity airplane-mode off
adb shell settings put global airplane_mode_on 0
adb reboot
```

### Logs Détaillés

Exécutez pour voir les logs réseau :

```bash
flutter run -v
```

## Contacts de Support

- **OpenStreetMap Status** : https://tile.openstreetmap.org/
- **Flutter Docs** : https://flutter.dev/docs
- **Android Emulator Network** : https://developer.android.com/studio/run/emulator-networking

---

**Après avoir appliqué une solution, redémarrez l'app avec `flutter run`**
