import 'package:flutter_riverpod/legacy.dart';

// Provider pour les paramètres (extrait de l'écran)
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  void toggleDarkMapTheme(bool value) {
    state = state.copyWith(darkMapTheme: value);
  }

  void toggleMapRotation(bool value) {
    state = state.copyWith(mapRotationEnabled: value);
  }

  void toggle3DBuildings(bool value) {
    state = state.copyWith(show3DBuildings: value);
  }

  void toggleVoiceGuidance(bool value) {
    state = state.copyWith(voiceGuidanceEnabled: value);
  }

  void toggleAutoSync(bool value) {
    state = state.copyWith(autoSyncEnabled: value);
  }

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  void toggleCourseReminders(bool value) {
    state = state.copyWith(courseRemindersEnabled: value);
  }

  void setTransportMode(String mode) {
    state = state.copyWith(defaultTransportMode: mode);
  }

  void downloadOfflineData() {
    // TODO: Implémenter le téléchargement
  }

  void deleteOfflineData() {
    state = state.copyWith(offlineDataSize: 0);
  }
}

class SettingsState {
  final bool darkMapTheme;
  final bool mapRotationEnabled;
  final bool show3DBuildings;
  final String defaultTransportMode;
  final bool voiceGuidanceEnabled;
  final bool autoSyncEnabled;
  final int offlineDataSize;
  final bool notificationsEnabled;
  final bool courseRemindersEnabled;

  SettingsState({
    this.darkMapTheme = false,
    this.mapRotationEnabled = true,
    this.show3DBuildings = true,
    this.defaultTransportMode = 'walking',
    this.voiceGuidanceEnabled = false,
    this.autoSyncEnabled = true,
    this.offlineDataSize = 0,
    this.notificationsEnabled = true,
    this.courseRemindersEnabled = true,
  });

  SettingsState copyWith({
    bool? darkMapTheme,
    bool? mapRotationEnabled,
    bool? show3DBuildings,
    String? defaultTransportMode,
    bool? voiceGuidanceEnabled,
    bool? autoSyncEnabled,
    int? offlineDataSize,
    bool? notificationsEnabled,
    bool? courseRemindersEnabled,
  }) {
    return SettingsState(
      darkMapTheme: darkMapTheme ?? this.darkMapTheme,
      mapRotationEnabled: mapRotationEnabled ?? this.mapRotationEnabled,
      show3DBuildings: show3DBuildings ?? this.show3DBuildings,
      defaultTransportMode: defaultTransportMode ?? this.defaultTransportMode,
      voiceGuidanceEnabled: voiceGuidanceEnabled ?? this.voiceGuidanceEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      offlineDataSize: offlineDataSize ?? this.offlineDataSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      courseRemindersEnabled:
          courseRemindersEnabled ?? this.courseRemindersEnabled,
    );
  }
}
