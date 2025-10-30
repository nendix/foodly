import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(String message) : super('Network Error: $message');
}

class ServerException extends ApiException {
  ServerException(String message) : super('Server Error: $message');
}

class ParseException extends ApiException {
  ParseException(String message) : super('Parse Error: $message');
}

class ApiService {
  static const Duration timeout = Duration(seconds: 10);

  Future<dynamic> get(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw ServerException('Resource not found');
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error (${response.statusCode})');
      } else {
        throw ServerException('HTTP Error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on FormatException catch (e) {
      throw ParseException('Invalid JSON response: ${e.message}');
    } catch (e) {
      throw NetworkException('Unexpected error: $e');
    }
  }
}
