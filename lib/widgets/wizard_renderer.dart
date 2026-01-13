/// A Flutter widget that renders Form.io wizard (multi-page) forms.
///
/// Wizard forms display one panel/page at a time with navigation buttons.
/// Each page must pass validation before proceeding to the next page.
library;

import 'package:flutter/material.dart';

import '../core/conditional_evaluator.dart';
import '../models/component.dart';
import '../models/wizard_config.dart';
import 'component_factory.dart';

/// Callback type for page changes in wizard
typedef OnWizardPageChanged = void Function(int pageIndex);

/// Callback type for wizard submission
typedef OnWizardSubmit = void Function(Map<String, dynamic> data);

class WizardRenderer extends StatefulWidget {
  /// Wizard configuration containing pages
  final WizardConfig wizardConfig;

  /// Initial form data
  final Map<String, dynamic>? initialData;

  /// Callback when wizard page changes
  final OnWizardPageChanged? onPageChanged;

  /// Callback when wizard is submitted (final page)
  final OnWizardSubmit onSubmit;

  /// Show progress indicator at top
  final bool showProgress;

  /// Allow users to navigate back to previous pages
  final bool allowPreviousNavigation;

  const WizardRenderer({
    super.key,
    required this.wizardConfig,
    this.initialData,
    this.onPageChanged,
    required this.onSubmit,
    this.showProgress = true,
    this.allowPreviousNavigation = true,
  });

  @override
  State<WizardRenderer> createState() => _WizardRendererState();
}

class _WizardRendererState extends State<WizardRenderer> {
  late int _currentPageIndex;
  late Map<String, dynamic> _formData;
  final Map<int, GlobalKey<FormState>> _pageFormKeys = {};

  @override
  void initState() {
    super.initState();
    _currentPageIndex = 0;
    _formData = Map<String, dynamic>.from(widget.initialData ?? {});

    // Initialize form keys for each page
    for (int i = 0; i < widget.wizardConfig.pageCount; i++) {
      _pageFormKeys[i] = GlobalKey<FormState>();
    }
  }

  /// Get the current page component
  ComponentModel get _currentPage {
    return widget.wizardConfig.pages[_currentPageIndex];
  }

  /// Check if we're on the first page
  bool get _isFirstPage => _currentPageIndex == 0;

  /// Check if we're on the last page
  bool get _isLastPage => _currentPageIndex == widget.wizardConfig.pageCount - 1;

  /// Validate current page
  bool _validateCurrentPage() {
    final formKey = _pageFormKeys[_currentPageIndex];
    if (formKey?.currentState == null) return true;
    return formKey!.currentState!.validate();
  }

  /// Navigate to next page
  void _goToNextPage() {
    if (_isLastPage) {
      _submitWizard();
      return;
    }

    if (!_validateCurrentPage()) {
      return; // Validation failed
    }

    setState(() {
      _currentPageIndex++;
    });

    widget.onPageChanged?.call(_currentPageIndex);
  }

  /// Navigate to previous page
  void _goToPreviousPage() {
    if (_isFirstPage) return;

    setState(() {
      _currentPageIndex--;
    });

    widget.onPageChanged?.call(_currentPageIndex);
  }

  /// Submit the wizard (final page)
  void _submitWizard() {
    if (!_validateCurrentPage()) {
      return;
    }

    widget.onSubmit(_formData);
  }

  /// Jump to a specific page (from progress indicator)
  void _jumpToPage(int pageIndex) {
    if (pageIndex == _currentPageIndex) return;

    // Validate all pages between current and target if jumping forward
    if (pageIndex > _currentPageIndex) {
      for (int i = _currentPageIndex; i < pageIndex; i++) {
        final formKey = _pageFormKeys[i];
        if (formKey?.currentState?.validate() == false) {
          // Can't jump forward if intermediate pages are invalid
          throw Exception('Please complete all previous steps first.');
        }
      }
    }

    setState(() {
      _currentPageIndex = pageIndex;
    });

    widget.onPageChanged?.call(_currentPageIndex);
  }

  /// Handle component value changes
  void _onComponentChanged(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
  }

  /// Build page content
  Widget _buildPageContent(ComponentModel page) {
    // Get nested components from the panel
    final components = page.raw['components'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      child: Form(
        key: _pageFormKeys[_currentPageIndex],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: components.map((componentJson) {
            final component = ComponentModel.fromJson(componentJson as Map<String, dynamic>);

            // Check conditional logic
            if (!ConditionalEvaluator.shouldShow(component.conditional, _formData)) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ComponentFactory.build(
                component: component,
                value: _formData[component.key],
                onChanged: (value) => _onComponentChanged(component.key, value),
                formData: _formData,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Build progress indicator
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: List.generate(widget.wizardConfig.pageCount, (index) {
          final page = widget.wizardConfig.pages[index];
          final isCompleted = index < _currentPageIndex;
          final isCurrent = index == _currentPageIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => _jumpToPage(index),
              child: Column(
                children: [
                  // Circle indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? Colors.green
                          : isCurrent
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Page label
                  Text(
                    page.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build navigation buttons
  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          if (!_isFirstPage && widget.allowPreviousNavigation)
            ElevatedButton.icon(
              onPressed: _goToPreviousPage,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
            )
          else
            const SizedBox.shrink(),

          // Next/Submit button
          ElevatedButton.icon(
            onPressed: _goToNextPage,
            icon: Icon(_isLastPage ? Icons.check : Icons.arrow_forward),
            label: Text(_isLastPage ? 'Submit' : 'Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLastPage ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress indicator
        if (widget.showProgress) _buildProgressIndicator(),

        // Divider
        if (widget.showProgress) const Divider(),

        // Page title
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _currentPage.label,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),

        // Page content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildPageContent(_currentPage),
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildNavigationButtons(),
        ),
      ],
    );
  }
}
