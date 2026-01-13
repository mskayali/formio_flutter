/// Type definitions for FormIO Flutter package callbacks.
library;

import 'package:flutter/material.dart';
import 'package:formio/flutter_formio.dart';
import 'package:formio_api/formio_api.dart' show FileData;


/// Callback type for custom file picker implementations.
///
/// Users of the formio_flutter package should implement this callback
/// to provide their own file picking logic (e.g., using file_picker, image_picker, etc.)
///
/// Parameters:
/// - [allowMultiple]: Whether multiple file selection is allowed
/// - [allowedExtensions]: Optional list of allowed file extensions (without dots, e.g., ['jpg', 'png', 'pdf'])
///
/// Returns a Future that resolves to:
/// - A list of [FileData] objects if files were selected
/// - null if the user cancelled the picker
///
/// Example implementation:
/// ```dart
/// Future<List<FileData>?> myFilePicker({
///   required bool allowMultiple,
///   List<String>? allowedExtensions,
/// }) async {
///   final result = await FilePicker.platform.pickFiles(
///     allowMultiple: allowMultiple,
///     type: allowedExtensions != null ? FileType.custom : FileType.any,
///     allowedExtensions: allowedExtensions,
///   );
///
///   if (result != null) {
///     return result.files.map((file) => FileData(
///       name: file.name,
///       bytes: file.bytes,
///       path: file.path,
///     )).toList();
///   }
///   return null;
/// }
/// ```
typedef FilePickerCallback = Future<List<FileData>?> Function({
  required bool allowMultiple,
  List<String>? allowedExtensions,
});

/// Callback invoked when file value changes.
///
/// Parameters:
/// - [files]: The new list of selected files
typedef OnFileChanged = void Function(List<FileData> files);

/// Callback for fetching data from external sources (APIs, databases, etc.)
///
/// This allows the package user to implement their own data fetching logic
/// for DataSource components without forcing a specific HTTP client dependency.
///
/// Parameters:
/// - [url]: The URL or endpoint to fetch data from
/// - [method]: HTTP method (GET, POST, etc.)
/// - [headers]: Optional map of headers to include in the request
/// - [body]: Optional request body for POST/PUT requests
///
/// Returns:
/// - A Future that resolves to the fetched data (typically Map or List)
///
/// Example implementation:
/// ```dart
/// Future<dynamic> myDataFetcher({
///   required String url,
///   required String method,
///   Map<String, String>? headers,
///   dynamic body,
/// }) async {
///   final response = await http.get(Uri.parse(url), headers: headers);
///   if (response.statusCode == 200) {
///     return json.decode(response.body);
///   }
///   throw Exception('Failed to fetch data');
/// }
/// ```
typedef DataSourceCallback = Future<dynamic> Function({
  required String url,
  required String method,
  Map<String, String>? headers,
  dynamic body,
});

/// Callback for custom date picker implementations.
///
/// Allows users to provide their own date picker widget instead of
/// using Flutter's default showDatePicker.
///
/// Parameters:
/// - [initialDate]: The initially selected date
/// - [firstDate]: The earliest selectable date
/// - [lastDate]: The latest selectable date
///
/// Returns:
/// - A Future that resolves to the selected DateTime
/// - null if the user cancelled
///
/// Example implementation:
/// ```dart
/// Future<DateTime?> myDatePicker({
///   required DateTime initialDate,
///   required DateTime firstDate,
///   required DateTime lastDate,
/// }) async {
///   return await showCustomDatePicker(
///     context: context,
///     initialDate: initialDate,
///     firstDate: firstDate,
///     lastDate: lastDate,
///   );
/// }
/// ```
typedef DatePickerCallback = Future<DateTime?> Function({
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
});

/// Callback for custom time picker implementations.
///
/// Allows users to provide their own time picker widget instead of
/// using Flutter's default showTimePicker.
///
/// Parameters:
/// - [initialTime]: The initially selected time
///
/// Returns:
/// - A Future that resolves to the selected TimeOfDay
/// - null if the user cancelled
///
/// Example implementation:
/// ```dart
/// Future<TimeOfDay?> myTimePicker({
///   required TimeOfDay initialTime,
/// }) async {
///   return await showCustomTimePicker(
///     context: context,
///     initialTime: initialTime,
///   );
/// }
/// ```
typedef TimePickerCallback = Future<TimeOfDay?> Function({
  required TimeOfDay initialTime,
});

/// Callback for custom date-time picker implementations.
///
/// Combines date and time selection in a single callback.
///
/// Parameters:
/// - [initialDateTime]: The initially selected date and time
/// - [firstDate]: The earliest selectable date
/// - [lastDate]: The latest selectable date
///
/// Returns:
/// - A Future that resolves to the selected DateTime
/// - null if the user cancelled
typedef DateTimePickerCallback = Future<DateTime?> Function({
  required DateTime initialDateTime,
  required DateTime firstDate,
  required DateTime lastDate,
});
