import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/food_provider.dart';
import '../providers/order_provider.dart';
import '../utils/food_images.dart';
import '../utils/format_utils.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/quantity_selector.dart';
import 'root_shell.dart';

/// Review screen for everything currently in the cart, with quantity
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController(text: '123 Main Street, Apt 4B');
  bool _isCheckingOut = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    final cartProvider = context.read<CartProvider>();
    final foodProvider = context.read<FoodProvider>();

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address')),
      );
      return;
    }

    setState(() => _isCheckingOut = true);
    try {
      await cartProvider.checkout(foodProvider.allFoods, _addressController.text.trim());
      if (!mounted) return;
      await context.read<OrderProvider>().loadOrders();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCheckingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not place order: $e')),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _isCheckingOut = false);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 40),
        title: const Text('Order placed!'),
        content: const Text('Your food is being prepared and will be on its way shortly.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              RootShell.selectedTab.value = 2; // Orders tab
            },
            child: const Text('View Orders'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Consumer2<CartProvider, FoodProvider>(
        builder: (context, cartProvider, foodProvider, _) {
          if (cartProvider.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Browse the menu and add something delicious!',
            );
          }

          final menu = foodProvider.allFoods;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cartItems[index];
                    final food = foodProvider.foodById(cartItem.foodId);
                    if (food == null) return const SizedBox.shrink();
                    final imagePath = foodImagePath(food.name);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: food.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: imagePath != null
                                  ? Image.asset(imagePath, width: 52, height: 52, fit: BoxFit.cover)
                                  : Icon(food.icon, color: food.color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(food.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppFormat.currency(food.price),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: food.color),
                                  ),
                                ],
                              ),
                            ),
                            QuantitySelector(
                              quantity: cartItem.quantity,
                              color: food.color,
                              minQuantity: 0,
                              onChanged: (q) => cartProvider.updateQuantity(food.foodId!, q),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Address',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _PriceRow(label: 'Subtotal', value: AppFormat.currency(cartProvider.subtotal(menu))),
                      _PriceRow(label: 'Delivery Fee', value: AppFormat.currency(CartProvider.deliveryFee)),
                      const Divider(height: 20),
                      _PriceRow(
                        label: 'Total',
                        value: AppFormat.currency(cartProvider.total(menu)),
                        emphasize: true,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _isCheckingOut ? null : _checkout,
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                        child: _isCheckingOut
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Place Order'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _PriceRow({required this.label, required this.value, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
