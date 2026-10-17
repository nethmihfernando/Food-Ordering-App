import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/order.dart';

/// Holds placed order history for the Orders screen.
class OrderProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  int? _userId;
  List<Order> _orders = [];
  final Map<int, List<OrderItem>> _itemsByOrder = {};
  bool _isLoading = false;
  String? errorMessage;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  /// Switches order history to a different user 
  void setUser(int? userId) {
    _userId = userId;
    _orders = [];
    _itemsByOrder.clear();
    if (userId != null) {
      loadOrders();
    } else {
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    if (_userId == null) return;
    _isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final loaded = await _db.getOrdersForUser(_userId!);
      _orders = loaded.where((o) => o.orderId != null).toList();
      for (final order in _orders) {
        _itemsByOrder[order.orderId!] = await _db.getOrderItems(order.orderId!);
      }
    } catch (e) {
      errorMessage = 'Could not load orders: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  List<OrderItem> itemsFor(int orderId) => List.unmodifiable(_itemsByOrder[orderId] ?? const []);

  /// Marks an order as cancelled by the user.
  Future<void> cancelOrder(int orderId) => _setStatus(orderId, 'Cancelled');

  /// Marks an order as received/delivered by the user.
  Future<void> markAsReceived(int orderId) => _setStatus(orderId, 'Delivered');

  Future<void> _setStatus(int orderId, String status) async {
    await _db.updateOrderStatus(orderId, status);
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      notifyListeners();
    }
  }

  Future<void> deleteOrder(int orderId) async {
    await _db.deleteOrder(orderId);
    _orders.removeWhere((o) => o.orderId == orderId);
    _itemsByOrder.remove(orderId);
    notifyListeners();
  }
}
