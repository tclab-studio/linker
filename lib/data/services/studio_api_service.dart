import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../models/vpn_config_api.dart';

class StudioApiService {
  String get _baseUrl => dotenv.env['BASE_URL'] ?? '';

  Future<List<VpnConfigApiModel>> verifyStudio(String studioId) async {
    final uri = Uri.parse('$_baseUrl/studios/verify');

    final response = await http
        .post(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
            HttpHeaders.acceptHeader: 'application/json',
          },
          body: jsonEncode({'studio_id': studioId}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .cast<Map<String, dynamic>>()
          .map(VpnConfigApiModel.fromJson)
          .toList();
    } else if (response.statusCode == 404 || response.statusCode == 403) {
      return [];
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
