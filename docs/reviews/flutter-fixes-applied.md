# Flutter Fixes Applied (Phase 1)

**Date:** 2026-11-27  
**Commit Range:** `d558b7f` → `b78d17a`  
**Total Tests:** 50 passing

## Issues Fixed

### 1.1 Layout overwrites on restart
- **Problem:** `WidgetInstance.fromJson` failed to deserialize `gridPosition` map after JSON round-trip.
- **Fix:** Fixed map value casting in `fromJson`.
- **Test:** `test/widget_instance_json_test.dart`

### 1.2 Move down by one position does nothing
- **Problem:** Double index adjustment in drag-and-drop.
- **Fix:** Removed redundant adjustment in `moveWidget`.
- **Test:** `test/widget_move_test.dart`

### 1.3 Refresh button and pull-to-refresh do nothing
- **Problem:** `FutureBuilder` created a new Future on every build, so provider invalidation had no effect.
- **Fix:** Replaced `FutureBuilder` with `ref.watch(widgetDataProvider(instance.id))`. Pull-to-refresh now invalidates all widget data providers.
- **Files:** `lib/features/dashboard/ui/views/dashboard_view.dart`

### 1.4 Multiple dashboards are a facade
- **Problem:** `_getActiveId()` always returned null; `setActive` stored nothing; provider created via `Provider` not `NotifierProvider`.
- **Fix:** Changed to `NotifierProvider`, added `_activeId` field, proper `setActive` implementation.
- **Files:** `lib/features/dashboard/ui/domain/dashboards_notifier.dart`, `lib/features/dashboard/ui/views/dashboard_view.dart`

### 1.5 Sync messages never appear
- **Problem:** `syncContext.mounted` checked after `Navigator.pop`, always false.
- **Fix:** Capture `ScaffoldMessenger.of(context)` before popping, use that to show messages.
- **Files:** `lib/features/dashboard/ui/views/dashboard_view.dart`

### 1.6 Copy doesn't copy to clipboard
- **Problem:** Only showed "copied" snackbar, didn't use `Clipboard`.
- **Fix:** Added `await Clipboard.setData(ClipboardData(text: layoutJson))`.
- **Files:** `lib/features/dashboard/ui/views/dashboard_view.dart`

### 1.7 Templates use wrong widget IDs
- **Problem:** Used `'steps'` and `'water'` instead of `'steps_tracker'` and `'water_tracker'`. Also typo "Produktivitäts-Widlets".
- **Fix:** Corrected IDs and typo.
- **Test:** `test/template_ids_test.dart`

### 1.8 Config dialog issues
- **Problem:** Bool switch didn't repaint; controllers disposed after `Navigator.pop`.
- **Fix:** Wrapped form in `StatefulBuilder`, dispose controllers after `showDialog` completes via `.then()`.
- **Files:** `lib/features/widgets/ui/base/widget_card.dart`

### 1.9 Water tracker quick add does nothing
- **Problem:** Entry added to throwaway `TrackerBase` object.
- **Fix:** Added `onQuickAdd` callback parameter to `WidgetDefinition.buildView`, wired through `WidgetCard` to `MockWidgetDataProvider.addEntry` + `ref.invalidate()`.
- **Files:** 34 files (all widget definitions + framework + dashboard view)

### 1.10 Map violates OSM tile usage policy
- **Problem:** Used `{s}` subdomains without permission.
- **Fix:** Removed subdomains, added `userAgentPackageName`.
- **Files:** `lib/features/widgets/ui/types/parties/parties_widget.dart`

### 1.11 Four widgets get no mock data
- **Problem:** `steps_tracker`, `water_tracker`, `carbs_tracker`, and `parties` returned empty data.
- **Fix:** Added mock data for all four widget types with proper schema.
- **Test:** `test/mock_data_missing_widgets_test.dart`

## Phase 1 Status: ✅ Complete

All 11 Phase 1 issues have been fixed with failing tests first, proper implementations, and all tests passing. Ready to proceed to Phase 2.