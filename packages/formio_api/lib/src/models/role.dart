/// Model representing a Form.io Role.
///
/// Roles are used for permission management and access control within
/// Form.io projects. Each role can be assigned to users and define
/// permissions for accessing forms, submissions, and resources.
library;

class RoleModel {
  /// Unique identifier of the role.
  final String? id;

  /// Display title of the role.
  final String title;

  /// Description of the role's purpose and permissions.
  final String? description;

  /// Whether this is the default role assigned to new users.
  final bool isDefault;

  /// Whether this role has administrative privileges.
  final bool admin;

  /// Timestamp of when the role was created.
  final DateTime? created;

  /// Timestamp of when the role was last modified.
  final DateTime? modified;

  RoleModel({
    this.id,
    required this.title,
    this.description,
    this.isDefault = false,
    this.admin = false,
    this.created,
    this.modified,
  });

  /// Creates a RoleModel from Form.io JSON response.
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['_id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      isDefault: json['default'] as bool? ?? false,
      admin: json['admin'] as bool? ?? false,
      created: json['created'] != null ? DateTime.tryParse(json['created']) : null,
      modified: json['modified'] != null ? DateTime.tryParse(json['modified']) : null,
    );
  }

  /// Converts the RoleModel to JSON for API requests.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,
      'default': isDefault,
      'admin': admin,
    };

    if (id != null) {
      json['_id'] = id!;
    }

    if (description != null) {
      json['description'] = description!;
    }

    return json;
  }

  @override
  String toString() => 'RoleModel(id: $id, title: $title, admin: $admin, default: $isDefault)';
}
