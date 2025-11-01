import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';
import '../models/recipe.dart';

class SpoonacularService {
  static const String baseUrl = 'https://api.spoonacular.com/recipes';
  static String get apiKey => dotenv.env['SPOONACULAR_API_KEY'] ?? '';
  final ApiService _apiService = ApiService();

  Future<List<Recipe>> findByIngredients(List<String> ingredients) async {
    if (ingredients.isEmpty) return [];

    try {
      final ingredientList = ingredients.join(',');
      final url =
          '$baseUrl/findByIngredients?ingredients=$ingredientList&number=10&ranking=2&apiKey=$apiKey';

      final response = await _apiService.get(url);

      if (response is List) {
        return (response)
            .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getRecipeInfo(int recipeId) async {
    try {
      final url = '$baseUrl/$recipeId/information?apiKey=$apiKey';
      return await _apiService.get(url);
    } catch (e) {
      rethrow;
    }
  }
}
