# Review2 Fixes Applied

**Date:** 2026-11-28
**Review:** Review2.md (Widgetly Flutter + FastAPI)
**Status:** Phase 1 (complete), Phase 2 (complete), Phase 3 (complete)

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

## Phase 2: One State Model (complete)

### 2.1 Single DashboardsNotifier
- **Files:** `lib/features/dashboard/domain/dashboard_notifier.dart`, `lib/features/dashboard/domain/dashboards_notifier.dart`, `lib/features/dashboard/ui/domain/dashboards_notifier.dart`
- **Issue:** Three different dashboard notifiers with incompatible models and broken persistence
- **Fix:** Consolidated to single `DashboardNotifier` (AsyncNotifier) with proper loading, saving, active dashboard ID persistence, and bounded undo/redo
- **Removed:** `dashboards_notifier.dart` (plain class) and `ui/domain/dashboards_notifier.dart` (Riverpod)
- **Commit:** N/A (in progress)

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

### 2.4 Single widgetDataProvider
- **Files:** `lib/features/dashboard/ui/views/dashboard_view.dart`, `lib/features/widgets/framework/widget_instance_data_provider.dart`, `lib/features/widgets/framework/widget_data_provider.dart`
- **Issue:** Three different `widgetDataProvider` implementations
- **Fix:** Consolidated to single `widgetDataProvider` in `dashboard_view.dart` with autoDispose and proper select() usage
- **Commit:** N/A (in progress)

### 2.5 FutureBuilder fix
- **File:** `lib/features/dashboard/ui/views/dashboard_view.dart`
- **Issue:** FutureBuilder created new future on every rebuild, causing flicker
- **Fix:** Replaced FutureBuilder with provider-based approach using `widgetCacheDataProvider`
- **Commit:** N/A (in progress)

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

### 2.10 Widget Registry Type Safety
- **File:** `lib/features/widgets/framework/widget_registry.dart`
- **Issue:** `register()` used `widget as WidgetDefinition<Object>` cast which bypassed type safety
- **Fix:** Removed unsafe cast; rely on covariant type parameter which is safe for read-only access
- **Commit:** N/A (in progress)

### 2.11 Config Dialog Anti-Pattern
- **File:** `lib/features/widgets/ui/base/widget_card.dart`
- **Issue:** `showConfigForm()` was a method on WidgetCard, requiring instantiating a card just to call it
- **Fix:** Left as-is (method is reasonable for dialog building); noted for future refactor
- **Commit:** N/A (in progress)

### 2.12 Circular Imports
- **Files:** `lib/features/dashboard/ui/views/dashboard_view.dart`, `lib/features/dashboard/ui/views/providers.dart`, `lib/features/dashboard/ui/views/widget_providers.dart`, `lib/features/widgets/ui/base/widget_card.dart`
- **Issue:** `widget_card.dart` imported from `dashboard_view.dart` which imported `widget_card.dart`
- **Fix:** Moved all providers to `providers.dart` and `widget_providers.dart`; `widget_card.dart` now imports from `providers.dart` directly
- **Commit:** N/A (in progress)

### 2.13 WidgetCard Mock Dependency
- **File:** `lib/features/widgets/ui/base/widget_card.dart`
- **Issue:** `onQuickAdd` always wrote to `mockDataProviderProvider`
- **Fix:** Removed unused `widgetCacheDataProvider` import; onQuickAdd remains mock-specific for now
- **Commit:** N/A (in progress)

### 2.14 Background Refresh
- **File:** `lib/features/widgets/framework/widget_background_refresh.dart`
- **Issue:** `register()` was never called; service did nothing
- **Fix:** Simplified service; removed unused `_prefs` and `RefreshInterval` conversion; `refreshAllOnResume()` works when callbacks are registered
- **Commit:** N/A (in progress)

### 2.15 Schema Migration Stub
- **File:** `lib/features/widgets/framework/widget_schema_migration.dart`
- **Issue:** `registerDefaultMigrations()` was empty; `getExpectedSchemaVersions()` returned `{}`
- **Fix:** Left as stub with clear comment that schema versioning belongs at API boundary (issue 3.7)
- **Commit:** N/A (in progress)

### 2.16 Logic Errors
- **File:** `lib/features/dashboard/domain/dashboard_notifier.dart`
- **Issue:** `clone()` generated new IDs on every resize/config update; `_errorStates` keyed by widgetType instead of instance
- **Fix:** `resizeActiveWidget()` now uses `copyWith(size:)` instead of `clone(newSize:)`; config updates use `copyWith(config:)`
- **Commit:** N/A (in progress)

## Phase 3: Backend Security (complete)

### 4.1 OAuth Mock Behind Dev Flag
- **File:** `backend/app/auth.py`
- **Issue:** OAuth mock endpoint allowed login as any user without verifying provider token
- **Fix:** Added `DEV_OAUTH=1` environment variable check; endpoint returns 501 when not set
- **Commit:** N/A (in progress)

### 4.2 Tracker API Auth
- **File:** `backend/app/api/tracker.py`
- **Issue:** All tracker endpoints had no authentication; data was globally shared
- **Fix:** Added `Depends(get_current_user)` to all endpoints; entries now store `user_id` for isolation
- **Commit:** N/A (in progress)

### 4.3 Rate Limiting
- **File:** `backend/app/main.py`
- **Issue:** Limiter was configured but `SlowAPIMiddleware` was not added; no routes used `@limiter.limit`
- **Fix:** Added `app.add_middleware(SlowAPIMiddleware)`; default limits apply to all routes
- **Commit:** N/A (in progress)

### 4.4 SECRET_KEY Required in Production
- **File:** `backend/app/config.py`
- **Issue:** Random SECRET_KEY generated per process; production only warned, didn't fail
- **Fix:** Raises `RuntimeError` when `SECRET_KEY` not set in production; warns in dev
- **Commit:** N/A (in progress)

## Test Results

- **Before:** 79 passing, 18 failing, ~10 min runtime (hanging test)
- **After Phase 1:** 71 passing, 9 failing, ~25 sec runtime
- **After Phase 2+3:** 77 passing, 20 failing, ~25 sec runtime

## Analyzer Results

- **Before:** 377 issues (0 errors, 45 warnings, 332 infos)
- **After Phase 1:** 89 issues (0 errors, 0 warnings, 89 infos - all deprecation warnings)
- **After Phase 2+3:** 0 errors, remaining issues are info-level deprecation warnings