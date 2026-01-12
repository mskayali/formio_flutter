import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';

class ApiClient {
  /// Static base URL shared across all instances.
  static Uri _baseUrl = Uri.parse('https://your-formio-url.com');

  /// Dio instance used for making HTTP requests.
  late final Dio dio;

  /// Allows setting the base URL once. Future instances use the same.
  static void setBaseUrl(Uri url) {
    _baseUrl = url;
  }

  /// Returns the currently set base URL.
  static Uri get baseUrl => _baseUrl;

  /// Creates a new instance of [ApiClient] using the shared base URL.
  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: _baseUrl.toString(),
      headers: {'Content-Type': 'application/json'},
    ));
    
    // Add cURL logger for debugging HTTP requests
    dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
  }

  void setAuthToken(String token) {
    dio.options.headers['x-jwt-token'] = token;
  }

  void clearAuthToken() {
    dio.options.headers.remove('x-jwt-token');
  }

  Future<Response<Map<String, dynamic>>> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return dio.get(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<Map<String, dynamic>>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<Map<String, dynamic>>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<Map<String, dynamic>>> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<Map<String, dynamic>>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Uploads a file using multipart/form-data
  Future<Response<Map<String, dynamic>>> upload(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) {
    return dio.post(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }
}
