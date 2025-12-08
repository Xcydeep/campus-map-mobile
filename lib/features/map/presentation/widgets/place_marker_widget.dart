import 'package:flutter/material.dart';
import '../../domain/entities/place.dart';

class PlaceMarkerWidget extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;

  const PlaceMarkerWidget({super.key, required this.place, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(Icons.location_on, size: 40, color: Colors.redAccent),
    );
  }
}
