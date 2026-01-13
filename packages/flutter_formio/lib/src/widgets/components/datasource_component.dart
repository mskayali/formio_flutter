/// A non-visual Flutter component that fetches data from external URLs.
///
/// The DataSource component makes HTTP requests to external APIs and stores
/// the result in form state for use by other components. It supports:
/// - HTTP GET/POST/PUT/DELETE requests
/// - Custom headers with form data interpolation
/// - JavaScript transformation of responses via mapFunction
/// - Reactive updates when trigger fields change
library;

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

  @override
  void initState() {
    super.initState();
    
    // print('🔍 DataSourceComponent.initState()');
    // print('   Component key: ${widget.component.key}');
    
    // Fetch on init if trigger.init is true (default)
    final trigger = widget.component.raw['trigger'] as Map<String, dynamic>?;
    final shouldFetchOnInit = trigger?['init'] ?? true;
    
    if (shouldFetchOnInit) {
      // print('   ✅ Fetching on init');
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
    } else {
      // print('   ❌ NOT fetching on init (trigger.init = false)');
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
        // print('🔄 DataSource: Field "$refreshOn" changed from "$oldValue" to "$newValue"');
        // print('   Triggering re-fetch...');
        _fetchData();
      }
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      // IsLoading state could be handled here if we add visual feedback
    });

    try {
      final fetchConfig = widget.component.raw['fetch'] as Map<String, dynamic>?;
      if (fetchConfig == null) {
        throw 'No fetch configuration';
      }

      // Delegate fetching to formio_api service
      final transformedData = await DataSourceService.fetchData(
        fetchConfig: fetchConfig,
        formData: widget.formData ?? {},
      );

      // Store in form state
      widget.onChanged(transformedData);
      
    } catch (e) {
      // print('   ❌ Error: $e');
      setState(() {
        // Handle error state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Non-visual component - renders nothing
    return const SizedBox.shrink();
  }
}
