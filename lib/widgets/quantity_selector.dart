import 'package:flutter/material.dart';

/// Small +/- stepper used to adjust an item's quantity.
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Color color;
  final ValueChanged<int> onChanged;
  final int minQuantity;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.color,
    required this.onChanged,
    this.minQuantity = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            color: color,
            onPressed: quantity > minQuantity ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            color: color,
            onPressed: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}
