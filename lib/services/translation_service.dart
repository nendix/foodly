import 'api_service.dart';

class TranslationService {
  static const String baseUrl =
      'https://translate.googleapis.com/translate_a/single';
  final ApiService _apiService = ApiService();

  Future<String> translateToEnglish(String text) async {
    if (text.isEmpty) return text;

    try {
      final encodedText = Uri.encodeComponent(text);
      final url =
          '$baseUrl?client=gtx&sl=auto&tl=en&dt=t&q=$encodedText';

      final data = await _apiService.get(url);

      if (data is List && data.isNotEmpty && data[0] is List) {
        final translations = data[0] as List;
        if (translations.isNotEmpty && translations[0] is List) {
          final firstTranslation = translations[0] as List;
          if (firstTranslation.isNotEmpty) {
            return firstTranslation[0] as String;
          }
        }
      }

      return text;
    } catch (e) {
      return text;
    }
  }
}
