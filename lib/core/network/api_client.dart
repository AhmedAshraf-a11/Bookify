import 'dart:io';

import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import 'api_exception.dart';
import 'auth_session.dart';

class ApiClient {
  ApiClient({
    required AuthSession session,
    Dio? dio,
  })  : _session = session,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
                headers: const {
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;
  final AuthSession _session;

  Future<Map<String, dynamic>> get(
    Uri uri, {
    bool requiresAuth = true,
  }) async {
    return _request(
      () => _dio.getUri(
        uri,
        options: _options(requiresAuth: requiresAuth),
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    Uri uri, {
    Object? body,
    bool requiresAuth = true,
  }) async {
    return _request(
      () => _dio.postUri(
        uri,
        data: body,
        options: _options(requiresAuth: requiresAuth),
      ),
    );
  }

  Future<Map<String, dynamic>> patch(
    Uri uri, {
    Object? body,
    bool requiresAuth = true,
  }) async {
    return _request(
      () => _dio.patchUri(
        uri,
        data: body,
        options: _options(requiresAuth: requiresAuth),
      ),
    );
  }

  Future<Map<String, dynamic>> delete(
    Uri uri, {
    Object? body,
    bool requiresAuth = true,
  }) async {
    return _request(
      () => _dio.deleteUri(
        uri,
        data: body,
        options: _options(requiresAuth: requiresAuth),
      ),
    );
  }

  Future<Map<String, dynamic>> postMultipart(
    Uri uri, {
    required Map<String, dynamic> fields,
    String? imagePath,
    String? pdfPath,
    bool requiresAuth = true,
  }) async {
    final formData = FormData.fromMap({
      ...fields,
      if (imagePath != null && imagePath.isNotEmpty)
        'image': await MultipartFile.fromFile(imagePath, filename: _basename(imagePath)),
      if (pdfPath != null && pdfPath.isNotEmpty)
        'pdf': await MultipartFile.fromFile(pdfPath, filename: _basename(pdfPath)),
    });

    return _request(
      () => _dio.postUri(
        uri,
        data: formData,
        options: _options(
          requiresAuth: requiresAuth,
          contentType: 'multipart/form-data',
        ),
      ),
    );
  }

  Options _options({
    required bool requiresAuth,
    String? contentType,
  }) {
    final headers = <String, String>{};
    if (requiresAuth) {
      final token = _session.accessToken;
      if (token == null || token.isEmpty) {
        throw const ApiException(message: 'Access token is missing');
      }
      headers['Authorization'] = 'bearer $token';
    }
    return Options(
      headers: headers,
      contentType: contentType,
    );
  }

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() action,
  ) async {
    try {
      final response = await action();
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw const ApiException(message: 'Unexpected response format');
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  String _basename(String path) {
    return File(path).uri.pathSegments.isNotEmpty
        ? File(path).uri.pathSegments.last
        : path;
  }
}
