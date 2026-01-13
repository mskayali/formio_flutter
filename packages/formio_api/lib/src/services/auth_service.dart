/// Service class for authenticating users against the Form.io API.
///
/// Handles login operations and token retrieval for secure communication
/// with protected Form.io endpoints.
library;

import 'package:formio_api/src/models/user.dart';
import 'package:formio_api/src/network/api_client.dart';

class AuthService {
  /// An instance of the API client to perform HTTP operations.
  final ApiClient client;

  /// Constructs an [AuthService] using the provided [ApiClient].
  AuthService(this.client);

  /// Logs a user in to the Form.io project.
  ///
  /// Sends a `POST /user/login` request with the user's email and password.
  ///
  /// On success, returns a [UserModel] with the JWT token and user ID populated.
  ///
  /// Example:
  /// ```dart
  /// final user = UserModel(email: 'test@example.com', password: '1234');
  /// final response = await authService.login(user);
  /// ```
  ///
  /// Throws [DioError] on failure (invalid credentials, server error, etc).
  Future<UserModel> login(UserModel credentials) async {
    final response = await client.dio.post('/user/login', data: credentials.toLoginJson());
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Registers a new user account.
  ///
  /// Sends a `POST /user/register` request with user information.
  ///
  /// [user] should contain email, password, and any additional registration fields.
  ///
  /// Returns the created [UserModel] with JWT token.
  ///
  /// Throws [DioError] on failure.
  Future<UserModel> register(UserModel user) async {
    final response = await client.dio.post('/user/register', data: user.toRegisterJson());
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Gets the currently authenticated user's profile.
  ///
  /// Sends a `GET /current` request (requires authentication token).
  ///
  /// Returns the current [UserModel].
  ///
  /// Throws [DioError] on failure.
  Future<UserModel> getCurrentUser() async {
    final response = await client.dio.get('/current');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Logs out the current user.
  ///
  /// Sends a `GET /user/logout` request.
  ///
  /// After logout, you should clear the auth token using `client.clearAuthToken()`.
  ///
  /// Throws [DioError] on failure.
  Future<void> logout() async {
    await client.dio.get('/user/logout');
  }
}
