/// A Flutter widget that renders static HTML content based on a
/// Form.io "htmlelement" component.
///
/// This component is read-only and used for displaying custom HTML
/// such as paragraphs, headers, separators, and basic formatting.
library;

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:formio_api/formio_api.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlElementComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Complete form data for interpolation
  final Map<String, dynamic>? formData;

  /// Whether to enable clicking on links.
  final bool enableLinks;

  const HtmlElementComponent({super.key, required this.component, this.formData, this.enableLinks = true});

  /// Raw HTML content to display with interpolation support.
  String get _htmlContent => InterpolationUtils.interpolate(
        component.raw['tag'] == 'hr' ? '<hr/>' : component.raw['content']?.toString() ?? '',
        formData,
      );

  /// Optional CSS class (unused by default).
  // String? get _cssClass => component.raw['className'];

  @override
  Widget build(BuildContext context) {
    if (_htmlContent.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Html(
        data: _htmlContent,
        style: {
          // Optionally apply styling based on tag types
          'h1': Style(fontSize: FontSize.xxLarge),
          'p': Style(fontSize: FontSize.medium),
          'hr': Style(margin: Margins.only(top: 12, bottom: 12)),
        },
        onLinkTap: (url, _, __) {
          if (enableLinks && url != null) {
            launchUrl(Uri.parse(url));
          }
        },
      ),
    );
  }
}
