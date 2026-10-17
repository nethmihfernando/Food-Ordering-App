import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../models/order.dart';

/// Manages the user's cart: adding/removing items, quantity changes, and
class CartProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  int? _userId;
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  bool get isLoading => _isLoading;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _cartItems.isEmpty;

  /// Switches the cart to a different user
  void setUser(int? userId) {
    _userId = userId;
    _cartItems = [];
    if (userId != null) {
      loadCart();
    } else {
      notifyListeners();
    }
  }

  Future<void> loadCart() async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();
    _cartItems = await _db.getCartItems(_userId!);
    _isLoading = false;
    notifyListeners();
  }

  int quantityOf(int foodId) {
    final match = _cartItems.where((c) => c.foodId == foodId);
    return match.isEmpty ? 0 : match.first.quantity;
  }

  Future<void> addToCart(int foodId, {int quantity = 1}) async {
    if (_userId == null) return;
    await _db.addToCart(_userId!, foodId, quantity);
    await loadCart();
  }

  Future<void> updateQuantity(int foodId, int quantity) async {
    if (_userId == null) return;
    await _db.updateCartItemQuantity(_userId!, foodId, quantity);
    await loadCart();
  }

  Future<void> removeFromCart(int foodId) async {
    if (_userId == null) return;
    await _db.removeFromCart(_userId!, foodId);
    await loadCart();
  }

  double subtotal(List<FoodItem> menu) {
    double total = 0;
    for (final item in _cartItems) {
      final food = menu.where((f) => f.foodId == item.foodId);
      if (food.isNotEmpty) {
        total += food.first.price * item.quantity;
      }
    }
    return total;
  }

  static const double deliveryFee = 2.99;

  double total(List<FoodItem> menu) => subtotal(menu) + (isEmpty ? 0 : deliveryFee);

  /// Places an order from the current cart contents, then clears the cart.
  Future<int> checkout(List<FoodItem> menu, String deliveryAddress) async {
    if (_userId == null) {
      throw StateError('Cannot checkout: no user is logged in.');
    }

    final items = <OrderItem>[];
    for (final cartItem in _cartItems) {
      final food = menu.where((f) => f.foodId == cartItem.foodId);
      if (food.isEmpty) continue;
      items.add(OrderItem(
        orderId: 0, // replaced inside the DB transaction
        foodName: food.first.name,
        priceAtOrder: food.first.price,
        quantity: cartItem.quantity,
      ));
    }

    final order = Order(
      userId: _userId!,
      orderDate: DateTime.now(),
      totalAmount: total(menu),
      status: 'Preparing',
      deliveryAddress: deliveryAddress,
    );

    final orderId = await _db.insertOrder(order, items);
    await _db.clearCart(_userId!);
    _cartItems = [];
    notifyListeners();
    return orderId;
  }
}
