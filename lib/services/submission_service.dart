/// A service for managing form submissions with Form.io's API.
///
/// Supports creating new submissions and optionally fetching existing ones
/// using the REST endpoints `/form/:path/submission`.

import '../core/exceptions.dart';
import '../models/submission.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';

class SubmissionService {
  /// API client used to make HTTP requests.
  final ApiClient client;

  SubmissionService(this.client);

  /// Sends a new form submission to the given form path.
  ///
  /// [formPath] is the full path to the form (e.g. '/registration')
  /// [data] is the map of form field values.
  ///
  /// Throws [SubmissionException] on error.
  Future<SubmissionModel> submit(String formPath, Map<String, dynamic> data) async {
    try {
      final url = ApiEndpoints.postSubmission(formPath);
      final response = await client.dio.post(url, data: {'data': data});
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
        return (response.data as List)
            .map((json) => SubmissionModel.fromJson(json as Map<String, dynamic>))
            .toList();
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
