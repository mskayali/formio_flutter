/// Represents a wizard form configuration.
///
/// Wizard forms in Form.io use panels as pages, allowing multi-step
/// form navigation with validation between steps.
library;

import 'component.dart';

class WizardConfig {
  /// Display mode for the form ('wizard' or 'form')
  final String display;

  /// List of panel components representing wizard pages
  final List<ComponentModel> pages;

  /// Optional wizard settings
  final Map<String, dynamic> settings;

  WizardConfig({
    required this.display,
    required this.pages,
    this.settings = const {},
  });

  /// Check if this is a wizard form
  bool get isWizard => display == 'wizard';

  /// Get page count
  int get pageCount => pages.length;

  /// Factory to create from Form.io JSON
  factory WizardConfig.fromJson(Map<String, dynamic> json) {
    final display = json['display']?.toString() ?? 'form';
    final components = (json['components'] as List<dynamic>?)
            ?.map((c) => ComponentModel.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];

    Map<String, dynamic> settings = {};
    if (json['settings'] != null) {
      settings = Map<String, dynamic>.from(json['settings']);
    }

    return WizardConfig(
      display: display,
      pages: components,
      settings: settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display': display,
      'components': pages.map((p) => p.toJson()).toList(),
      if (settings.isNotEmpty) 'settings': settings,
    };
  }
}
