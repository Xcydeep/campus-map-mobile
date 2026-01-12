import 'package:flutter/material.dart';

class SearchFiltersWidget extends StatelessWidget {
  final bool isInBottomSheet;

  const SearchFiltersWidget({
    super.key,
    this.isInBottomSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.category),
          title: const Text('Catégorie'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implémenter la sélection de catégorie
          },
        ),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('Distance'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implémenter la sélection de distance
          },
        ),
      ],
    );
  }
}
