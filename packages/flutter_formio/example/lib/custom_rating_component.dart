// Example custom component: Star Rating Widget
// This demonstrates how to create a completely new Form.io component type

import 'package:flutter/material.dart';
import 'package:flutter_formio/flutter_formio.dart';

/// A custom star rating component for Form.io forms.
///
/// This component allows users to rate something from 1-5 stars.
/// Configuration example in Form.io JSON:
/// ```json
/// {
///   "type": "rating",
///   "key": "userRating",
///   "label": "How would you rate this?",
///   "defaultValue": 0,
///   "validate": {
///     "required": true
///   }
/// }
/// ```
class CustomRatingComponent extends StatefulWidget {
  final ComponentModel component;
  final int? value;
  final ValueChanged<int> onChanged;

  const CustomRatingComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CustomRatingComponent> createState() => _CustomRatingComponentState();
}

class _CustomRatingComponentState extends State<CustomRatingComponent> {
  int _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.value ?? 0;
  }

  @override
  void didUpdateWidget(covariant CustomRatingComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _currentRating = widget.value ?? 0;
    }
  }

  void _setRating(int rating) {
    setState(() {
      _currentRating = rating;
    });
    widget.onChanged(rating);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.component.hideLabel) ...[
          Text(
            widget.component.label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return IconButton(
              icon: Icon(
                starValue <= _currentRating ? Icons.star : Icons.star_border,
                color: starValue <= _currentRating
                    ? Colors.amber
                    : Colors.grey,
                size: 32,
              ),
              onPressed: widget.component.disabled
                  ? null
                  : () => _setRating(starValue),
              tooltip: 'Rate $starValue stars',
            );
          }),
        ),
        if (_currentRating > 0) ...[
          const SizedBox(height: 4),
          Text(
            '$_currentRating star${_currentRating != 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (widget.component.description != null &&
            widget.component.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.component.description!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
        ],
      ],
    );
  }
}

/// Builder for the custom rating component
class RatingComponentBuilder implements FormioComponentBuilder {
  const RatingComponentBuilder();

  @override
  Widget build(FormioComponentBuildContext context) {
    return CustomRatingComponent(
      component: context.component,
      value: context.value is int ? context.value : null,
      onChanged: (rating) => context.onChanged(rating),
    );
  }
}
