import 'package:flutter/material.dart';

class FloatingActionButtons extends StatelessWidget {
  final VoidCallback? onMyLocationPressed;
  final VoidCallback? onLayersPressed;
  final VoidCallback? onSchedulePressed;

  const FloatingActionButtons({
    super.key,
    this.onMyLocationPressed,
    this.onLayersPressed,
    this.onSchedulePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: 'my_location',
          onPressed: onMyLocationPressed,
          child: const Icon(Icons.my_location),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'layers',
          onPressed: onLayersPressed,
          child: const Icon(Icons.layers),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'schedule',
          onPressed: onSchedulePressed,
          child: const Icon(Icons.schedule),
        ),
      ],
    );
  }
}
