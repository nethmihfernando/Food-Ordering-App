/// A single line item in the user's cart.
///
/// Maps to a row in the `cart_items` table. `foodId` references a
/// `foods` row; quantity is how many of that item are in the cart.
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
