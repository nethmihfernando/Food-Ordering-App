import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/food_item.dart';

/// Holds the full menu and exposes category filtering / search used by
/// the Home screen. All food CRUD is funneled through here.
class FoodProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<FoodItem> _foods = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<FoodItem> get allFoods => List.unmodifiable(_foods);
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  List<String> get categories => ['All', ...kFoodCategories];

  List<FoodItem> get filteredFoods {
    return _foods.where((food) {
      final matchesCategory = _selectedCategory == 'All' || food.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          food.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> loadFoods() async {
    _isLoading = true;
    notifyListeners();
    _foods = await _db.getAllFoods();
    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  FoodItem? foodById(int foodId) {
    for (final food in _foods) {
      if (food.foodId == foodId) return food;
    }
    return null;
  }
}
