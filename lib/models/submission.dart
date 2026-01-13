/// A data model representing a submission instance in Form.io.
///
/// Submissions are the actual form data submitted by users, along with metadata
/// such as IDs, timestamps, and user info.
library;

class SubmissionModel {
  /// Unique identifier of the submission in Form.io.
  final String? id;

  /// The actual form data submitted by the user.
  final Map<String, dynamic> data;

  /// Timestamp of when the submission was created.
  final DateTime? created;

  /// Timestamp of last modification, if applicable.
  final DateTime? modified;

  /// ID of the user who created this submission, if authenticated.
  final String? owner;

  SubmissionModel({this.id, required this.data, this.created, this.modified, this.owner});

  /// Creates a [SubmissionModel] from Form.io JSON response.
  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['_id'] as String?,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      created: json['created'] != null ? DateTime.tryParse(json['created']) : null,
      modified: json['modified'] != null ? DateTime.tryParse(json['modified']) : null,
      owner: json['owner'] as String?,
    );
  }

  /// Converts the model into JSON for POST requests.
  Map<String, dynamic> toJson() {
    return {'data': data};
  }
}
