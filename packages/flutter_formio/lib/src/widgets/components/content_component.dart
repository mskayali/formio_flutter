/// A Flutter widget that renders static content based on a Form.io "content" component.
///
/// Used to display non-interactive information, such as instructions, notes,
/// or markdown/HTML-based explanations inside the form.
library;

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:formio_api/formio_api.dart';

import 'package:url_launcher/url_launcher.dart';

class ContentComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Complete form data for interpolation
  final Map<String, dynamic>? formData;

  /// Whether to enable clicking on links.
  final bool enableLinks;

  const ContentComponent({super.key, required this.component, this.formData, this.enableLinks = true});

  /// Extracts the raw HTML or text content from the component and performs interpolation.
  String get _content => InterpolationUtils.interpolate(
        component.raw['html'] ?? '',
        formData,
      );

  /// Optional CSS class name from Form.io (ignored in this implementation).
  // String? get _cssClass => component.raw['className'];

  @override
  Widget build(BuildContext context) {
    if (_content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Html(
        data: _content,
        style: {'p': Style(fontSize: FontSize.medium), 'h2': Style(fontSize: FontSize.larger, fontWeight: FontWeight.w600)},
        onLinkTap: (url, _, __) {
          if (enableLinks && url != null) {
            launchUrl(Uri.parse(url));
          }
        },
      ),
    );
  }
}
