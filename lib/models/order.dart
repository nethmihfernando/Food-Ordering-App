class Order {
  final int? orderId;
  final int userId;
  final DateTime orderDate;
  final double totalAmount;
  final String status; // Preparing, On the way, Delivered, Cancelled
  final String deliveryAddress;

  const Order({
    this.orderId,
    required this.userId,
    required this.orderDate,
    required this.totalAmount,
    this.status = 'Preparing',
    required this.deliveryAddress,
  });

  Order copyWith({
    int? orderId,
    int? userId,
    DateTime? orderDate,
    double? totalAmount,
    String? status,
    String? deliveryAddress,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'orderDate': orderDate.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status,
      'deliveryAddress': deliveryAddress,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['orderId'] as int?,
      userId: map['userId'] as int,
      orderDate: DateTime.parse(map['orderDate'] as String),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      status: map['status'] as String,
      deliveryAddress: map['deliveryAddress'] as String,
    );
  }
}

class OrderItem {
  final int? orderItemId;
  final int orderId;
  final String foodName;
  final double priceAtOrder;
  final int quantity;

  const OrderItem({
    this.orderItemId,
    required this.orderId,
    required this.foodName,
    required this.priceAtOrder,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderItemId': orderItemId,
      'orderId': orderId,
      'foodName': foodName,
      'priceAtOrder': priceAtOrder,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      orderItemId: map['orderItemId'] as int?,
      orderId: map['orderId'] as int,
      foodName: map['foodName'] as String,
      priceAtOrder: (map['priceAtOrder'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }
}
