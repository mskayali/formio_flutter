/// Service class for managing user operations with Form.io.
///
/// Handles user CRUD operations, distinct from authentication.
/// Use AuthService for login/register/logout operations.

import '../models/user.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';

class UserService {
  /// API client used to perform HTTP operations.
  final ApiClient client;

  /// Constructs a [UserService] using the provided [ApiClient].
  UserService(this.client);

  /// Gets a specific user by ID.
  ///
  /// Makes a `GET /user/:userId` request.
  ///
  /// Returns the [UserModel].
  ///
  /// Throws [DioError] on failure.
  Future<UserModel> getUser(String userId) async {
    final response = await client.dio.get(ApiEndpoints.getUser(userId));
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Lists all users in the project.
  ///
  /// Makes a `GET /user` request.
  ///
  /// [limit] maximum number of users to return.
  /// [skip] number of users to skip (for pagination).
  ///  
  /// Returns a list of [UserModel] objects.
  ///
  /// Throws [DioError] on failure.
  Future<List<UserModel>> listUsers({int? limit, int? skip}) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (skip != null) queryParams['skip'] = skip;

    final response = await client.dio.get(
      ApiEndpoints.listUsers,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.data is List) {
      return (response.data as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Updates a user's profile.
  ///
  /// Makes a `PUT /user/:userId` request.
  ///
  /// [userId] is the ID of the user to update.
  /// [user] contains the updated user data.
  ///
  /// Returns the updated [UserModel].
  ///
  /// Throws [DioError] on failure.
  Future<UserModel> updateUser(String userId, UserModel user) async {
    final response = await client.dio.put(
      ApiEndpoints.updateUser(userId),
      data: user.toUpdateJson(),
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Deletes a user.
  ///
  /// Makes a `DELETE /user/:userId` request.
  ///
  /// [userId] is the ID of the user to delete.
  ///
  /// Throws [DioError] on failure.
  Future<void> deleteUser(String userId) async {
    await client.dio.delete(ApiEndpoints.deleteUser(userId));
  }

  /// Checks if a user with the given email exists.
  ///
  /// Makes a `GET /user/exists?email=` request.
  ///
  /// [email] is the email address to check.
  ///
  /// Returns true if the user exists, false otherwise.
  ///
  /// Throws [DioError] on failure.
  Future<bool> userExists(String email) async {
    try {
      final response = await client.dio.get(ApiEndpoints.userExists(email));
      // The API typically returns the user object if exists, or null/error if not
      return response.data != null;
    } catch (e) {
      // If we get a 404 or similar, user doesn't exist
      return false;
    }
  }
}
