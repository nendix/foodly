import 'package:flutter/material.dart';
import '../models/food.dart';
import '../screens/food_screen.dart';

class NavigationService {
  Future<Food?> navigateToAddFood(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FoodScreen()),
    );
    return result is Food ? result : null;
  }

  Future<Food?> navigateToEditFood(BuildContext context, Food food) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodScreen(food: food)),
    );
    return result is Food ? result : null;
  }
}
