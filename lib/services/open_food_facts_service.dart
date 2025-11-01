import 'api_service.dart';
import '../models/food_dto.dart';

class OpenFoodFactsService {
  static const String baseUrl = 'https://world.openfoodfacts.org/api/v0';
  final ApiService _apiService = ApiService();

  Future<FoodDTO?> searchByBarcode(String barcode) async {
    try {
      final data = await _apiService.get('$baseUrl/product/$barcode.json');

      if (data['status'] == 1 && data['product'] != null) {
        return FoodDTO.fromJson(data['product'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FoodDTO>> searchByName(String query) async {
    try {
      final data = await _apiService.get(
        '$baseUrl/cgi/search.pl?search_terms=$query&json=1&page_size=10',
      );

      final products =
          (data['products'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(FoodDTO.fromJson)
              .toList() ??
          [];

      return products;
    } catch (e) {
      rethrow;
    }
  }
}
