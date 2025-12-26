import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;
  factory ApiClient() => _instance;

  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
    if (kDebugMode) {
      print("Base URL changed to: $url");
    }
  }

  ApiClient._internal() {
    const String staticToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0ZW5Mb3AiOiJGbHV0dGVyIDAzIiwiSGV0SGFuU3RyaW5nIjoiMTIvMDQvMjAyNiIsIkhldEhhblRpbWUiOiIxNzc1OTUyMDAwMDAwIiwibmJmIjoxNzUzMjA3MjAwLCJleHAiOjE3NzYxMDMyMDB9.pOPJx-SHzqV9qZ_hGE1-4YHCsU_ZZdyisQDO3DLL84g';
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://fiverrnew.cybersoft.edu.vn',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 100),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "tokenCybersoft": staticToken,
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print("[${options.method}] ${options.uri}");
            print("Headers: ${options.headers}");
            print("Data: ${options.data}");
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print("Response [${response.statusCode}]: ${response.data}");
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print("Error [${e.response?.statusCode}]: ${e.message}");
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.get(path,
          queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path,
      {dynamic data, Options? options}) async {
    try {
      return await _dio.post(path, data: data, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path,
      {dynamic data, Options? options}) async {
    try {
      return await _dio.put(path, data: data, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path,
      {dynamic data, Options? options}) async {
    try {
      return await _dio.patch(path, data: data, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path,
      {dynamic data, Options? options}) async {
    try {
      return await _dio.delete(path, data: data, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout";
      case DioExceptionType.receiveTimeout:
        return "Receive timeout";
      case DioExceptionType.badResponse:
        return "Server error: ${error.response?.statusCode}";
      case DioExceptionType.cancel:
        return "Request cancelled";
      default:
        return "Unknown error: ${error.message}";
    }
  }
}