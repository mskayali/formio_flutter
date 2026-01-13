/// A Flutter widget that renders a structured address input based on a Form.io "address" component.
///
/// Provides separate fields for address1, address2, city, state, country, and zip code.
/// Returns data as a Map<String, String>.
library;

import 'package:flutter/material.dart';

import 'package:formio_api/formio_api.dart';
import '../component_factory.dart';

class AddressComponent extends StatefulWidget {
  /// The Form.io component definition for the address.
  final ComponentModel component;

  /// The current address value map.
  final Map<String, dynamic> value;

  /// Callback triggered when any address field changes.
  final ValueChanged<Map<String, dynamic>> onChanged;

  const AddressComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
  });

  @override
  State<AddressComponent> createState() => _AddressComponentState();
}

class _AddressComponentState extends State<AddressComponent> {
  late Map<String, dynamic> _addressData;

  @override
  void initState() {
    super.initState();
    _addressData = Map<String, dynamic>.from(widget.value);
  }

  /// Updates a specific address field.
  void _updateField(String key, dynamic fieldValue) {
    setState(() {
      _addressData[key] = fieldValue;
    });
    widget.onChanged(_addressData);
  }

  /// Gets placeholder text for a field.
  String? _getPlaceholder(String field) {
    final placeholders = {
      'address1': 'Street Address',
      'address2': 'Apt, Suite, etc. (optional)',
      'city': 'City',
      'state': 'State/Province',
      'country': 'Country',
      'zip': 'Postal/Zip Code',
    };
    return placeholders[field];
  }

  /// Builds a text field for an address component.
  Widget _buildAddressField({
    required String key,
    required String label,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        key: ValueKey('${widget.component.key}_$key'),
        initialValue: _addressData[key]?.toString() ?? '',
        decoration: InputDecoration(
          labelText: label,
          hintText: _getPlaceholder(key),
        ),
        onChanged: (val) => _updateField(key, val),
        validator: required ? (val) => (val == null || val.isEmpty) ? ComponentFactory.locale.getRequiredMessage(label) : null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRequired = widget.component.required;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.component.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              widget.component.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        _buildAddressField(
          key: 'address1',
          label: 'Address Line 1',
          required: isRequired,
        ),
        _buildAddressField(
          key: 'address2',
          label: 'Address Line 2',
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildAddressField(
                key: 'city',
                label: 'City',
                required: isRequired,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAddressField(
                key: 'state',
                label: 'State',
                required: isRequired,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildAddressField(
                key: 'zip',
                label: 'Zip Code',
                required: isRequired,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAddressField(
                key: 'country',
                label: 'Country',
                required: isRequired,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
