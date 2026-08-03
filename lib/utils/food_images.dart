/// Maps each seeded menu item's name to its photo in `assets/`.
///
/// Looked up by name rather than food id since ids are assigned by
/// SQLite at insert time. If a food has no matching entry here (e.g. a
/// new item added later without a photo), callers should fall back to
/// showing the existing [FoodItem.icon] instead.
const Map<String, String> kFoodImagePaths = {
  'Classic Cheeseburger': 'assets/classic_cheeseburger.jpg',
  'BBQ Bacon Burger': 'assets/bbq_bacon_burger.jpg',
  'Margherita Pizza': 'assets/margherita_pizza.jpg',
  'Pepperoni Pizza': 'assets/pepperoni_pizza.jpg',
  'Salmon Sushi Roll': 'assets/salmon_sushi_roll.jpg',
  'Dragon Roll': 'assets/dragon_roll.jpg',
  'Caesar Salad': 'assets/ceaser_salad.jpg',
  'Greek Salad': 'assets/greek_salad.jpg',
  'Chocolate Lava Cake': 'assets/chocolate_lava_cake.jpg',
  'New York Cheesecake': 'assets/new_york_cheesecake.jpg',
  'Fresh Lemonade': 'assets/fresh_lemonade.jpg',
  'Iced Coffee': 'assets/iced_coffe.jpg',
};

/// Returns the asset path for [foodName]'s photo, or null if none exists.
String? foodImagePath(String foodName) => kFoodImagePaths[foodName];
