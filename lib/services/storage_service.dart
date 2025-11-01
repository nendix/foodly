import 'package:hive_flutter/hive_flutter.dart';
import '../models/food.dart';

class StorageService {
  static const String foodBoxName = 'foods';
  late Box<Food> _foodBox;

  StorageService._();
  static final StorageService _instance = StorageService._();

  factory StorageService() => _instance;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FoodAdapter());
    _foodBox = await Hive.openBox<Food>(foodBoxName);
  }

  List<Food> getAllFoods() {
    return _foodBox.values.toList();
  }

  Future<void> addFood(Food food) async {
    await _foodBox.put(food.id, food);
  }

  Future<void> updateFood(Food food) async {
    await _foodBox.put(food.id, food);
  }

  Future<void> deleteFood(String id) async {
    await _foodBox.delete(id);
  }
}
