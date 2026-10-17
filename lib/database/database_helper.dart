import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../models/order.dart';
import '../models/user.dart';

/// five tables:
///  - `users`       : registered accounts (email + hashed password)
///  - `foods`       : the menu (seeded once on first launch)
///  - `cart_items`  : items currently in a user's cart (scoped by userId)
///  - `orders`      : placed orders (scoped by userId)
///  - `order_items` : line items snapshotted at checkout time
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fastbite.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS order_items');
    await db.execute('DROP TABLE IF EXISTS orders');
    await db.execute('DROP TABLE IF EXISTS cart_items');
    await db.execute('DROP TABLE IF EXISTS foods');
    await db.execute('DROP TABLE IF EXISTS users');
    await _onCreate(db, newVersion);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        userId INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        phone TEXT,
        address TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE foods (
        foodId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        icon INTEGER NOT NULL,
        iconFontFamily TEXT,
        color INTEGER NOT NULL,
        rating REAL NOT NULL DEFAULT 4.5,
        prepTimeMinutes INTEGER NOT NULL DEFAULT 20
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        cartItemId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        foodId INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE,
        FOREIGN KEY (foodId) REFERENCES foods (foodId) ON DELETE CASCADE,
        UNIQUE (userId, foodId)
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        orderId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        orderDate TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'Preparing',
        deliveryAddress TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        orderItemId INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        foodName TEXT NOT NULL,
        priceAtOrder REAL NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (orderId) ON DELETE CASCADE
      )
    ''');

    await _seedMenu(db);
  }

  /// Populates the menu with sample items the first time the database is
  /// created, so the app has content to browse immediately.
  Future<void> _seedMenu(Database db) async {
    final sampleFoods = <FoodItem>[
      const FoodItem(
        name: 'Classic Cheeseburger',
        description: 'Juicy beef patty, cheddar, lettuce, tomato, and house sauce.',
        price: 8.99,
        category: 'Burgers',
        icon: Icons.lunch_dining,
        color: Color(0xFFB3261E),
        rating: 4.6,
        prepTimeMinutes: 15,
      ),
      const FoodItem(
        name: 'BBQ Bacon Burger',
        description: 'Smoky BBQ sauce, crispy bacon, and caramelized onions.',
        price: 10.49,
        category: 'Burgers',
        icon: Icons.lunch_dining,
        color: Color(0xFFB3261E),
        rating: 4.7,
        prepTimeMinutes: 18,
      ),
      const FoodItem(
        name: 'Margherita Pizza',
        description: 'Fresh mozzarella, basil, and San Marzano tomato sauce.',
        price: 12.99,
        category: 'Pizza',
        icon: Icons.local_pizza,
        color: Color(0xFF8B5000),
        rating: 4.8,
        prepTimeMinutes: 25,
      ),
      const FoodItem(
        name: 'Pepperoni Pizza',
        description: 'Loaded with spicy pepperoni and mozzarella cheese.',
        price: 13.99,
        category: 'Pizza',
        icon: Icons.local_pizza,
        color: Color(0xFF8B5000),
        rating: 4.7,
        prepTimeMinutes: 25,
      ),
      const FoodItem(
        name: 'Salmon Sushi Roll',
        description: 'Fresh salmon, avocado, and cucumber wrapped in rice.',
        price: 14.99,
        category: 'Sushi',
        icon: Icons.set_meal,
        color: Color(0xFF006A6A),
        rating: 4.9,
        prepTimeMinutes: 20,
      ),
      const FoodItem(
        name: 'Dragon Roll',
        description: 'Shrimp tempura topped with eel and spicy mayo.',
        price: 16.49,
        category: 'Sushi',
        icon: Icons.set_meal,
        color: Color(0xFF006A6A),
        rating: 4.8,
        prepTimeMinutes: 22,
      ),
      const FoodItem(
        name: 'Caesar Salad',
        description: 'Crisp romaine, parmesan, croutons, and Caesar dressing.',
        price: 7.99,
        category: 'Salads',
        icon: Icons.eco,
        color: Color(0xFF386A20),
        rating: 4.4,
        prepTimeMinutes: 10,
      ),
      const FoodItem(
        name: 'Greek Salad',
        description: 'Cucumber, tomato, olives, and feta with olive oil dressing.',
        price: 8.49,
        category: 'Salads',
        icon: Icons.eco,
        color: Color(0xFF386A20),
        rating: 4.5,
        prepTimeMinutes: 10,
      ),
      const FoodItem(
        name: 'Chocolate Lava Cake',
        description: 'Warm chocolate cake with a molten center, served with ice cream.',
        price: 6.99,
        category: 'Desserts',
        icon: Icons.cake,
        color: Color(0xFF7D5260),
        rating: 4.9,
        prepTimeMinutes: 12,
      ),
      const FoodItem(
        name: 'New York Cheesecake',
        description: 'Creamy classic cheesecake with a graham cracker crust.',
        price: 6.49,
        category: 'Desserts',
        icon: Icons.cake,
        color: Color(0xFF7D5260),
        rating: 4.7,
        prepTimeMinutes: 5,
      ),
      const FoodItem(
        name: 'Fresh Lemonade',
        description: 'Refreshing house-made lemonade over ice.',
        price: 3.49,
        category: 'Drinks',
        icon: Icons.local_drink,
        color: Color(0xFF29539B),
        rating: 4.5,
        prepTimeMinutes: 3,
      ),
      const FoodItem(
        name: 'Iced Coffee',
        description: 'Cold brew coffee served over ice with a splash of cream.',
        price: 4.29,
        category: 'Drinks',
        icon: Icons.local_cafe,
        color: Color(0xFF29539B),
        rating: 4.6,
        prepTimeMinutes: 5,
      ),
    ];

    for (final food in sampleFoods) {
      await db.insert('foods', food.toMap()..remove('foodId'));
    }
  }

  // ============================================================
  // Food CRUD (menu is mostly read-only, but full CRUD is exposed)
  // ============================================================

  Future<int> insertFood(FoodItem food) async {
    final db = await database;
    return db.insert('foods', food.toMap()..remove('foodId'));
  }

  Future<List<FoodItem>> getAllFoods() async {
    final db = await database;
    final rows = await db.query('foods', orderBy: 'name ASC');
    return rows.map(FoodItem.fromMap).toList();
  }

  Future<FoodItem?> getFoodById(int foodId) async {
    final db = await database;
    final rows = await db.query('foods', where: 'foodId = ?', whereArgs: [foodId], limit: 1);
    if (rows.isEmpty) return null;
    return FoodItem.fromMap(rows.first);
  }

  Future<int> updateFood(FoodItem food) async {
    final db = await database;
    return db.update('foods', food.toMap(), where: 'foodId = ?', whereArgs: [food.foodId]);
  }

  Future<int> deleteFood(int foodId) async {
    final db = await database;
    return db.delete('foods', where: 'foodId = ?', whereArgs: [foodId]);
  }

  // ============================================================
  // Cart CRUD (scoped per user)
  // ============================================================

  Future<List<CartItem>> getCartItems(int userId) async {
    final db = await database;
    final rows = await db.query('cart_items', where: 'userId = ?', whereArgs: [userId]);
    return rows.map(CartItem.fromMap).toList();
  }

  /// Adds [quantity] of [foodId] to [userId]'s cart, or increases quantity
  /// if that food is already present.
  Future<void> addToCart(int userId, int foodId, int quantity) async {
    final db = await database;
    final existing = await db.query(
      'cart_items',
      where: 'userId = ? AND foodId = ?',
      whereArgs: [userId, foodId],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert('cart_items', {'userId': userId, 'foodId': foodId, 'quantity': quantity});
    } else {
      final newQty = (existing.first['quantity'] as int) + quantity;
      await db.update(
        'cart_items',
        {'quantity': newQty},
        where: 'userId = ? AND foodId = ?',
        whereArgs: [userId, foodId],
      );
    }
  }

  Future<void> updateCartItemQuantity(int userId, int foodId, int quantity) async {
    final db = await database;
    if (quantity <= 0) {
      await removeFromCart(userId, foodId);
      return;
    }
    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'userId = ? AND foodId = ?',
      whereArgs: [userId, foodId],
    );
  }

  Future<void> removeFromCart(int userId, int foodId) async {
    final db = await database;
    await db.delete('cart_items', where: 'userId = ? AND foodId = ?', whereArgs: [userId, foodId]);
  }

  Future<void> clearCart(int userId) async {
    final db = await database;
    await db.delete('cart_items', where: 'userId = ?', whereArgs: [userId]);
  }

  // ============================================================
  // Order CRUD (scoped per user)
  // ============================================================

  Future<int> insertOrder(Order order, List<OrderItem> items) async {
    final db = await database;
    return db.transaction((txn) async {
      final orderId = await txn.insert('orders', order.toMap()..remove('orderId'));
      for (final item in items) {
        await txn.insert(
          'order_items',
          item.toMap()
            ..remove('orderItemId')
            ..['orderId'] = orderId,
        );
      }
      return orderId;
    });
  }

  Future<List<Order>> getOrdersForUser(int userId) async {
    final db = await database;
    final rows = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'orderDate DESC',
    );
    return rows.map(Order.fromMap).toList();
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final db = await database;
    final rows = await db.query('order_items', where: 'orderId = ?', whereArgs: [orderId]);
    return rows.map(OrderItem.fromMap).toList();
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    final db = await database;
    await db.update('orders', {'status': status}, where: 'orderId = ?', whereArgs: [orderId]);
  }

  Future<void> deleteOrder(int orderId) async {
    final db = await database;
    await db.delete('order_items', where: 'orderId = ?', whereArgs: [orderId]);
    await db.delete('orders', where: 'orderId = ?', whereArgs: [orderId]);
  }

  // ============================================================
  // User CRUD (registration / login / profile)
  // ============================================================

  Future<int> insertUser(User user) async {
    final db = await database;
    return db.insert('users', user.toMap()..remove('userId'));
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<User?> getUserById(int userId) async {
    final db = await database;
    final rows = await db.query('users', where: 'userId = ?', whereArgs: [userId], limit: 1);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return db.update('users', user.toMap(), where: 'userId = ?', whereArgs: [user.userId]);
  }

  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db.delete('users', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
