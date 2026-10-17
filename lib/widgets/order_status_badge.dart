import 'package:flutter/material.dart';

/// Colored pill showing an order's current status.
class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  Color _color() {
    switch (status) {
      case 'Delivered':
        return const Color(0xFF386A20);
      case 'On the way':
        return const Color(0xFF29539B);
      case 'Cancelled':
        return const Color(0xFFBA1A1A);
      default:
        return const Color(0xFF8B5000);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
