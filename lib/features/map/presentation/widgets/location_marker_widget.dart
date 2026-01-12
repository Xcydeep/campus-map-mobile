import 'package:flutter/material.dart';

class LocationMarkerWidget extends StatelessWidget {
  const LocationMarkerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.person_pin_circle,
      size: 48,
      color: Colors.blueAccent,
    );
  }
}
