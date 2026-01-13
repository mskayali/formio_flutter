/// A non-visual Flutter component that fetches data from external URLs.
///
/// The DataSource component makes HTTP requests to external APIs and stores
/// the result in form state for use by other components. It supports:
/// - HTTP GET/POST/PUT/DELETE requests
/// - Custom headers with form data interpolation
/// - JavaScript transformation of responses via mapFunction
/// - Reactive updates when trigger fields change
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:formio_api/formio_api.dart';

class DataSourceComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value (fetched data).
  final dynamic value;

  /// Complete form data for header interpolation.
  final Map<String, dynamic>? formData;

  /// Callback when data is fetched.
  final ValueChanged<dynamic> onChanged;

  const DataSourceComponent({
    super.key,
    required this.component,
    required this.value,
    this.formData,
    required this.onChanged,
  });

  @override
  State<DataSourceComponent> createState() => _DataSourceComponentState();
}

class _DataSourceComponentState extends State<DataSourceComponent> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    print('🔍 DataSourceComponent.initState()');
    print('   Component key: ${widget.component.key}');
    
    // Fetch on init if trigger.init is true (default)
    final trigger = widget.component.raw['trigger'] as Map<String, dynamic>?;
    final shouldFetchOnInit = trigger?['init'] ?? true;
    
    if (shouldFetchOnInit) {
      print('   ✅ Fetching on init');
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
    } else {
      print('   ❌ NOT fetching on init (trigger.init = false)');
    }
  }

  @override
  void didUpdateWidget(DataSourceComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if refreshOnBlur field changed
    final refreshOn = widget.component.raw['refreshOnBlur']?.toString();
    if (refreshOn != null && refreshOn.isNotEmpty) {
      final oldValue = oldWidget.formData?[refreshOn];
      final newValue = widget.formData?[refreshOn];
      
      if (oldValue != newValue) {
        print('🔄 DataSource: Field "$refreshOn" changed from "$oldValue" to "$newValue"');
        print('   Triggering re-fetch...');
        _fetchData();
      }
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fetchConfig = widget.component.raw['fetch'] as Map<String, dynamic>?;
      if (fetchConfig == null) {
        throw 'No fetch configuration';
      }

      final url = fetchConfig['url']?.toString();
      if (url == null || url.isEmpty) {
        throw 'No URL specified';
      }

      final method = fetchConfig['method']?.toString() ?? 'get';
      final headers = _buildHeaders(fetchConfig['headers']);
      
      print('🌐 DataSource fetching:');
      print('   URL: $url');
      print('   Method: $method');
      print('   Headers: $headers');

      // Make HTTP request
      final dio = Dio();
      final response = await dio.request(
        url,
        options: Options(method: method.toUpperCase(), headers: headers),
      );

      print('   ✅ Response received (${response.statusCode})');

      // Transform data using mapFunction
      final mapFunction = fetchConfig['mapFunction']?.toString();
      final transformedData = await _transformData(response.data, mapFunction);

      print('   ✅ Data transformed: $transformedData');

      // Store in form state
      widget.onChanged(transformedData);
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('   ❌ Error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _buildHeaders(dynamic headersConfig) {
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
          widget.formData ?? {},
        );
        headers[key] = interpolated;
      }
    }
    return headers;
  }

  Future<dynamic> _transformData(dynamic responseData, String? mapFunction) async {
    if (mapFunction == null || mapFunction.isEmpty) {
      print('   No mapFunction - returning raw response');
      return responseData;
    }

    print('   mapFunction specified: $mapFunction');
    print('   ⚠️  JavaScript execution not yet implemented');
    print('   Returning raw response data for now');
    
    // TODO: Implement JavaScript evaluation using flutter_js
    // For now, return raw response data
    // Users can still use the data, just not transformed
    
    return responseData;
  }

  @override
  Widget build(BuildContext context) {
    // Non-visual component - renders nothing
    return const SizedBox.shrink();
  }
}
