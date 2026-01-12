import 'package:flutter/material.dart';

class ScheduleFilterWidget extends StatelessWidget {
  final List<String> filters;
  final ValueChanged<String> onFilterRemoved;

  const ScheduleFilterWidget({
    super.key,
    required this.filters,
    required this.onFilterRemoved,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters.map((filter) {
        return Chip(
          label: Text(filter),
          onDeleted: () => onFilterRemoved(filter),
        );
      }).toList(),
    );
  }
}
