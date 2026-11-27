# Fixes Applied from Phase-by-Phase Review

**Date:** 2026-11-26
**Review Document:** `docs/reviews/phase-by-phase-review.md`
**Commits:** f5900c1 (initial fixes), current batch

## Critical Issues Fixed

### 1. Parties Widget Map Not Functional
**Issue:** Used a static Unsplash image with overlay pins instead of an interactive map.
**Fix:** Integrated `flutter_map` 7.0.2 with OpenStreetMap tiles and `MarkerLayer` for event locations.
**Files Changed:**
- `lib/features/widgets/ui/types/parties/parties_widget.dart` - Replaced static image with FlutterMap
- `pubspec.yaml` - Added `flutter_map: ^7.0.0` and `latlong2: ^0.9.0` dependencies

### 2. In-Memory User Storage
**Issue:** `backend/app/api/auth.py` used an in-memory dictionary for user storage, losing all users on server restart.
**Fix:** Deleted the redundant `backend/app/api/auth.py` file. The production auth module `backend/app/auth.py` already uses PostgreSQL-backed User model with proper JWT validation and OAuth2PasswordBearer.
**Files Changed:**
- `backend/app/api/auth.py` - Deleted (redundant in-memory implementation)

## High Priority Issues Fixed

### 3. Security Module Not Integrated
**Issue:** `app/security.py` existed with security functions but was unused in the AI pipeline.
**Fix:** Imported and integrated security functions into the pipeline:
- `sanitize_text()` for user input in `build_user_message()`
- `validate_url()` for source URLs in `build_widget_json()`
- `validate_url()` for API URLs in `get_weather()`
**Files Changed:**
- `backend/app/ai/pipeline.py`

### 4. No Input Validation on API Endpoints
**Issue:** Endpoints accepted arbitrary `widget_id` values without validation.
**Fix:** Added `validate_widget_type()` function that validates against a whitelist of known widget types. Applied to all widget endpoints.
**Files Changed:**
- `backend/app/api/widgets.py` - Added validation to GET/POST endpoints

### 5. MockWidgetDataProvider in Dashboard View
**Issue:** 447-line `MockWidgetDataProvider` class was defined in `dashboard_view.dart`, violating separation of concerns.
**Fix:** Extracted to separate file `lib/features/widgets/framework/mock_widget_data_provider.dart`.
**Files Changed:**
- `lib/features/dashboard/ui/views/dashboard_view.dart` - Removed class, added import
- `lib/features/widgets/framework/mock_widget_data_provider.dart` - New file
- `test/new_widgets_test.dart` - Updated import

### 6. BuildContext Across Async Gaps (11 occurrences)
**Issue:** `context` was used after `await` without checking `mounted` in `_showSyncOptions` method.
**Fix:** Added `if (!syncContext.mounted) return;` checks before all `ScaffoldMessenger.of(syncContext).showSnackBar()` calls.
**Files Changed:**
- `lib/features/dashboard/ui/views/dashboard_view.dart` - Fixed lines 877, 878, 881, 882, 918, 919, 922, 928, 929, 933, 934

### 7. Pydantic V1 Validator
**Issue:** `@validator('widget_id')` used Pydantic V1 syntax.
**Fix:** Migrated to Pydantic V2 `@field_validator('widget_id')` with `@classmethod` decorator.
**Files Changed:**
- `backend/app/api/widgets.py`

### 8. Global Mutable Token State
**Issue:** `token_usage` dict in pipeline was globally mutable without thread safety.
**Fix:** Added `asyncio.Lock()` to protect all token_usage read/write operations.
**Files Changed:**
- `backend/app/ai/pipeline.py`

### 9. Deprecated `onReorder` API
**Issue:** Used deprecated `onReorder` callback in `ReorderableListView`.
**Fix:** Replaced with `onReorderItem` callback with proper index adjustment.
**Files Changed:**
- `lib/features/dashboard/ui/views/dashboard_view.dart`

### 10. Material-UI Migration Incomplete (70+ warnings)
**Issue:** All 40 widget files and core files still imported `package:flutter/material.dart`, causing 70+ deprecation warnings.
**Fix:** Migrated all imports to `package:material_ui/material_ui.dart`. Updated `lib/main.dart` and test files to use split package imports for `GlobalMaterialLocalizations` and `GlobalCupertinoLocalizations`.
**Files Changed:** All 40 `.dart` files in `lib/` and `test/` directories.

### 11. Deprecated `value` Parameter
**Issue:** `DropdownButtonFormField` used deprecated `value` parameter.
**Fix:** Replaced with `initialValue`.
**Files Changed:**
- `lib/features/widgets/ui/base/widget_card.dart`

## Technical Debt Fixed

### 12. Deprecated `withOpacity()` Calls
**Issue:** Multiple instances of deprecated `withOpacity()` method.
**Fix:** Replaced all with `withValues(alpha: ...)`.
**Files Changed:** 12 widget type files

### 13. `throw e` → `rethrow`
**Issue:** Used `throw e` which loses original stack trace.
**Fix:** Replaced with `rethrow` to preserve stack trace.
**Files Changed:**
- `lib/features/dashboard/ui/views/dashboard_view.dart`

### 14. Duplicate Import
**Issue:** `import 'dart:convert';` appeared twice in `dashboard_view.dart`.
**Fix:** Removed duplicate import.
**Files Changed:**
- `lib/features/dashboard/ui/views/dashboard_view.dart`

## Tests

- **Flutter:** 37/37 tests passed
- **Backend:** 66/66 tests passed
- **Flutter Analyze:** 60 issues found (0 errors, all info/warnings) — down from 114 issues

## Remaining Issues (Non-Critical)

- Unused imports (widget_background_refresh.dart, widget_action_menu.dart)
- Print statements in production code (should use debugPrint or logger)
- Unnecessary `.toList()` in spreads (6 files)
- Unnecessary string interpolation braces (multiple widget files)
- Dead code in widget_schema_validator.dart
- No integration tests, golden tests, or performance tests
- Many Phase 7 widgets still incomplete (backend integration)
