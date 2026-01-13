/// Model class representing a Form.io form definition.
///
/// This class is used to deserialize the JSON structure of a Form.io form
/// and access its components, metadata, and path for submission.
library;

import 'component.dart';

class FormModel {
  /// Unique identifier of the form (_id in Form.io response).
  final String id;

  /// The submission path of the form (used in POST/GET requests).
  ///
  /// For example, a form with path "contact" is accessed at `/contact` and
  /// submissions are sent to `/contact/submission`.
  final String path;

  /// Title of the form.
  final String title;

  /// List of form components (fields, panels, etc.)
  final List<ComponentModel> components;

  /// Constructs a [FormModel] instance.
  FormModel({required this.id, required this.path, required this.title, required this.components});

  /// Factory constructor that creates a [FormModel] from a Form.io JSON response.
  ///
  /// Example input:
  /// ```json
  /// {
  ///   "_id": "form123",
  ///   "path": "contact",
  ///   "title": "Contact Form",
  ///   "components": [ ... ]
  /// }
  /// ```
  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      id: json['_id'] as String,
      path: json['path'] as String,
      title: json['title'] as String,
      components: (json['components'] as List<dynamic>).map((c) => ComponentModel.fromJson(c as Map<String, dynamic>)).toList(),
    );
  }

  /// Converts the [FormModel] into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {'_id': id, 'path': path, 'title': title, 'components': components.map((c) => c.toJson()).toList()};
  }
  @override
  String toString() {
    return  '$runtimeType: ${toJson()}';
  }
}
