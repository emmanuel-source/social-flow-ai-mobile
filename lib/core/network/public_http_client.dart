import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class PublicHttpClient {
  PublicHttpClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<bool> healthCheck() async {
    final response = await _client
        .get(Uri.parse('${AppConfig.apiBaseUrl}/health'))
        .timeout(const Duration(seconds: 8));
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  void close() => _client.close();
}
