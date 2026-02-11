# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.4] - 2026-02-11

### Added

- Added sticky header support with `sticky_headers` package for improved form navigation
- Added button registration functionality for enhanced component management
- Added new translation support for internationalization

### Fixed

- Fixed `initialData` override for all nested components
- Fixed form submission nesting issues
- Fixed survey component scroll bug
- Fixed validation bugs affecting form validation behavior
- Improved URL parser for better link handling
- Code cleanup: Removed empty containers

## [2.0.3] - 2026-01-14

### Added

- Added `enableLinks` parameter to `HtmlElementComponent` for controlling link interactivity
  - Matching behavior with `ContentComponent`
  - Defaults to `true` for backward compatibility
  - Imported `url_launcher` package for link handling

### Fixed

- Fixed duplicate `fieldWidget` variable declaration in `form_renderer.dart`
- Cleaned up example code: Removed undefined `CustomSubmitButtonBuilder` registration

## [2.0.2] - 2026-01-13

### Added

- Added DataSourceComponent to main library file

## [2.0.1] - 2026-01-13

### Changed

- Updated dependencies for pub.dev compatibility:
  - `flutter_lints`: ^3.0.0 → ^6.0.0
- Changed `formio_api` from path dependency to hosted dependency ^2.0.1

### Added

- Added missing `dio` ^5.9.0 dependency (required by `datasource_component`)

### Fixed

- Removed debug print statements for production readiness
- Cleaned up unused state fields in components

## [2.0.0] - 2026-01-13

### Breaking Changes

- **Package Split**: `formio` package has been split into two packages:
  - `formio_api` - Pure Dart API client (no Flutter dependencies)
  - `flutter_formio` - Flutter widgets for rendering forms
- **Import Changes**: Update imports from `package:formio/formio.dart` to `package:formio/formio.dart`
- **JS Evaluator**: Must now explicitly initialize JavaScript evaluator in `main()`:
  ```dart
  JavaScriptEvaluator.setEvaluator(FlutterJsEvaluator());
  ```

### Added

- **Pure Dart Support**: `formio_api` can now be used in non-Flutter Dart projects
- **Pluggable JS Engine**: `JsEvaluator` interface allows custom JavaScript implementations
- **Custom Locale Interface**: Pure Dart `FormioLocale` interface for API package
- **Dependency Injection**: Platform-independent architecture with injectable components
- **NoOp JS Evaluator**: Testing-friendly no-op evaluator for unit tests

### Changed

- **Package Structure**: Monorepo with `packages/formio_api` and `packages/flutter_formio`
- **Dependencies**: `flutter_formio` now depends on `formio_api` ^2.0.0
- **Component Builder**: Changed from typedef to abstract class `FormioComponentBuilder`

### Improved

- **Modularity**: Clean separation between API logic and UI components
- **Testability**: Pure Dart API package is easier to test
- **Flexibility**: Custom JS engines, locales, and validators
- **Documentation**: Comprehensive README, migration guide, and API documentation

### Migration

See [MIGRATION.md](MIGRATION.md) for detailed upgrade instructions.

## [1.1.0] - 2026-01-12

### Added

- JavaScript evaluation support for calculations and validations
- flutter_js integration for cross-platform JS execution
- Comprehensive validation system with 15+ validators
- JSONLogic-based conditional rendering
- Plugin system for custom components

### Fixed

- Conditional logic edge cases
- Validation message formatting
- Wizard navigation issues

## [1.0.0] - 2026-01-10

### Added

- Initial release
- 46+ Form.io components
- Wizard forms support
- API integration (forms, submissions, users)
- Localization support
- Material Design theming

---

[2.0.0]: https://github.com/mskayali/formio_flutter/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/mskayali/formio_flutter/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/mskayali/formio_flutter/releases/tag/v1.0.0
