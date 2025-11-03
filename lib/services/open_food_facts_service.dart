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
}
