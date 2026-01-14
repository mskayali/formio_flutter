/// Localization/Internationalization configuration for Form.io Flutter.
///
/// Contains all user-facing strings used in components.
/// Implement this abstract class to create custom localizations for your language.
///
/// Example:
/// ```dart
/// class MyGermanFormioLocalizations implements FormioLocalizations {
///   const MyGermanFormioLocalizations();
///
///   @override
///   String get submit => 'Absenden';
///   // ... implement all other getters
///
///   static const LocalizationsDelegate<FormioLocalizations> delegate =
///       _GermanFormioLocalizationsDelegate();
/// }
/// ```
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Abstract class that defines all localizable strings for Form.io components.
///
/// Implement this class to provide translations for your language.
/// See [DefaultFormioLocalizations] for the default English implementation.
abstract class FormioLocalizations {
  // Buttons & Actions
  String get submit;
  String get cancel;
  String get clear;
  String get undo;
  String get next;
  String get previous;
  String get complete;
  String get add;
  String get addAnother;
  String get addEntry;
  String get edit;
  String get save;
  String get remove;
  String get delete;

  // File Component
  String get uploadFile;
  String get noFileSelected;
  String get fileSelected;
  String get filesSelected;

  // DataSource
  String get fetching;
  String get dataSourceError;

  // DataGrid & EditGrid
  String get removeRow;
  String get editRow;
  String get saveRow;
  String get cancelEdit;

  // DataTable
  String get showing;
  String get of;
  String get rowsPerPage;
  String get rowSelected;
  String get rowsSelected;
  String get noDataAvailable;

  // Wizard & DynamicWizard
  String get step;
  String get stepOf;

  // Generic
  String get required;
  String get isRequired;
  String get noData;
  String get noDataToReview;
  String get noOptions;
  String get empty;
  String get none;
  String get yes;
  String get no;
  String get actions;
  String get day;
  String get month;
  String get year;

  // Input Helpers
  String get typeAndPressEnter;
  String get typeToAddTag;
  String get searchPlaceholder;

  // Validation Messages
  String get fieldRequired;
  String get invalidEmail;
  String get invalidUrl;
  String get invalidNumber;
  String get mustBeNumber;

  // Signature & Sketchpad
  String get clearSignature;
  String get clearCanvas;
  String get undoLastStroke;
  String get color;
  String get size;
  String get eraser;

  // Review Page
  String get review;
  String get reviewYourSubmission;

  // Wizard
  String get noStepsConfigured;
  String get noEntriesAdded;

  /// Get required message for a field
  String getRequiredMessage(String fieldLabel) => '$fieldLabel $isRequired.';

  /// Get file count message
  String getFileCountMessage(int count) {
    if (count == 0) return noFileSelected;
    if (count == 1) return '1 $fileSelected';
    return '$count $filesSelected';
  }

  /// Get showing range message for DataTable
  String getShowingMessage(int start, int end, int total) => '$showing $start-$end $of $total';

  /// Get selected rows message
  String getSelectedRowsMessage(int count) {
    if (count == 1) return '1 $rowSelected';
    return '$count $rowsSelected';
  }

  /// Get step progress message
  String getStepMessage(int current, int total) => '$step $current $stepOf $total';
}

/// Default English implementation of [FormioLocalizations].
class DefaultFormioLocalizations implements FormioLocalizations {
  const DefaultFormioLocalizations();

  @override
  String get submit => 'Submit';
  @override
  String get cancel => 'Cancel';
  @override
  String get clear => 'Clear';
  @override
  String get undo => 'Undo';
  @override
  String get next => 'Next';
  @override
  String get previous => 'Previous';
  @override
  String get complete => 'Complete';
  @override
  String get add => 'Add';
  @override
  String get addAnother => 'Add Another';
  @override
  String get addEntry => 'Add Entry';
  @override
  String get edit => 'Edit';
  @override
  String get save => 'Save';
  @override
  String get remove => 'Remove';
  @override
  String get delete => 'Delete';

  @override
  String get uploadFile => 'Upload File';
  @override
  String get noFileSelected => 'No file selected';
  @override
  String get fileSelected => 'file selected';
  @override
  String get filesSelected => 'files selected';

  @override
  String get fetching => 'Fetching';
  @override
  String get dataSourceError => 'DataSource Error';

  @override
  String get removeRow => 'Remove Row';
  @override
  String get editRow => 'Edit Row';
  @override
  String get saveRow => 'Save Row';
  @override
  String get cancelEdit => 'Cancel Edit';

  @override
  String get showing => 'Showing';
  @override
  String get of => 'of';
  @override
  String get rowsPerPage => 'Rows per page';
  @override
  String get rowSelected => 'row selected';
  @override
  String get rowsSelected => 'rows selected';
  @override
  String get noDataAvailable => 'No data available';

  @override
  String get step => 'Step';
  @override
  String get stepOf => 'of';

  @override
  String get required => 'required';
  @override
  String get isRequired => 'is required';
  @override
  String get noData => 'No data';
  @override
  String get noDataToReview => 'No data to review';
  @override
  String get noOptions => 'No options';
  @override
  String get empty => '(empty)';
  @override
  String get none => '(none)';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
  @override
  String get actions => 'Actions';
  @override
  String get day => 'Day';
  @override
  String get month => 'Month';
  @override
  String get year => 'Year';

  @override
  String get typeAndPressEnter => 'Type and press Enter';
  @override
  String get typeToAddTag => 'Type and press Enter to add tag';
  @override
  String get searchPlaceholder => 'Search...';

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
  String get clearSignature => 'Clear';
  @override
  String get clearCanvas => 'Clear';
  @override
  String get undoLastStroke => 'Undo';
  @override
  String get color => 'Color';
  @override
  String get size => 'Size';
  @override
  String get eraser => 'Eraser';

  @override
  String get review => 'Review';
  @override
  String get reviewYourSubmission => 'Review Your Submission';

  @override
  String get noStepsConfigured => 'No wizard steps configured';
  @override
  String get noEntriesAdded => 'No entries added yet';

  @override
  String getRequiredMessage(String fieldLabel) => '$fieldLabel $isRequired.';

  @override
  String getFileCountMessage(int count) {
    if (count == 0) return noFileSelected;
    if (count == 1) return '1 $fileSelected';
    return '$count $filesSelected';
  }

  @override
  String getShowingMessage(int start, int end, int total) => '$showing $start-$end $of $total';

  @override
  String getSelectedRowsMessage(int count) {
    if (count == 1) return '1 $rowSelected';
    return '$count $rowsSelected';
  }

  @override
  String getStepMessage(int current, int total) => '$step $current $stepOf $total';

  /// Creates an object that provides English resource values for Form.io widgets.
  static Future<FormioLocalizations> load(Locale locale) {
    return SynchronousFuture<FormioLocalizations>(const DefaultFormioLocalizations());
  }

  /// A [LocalizationsDelegate] for English Form.io localizations.
  static const LocalizationsDelegate<FormioLocalizations> delegate = _DefaultFormioLocalizationsDelegate();
}

class _DefaultFormioLocalizationsDelegate extends LocalizationsDelegate<FormioLocalizations> {
  const _DefaultFormioLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true; // Default supports all locales as fallback

  @override
  Future<FormioLocalizations> load(Locale locale) => DefaultFormioLocalizations.load(locale);

  @override
  bool shouldReload(_DefaultFormioLocalizationsDelegate old) => false;

  @override
  String toString() => 'DefaultFormioLocalizations.delegate(en)';
}
