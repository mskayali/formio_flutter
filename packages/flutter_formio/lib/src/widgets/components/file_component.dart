/// A Flutter widget that renders a file upload input based on
/// a Form.io "file" component.
///
/// Handles file selection, preview, and basic validation.
/// Upload logic (to Form.io or custom storage) must be handled externally.
///
/// Users must provide their own file picking implementation via [onFilePick].
library;

import 'package:flutter/material.dart';
import 'package:flutter_formio/flutter_formio.dart';

class FileComponent extends StatelessWidget {
  /// The Form.io file component definition.
  final ComponentModel component;

  /// Currently selected files.
  final List<FileData> value;

  /// Callback triggered when files are selected or cleared.
  final OnFileChanged onChanged;

  /// Optional callback for file picking.
  /// If not provided, the component will display a message asking users
  /// to configure file picking.
  final FilePickerCallback? onFilePick;

  const FileComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.onFilePick,
  });

  /// Whether multiple file selection is allowed.
  bool get _isMultiple => component.raw['multiple'] == true;

  /// Whether this field is required.
  bool get _isRequired => component.required;

  /// Allowed file types (from accept property, e.g., 'image/*').
  List<String> get _acceptedExtensions {
    final accept = component.raw['fileTypes'] as List? ?? [];
    return accept.map((e) => e['value'].toString()).toList();
  }

  Future<void> _pickFiles(BuildContext context) async {
    if (onFilePick == null) {
      // _showConfigurationMessage(context);
      throw Exception('File picker not configured. Please provide an onFilePick callback to FileComponent.');
    }

    final result = await onFilePick!(
      allowMultiple: _isMultiple,
      allowedExtensions: _acceptedExtensions.isNotEmpty ? _acceptedExtensions.map((e) => e.replaceAll(RegExp(r'[^\w]'), '')).toList() : null,
    );

    if (result != null) {
      onChanged(result);
    }
  }

  void _removeFile(FileData file) {
    final updated = List<FileData>.from(value)..remove(file);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _isRequired && value.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(component.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: value.map((fileData) {
            return Chip(
              label: Text(fileData.name),
              onDeleted: () => _removeFile(fileData),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _pickFiles(context),
          icon: const Icon(Icons.upload_file),
          label: Text(_isMultiple ? 'Upload Files' : 'Upload File'),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              ComponentFactory.locale.getRequiredMessage(component.label),
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
