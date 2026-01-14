import 'package:dio/dio.dart';
import 'package:formio_api/formio_api.dart';

/// Service for handling DataSource component data fetching.
class DataSourceService {
  /// Fetches data for a DataSource component.
  ///
  /// [fetchConfig] is the 'fetch' configuration map from the component definition.
  /// [formData] is the current form data for interpolation.
  static Future<dynamic> fetchData({
    required Map<String, dynamic> fetchConfig,
    required Map<String, dynamic> formData,
  }) async {
    final url = fetchConfig['url']?.toString();
    if (url == null || url.isEmpty) {
      throw 'No URL specified';
    }

    final method = fetchConfig['method']?.toString() ?? 'get';
    final headers = _buildHeaders(fetchConfig['headers'], formData);

    // Make HTTP request
    final dio = Dio();
    final response = await dio.request(
      url,
      options: Options(method: method.toUpperCase(), headers: headers),
    );

    // Transform data using mapFunction
    final mapFunction = fetchConfig['mapFunction']?.toString();
    return _transformData(response.data, mapFunction);
  }

  static Map<String, dynamic> _buildHeaders(
    dynamic headersConfig,
    Map<String, dynamic> formData,
  ) {
    if (headersConfig is! List) return {};

    final headers = <String, dynamic>{};
    for (final header in headersConfig) {
      if (header is! Map) continue;

      final key = header['key']?.toString();
      final value = header['value']?.toString();

      if (key != null && value != null) {
        // Interpolate {{data.field}} in header value
        final interpolated = InterpolationUtils.interpolate(
          value,
          formData,
        );
        headers[key] = interpolated;
      }
    }
    return headers;
  }

  static Future<dynamic> _transformData(
    dynamic responseData,
    String? mapFunction,
  ) async {
    if (mapFunction == null || mapFunction.isEmpty) {
      return responseData;
    }

    // For now, return raw response data
    return responseData;
  }
}
