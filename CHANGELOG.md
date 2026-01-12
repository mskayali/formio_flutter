# Changelog

All notable changes to the Form.io Flutter package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-12

### Added - Phase 1: Centralized Validation System
- ✨ **Centralized Validators** - `FormioValidators` class with 11 validation methods
  - `required()` - Required field validation
  - `pattern()` - Regex pattern matching
  - `minLength()` / `maxLength()` - String length constraints  
  - `minWords()` / `maxWords()` - Word count validation
  - `email()` - Email format validation
  - `url()` - URL format validation
  - `min()` / `max()` - Numeric range validation
  - `json()` - JSON format validation
  - `combine()` - Combine multiple validators
  - `fromConfig()` - Auto-parse Form.io validate config
- 🧪 28 comprehensive validator tests (100% passing)
- 📝 Updated TextField and TextArea components to use centralized validators
- 🔧 Added date type alias for backward compatibility

### Added - Phase 2: Wizard Forms & Calculated Values
- ✨ **Wizard Forms Support**
  - `WizardConfig` model for wizard form configuration
  - `WizardRenderer` widget for multi-page forms
  - Page navigation (Next/Previous/Jump to page)
  - Visual progress indicator with clickable steps
  - Page-level validation before navigation
  - Form state persistence across pages
- ✨ **Calculated Values**
  - `CalculationEvaluator` for JSONLogic-based calculations
  - Automatic recalculation on dependency changes
  - `allowCalculateOverride` support
  - Dependency extraction and tracking
  - Integration with `FormRenderer`
- 🧪 13 calculation evaluator tests (100% passing)
- 📚 Shopping cart example with auto-calculated totals
- 📚 Multi-page wizard registration example

### Added - Phase 3: Cross-Field Validation
- ✨ **Cross-Field Validation**
  - `matchField()` - Password confirmation validation
  - `compareFields()` - Numeric field comparison (>, <, >=, <=, ==, !=)
  - `crossFieldValidator()` - Helper with custom error messages
  - Integration with `fromConfig()` for matchField support
- 🧪 15 cross-field validation tests (100% passing)
- 📝 Updated `FormioValidators.fromConfig()` to accept formData context

### Added - Components (6 new)
- 🆕 `UnknownComponent` - Fallback for unsupported types
- 🆕 `UrlComponent` - URL input with validation
- 🆕 `AlertComponent` - Display alerts (error, success, info, warning)
- 🆕 `AddressComponent` - Structured address input
- 🆕 `TagsComponent` - Chip-based tag input
- 🆕 `FormComponent` - Nested form support

### Added - Example App
- 📱 Complete live demo application
- 📋 Form list page with API integration
- 📄 Form detail page with rendering and JSON view
- 🎨 Material 3 UI design
- 🔄 Loading and error states
- ✅ Submission handling with visual feedback

### Fixed
- 🐛 **CRITICAL**: Fixed ComponentModel.fromJson mutation bug
  - Changed from mutating original JSON to creating a copy
  - Prevents components from becoming "unsupported" on form revisit
- 🐛 Fixed AlertComponent using correct `alertType` field
- 🐛 Fixed flaky tests in AlertComponent
- 🔧 Removed unused imports to fix lint warnings

### Changed
- ♻️ Refactored FormRenderer to support calculated values
- ♻️ Enhanced ComponentFactory with better error handling
- 📝 Improved documentation across all components
- 🧪 Increased test coverage to 56 tests (100% passing)

### Performance
- ⚡ Optimized calculated value recalculation with dependency tracking
- ⚡ Efficient wizard form state management with separate FormStates per page

## [0.9.0] - 2025-XX-XX

### Added
- Initial implementation of 35 Form.io components
- Basic validation support (required only)
- Simple conditional logic
- API services (Form, Submission, User, Auth, Action)
- FormRenderer widget
- ComponentFactory pattern

### Known Limitations
- No wizard form support
- No calculated values
- Limited validation rules
- No cross-field validation

---

## Migration Guide

### Upgrading from 0.9.x to 1.0.0

#### Validation Changes

**Before (0.9.x):**
```dart
validator: _isRequired 
  ? (val) => (val == null || val.isEmpty) 
      ? '${component.label} is required.' 
      : null 
  : null
```

**After (1.0.0):**
```dart
validator: FormioValidators.fromConfig(
  component.raw['validate'],
  component.label,
  formData: _formData, // For cross-field validation
)
```

#### Component JSON Changes

No breaking changes to component JSON structure. All existing forms are compatible.

New features:
- Add `matchField` to `validate` for password confirmation
- Add `calculateValue` for auto-calculated fields
- Set `display: 'wizard'` for multi-page forms

---

## Statistics

### Version 1.0.0
- **Components**: 41/41 (100%)
- **Validation**: 11 validators
- **Tests**: 56/56 passing
- **Lines of Code**: ~1,780 lines added
- **Coverage**: ~92% Form.io feature parity

---

## Roadmap

### Future Enhancements
- [ ] Select data sources (API-based dropdown options)
- [ ] Unique validation via API
- [ ] File upload to external providers
- [ ] Google Places autocomplete
- [ ] i18n support
- [ ] Accessibility improvements

---

[1.0.0]: https://github.com/your-repo/formio_flutter/releases/tag/v1.0.0
[0.9.0]: https://github.com/your-repo/formio_flutter/releases/tag/v0.9.0
