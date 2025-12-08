import 'package:flutter/material.dart';

class CalendarHeaderWidget extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const CalendarHeaderWidget({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              final newDate = selectedDate.subtract(const Duration(days: 1));
              onDateChanged(newDate);
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            onPressed: () {
              final newDate = selectedDate.add(const Duration(days: 1));
              onDateChanged(newDate);
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
