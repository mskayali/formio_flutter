/// Service class for interacting with Form.io form endpoints.
///
/// Provides methods to fetch form definitions from the Form.io backend,
/// either as a list of available forms or a single form by its path or ID.
library;

import 'package:dio/dio.dart';
// Flutter dependency removed

import 'package:formio_api/src/models/form.dart';
import 'package:formio_api/src/network/api_client.dart';

class FormService {
  /// An instance of the API client to make HTTP requests.
  final ApiClient client;

  /// Constructs a [FormService] using the provided [ApiClient].
  FormService(this.client);

  /// Fetches all available forms from the Form.io backend.
  ///
  /// Makes a `GET /form` request.
  ///
  /// Returns a list of [FormModel] objects.
  ///
  /// Throws [DioException] on failure.
  Future<List<FormModel>> fetchForms() async {
    try {
      final response = await client.dio.get('/form');
      if (response.data is List<dynamic>) {
        final data = response.data as List<dynamic>;
        return data.map((json) => FormModel.fromJson(json as Map<String, dynamic>)).toList();
      }

      // handle response
    } on DioException catch (e) {
      // print('DioException occurred:');
      // print('Type: ${e.type}');
      // print('Message: ${e.message}');
      // print('Request: ${e.requestOptions.method} ${e.requestOptions.uri}');
      if (e.response != null) {
        // print('Status code: ${e.response?.statusCode}');
        // print('Data: ${e.response?.data}');
        // print('Headers: ${e.response?.headers}');
      } else {
        // print('Underlying error: ${e.error}');
      }
    } catch (e) {
      // print('Other exception: $e');
    }
    throw 'Failed to fetch forms';
  }

  /// Fetches a single form using its path or ID from Form.io.
  ///
  /// Makes a `GET /form/:pathOrId` request.
  ///
  /// [pathOrId] can be either the `path` of the form (recommended) or its `_id`.
  ///
  /// Returns a [FormModel] object.
  ///
  /// Throws [DioException] on failure.
  Future<FormModel> getFormByPath(String pathOrId) async {
    final response = await client.dio.get('/form/$pathOrId');
    return FormModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Creates a new form in the Form.io project.
  ///
  /// Makes a `POST /form` request.
  ///
  /// [form] is the FormModel containing form definition.
  ///
  /// Returns the created [FormModel] with server-generated ID.
  ///
  /// Throws [DioException] on failure.
  Future<FormModel> createForm(FormModel form) async {
    final response = await client.dio.post('/form', data: form.toJson());
    return FormModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Updates an existing form.
  ///
  /// Makes a `PUT /form/:formId` request.
  ///
  /// [formId] is the unique ID of the form to update.
  /// [form] is the FormModel with updated data.
  ///
  /// Returns the updated [FormModel].
  ///
  /// Throws [DioException] on failure.
  Future<FormModel> updateForm(String formId, FormModel form) async {
    final response = await client.dio.put('/form/$formId', data: form.toJson());
    return FormModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Deletes a form from the Form.io project.
  ///
  /// Makes a `DELETE /form/:formId` request.
  ///
  /// [formId] is the unique ID of the form to delete.
  ///
  /// Throws [DioException] on failure.
  Future<void> deleteForm(String formId) async {
    await client.dio.delete('/form/$formId');
  }

  /// Fetches submissions from a resource (form) by ID.
  ///
  /// Used for populating select component options from other forms/resources.
  /// Makes a `GET /form/:resourceId/submission` request.
  ///
  /// [resourceId] is the unique ID of the source form/resource.
  /// [limit] optional parameter to limit number of results (default: 100).
  /// [skip] optional parameter for pagination offset (default: 0).
  ///
  /// Returns a list of submission data maps.
  ///
  /// Example:
  /// ```dart
  /// final submissions = await formService.fetchResourceSubmissions('662fa9be1e8aa19b582626f7');
  /// ```
  ///
  /// Throws [DioException] on failure.
  Future<List<Map<String, dynamic>>> fetchResourceSubmissions(
    String resourceId, {
    int limit = 100,
    int skip = 0,
  }) async {
    final response = await client.dio.get(
      '/form/$resourceId/submission',
      queryParameters: {
        'limit': limit,
        'skip': skip,
      },
    );

    if (response.data is List<dynamic>) {
      return List<Map<String, dynamic>>.from(
        response.data.map((item) => item as Map<String, dynamic>),
      );
    }

    return [];
  }
}
