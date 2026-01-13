/// A Flutter widget that renders a tags/chips input based on a Form.io "tags" component.
///
/// Allows users to add and remove tags. Supports storing as array or delimited string.
library;

import 'package:flutter/material.dart';

import 'package:formio_api/formio_api.dart';
import '../component_factory.dart';

class TagsComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value (can be String or List<String>).
  final dynamic value;

  /// Callback called when tags change.
  final ValueChanged<dynamic> onChanged;

  const TagsComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TagsComponent> createState() => _TagsComponentState();
}

class _TagsComponentState extends State<TagsComponent> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _tags;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tags = _parseTags(widget.value);
  }

  @override
  void didUpdateWidget(TagsComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with external value changes
    if (widget.value != oldWidget.value) {
      _tags = _parseTags(widget.value);
    }
  }

  /// Gets the delimiter from component config (default: ',').
  String get _delimiter => widget.component.raw['delimeter']?.toString() ?? ',';

  /// Gets the storage type ('string' or 'array').
  String get _storeAs => widget.component.raw['storeas']?.toString() ?? 'string';

  /// Gets max tags limit (0 = unlimited).
  int get _maxTags => widget.component.raw['maxTags'] is int ? widget.component.raw['maxTags'] as int : 0;

  /// Placeholder text.
  String? get _placeholder => widget.component.raw['placeholder']?.toString();

  /// Returns true if the field is required.
  bool get _isRequired => widget.component.required;

  /// Parses the value into a list of tags.
  List<String> _parseTags(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      if (value.isEmpty) return [];
      return value.split(_delimiter).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  /// Converts tags list to the appropriate storage format.
  dynamic _formatTags(List<String> tags) {
    if (_storeAs == 'array') {
      return tags;
    } else {
      return tags.join(_delimiter);
    }
  }

  /// Adds a new tag.
  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return;

    // Check max tags limit
    if (_maxTags > 0 && _tags.length >= _maxTags) {
      return;
    }

    // Check for duplicates
    if (_tags.contains(trimmed)) {
      _controller.clear();
      return;
    }

    setState(() {
      _tags.add(trimmed);
    });
    _controller.clear();
    widget.onChanged(_formatTags(_tags));
  }

  /// Removes a tag by index.
  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
    widget.onChanged(_formatTags(_tags));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reachedMaxTags = _maxTags > 0 && _tags.length >= _maxTags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.component.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.component.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        // Tags display
        if (_tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _tags.asMap().entries.map((entry) {
                return Chip(
                  label: Text(entry.value),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeTag(entry.key),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ),
        // Input field
        TextFormField(
          key: ValueKey('${widget.component.key}_input'),
          controller: _controller,
          focusNode: _focusNode,
          enabled: !reachedMaxTags,
          decoration: InputDecoration(
            labelText: reachedMaxTags ? 'Maximum tags reached' : 'Add tag',
            hintText: reachedMaxTags ? null : _placeholder ?? 'Type and press Enter or comma',
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addTag(_controller.text),
                  )
                : null,
          ),
          onChanged: (value) {
            // Auto-add tag when user types comma or delimiter
            if (value.endsWith(_delimiter) || value.endsWith(',')) {
              final tagText = value.substring(0, value.length - 1).trim();
              if (tagText.isNotEmpty) {
                _addTag(tagText);
                return;
              }
            }
            // Only rebuild if add button visibility should change
            if ((value.isEmpty) != (_controller.text.isEmpty)) {
              setState(() {});
            }
          },
          onFieldSubmitted: (value) {
            _addTag(value);
            _focusNode.requestFocus();
          },
          validator: _isRequired && _tags.isEmpty ? (_) => ComponentFactory.locale.getRequiredMessage(widget.component.label) : null,
        ),
        if (_maxTags > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${_tags.length}/$_maxTags tags',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
