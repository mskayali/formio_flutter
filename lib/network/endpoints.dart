/// Centralized API endpoint definitions for Form.io operations.
///
/// These helper functions and constants provide consistent paths
/// for use in services such as FormService, SubmissionService, etc.

class ApiEndpoints {
  // ============================================================================
  // FORM ENDPOINTS
  // ============================================================================
  
  /// Returns the path to list all forms
  /// Example: `/form`
  static const String listForms = '/form';
  
  /// Returns the full path to fetch a form schema.
  /// Example: `/registration`
  static String getForm(String path) => '$path';
  
  /// Returns the path to create a new form
  /// Example: `/form`
  static const String createForm = '/form';
  
  /// Returns the path to update a form
  /// Example: `/form/formId`
  static String updateForm(String formId) => '/form/$formId';
  
  /// Returns the path to delete a form
  /// Example: `/form/formId`
  static String deleteForm(String formId) => '/form/$formId';

  // ============================================================================
  // SUBMISSION ENDPOINTS
  // ============================================================================

  /// Returns the path to list all submissions for a form
  /// Example: `/registration/submission`
  static String listSubmissions(String formPath) {
    final path = formPath.startsWith('/') ? formPath : '/$formPath';
    return '$path/submission';
  }

  /// Returns the path to create a new submission.
  /// Example: `/registration/submission`
  static String postSubmission(String formPath) {
    final path = formPath.startsWith('/') ? formPath : '/$formPath';
    return '$path/submission';
  }

  /// Returns the path to fetch a specific submission.
  /// Example: `/registration/submission/submissionId`
  static String getSubmissionById(String formPath, String id) {
    final path = formPath.startsWith('/') ? formPath : '/$formPath';
    return '$path/submission/$id';
  }
  
  /// Returns the path to update a submission
  /// Example: `/registration/submission/submissionId`
  static String updateSubmission(String formPath, String id) {
    final path = formPath.startsWith('/') ? formPath : '/$formPath';
    return '$path/submission/$id';
  }
  
  /// Returns the path to partially update a submission
  /// Example: `/registration/submission/submissionId`
  static String patchSubmission(String formPath, String id) {
    final path = formPath.startsWith('/') ? formPath : '/$formPath';
    return '$path/submission/$id';
  }
  
  /// Returns the path to delete a submission
  /// Example: `/registration/submission/submissionId`
  static String deleteSubmission(String formPath, String id) {
    final path = formPath.startsWith('/') ? formPath : '/$formPath';
    return '$path/submission/$id';
  }

  // ============================================================================
  // USER/AUTHENTICATION ENDPOINTS
  // ============================================================================

  /// Returns the login endpoint (if using Form.io authentication).
  static const String login = '/user/login';

  /// Returns the registration endpoint.
  static const String register = '/user/register';

  /// Returns the current user profile endpoint.
  static const String currentUser = '/current';

  /// Returns the logout endpoint
  static const String logout = '/user/logout';
  
  /// Returns the path to list all users
  static const String listUsers = '/user';
  
  /// Returns the path to get a specific user
  /// Example: `/user/userId`
  static String getUser(String userId) => '/user/$userId';
  
  /// Returns the path to update a user
  /// Example: `/user/userId`
  static String updateUser(String userId) => '/user/$userId';
  
  /// Returns the path to delete a user
  /// Example: `/user/userId`
  static String deleteUser(String userId) => '/user/$userId';
  
  /// Returns the path to check if a user exists by email
  /// Example: `/user/exists?email=test@example.com`
  static String userExists(String email) => '/user/exists?email=${Uri.encodeComponent(email)}';

  // ============================================================================
  // ACTION ENDPOINTS
  // ============================================================================
  
  /// Returns the path to list all actions for a form
  /// Example: `/form/formId/action`
  static String listActions(String formId) => '/form/$formId/action';
  
  /// Returns the path to create a new action for a form
  /// Example: `/form/formId/action`
  static String createAction(String formId) => '/form/$formId/action';
  
  /// Returns the path to get a specific action
  /// Example: `/form/formId/action/actionId`
  static String getAction(String formId, String actionId) => '/form/$formId/action/$actionId';
  
  /// Returns the path to update an action
  /// Example: `/form/formId/action/actionId`
  static String updateAction(String formId, String actionId) => '/form/$formId/action/$actionId';
  
  /// Returns the path to delete an action
  /// Example: `/form/formId/action/actionId`
  static String deleteAction(String formId, String actionId) => '/form/$formId/action/$actionId';

  // ============================================================================
  // ROLE ENDPOINTS
  // ============================================================================
  
  /// Returns the path to list all roles
  static const String listRoles = '/role';
  
  /// Returns the path to get a specific role
  /// Example: `/role/roleId`
  static String getRole(String roleId) => '/role/$roleId';
  
  /// Returns the path to create a new role
  static const String createRole = '/role';
  
  /// Returns the path to update a role
  /// Example: `/role/roleId`
  static String updateRole(String roleId) => '/role/$roleId';
  
  /// Returns the path to delete a role
  /// Example: `/role/roleId`
  static String deleteRole(String roleId) => '/role/$roleId';

  // ============================================================================
  // PROJECT ENDPOINTS
  // ============================================================================

  /// Returns a path to fetch project or form-level configuration.
  static const String projectConfig = '/project';
}

