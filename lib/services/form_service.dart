/// Service class for interacting with Form.io form endpoints.
///
/// Provides methods to fetch form definitions from the Form.io backend,
/// either as a list of available forms or a single form by its path or ID.

import 'package:dio/dio.dart';

import '../models/form.dart';
import '../network/api_client.dart';

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
  /// Throws [DioError] on failure.
  Future<List<FormModel>> fetchForms() async {
    try {
      final response = await client.dio.get('/form');
      if (response.data is List<dynamic>) {
        final data = response.data as List<dynamic>;
        return data.map((json) => FormModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      // handle response
    } on DioException catch (e) {
      print('DioException occurred:');
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Request: ${e.requestOptions.method} ${e.requestOptions.uri}');
      if (e.response != null) {
        print('Status code: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
        print('Headers: ${e.response?.headers}');
      } else {
        print('Underlying error: ${e.error}');
      }
    } catch (e) {
      print('Other exception: $e');
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
  /// Throws [DioError] on failure.
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
  /// Throws [DioError] on failure.
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
  /// Throws [DioError] on failure.
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
  /// Throws [DioError] on failure.
  Future<void> deleteForm(String formId) async {
    await client.dio.delete('/form/$formId');
  }
}
