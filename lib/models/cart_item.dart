class CartItem {
  final int? cartItemId;
  final int foodId;
  final int quantity;

  const CartItem({
    this.cartItemId,
    required this.foodId,
    required this.quantity,
  });

  CartItem copyWith({int? cartItemId, int? foodId, int? quantity}) {
    return CartItem(
      cartItemId: cartItemId ?? this.cartItemId,
      foodId: foodId ?? this.foodId,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cartItemId': cartItemId,
      'foodId': foodId,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      cartItemId: map['cartItemId'] as int?,
      foodId: map['foodId'] as int,
      quantity: map['quantity'] as int,
    );
  }
}
