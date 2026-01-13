/// Model representing a Form.io Action.
///
/// Actions are automated behaviors triggered by form events such as
/// submission creation, updates, or deletions. Common action types include:
/// - Email notifications
/// - Webhooks
/// - Role assignments
/// - Save to database
/// - Login/Logout actions
library;

class ActionModel {
  /// Unique identifier of the action.
  final String? id;

  /// Display title of the action.
  final String title;

  /// Internal name/key of the action.
  final String name;

  /// The handler type for this action.
  /// Examples: 'email', 'webhook', 'role', 'save', 'login'
  final String handler;

  /// The event method that triggers this action.
  /// Examples: 'create', 'update', 'delete', 'read'
  final List<String> method;

  /// Priority order for execution (lower numbers execute first).
  final int priority;

  /// Whether this action is currently enabled.
  final bool enabled;

  /// Configuration settings specific to the handler type.
  /// For email: {to, from, subject, message, template}
  /// For webhook: {url, method, headers}
  /// For role: {role, type, association}
  final Map<String, dynamic> settings;

  /// Conditions that must be met for the action to execute.
  final Map<String, dynamic>? condition;

  ActionModel({
    this.id,
    required this.title,
    required this.name,
    required this.handler,
    required this.method,
    this.priority = 0,
    this.enabled = true,
    required this.settings,
    this.condition,
  });

  /// Creates an ActionModel from Form.io JSON response.
  factory ActionModel.fromJson(Map<String, dynamic> json) {
    return ActionModel(
      id: json['_id'] as String?,
      title: json['title'] as String? ?? '',
      name: json['name'] as String? ?? '',
      handler: json['handler'] as String? ?? '',
      method: (json['method'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      priority: json['priority'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? true,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      condition: json['condition'] != null ? Map<String, dynamic>.from(json['condition']) : null,
    );
  }

  /// Converts the ActionModel to JSON for API requests.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,
      'name': name,
      'handler': handler,
      'method': method,
      'priority': priority,
      'enabled': enabled,
      'settings': settings,
    };

    if (id != null) {
      json['_id'] = id!;
    }

    if (condition != null) {
      json['condition'] = condition!;
    }

    return json;
  }

  @override
  String toString() => 'ActionModel(id: $id, title: $title, handler: $handler, enabled: $enabled)';
}
