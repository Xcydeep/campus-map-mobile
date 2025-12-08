import 'package:flutter/material.dart';

class BottomSheetPlacesList extends StatelessWidget {
  const BottomSheetPlacesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Center(child: Text('Liste des lieux')),
    );
  }
}
