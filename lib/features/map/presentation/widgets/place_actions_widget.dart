import 'package:flutter/material.dart';

class PlaceActionsWidget extends StatelessWidget {
  final dynamic place;
  final VoidCallback? onNavigate;
  final VoidCallback? onShare;
  final VoidCallback? onReport;

  const PlaceActionsWidget({
    super.key,
    this.place,
    this.onNavigate,
    this.onShare,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
