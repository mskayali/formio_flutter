/// Abstract localization interface for Form.io API error messages and labels.
///
/// This interface is pure Dart with no Flutter dependencies.
/// For Flutter applications, use the full FormioLocalizations from flutter_formio package.
library;

/// Abstract class that defines all localizable strings for Form.io components.
///
/// Implement this class to provide custom error messages and labels.
/// This is a minimal interface for pure Dart usage.
abstract class FormioLocale {
  // Buttons & Actions
  String get submit;
  String get cancel;
  String get save;
  String get delete;
  String get add;
  String get edit;
  String get remove;
  String get clear;

  // Generic
  String get required;
  String get isRequired;
  String get yes;
  String get no;

  // Validation Messages
  String get fieldRequired;
  String get invalidEmail;
  String get invalidUrl;
  String get invalidNumber;
  String get mustBeNumber;

  /// Get required message for a field
  String getRequiredMessage(String fieldLabel) => '$fieldLabel $isRequired.';
}

/// Default English implementation of FormioLocale.
class DefaultFormioLocale implements FormioLocale {
  const DefaultFormioLocale();

  @override
  String get submit => 'Submit';
  @override
  String get cancel => 'Cancel';
  @override
  String get save => 'Save';
  @override
  String get delete => 'Delete';
  @override
  String get add => 'Add';
  @override
  String get edit => 'Edit';
  @override
  String get remove => 'Remove';
  @override
  String get clear => 'Clear';

  @override
  String get required => 'required';
  @override
  String get isRequired => 'is required';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';

  @override
  String get fieldRequired => 'This field is required';
  @override
  String get invalidEmail => 'Invalid email address';
  @override
  String get invalidUrl => 'Invalid URL';
  @override
  String get invalidNumber => 'Invalid number';
  @override
  String get mustBeNumber => 'Must be a number';

  @override
  String getRequiredMessage(String fieldLabel) => '$fieldLabel $isRequired.';
}
