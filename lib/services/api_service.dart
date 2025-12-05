import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _storageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<http.Response> get(String endpoint, {bool includeAuth = true}) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    return await http.put(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    return await http.patch(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String endpoint,
      {bool includeAuth = true}) async {
    final headers = await _getHeaders(includeAuth: includeAuth);
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    return await http.delete(url, headers: headers);
  }

  // Multipart POST request for file uploads
  Future<http.Response> postMultipart(
    String endpoint,
    Map<String, String> fields,
    File? file, {
    String fileField = 'image',
  }) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', url);

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Add fields
    request.fields.addAll(fields);

    // Add file if provided
    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );
    }

    print('POST Multipart - Fields: ${request.fields}');
    print('POST Multipart - Has file: ${file != null}');

    // Send request
    final streamedResponse = await request.send();

    // Convert StreamedResponse to Response
    final response = await http.Response.fromStream(streamedResponse);

    return response;
  }

  // FIXED: Multipart PUT request (uses POST with _method=PUT for Laravel)
  Future<http.Response> putMultipart(
    String endpoint,
    Map<String, String> fields,
    File? file, {
    String fileField = 'image',
  }) async {
    final token = await _storageService.getToken();
    final url = Uri.parse('${AppConfig.baseUrl}$endpoint');

    // Use POST method (Laravel doesn't support PUT multipart directly)
    final request = http.MultipartRequest('POST', url);

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // IMPORTANT: Add _method field for Laravel to recognize it as PUT
    final allFields = Map<String, String>.from(fields);
    allFields['_method'] = 'PUT';

    // Add all fields
    request.fields.addAll(allFields);

    // Add file if provided
    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );
    }

    print('PUT Multipart - URL: $url');
    print('PUT Multipart - Fields: ${request.fields}');
    print('PUT Multipart - Has file: ${file != null}');

    // Send request
    final streamedResponse = await request.send();

    // Convert StreamedResponse to Response
    final response = await http.Response.fromStream(streamedResponse);

    print('PUT Multipart - Response status: ${response.statusCode}');
    print('PUT Multipart - Response body: ${response.body}');

    return response;
  }

  // Handle API response
  Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Something went wrong');
    }
  }
}
