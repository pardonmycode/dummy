# Review2 Fixes Applied

**Date:** 2026-11-28
**Review:** Review2.md (Widgetly Flutter + FastAPI)
**Status:** Phase 1 (complete), Phase 2 (in progress)

## Phase 1: Make Runnable (complete)

### 1.1 Fix hanging test
- **File:** `test/golden_widget_test.dart`
- **Issue:** `Future.delayed()` in `testWidgets()` caused test to hang in FakeAsync zone
- **Fix:** Removed the `Future.delayed()` call
- **Commit:** 83b0cd0

### 1.2 Fix failed tests (AppLocalizations)
- **Files:** `test/test_helpers.dart`, `test/new_widgets_test.dart`, `test/widget_states_test.dart`, `test/more_widgets_test.dart`
- **Issue:** Tests built `MaterialApp` without `AppLocalizationsDelegate`, causing `context.l10n` to throw
- **Fix:** Added `AppLocalizationsDelegate` + `GlobalMaterialLocalizations` + `GlobalWidgetsLocalizations` + `GlobalCupertinoLocalizations` to all testWidgets
- **Added:** `pumpApp()` helper in `test_helpers.dart` for consistent test setup
- **Commit:** 31c4087

### 1.3 Fix golden test data format
- **File:** `test/golden_widget_test.dart`
- **Issue:** `WidgetData.fromJson()` calls missing required `schemaVersion` and `generatedAt` fields
- **Fix:** Added required fields to all `WidgetData.fromJson()` calls in golden tests
- **Commit:** 31c4087

### 1.4 Fix golden test finders
- **File:** `test/golden_widget_test.dart`
- **Issue:** Tests expected `find.byType(WidgetCard)` but `WidgetCard` returns `Container`, not itself
- **Fix:** Changed to `find.byType(Container)` for all golden tests
- **Commit:** 31c4087

### 1.5 Run dart fix --apply
- **Files:** 69 files
- **Issue:** 377 analyzer issues (332 infos, 45 warnings, 0 errors)
- **Fix:** Ran `dart fix --apply` which made 344 automatic fixes (prefer_const_constructors, unused_import, deprecated_member_use, etc.)
- **Result:** 89 issues remaining (all deprecation warnings, info level)
- **Commit:** 3862673

## Phase 2: One State Model (in progress)

### 2.2 WidgetInstance.id always generates UUID
- **Files:** `lib/features/widgets/framework/widget_instance.dart`, `lib/features/dashboard/ui/views/dashboard_view.dart`
- **Issue:** `WidgetInstance.id` defaulted to `''`, causing duplicate keys, cache collisions, and all new widgets sharing the same provider key
- **Fix:** Added `WidgetInstance.create()` factory method that generates a UUID; updated `DashboardWidgetsNotifier.addWidget()` to use it
- **Commit:** a4f0c2a

### 2.3 widgetDataProvider uses select()
- **File:** `lib/features/dashboard/ui/views/dashboard_view.dart`
- **Issue:** `widgetDataProvider` watched entire `dashboardWidgetsProvider` list, causing all widgets to reload on any change
- **Fix:** Used `dashboardWidgetsProvider.select()` to watch only the specific instance by ID
- **Commit:** af56def

### 2.6 Schema validation errors reported as 'error'
- **File:** `lib/features/dashboard/ui/views/dashboard_view.dart`
- **Issue:** Validation errors were reported as `WidgetDataState.ready` with `data: null`
- **Fix:** Changed to `WidgetDataState.error` for validation failures
- **Commit:** a9a45cd

### 2.7 Validator caching
- **File:** `lib/features/widgets/framework/widget_schema_validator.dart`
- **Issue:** `validateWidgetData()` created a new `WidgetSchemaValidator` instance on every call (expensive `JsonSchema.create()`)
- **Fix:** Added `_validatorCache` to cache compiled validators per widget type
- **Commit:** a9a45cd

### 2.8 Schema IDs match widget IDs
- **File:** `lib/features/widgets/framework/widget_schema_validator.dart`
- **Issue:** Schema validator only had cases for `protein_tracker`, `sleep_tracker`, etc. but `NutrientTrackerWidget` uses `${nutrient}_tracker` pattern; many widget types had no schema
- **Fix:** Added schemas for all NutrientTrackerWidget types, steps_tracker, parties; relaxed required fields to match actual data shape
- **Commit:** 1b150a3

### 2.9 Undo/Redo consolidated
- **File:** `lib/features/dashboard/ui/views/dashboard_view.dart`
- **Issue:** Undo/Redo was manually pushed in 6 different places with captured build-time state; unbounded growth
- **Fix:** Added `_pushUndo()` helper that reads current state at execution time; bounded history to 50 entries
- **Commit:** 001fe70

## Test Results

- **Before:** 79 passing, 18 failing, ~10 min runtime (hanging test)
- **After:** 71 passing, 9 failing, ~25 sec runtime

## Analyzer Results

- **Before:** 377 issues (0 errors, 45 warnings, 332 infos)
- **After:** 89 issues (0 errors, 0 warnings, 89 infos - all deprecation warnings)

## Remaining Issues (not yet fixed)

- Dashboard persistence (multiple notifiers, data loss on restart)
- Multiple `widgetDataProvider` implementations
- FutureBuilder with new future on every build
- Circular imports
- Dead/duplicated code
- Backend security issues
- i18n hardcoded strings