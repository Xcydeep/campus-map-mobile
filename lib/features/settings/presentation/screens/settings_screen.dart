import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../routes/app_router.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: IconButton(
          onPressed: () => context.navigateBack(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        children: [
          // Section Carte
          _buildSectionHeader('Carte', Icons.map),
          _buildSwitchTile(
            title: 'Mode sombre',
            subtitle: 'Utiliser le thème sombre pour la carte',
            value: settingsState.darkMapTheme,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleDarkMapTheme(value);
            },
          ),
          _buildSwitchTile(
            title: 'Rotation de la carte',
            subtitle: 'Permettre la rotation avec deux doigts',
            value: settingsState.mapRotationEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleMapRotation(value);
            },
          ),
          _buildSwitchTile(
            title: 'Bâtiments 3D',
            subtitle: 'Afficher les bâtiments en 3D',
            value: settingsState.show3DBuildings,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggle3DBuildings(value);
            },
          ),

          const Divider(),

          // Section Navigation
          _buildSectionHeader('Navigation', Icons.directions),
          _buildListTile(
            title: 'Mode de déplacement par défaut',
            subtitle: settingsState.defaultTransportMode == 'walking'
                ? 'À pied'
                : 'Véhicule',
            leading: Icons.directions_walk,
            onTap: () {
              _showTransportModeDialog(context, ref, settingsState);
            },
          ),
          _buildSwitchTile(
            title: 'Guidage vocal',
            subtitle: 'Instructions vocales pendant la navigation',
            value: settingsState.voiceGuidanceEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleVoiceGuidance(value);
            },
          ),

          const Divider(),

          // Section Données hors-ligne
          _buildSectionHeader('Données hors-ligne', Icons.cloud_download),
          _buildListTile(
            title: 'Télécharger les données',
            subtitle: settingsState.offlineDataSize > 0
                ? '${settingsState.offlineDataSize} MB téléchargés'
                : 'Aucune donnée téléchargée',
            leading: Icons.download,
            onTap: () {
              _showDownloadDialog(context, ref);
            },
          ),
          _buildSwitchTile(
            title: 'Synchronisation automatique',
            subtitle: 'Mettre à jour les données en arrière-plan',
            value: settingsState.autoSyncEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleAutoSync(value);
            },
          ),
          if (settingsState.offlineDataSize > 0)
            _buildListTile(
              title: 'Supprimer les données hors-ligne',
              subtitle: 'Libérer de l\'espace de stockage',
              leading: Icons.delete_outline,
              textColor: AppColors.error,
              onTap: () {
                _showDeleteOfflineDataDialog(context, ref);
              },
            ),

          const Divider(),

          // Section Notifications
          _buildSectionHeader('Notifications', Icons.notifications),
          _buildSwitchTile(
            title: 'Notifications',
            subtitle: 'Recevoir des alertes et rappels',
            value: settingsState.notificationsEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).toggleNotifications(value);
            },
          ),
          if (settingsState.notificationsEnabled)
            _buildSwitchTile(
              title: 'Rappels de cours',
              subtitle: 'Être notifié avant vos cours',
              value: settingsState.courseRemindersEnabled,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .toggleCourseReminders(value);
              },
            ),

          const Divider(),

          // Section À propos
          _buildSectionHeader('À propos', Icons.info),
          _buildListTile(
            title: 'Version',
            subtitle: AppConfig.appVersion,
            leading: Icons.app_settings_alt,
            onTap: () {},
          ),
          _buildListTile(
            title: 'Conditions d\'utilisation',
            leading: Icons.description,
            onTap: () {
              // TODO: Ouvrir les CGU
            },
          ),
          _buildListTile(
            title: 'Politique de confidentialité',
            leading: Icons.privacy_tip,
            onTap: () {
              // TODO: Ouvrir la politique de confidentialité
            },
          ),
          _buildListTile(
            title: 'Licences open source',
            leading: Icons.code,
            onTap: () {
              showLicensePage(context: context);
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.h6.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.body),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData leading,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(leading, color: textColor ?? AppColors.textPrimary),
      title: Text(title, style: AppTextStyles.body.copyWith(color: textColor)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showTransportModeDialog(
    BuildContext context,
    WidgetRef ref,
    SettingsState state,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mode de déplacement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('À pied'),
              value: 'walking',
              groupValue: state.defaultTransportMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setTransportMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Véhicule'),
              value: 'driving',
              groupValue: state.defaultTransportMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setTransportMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloadDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Télécharger les données'),
        content: const Text(
          'Télécharger les données du campus pour une utilisation hors-ligne?\n\nTaille estimée: 50 MB',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).downloadOfflineData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Téléchargement en cours...')),
              );
            },
            child: const Text('Télécharger'),
          ),
        ],
      ),
    );
  }

  void _showDeleteOfflineDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer les données'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer toutes les données hors-ligne?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).deleteOfflineData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Données supprimées'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// Provider moved to `providers/settings_provider.dart`.
