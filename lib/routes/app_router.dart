import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/map/presentation/screens/map_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/navigation/presentation/screens/navigation_screen.dart';
import '../features/schedule/presentation/screens/schedule_screen.dart';
import '../features/schedule/presentation/screens/course_detail_screen.dart';
import '../features/place_detail/presentation/screens/place_detail_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

// Provider pour le router
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Route principale - Carte
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MapScreen(),
      ),

      // Recherche
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return SearchScreen(initialQuery: query);
        },
      ),

      // Détails d'un lieu
      GoRoute(
        path: '/place/:id',
        name: 'place-detail',
        builder: (context, state) {
          final placeId = state.pathParameters['id']!;
          return PlaceDetailScreen(placeId: placeId);
        },
      ),

      // Navigation/Itinéraire
      GoRoute(
        path: '/navigation',
        name: 'navigation',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return NavigationScreen(
            destinationId: extra?['destinationId'],
            startLat: extra?['startLat'],
            startLon: extra?['startLon'],
          );
        },
      ),

      // Planning des cours
      GoRoute(
        path: '/schedule',
        name: 'schedule',
        builder: (context, state) => const ScheduleScreen(),
        routes: [
          // Détails d'un cours
          GoRoute(
            path: 'course/:id',
            name: 'course-detail',
            builder: (context, state) {
              final courseId = state.pathParameters['id']!;
              return CourseDetailScreen(courseId: courseId);
            },
          ),
        ],
      ),

      // Partage de position (deep link)
      GoRoute(
        path: '/share/:token',
        name: 'share',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          // Décoder le token et rediriger vers la carte avec position
          return MapScreen(shareToken: token);
        },
      ),

      // Paramètres
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],

    // Gestion des erreurs de routing
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Erreur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page non trouvée',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chemin: ${state.uri.path}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),

    // Redirection si nécessaire
    redirect: (context, state) {
      // Ajoutez ici la logique de redirection si besoin
      // Par exemple, vérifier si l'utilisateur a accepté les permissions
      return null;
    },
  );
});

// Extension pour faciliter la navigation
extension NavigationExtension on BuildContext {
  void navigateToPlace(String placeId) {
    go('/place/$placeId');
  }

  void navigateToSearch({String? query}) {
    if (query != null && query.isNotEmpty) {
      go('/search?q=$query');
    } else {
      go('/search');
    }
  }

  void navigateToNavigation({
    required String destinationId,
    double? startLat,
    double? startLon,
  }) {
    go(
      '/navigation',
      extra: {
        'destinationId': destinationId,
        'startLat': startLat,
        'startLon': startLon,
      },
    );
  }

  void navigateToSchedule() {
    go('/schedule');
  }

  void navigateToCourseDetail(String courseId) {
    go('/schedule/course/$courseId');
  }

  void navigateToSettings() {
    go('/settings');
  }

  void navigateBack() {
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}