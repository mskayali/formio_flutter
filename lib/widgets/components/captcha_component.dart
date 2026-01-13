/// A Flutter widget that simulates a CAPTCHA field based on a
/// Form.io "captcha" component.
///
/// Since Google reCAPTCHA is web-based, this implementation provides
/// a placeholder with optional integration logic. For production, you
/// should integrate with Firebase App Check, a backend verifier, or
/// use `webview_flutter` for full reCAPTCHA rendering.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class CaptchaComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Captured CAPTCHA token (if any).
  final String? value;

  /// Callback triggered when CAPTCHA token is updated.
  final ValueChanged<String?> onChanged;

  const CaptchaComponent({super.key, required this.component, required this.value, required this.onChanged});

  /// CAPTCHA type (e.g., 'reCaptcha2' or 'reCaptcha3').
  String get _captchaType => component.raw['type'] ?? 'reCaptcha2';

  /// Placeholder key (not used here unless you're integrating).
  // String get _siteKey => component.raw['key'] ?? 'missing-site-key';

  /// Whether the CAPTCHA is required for form submission.
  bool get _isRequired => component.required;

  @override
  Widget build(BuildContext context) {
    // ⚠️ Production users: Integrate actual CAPTCHA solution here
    final hasError = _isRequired && (value == null || value!.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(component.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Container(
          height: 100,
          width: double.infinity,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outline), borderRadius: BorderRadius.circular(6), color: Theme.of(context).colorScheme.surfaceContainerHighest),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [const Icon(Icons.privacy_tip, size: 32), Text('CAPTCHA ($_captchaType) integration required', textAlign: TextAlign.center)],
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            // Simulate CAPTCHA token (for testing only)
            onChanged('mock-captcha-token');
          },
          icon: const Icon(Icons.check),
          label: const Text('Simulate CAPTCHA'),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(ComponentFactory.locale.getRequiredMessage(component.label), style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ),
      ],
    );
  }
}
