/// A Flutter widget that renders a Tagpad component.
///
/// Similar to Tags component but with enhanced UI featuring:
/// - Visual tag chips with close buttons
/// - Autocomplete support
/// - Drag-to-reorder (future enhancement)
/// - Color-coded tags (future enhancement)
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class TagpadComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Current list of tags.
  final List<String>? value;

  /// Callback triggered when tags change.
  final ValueChanged<List<String>> onChanged;

  const TagpadComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TagpadComponent> createState() => _TagpadComponentState();
}

class _TagpadComponentState extends State<TagpadComponent> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.value ?? []);
  }

  @override
  void didUpdateWidget(TagpadComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _tags = List.from(widget.value ?? []);
    }
  }

  bool get _isRequired => widget.component.required;
  String? get _placeholder => widget.component.raw['placeholder'] as String?;
  int? get _maxTags => widget.component.raw['maxTags'] as int?;
  List<String>? get _suggestions => (widget.component.raw['data']?['values'] as List?)?.cast<String>();

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) return;
    if (_tags.contains(trimmed)) return;
    if (_maxTags != null && _tags.length >= _maxTags!) return;

    setState(() {
      _tags.add(trimmed);
      _controller.clear();
    });
    widget.onChanged(_tags);
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
    widget.onChanged(_tags);
  }

  Color _getTagColor(BuildContext context, int index) {
    // Use theme primary color with opacity variations for visual variety
    final baseColor = Theme.of(context).colorScheme.primary;
    final opacities = [0.1, 0.15, 0.2, 0.12, 0.18, 0.14];
    return baseColor.withValues(alpha: opacities[index % opacities.length]);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _isRequired && _tags.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.component.label.isNotEmpty)
          Text(
            widget.component.label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        const SizedBox(height: 8),

        // Tag chips display
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.asMap().entries.map((entry) {
              final index = entry.key;
              final tag = entry.value;
              return Chip(
                label: Text(tag),
                backgroundColor: _getTagColor(context, index),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeTag(index),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        if (_tags.isNotEmpty) const SizedBox(height: 8),

        // Input field
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: _placeholder ?? 'Type and press Enter to add tag',
            errorText: hasError ? ComponentFactory.locale.getRequiredMessage(widget.component.label) : null,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addTag(_controller.text),
                  )
                : null,
          ),
          onSubmitted: _addTag,
          onChanged: (_) => setState(() {}), // Rebuild to show/hide add button
        ),

        // Suggestions (if available)
        if (_suggestions != null && _suggestions!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _suggestions!
                  .where((s) => !_tags.contains(s))
                  .take(5)
                  .map((suggestion) => ActionChip(
                        label: Text(suggestion, style: const TextStyle(fontSize: 12)),
                        onPressed: () => _addTag(suggestion),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ),

        // Max tags info
        if (_maxTags != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${_tags.length}/$_maxTags tags',
              style: TextStyle(
                fontSize: 12,
                color: _tags.length >= _maxTags! ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
