/// Represents a user in the Form.io system, primarily for authentication.
///
/// This model is used for logging in, storing user credentials, and
/// handling JWT tokens returned from the Form.io authentication endpoint.
library;

class UserModel {
  /// Unique ID of the user (if available).
  final String? id;

  /// User's email address used for login.
  final String? email;

  /// User's password used for login/registration.
  /// Note: This field is typically null when fetching user data.
  final String? password;

  /// JWT token issued upon successful authentication.
  final String? token;

  /// User's data fields (custom form fields from user resource form).
  final Map<String, dynamic>? data;

  /// List of role IDs assigned to this user.
  final List<String>? roles;

  /// Timestamp of when the user was created.
  final DateTime? created;

  /// Timestamp of when the user was last modified.
  final DateTime? modified;

  /// Constructs a [UserModel] instance for login or authentication tracking.
  UserModel({
    this.id,
    this.email,
    this.password,
    this.token,
    this.data,
    this.roles,
    this.created,
    this.modified,
  });

  /// Converts the user credentials into a JSON-compatible map for login.
  ///
  /// Only email and password are included in this request body.
  ///
  /// Example:
  /// ```json
  /// {
  ///   "data": {
  ///     "email": "john@example.com",
  ///     "password": "secure123"
  ///   }
  /// }
  /// ```
  Map<String, dynamic> toLoginJson() {
    return {
      'data': {
        'email': email,
        'password': password,
      },
    };
  }

  /// Converts the user data into JSON for registration.
  ///
  /// Includes email, password, and any additional data fields.
  Map<String, dynamic> toRegisterJson() {
    final registerData = <String, dynamic>{
      'email': email,
      'password': password,
    };

    // Merge additional data fields if present
    if (data != null) {
      registerData.addAll(data!);
    }

    return {
      'data': registerData,
    };
  }

  /// Converts user data to JSON for update operations.
  ///
  /// Excludes password (use separate password change endpoint).
  Map<String, dynamic> toUpdateJson() {
    final updateData = <String, dynamic>{};

    if (email != null) {
      updateData['email'] = email;
    }

    // Merge additional data fields if present
    if (data != null) {
      updateData.addAll(data!);
    }

    return {
      'data': updateData,
    };
  }

  /// Creates a [UserModel] from a JSON response, usually from the auth API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both direct user object and nested under 'data'
    final userData = json['data'] ?? json;

    return UserModel(
      id: json['_id'] as String?,
      email: userData['email'] as String?,
      token: json['token'] as String?,
      data: userData is Map<String, dynamic> ? Map<String, dynamic>.from(userData) : null,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      created: json['created'] != null ? DateTime.tryParse(json['created']) : null,
      modified: json['modified'] != null ? DateTime.tryParse(json['modified']) : null,
    );
  }

  /// Converts the full user model to JSON.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (id != null) json['_id'] = id;
    if (token != null) json['token'] = token;
    if (roles != null) json['roles'] = roles;
    if (created != null) json['created'] = created!.toIso8601String();
    if (modified != null) json['modified'] = modified!.toIso8601String();

    final userData = <String, dynamic>{};
    if (email != null) userData['email'] = email;
    if (data != null) userData.addAll(data!);

    json['data'] = userData;

    return json;
  }

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, roles: $roles, created: $created)';
}

