/// A service for managing form submissions with Form.io's API.
///
/// Supports creating new submissions and optionally fetching existing ones
/// using the REST endpoints `/form/:path/submission`.
library;

import 'package:formio_api/src/core/exceptions.dart';
import 'package:formio_api/src/models/submission.dart';
import 'package:formio_api/src/network/api_client.dart';
import 'package:formio_api/src/network/endpoints.dart';

class SubmissionService {
  /// API client used to make HTTP requests.
  final ApiClient client;

  SubmissionService(this.client);

  /// Checks if a map value represents a "leaf" field value (like selectboxes,
  /// survey responses, etc.) rather than a nested container.
  ///
  /// SelectBoxes values typically have:
  /// - Short keys (often numeric like "1", "2", "5" or short identifiers)
  /// - All boolean values
  ///
  /// Panel/container maps typically have:
  /// - Long field name keys (like "panelPanelBaHarfler")
  /// - Mixed value types (strings, numbers, dates, etc.)
  bool _isLeafMap(Map<String, dynamic> map) {
    // Empty maps are considered leaf values
    if (map.isEmpty) return true;

    // Check if any value is a nested map (definitely a container)
    for (final value in map.values) {
      if (value is Map) {
        return false;
      }
    }

    // Check if this looks like a selectboxes value:
    // - All values are booleans
    // - Keys are short (typically option indices like "1", "2", "5")
    bool allBooleanValues = true;
    bool hasShortKeys = true;
    const maxLeafKeyLength = 10; // SelectBoxes keys are usually short

    for (final entry in map.entries) {
      if (entry.value is! bool) {
        allBooleanValues = false;
      }
      if (entry.key.length > maxLeafKeyLength) {
        hasShortKeys = false;
      }
    }

    // If all values are booleans with short keys, this is likely a selectboxes value
    if (allBooleanValues && hasShortKeys) {
      return true;
    }

    // Otherwise, this is likely a panel/container with form field values
    // that should be flattened
    return false;
  }

  /// Flattens nested form data to the format expected by Form.io.
  ///
  /// Form.io expects all field values at the root level of the 'data' object,
  /// not nested inside container components (panels, columns, fieldsets, etc.).
  ///
  /// This method recursively walks through the nested structure and extracts
  /// all leaf values to the root level, while preserving actual field values
  /// that happen to be maps (like selectboxes, survey components).
  Map<String, dynamic> _flattenData(Map<String, dynamic> data) {
    final flattened = <String, dynamic>{};

    void flatten(Map<String, dynamic> map) {
      for (final entry in map.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is Map<String, dynamic>) {
          if (_isLeafMap(value)) {
            // This is a field value (selectboxes, survey, etc.) - preserve it
            flattened[key] = value;
          } else {
            // This is a container (panel, columns, etc.) - flatten its contents
            flatten(value);
          }
        } else {
          // Primitive value - add directly to flattened map
          flattened[key] = value;
        }
      }
    }

    flatten(data);
    return flattened;
  }

  /// Sends a new form submission to the given form path.
  ///
  /// [formPath] is the full path to the form (e.g. '/registration')
  /// [data] is the map of form field values (can be nested from panels/columns).
  ///
  /// The data is automatically flattened to match Form.io's expected format
  /// where all field values are at the root level.
  ///
  /// Throws [SubmissionException] on error.
  Future<SubmissionModel> submit(String formPath, Map<String, dynamic> data) async {
    try {
      final url = ApiEndpoints.postSubmission(formPath);
      // Flatten nested data and add required Form.io fields
      final flattenedData = _flattenData(data);
      flattenedData['submit'] = true;

      final response = await client.dio.post(
        url,
        data: {
          'data': flattenedData,
          'state': 'submitted',
        },
      );
      return SubmissionModel.fromJson(response.data ?? {});
    } catch (e) {
      throw SubmissionException('Failed to submit form: $e');
    }
  }

  /// (Optional) Fetches a submission by its ID under a form.
  ///
  /// Useful for edit/view workflows.
  Future<SubmissionModel> fetchById(String formPath, String submissionId) async {
    try {
      final url = ApiEndpoints.getSubmissionById(formPath, submissionId);
      final response = await client.dio.get(url);
      return SubmissionModel.fromJson(response.data ?? {});
    } catch (e) {
      throw SubmissionException('Failed to fetch submission: $e');
    }
  }

  /// Lists all submissions for a given form.
  ///
  /// [formPath] is the full path to the form (e.g. '/registration').
  /// [limit] maximum number of submissions to return.
  /// [skip] number of submissions to skip (for pagination).
  /// [sort] field to sort by (prefix with - for descending, e.g. '-created').
  /// [filter] query parameters for filtering submissions.
  ///
  /// Throws [SubmissionException] on error.
  Future<List<SubmissionModel>> listSubmissions(
    String formPath, {
    int? limit,
    int? skip,
    String? sort,
    Map<String, dynamic>? filter,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (skip != null) queryParams['skip'] = skip;
      if (sort != null) queryParams['sort'] = sort;
      if (filter != null) queryParams.addAll(filter);

      final url = ApiEndpoints.listSubmissions(formPath);
      final response = await client.dio.get(
        url,
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return (response.data as List).map((json) => SubmissionModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw SubmissionException('Failed to list submissions: $e');
    }
  }

  /// Updates an existing submission (full replace).
  ///
  /// [formPath] is the full path to the form.
  /// [submissionId] is the ID of the submission to update.
  /// [data] is the complete updated form data.
  ///
  /// Throws [SubmissionException] on error.
  Future<SubmissionModel> updateSubmission(
    String formPath,
    String submissionId,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = ApiEndpoints.updateSubmission(formPath, submissionId);
      final response = await client.dio.put(
        url,
        data: {'data': data},
      );
      return SubmissionModel.fromJson(response.data ?? {});
    } catch (e) {
      throw SubmissionException('Failed to update submission: $e');
    }
  }

  /// Partially updates a submission (PATCH).
  ///
  /// [formPath] is the full path to the form.
  /// [submissionId] is the ID of the submission to update.
  /// [data] contains only the fields to update.
  ///
  /// Throws [SubmissionException] on error.
  Future<SubmissionModel> patchSubmission(
    String formPath,
    String submissionId,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = ApiEndpoints.patchSubmission(formPath, submissionId);
      final response = await client.dio.patch(
        url,
        data: {'data': data},
      );
      return SubmissionModel.fromJson(response.data ?? {});
    } catch (e) {
      throw SubmissionException('Failed to patch submission: $e');
    }
  }

  /// Deletes a submission.
  ///
  /// [formPath] is the full path to the form.
  /// [submissionId] is the ID of the submission to delete.
  ///
  /// Throws [SubmissionException] on error.
  Future<void> deleteSubmission(String formPath, String submissionId) async {
    try {
      final url = ApiEndpoints.deleteSubmission(formPath, submissionId);
      await client.dio.delete(url);
    } catch (e) {
      throw SubmissionException('Failed to delete submission: $e');
    }
  }
}
