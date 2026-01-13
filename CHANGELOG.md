# Changelog

All notable changes to the Form.io Flutter package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-01-12

### Added
- 🚀 **JavaScript Evaluation Support** - Execute custom JavaScript for validation and calculations
  - Web platform: Uses native `dart:js`
  - Mobile/Desktop: Uses `flutter_js` with QuickJS engine
  - Security measures: Code validation and execution timeouts
- ✅ **Custom JavaScript Validation** - `customJS` validator for Form.io `validate.custom` fields
- ✅ **JavaScript Calculated Values** - Support for `calculateValue` with JavaScript expressions
- ✅ **Date/Time Validators** - Added 5 new validators:
  - `minDate` / `maxDate` - Date range validation
  - `dateRange` - Convenience validator for date ranges
  - `minYear` / `maxYear` - Year validation
- ✅ **File Validators** - Added 2 new validators:
  - `fileSize` - File size validation (min/max with smart formatting)
  - `filePattern` - File type validation (extensions and MIME types)
- 📚 **Comprehensive Documentation** - Updated README with unsupported features and roadmap

### Changed
- 📈 **Form.io Compatibility** - Increased from ~92% to ~98%
- 🔧 **CalculationEvaluator** - Now supports both JSONLogic and JavaScript expressions
- 📝 **Validation Coverage** - Improved from 61% to 95% (18/19 validators)

### Dependencies
- Added `flutter_js: ^0.8.5` for JavaScript evaluation on mobile/desktop platforms

### Tests
- ✅ 23 new tests for date/time and file validators
- ✅ All 81+ core tests passing

## [1.0.1] - 2026-01-12

### Changed
- Updated repository URLs to correct GitHub location

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

#### Component JSON Changes

No breaking changes to component JSON structure. All existing forms are compatible.

New features:
- Add `matchField` to `validate` for password confirmation
- Add `calculateValue` for auto-calculated fields
- Set `display: 'wizard'` for multi-page forms

---

## Statistics

### Version 1.1.0
- **Components**: 41/41 (100%)
- **Validation**: 18 validators (95% coverage)
- **Tests**: 81+ passing
- **Lines of Code**: ~2,200+ lines added
- **Coverage**: ~98% Form.io feature parity

---

## Roadmap

### v1.2.0 (Next)
- [ ] Dynamic select data sources (API-based dropdown options)
- [ ] Enhanced file handling

### v1.3.0
- [ ] File upload to Form.io storage
- [ ] Unique validation via API

### Future
- [ ] Google Places autocomplete
- [ ] i18n support
- [ ] Accessibility improvements

---

[1.1.0]: https://github.com/mskayali/formio_flutter/releases/tag/v1.1.0
[1.0.1]: https://github.com/mskayali/formio_flutter/releases/tag/v1.0.1
[1.0.0]: https://github.com/m skayali/formio_flutter/releases/tag/v1.0.0
[0.9.0]: https://github.com/mskayali/formio_flutter/releases/tag/v0.9.0
