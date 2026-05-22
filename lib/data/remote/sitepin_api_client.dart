import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class SitePinApiClient {
  final http.Client _client;

  SitePinApiClient({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: path,
      queryParameters: query,
    );
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final response = await _client.post(
      _uri(path),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    String? token,
    Map<String, String>? query,
  }) async {
    final response = await _client.get(
      _uri(path, query),
      headers: {
        if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final response = await _client.put(
      _uri(path),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final map = (jsonDecode(response.body) as Map<String, dynamic>);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        (map['message'] ?? map['error'] ?? 'Request failed').toString(),
      );
    }
    return map;
  }
}
