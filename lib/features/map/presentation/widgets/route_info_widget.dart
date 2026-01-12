import 'package:flutter/material.dart';
import '../../domain/entities/map_route.dart';

class RouteInfoWidget extends StatelessWidget {
  final MapRoute route;
  final String transportMode;
  final VoidCallback onStartNavigation;
  final VoidCallback onShowDirections;

  const RouteInfoWidget({
    super.key,
    required this.route,
    required this.transportMode,
    required this.onStartNavigation,
    required this.onShowDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Itinéraire calculé',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: onShowDirections,
                    icon: const Icon(Icons.list),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onStartNavigation,
                      child: const Text('Commencer la navigation'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
