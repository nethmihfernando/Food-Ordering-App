import 'package:flutter/material.dart';

class FoodItem {
  final int? foodId;
  final String name;
  final String description;
  final double price;
  final String category;
  final IconData icon;
  final Color color;
  final double rating;
  final int prepTimeMinutes;

  const FoodItem({
    this.foodId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.icon,
    required this.color,
    this.rating = 4.5,
    this.prepTimeMinutes = 20,
  });

  FoodItem copyWith({
    int? foodId,
    String? name,
    String? description,
    double? price,
    String? category,
    IconData? icon,
    Color? color,
    double? rating,
    int? prepTimeMinutes,
  }) {
    return FoodItem(
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      rating: rating ?? this.rating,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'color': color.toARGB32(),
      'rating': rating,
      'prepTimeMinutes': prepTimeMinutes,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      foodId: map['foodId'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String,
      icon: IconData(
        map['icon'] as int,
        fontFamily: map['iconFontFamily'] as String? ?? 'MaterialIcons',
      ),
      color: Color(map['color'] as int),
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      prepTimeMinutes: map['prepTimeMinutes'] as int? ?? 20,
    );
  }
}

/// Fixed list of categories used to seed data and filter the Home screen.
const List<String> kFoodCategories = [
  'Burgers',
  'Pizza',
  'Sushi',
  'Salads',
  'Desserts',
  'Drinks',
];
