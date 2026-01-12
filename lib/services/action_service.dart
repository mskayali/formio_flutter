/// Service class for managing Form.io actions.
///
/// Actions are event-triggered behaviors on forms such as sending emails,
/// calling webhooks, assigning roles, etc. This service provides CRUD
/// operations for managing these actions.

import '../models/action.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';

class ActionService {
  /// API client used to perform HTTP operations.
  final ApiClient client;

  /// Constructs an [ActionService] using the provided [ApiClient].
  ActionService(this.client);

  /// Lists all actions configured for a specific form.
  ///
  /// Makes a `GET /form/:formId/action` request.
  ///
  /// [formId] is the unique ID of the form.
  ///
  /// Returns a list of [ActionModel] objects.
  ///
  /// Throws [DioError] on failure.
  Future<List<ActionModel>> listActions(String formId) async {
    final response = await client.dio.get(ApiEndpoints.listActions(formId));

    if (response.data is List) {
      return (response.data as List)
          .map((json) => ActionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Gets a specific action by ID.
  ///
  /// Makes a `GET /form/:formId/action/:actionId` request.
  ///
  /// [formId] is the unique ID of the form.
  /// [actionId] is the unique ID of the action.
  ///
  /// Returns the [ActionModel].
  ///
  /// Throws [DioError] on failure.
  Future<ActionModel> getAction(String formId, String actionId) async {
    final response = await client.dio.get(
      ApiEndpoints.getAction(formId, actionId),
    );
    return ActionModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Creates a new action for a form.
  ///
  /// Makes a `POST /form/:formId/action` request.
  ///
  /// [formId] is the unique ID of the form.
  /// [action] is the ActionModel containing action configuration.
  ///
  /// Returns the created [ActionModel] with server-generated ID.
  ///
  /// Example:
  /// ```dart
  /// final emailAction = ActionModel(
  ///   title: 'Send Confirmation Email',
  ///   name: 'email',
  ///   handler: 'email',
  ///   method: ['create'],
  ///   settings: {
  ///     'to': '{{ data.email }}',
  ///     'from': 'noreply@example.com',
  ///     'subject': 'Thank you for your submission',
  ///     'message': 'We received your submission.',
  ///   },
  /// );
  /// final created = await actionService.createAction(formId, emailAction);
  /// ```
  ///
  /// Throws [DioError] on failure.
  Future<ActionModel> createAction(String formId, ActionModel action) async {
    final response = await client.dio.post(
      ApiEndpoints.createAction(formId),
      data: action.toJson(),
    );
    return ActionModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Updates an existing action.
  ///
  /// Makes a `PUT /form/:formId/action/:actionId` request.
  ///
  /// [formId] is the unique ID of the form.
  /// [actionId] is the unique ID of the action to update.
  /// [action] is the ActionModel with updated configuration.
  ///
  /// Returns the updated [ActionModel].
  ///
  /// Throws [DioError] on failure.
  Future<ActionModel> updateAction(
    String formId,
    String actionId,
    ActionModel action,
  ) async {
    final response = await client.dio.put(
      ApiEndpoints.updateAction(formId, actionId),
      data: action.toJson(),
    );
    return ActionModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Deletes an action from a form.
  ///
  /// Makes a `DELETE /form/:formId/action/:actionId` request.
  ///
  /// [formId] is the unique ID of the form.
  /// [actionId] is the unique ID of the action to delete.
  ///
  /// Throws [DioError] on failure.
  Future<void> deleteAction(String formId, String actionId) async {
    await client.dio.delete(ApiEndpoints.deleteAction(formId, actionId));
  }
}
