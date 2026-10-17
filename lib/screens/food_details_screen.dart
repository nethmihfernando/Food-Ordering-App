import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/food_provider.dart';
import '../utils/food_images.dart';
import '../utils/format_utils.dart';
import '../widgets/quantity_selector.dart';

/// Detail view for a single menu item: description, rating, prep time,a quantity stepper, and an "Add to Cart" action.
class FoodDetailsScreen extends StatefulWidget {
  final int foodId;

  const FoodDetailsScreen({super.key, required this.foodId});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final food = context.watch<FoodProvider>().foodById(widget.foodId);

    if (food == null) {
      return const Scaffold(body: Center(child: Text('Item not found')));
    }

    final theme = Theme.of(context);
    final imagePath = foodImagePath(food.name);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: food.color,
            flexibleSpace: FlexibleSpaceBar(
              background: imagePath != null
                  ? Image.asset(imagePath, fit: BoxFit.cover)
                  : Container(
                      color: food.color,
                      child: Center(
                        child: Icon(food.icon, size: 110, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(food.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Text(
                        AppFormat.currency(food.price),
                        style: theme.textTheme.headlineSmall?.copyWith(color: food.color, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: food.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(food.category, style: TextStyle(color: food.color, fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('${food.rating} rating', style: theme.textTheme.bodyMedium),
                      const SizedBox(width: 18),
                      Icon(Icons.access_time, size: 17, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${food.prepTimeMinutes} min prep time', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    food.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quantity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      QuantitySelector(
                        quantity: _quantity,
                        color: food.color,
                        onChanged: (q) => setState(() => _quantity = q),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: food.color, minimumSize: const Size.fromHeight(52)),
            onPressed: () async {
              await context.read<CartProvider>().addToCart(food.foodId!, quantity: _quantity);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            child: Text('Add to Cart • ${AppFormat.currency(food.price * _quantity)}'),
          ),
        ),
      ),
    );
  }
}
