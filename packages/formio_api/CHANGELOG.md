# Changelog

All notable changes to this project will be documented in this file.

## [2.0.4] - 2026-02-11

### Changed

- Maintenance release to maintain version parity with `formio` package

## [2.0.3] - 2026-01-14

### Fixed

- Code cleanup: Removed obsolete TODO comments in `datasource_service.dart`

## [2.0.2] - 2026-01-13

### Added

- Added DataSourceService to main library file

## [2.0.1] - 2026-01-13

### Fixed

- Added missing `TemplateParser` export to main library file
- Ensures `TemplateParser.evaluate()` and `TemplateParser.stripHtml()` are accessible to downstream packages
- Fixes compatibility issue with `flutter_formio` package's `SelectComponent`

## [2.0.0] - 2026-01-13

### Added

- Initial release of `formio_api` - Pure Dart client for Form.io REST API
- Complete Form.io API coverage (forms, submissions, users, roles, actions)
- JSONLogic conditional evaluation
- Calculated values support (JSONLogic + JavaScript)
- String interpolation utilities
- Platform-independent `JsEvaluator` interface
- `FormioLocale` interface for customizable error messages
- Comprehensive test suite (8 tests, 100% passing)
- Pure Dart implementation - zero Flutter dependencies

### Features

- **Authentication**: JWT-based login, logout, and token management
- **Forms Management**: Create, read, update, delete forms
- **Submissions**: Full CRUD operations for form submissions
- **Users & Roles**: User management and role-based access control
- **Actions**: Form actions and webhooks support
- **Business Logic**: Conditional logic, calculations, interpolation
- **Extensibility**: Pluggable JS evaluator and locale interfaces

### Philosophy

This package provides the business logic and API integration for Form.io.
It's designed to work in any Dart environment - Flutter apps, CLI tools,
backend services, or standalone Dart applications.

For Flutter UI components, see the `flutter_formio` package.

---

[2.0.0]: https://github.com/mskayali/formio_flutter/releases/tag/formio_api-v2.0.0
