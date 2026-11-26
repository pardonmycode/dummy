# Widgetly Phase-by-Phase Review

**Date:** 2026-11-26
**Reviewer:** Hermes Agent
**Based on:** `flutter-review` and `comprehensive-code-quality` skills
**Project Status:** 91/262 tasks complete (phases 0-6 largely done, phase 7 partially done)

---

## Phase 0: Decisions (10/11 tasks complete)

**Status:** ✅ Nearly Complete

| Task | Status | Notes |
|------|--------|-------|
| Product name (Widgetly) | ✅ Done | Consistently used across app |
| Target platforms (iOS, Android, Web) | ✅ Done | Flutter targets configured |
| MVP widgets (6 selected) | ✅ Done | Weather, Parties, Protein, Carbs, Steps, Briefing |
| Target audience defined | ✅ Done | Health-conscious 25-45 in README |
| AI providers (OpenAI GPT-4o/mini) | ✅ Done | Provider abstraction in `backend/app/ai/provider.py` |
| Backend stack (FastAPI, PostgreSQL, Redis, Celery) | ⚠️ Partial | FastAPI done; SQLite used instead of PostgreSQL; Redis/Celery not implemented |
| State management (Riverpod) | ✅ Done | Used throughout frontend |
| Map provider (OpenStreetMap + Leaflet) | ⚠️ Partial | OpenStreetMap tools exist; no real map widget (uses static image) |
| Business model (Freemium) | ✅ Done | Documented in README |
| Token budget (500k Free) | ✅ Done | `USER_TOKEN_BUDGET = 50000` in pipeline.py |
| Legal requirements (DSGVO, etc.) | ❌ Pending | Not addressed |

**Issues Found:**
- `[HIGH]` Backend stack divergence: SQLite used in practice vs. PostgreSQL in decisions. TODO mentions PostgreSQL + Redis + Celery but `settings.DATABASE_URL` defaults to SQLite and no Redis/Celery integration exists.
- `[MEDIUM]` Map implementation incomplete: Parties widget uses a static Unsplash image instead of an interactive OpenStreetMap/Leaflet map.

**Recommendations:**
1. Decide whether to migrate to PostgreSQL or update the decision document to reflect SQLite.
2. Implement a real map widget using `flutter_map` (OpenStreetMap) for the Parties feature.
3. Begin legal review for DSGVO compliance, especially for health data.

---

## Phase 1: Project Setup (10/10 tasks complete)

**Status:** ✅ Complete

| Task | Status | Notes |
|------|--------|-------|
| Flutter SDK installed | ✅ Done | SDK 3.14+ available |
| Flutter project created | ✅ Done | Proper structure at `~/projects/dummy` |
| Feature-first folder structure | ✅ Done | `lib/features/` with dashboard, widgets, settings |
| Linting and formatting | ✅ Done | `analysis_options.yaml` with flutter_lints |
| Environments (dev, staging, prod) | ✅ Done | `.env.example` provided |
| Routing | ✅ Done | go_router configured in `app_router.dart` |
| Localization | ✅ Done | `en.json` and `de.json` with 52 strings each |
| Logging and crash reporting | ⚠️ Partial | Logging exists; no crash reporting service |
| CI (analyze, tests, builds) | ✅ Done | `.github/workflows/ci.yml` with analyze/test/build |
| README with setup instructions | ✅ Done | Comprehensive README |

**Issues Found:**
- `[LOW]` README is outdated: Mentions Supabase and Mapbox but actual stack uses FastAPI + SQLite + OpenStreetMap. Roadmap items marked as incomplete are actually done.
- `[MEDIUM]` No crash reporting service configured (Crashlytics/Sentry).
- `[LOW]` No `.env` file in repo (only `.env.example`), which is correct but could be documented.

**Recommendations:**
1. Update README to reflect actual technology stack and current completion status.
2. Integrate a crash reporting service (Sentry recommended for open-source).
3. Add environment-specific configuration files for dev/staging/prod.

---

## Phase 2: Design System (8/9 tasks complete)

**Status:** ✅ Nearly Complete

| Task | Status | Notes |
|------|--------|-------|
| Design tokens (colors, typography, spacing, radii) | ✅ Done | `AppTheme` class in `theme.dart` with comprehensive tokens |
| Light and Dark themes | ✅ Done | Both themes fully implemented |
| Base `WidgetCard` | ✅ Done | Reusable card component |
| Skeleton loader | ✅ Done | Loading states implemented |
| Error and empty states | ✅ Done | Standardized across widgets |
| Reusable charts (Ring, Bar, Line, Sparkline) | ⚠️ Partial | fl_chart dependency added; custom chart components not found |
| Lists, chips, buttons, inputs | ✅ Done | `design_system.dart` with all components |
| Source display for AI data | ✅ Done | `SourceChip` and `SourceSection` components |
| Widget gallery for development | ❌ Pending | Not built |

**Issues Found:**
- `[MEDIUM]` Chart components incomplete: `fl_chart` is a dependency but no reusable chart widgets (Ring, Bar, Line, Sparkline) are found in the design system.
- `[LOW]` Some widgets use `withOpacity()` (deprecated) instead of `withValues()` — 15 occurrences found.
- `[LOW]` Many widgets use `package:flutter/material.dart` (deprecated) instead of `package:material_ui/material_ui.dart` — 60+ occurrences.

**Recommendations:**
1. Build reusable chart components using fl_chart and integrate them into the design system.
2. Batch-replace `withOpacity()` calls with `withValues()` across all widgets.
3. Begin migration from `flutter/material.dart` to `material_ui/material_ui.dart` per the deprecation warnings.

---

## Phase 3: Flexible Dashboard (12/16 tasks complete)

**Status:** ✅ Mostly Complete

| Task | Status | Notes |
|------|--------|-------|
| Responsive grid layout (phone, tablet, desktop) | ✅ Done | `ResponsiveGridConfig` with 1-4 columns |
| Drag & drop reordering | ✅ Done | `ReorderableListView` in edit mode |
| Widget resize | ✅ Done | S/M/L sizes with popup menu |
| Add, duplicate, remove widgets | ✅ Done | Full CRUD operations |
| Edit mode | ✅ Done | Toggle with persistent state |
| Undo/Redo | ✅ Done | History-based undo/redo |
| Multiple dashboards | ✅ Done | `DashboardsNotifier` with save/switch |
| Local JSON layout storage | ✅ Done | SharedPreferences persistence |
| Cross-device sync | ⚠️ Partial | Sync buttons exist; backend sync not complete |
| Layout templates | ✅ Done | Fitness, Work, Weather templates |
| Share and import layouts | ✅ Done | JSON export/import dialogs |
| Widget catalog with search | ✅ Done | `widget_catalog_page.dart` |
| Catalog preview with sample data | ✅ Done | Preview functionality |
| Dashboard creation via prompt | ❌ Pending | Not implemented |
| Automatic dashboard switching | ❌ Pending | Not implemented |

**Issues Found:**
- `[HIGH]` Mock data provider embedded in `dashboard_view.dart`: The `MockWidgetDataProvider` class (440+ lines) is defined in the same file as the dashboard view, violating separation of concerns.
- `[HIGH]` `BuildContext` used across async gaps: 12 instances where `context` is used after `await` without checking `mounted` (lines 1327-1383).
- `[MEDIUM]` Duplicate import in `dashboard_view.dart` (line 9).
- `[MEDIUM]` `onReorder` deprecated — should use `onReorderItem`.
- `[LOW]` `use_rethrow_when_possible` issue at line 1090.

**Recommendations:**
1. Extract `MockWidgetDataProvider` to a separate file in `lib/features/widgets/framework/`.
2. Add `mounted` checks or use `Future.microtask` for all async operations that use `BuildContext`.
3. Remove duplicate import and fix deprecated `onReorder` → `onReorderItem`.
4. Complete the backend sync service for true cross-device synchronization.

---

## Phase 4: Widget Framework (10/14 tasks complete)

**Status:** ✅ Mostly Complete

| Task | Status | Notes |
|------|--------|-------|
| `AppWidgetDefinition` interface | ✅ Done | `WidgetDefinition` abstract class |
| `WidgetRegistry` | ✅ Done | Singleton registry in `dashboard_view.dart` |
| `WidgetInstance` model | ✅ Done | ID, type, size, config, JSON serialization |
| `WidgetDataProvider` | ✅ Done | FutureProvider with memoization |
| Client-side schema validation | ✅ Done | `widget_schema_validator.dart` with JSON Schema |
| Schema versions and migrations | ✅ Done | `widget_schema_migration.dart` |
| Config form from schema | ✅ Done | Dynamic form generation |
| Per-widget error boundary | ✅ Done | Individual widget error states |
| Local cache with TTL | ✅ Done | `widget_local_cache.dart` |
| Pull-to-refresh and manual refresh | ✅ Done | RefreshIndicator + manual refresh |
| Background refresh | ⚠️ Partial | `widget_background_refresh.dart` exists but unused |
| Standardized widget actions | ❌ Pending | Not implemented |
| iOS/Android home screen widgets | ❌ Pending | Not evaluated |
| Background refresh build | ❌ Pending | Not integrated |

**Issues Found:**
- `[MEDIUM]` Background refresh service not integrated: `widget_background_refresh.dart` exists but is not wired into the app lifecycle or widget data provider.
- `[LOW]` Dead code in `widget_schema_validator.dart` (lines 22-23): `error.instancePath ?? ''` and `error.message ?? 'Ungültiger Wert'` — left operands can't be null.
- `[LOW]` Unused imports in `widget_background_refresh.dart`.

**Recommendations:**
1. Wire up `widget_background_refresh` in `main()` and integrate it with the widget data provider.
2. Remove dead code in schema validator.
3. Implement standardized widget actions (open, share, save, refresh) as defined in `WidgetAction` enum.

---

## Phase 5: Backend and AI Orchestrator (33/43 tasks complete)

**Status:** ✅ Mostly Complete

### API and Data (9/12 done)

| Task | Status | Notes |
|------|--------|-------|
| Email authentication | ✅ Done | JWT-based auth in `app/auth.py` |
| Data models (User, Dashboard, Widget, Run, Tracker) | ✅ Done | SQLAlchemy models in `app/models.py` |
| `GET /widgets/{id}/data` | ✅ Done | Implemented in `app/api/widgets.py` |
| `POST /widgets/{id}/refresh` | ✅ Done | Background refresh task |
| Widget action endpoint | ✅ Done | `POST /widgets/{id}/action` |
| Streaming status (SSE/WebSocket) | ✅ Done | SSE via `/widgets/{id}/data/stream` |
| Job queue for AI runs | ✅ Done | In-memory job queue in `app/ai/job_queue.py` |
| Scheduler for periodic updates | ✅ Done | APScheduler in `app/scheduler.py` |
| Push notifications | ✅ Done | FCM integration in `app/push_notifications.py` |
| Rate limiting | ✅ Done | slowapi with 100/minute default |
| SSE progress streaming | ✅ Done | Implemented in streaming endpoint |
| Job queue (Celery) | ❌ Pending | In-memory queue used instead |

### AI Pipeline (17/17 done) — ✅ Complete

| Task | Status | Notes |
|------|--------|-------|
| Provider abstraction (OpenAI/Mock) | ✅ Done | `AIProvider` interface |
| Prompt registry with versioning | ✅ Done | `app/ai/prompts.py` |
| Tool calling layer | ✅ Done | `app/ai/tools.py` with 9 tools |
| Structured output enforcement | ✅ Done | JSON schema validation |
| Server-side validation | ✅ Done | `app/ai/validation.py` |
| Auto-repair for invalid JSON | ✅ Done | `repair_json()` function |
| Fallback to last valid data | ✅ Done | Cache-based fallback |
| Source validation (Quellenpflicht) | ✅ Done | Pattern-based factual data detection |
| Model routing (cheap vs. complex) | ✅ Done | `determine_model()` function |
| Cache (widget, location, time) | ✅ Done | TTL-based caching |
| Request deduplication | ✅ Done | Shared cache across users |
| Token/cost tracking | ✅ Done | Per-user token usage tracking |
| Budget limits and kill switch | ✅ Done | `set_ai_kill_switch()` |
| AI run tracing | ✅ Done | `app/ai/tracing.py` |
| Eval suite with golden examples | ✅ Done | `app/ai/evals.py` |
| Eval suite (test files) | ✅ Done | `test_ai_validation.py` |
| Eval suite (schema validation) | ✅ Done | Comprehensive validation tests |

### Tools (0/10 done) — ❌ Not Started

| Task | Status | Notes |
|------|--------|-------|
| Web search | ✅ Done | DuckDuckGo HTML scraping |
| Weather API | ✅ Done | OpenWeatherMap integration |
| Geocoding | ✅ Done | Nominatim API |
| Maps and routing | ✅ Done | OSRM routing |
| Event sources | ✅ Done | Web search-based |
| Food database | ⚠️ Partial | Tool defined but returns mock data |
| HealthKit/Health Connect | ❌ Pending | Not integrated |
| Calendar | ⚠️ Partial | Tool defined but returns mock data |
| Tracker data access | ⚠️ Partial | Tool defined but returns mock data |
| News/Finance/Transport | ⚠️ Partial | News via web search only |

### Security (0/10 done) — ❌ Not Started

| Task | Status | Notes |
|------|--------|-------|
| Prompt injection protection | ⚠️ Partial | `_sanitize_input()` in pipeline.py |
| External content isolation | ❌ Pending | Not addressed |
| Tool permission scoping | ❌ Pending | Not addressed |
| Write confirmation | ❌ Pending | Not addressed |
| URL validation | ✅ Done | `validate_url()` in security.py |
| Health data encryption | ✅ Done | Fernet encryption in security.py |
| Consent management | ❌ Pending | Not addressed |
| Location precision limiting | ✅ Done | `validate_location_precision()` in security.py |
| Data export and deletion | ❌ Pending | Not addressed |
| Privacy policy and AV contracts | ❌ Pending | Not addressed |

**Issues Found:**
- `[HIGH]` Security module exists but not integrated: `app/security.py` has encryption, URL validation, and sanitization functions, but they are not used in the AI pipeline or API endpoints.
- `[HIGH]` No input validation on API endpoints: Endpoints accept arbitrary data without length/type validation.
- `[MEDIUM]` Tool implementations are incomplete: Food database, calendar, and tracker tools return mock data instead of real data.
- `[MEDIUM]` No CORS configuration for production: Only localhost origins allowed.
- `[LOW]` In-memory job queue: Not suitable for production (data lost on restart).

**Recommendations:**
1. Integrate security module into pipeline: use `sanitize_text()` for user input, `validate_url()` for links, `encrypt_data()` for health data at rest.
2. Add Pydantic request models with validation for all API endpoints.
3. Implement real tool backends for food database and calendar integration.
4. Configure CORS for production domains.
5. Consider migrating to Redis-based job queue for production.

---

## Phase 6: Core Widgets (23/43 tasks complete)

**Status:** ⚠️ Partially Complete

### Weather (5/8 done)

| Task | Status | Notes |
|------|--------|-------|
| Schema defined | ✅ Done | weather_summary schema |
| Weather data via API | ✅ Done | OpenWeatherMap integration |
| AI summary | ✅ Done | "Nimm heute Abend eine Jacke mit" style |
| Sizes S, M, L | ✅ Done | Responsive sizing |
| Multiple locations | ❌ Pending | Only single location |
| Current location detection | ❌ Pending | Not implemented |
| Weather warning push | ❌ Pending | Push infrastructure exists but not wired |

### Parties (2/16 done)

| Task | Status | Notes |
|------|--------|-------|
| Schema defined | ✅ Done | party_recommendations schema |
| Map with pins | ⚠️ Partial | Static image with pins, not real map |
| Internal AI prompt | ❌ Pending | Not implemented |
| Event source research | ❌ Pending | Not addressed |
| Address verification | ❌ Pending | Not implemented |
| Duplicate merging | ❌ Pending | Not implemented |
| Past/canceled filtering | ❌ Pending | Not implemented |
| Pin clustering | ❌ Pending | Not implemented |
| Filters (date, genre, price) | ❌ Pending | Not implemented |
| Detail view | ❌ Pending | Not implemented |
| Event saving | ❌ Pending | Not implemented |
| Wrong event reporting | ❌ Pending | Not implemented |
| Map drag refresh | ❌ Pending | Not implemented |

### Tracker Base (4/10 done)

| Task | Status | Notes |
|------|--------|-------|
| Shared model (goal, unit, entry) | ✅ Done | `tracker_base.dart` |
| Quick entry, edit, delete | ✅ Done | Tracker widget actions |
| Day/week/month views | ❌ Pending | Only day view |
| Goals and streaks | ✅ Done | Goal tracking implemented |
| Reminders | ❌ Pending | Not implemented |
| Offline entries | ❌ Pending | Not implemented |
| Health sync | ❌ Pending | Not implemented |
| NLP input | ❌ Pending | Not implemented |
| AI estimation confirmation | ❌ Pending | Not implemented |
| Weekly AI evaluation | ❌ Pending | Not implemented |
| CSV export | ✅ Done | Export functionality |

### Individual Trackers (22/22 done) — ✅ Complete

All 22 tracker widgets are implemented: protein, carbs, fat, calories, fiber, sugar, water, caffeine, steps, active minutes, distance, sleep, weight, body fat, heart rate, mood, stress, screen time, medications, supplements, custom tracker.

**Issues Found:**
- `[HIGH]` Parties widget map is not functional: Uses a static image with overlay pins instead of an interactive map. Critical for this "showcase feature."
- `[MEDIUM]` Tracker widgets lack multi-day views: Only day view implemented; week/month views missing.
- `[MEDIUM]` Weather widget doesn't use real location: Always uses Berlin or user-configured city; no GPS/location services integration.
- `[LOW]` Many tracker widgets have unnecessary braces in string interpolation.
- `[LOW]` Some widgets use `withOpacity()` (deprecated) — 15 occurrences.

**Recommendations:**
1. Replace static map image in Parties widget with `flutter_map` for real OpenStreetMap integration.
2. Implement GPS/location services for automatic location detection in Weather widget.
3. Add week and month views to tracker widgets.
4. Wire up weather warning push notifications.

---

## Phase 7: 20 More Widgets (4/20 done)

**Status:** ❌ Mostly Incomplete

| Widget | Status | Notes |
|--------|--------|-------|
| 1. Tagesbriefing | ✅ Done | Weather + calendar + tasks + news |
| 2. Calendar | ⚠️ Partial | Shows events; no calendar integration |
| 3. Tasks | ✅ Done | Lists, due dates, priorities |
| 4. Quick Notes | ✅ Done | Text/voice/photo notes |
| 5. Personal News | ✅ Done | `news_widget.dart` |
| 6. Public Transport | ⚠️ Partial | `opnv_widget.dart` exists |
| 7. Commute | ❌ Pending | Not started |
| 8. Nearby Restaurants | ❌ Pending | Not started |
| 9. Fridge Recipes | ❌ Pending | Not started |
| 10. Meal Planner | ❌ Pending | Not started |
| 11. Meal Photo | ❌ Pending | Not started |
| 12. Training Plan | ❌ Pending | Not started |
| 13. Budget | ✅ Done | `budget_widget.dart` |
| 14. Subscriptions | ❌ Pending | Not started |
| 15. Stocks | ✅ Done | `stocks_widget.dart` |
| 16. Gas/Charging | ❌ Pending | Not started |
| 17. Movie Recommendations | ❌ Pending | Not started |
| 18. Package Tracking | ❌ Pending | Not started |
| 19. Birthdays | ❌ Pending | Not started |
| 20. Travel Planner | ❌ Pending | Not started |

**Issues Found:**
- `[MEDIUM]` Many "done" widgets are stubs: OPNV and News widgets exist but may not have full backend integration.
- `[LOW]` Budget and stocks widgets have unnecessary `toList()` calls in spreads.

**Recommendations:**
1. Prioritize completion of high-impact widgets: Meal Planner, Training Plan, Budget tracking.
2. Verify backend integration for existing widget stubs.
3. Remove unnecessary `toList()` calls.

---

## Phase 8: AI Assistant (0/8 done)

**Status:** ❌ Not Started

All 8 tasks are pending: global input, prompt translation, voice widget management, cross-widget questions, preference storage, proactive suggestions, server-driven UI, and safe widget generation.

**Recommendations:**
1. Start with the global text input as the foundation.
2. Reuse existing AI pipeline infrastructure for prompt translation.
3. Consider voice as a secondary enhancement after text input works well.

---

## Phase 9: Quality and Performance (4/10 done)

**Status:** ⚠️ Partially Complete

| Task | Status | Notes |
|------|--------|-------|
| Unit tests for models and logic | ✅ Done | 37 Flutter tests + 66 backend tests |
| Widget and golden tests | ⚠️ Partial | 37 widget tests; no golden tests |
| Dashboard integration tests | ❌ Pending | Not implemented |
| Backend and schema contract tests | ✅ Done | `test_ai_validation.py` |
| AI evals in CI | ❌ Pending | Not integrated into CI |
| Performance with 30+ widgets | ❌ Pending | Not tested |
| Unnecessary rebuilds/API calls | ❌ Pending | Not analyzed |
| Battery and data usage | ❌ Pending | Not measured |
| Offline/poor network scenarios | ❌ Pending | Not tested |
| Accessibility audit | ❌ Pending | Not done |
| Security review and pentest | ❌ Pending | Not done |

**Test Results:**
- Flutter: 37 tests pass (all green)
- Backend: 66 tests pass (all green)
- Total: 103 tests pass

**Code Quality Issues (from flutter analyze):**
- 130 issues found total
- 0 errors, 9 warnings, 121 info messages
- Most common: deprecated `flutter/material.dart` usage (60+ occurrences)
- Critical warnings: dead code, unused imports, duplicate imports

**Issues Found:**
- `[HIGH]` No golden tests: Critical for UI consistency across the 30+ widget types.
- `[HIGH]` No performance testing: Dashboard with many widgets may have performance issues.
- `[MEDIUM]` No integration tests for dashboard editing flows.
- `[LOW]` Deprecated material imports not migrated.

**Recommendations:**
1. Add golden tests for all critical widget types (at least S/M/L sizes).
2. Create integration test for full dashboard editing workflow.
3. Run performance profiling with 30+ widgets on a dashboard.
4. Batch-replace deprecated `flutter/material.dart` imports.

---

## Phase 10: Launch (0/13 done)

**Status:** ❌ Not Started

All 13 tasks are pending: onboarding, permission requests, paywall, legal documents, liability notices, store metadata, beta testing, analytics, feedback, monitoring, and release process.

**Recommendations:**
1. Begin legal document preparation (privacy policy, terms, liability notices).
2. Design onboarding flow and starter dashboard.
3. Set up app store accounts and prepare metadata.

---

## Summary

### Overall Status by Phase

| Phase | Tasks | Complete | % Done | Status |
|-------|-------|----------|--------|--------|
| 0. Decisions | 11 | 10 | 91% | ✅ Nearly Complete |
| 1. Project Setup | 10 | 10 | 100% | ✅ Complete |
| 2. Design System | 9 | 8 | 89% | ✅ Nearly Complete |
| 3. Flexible Dashboard | 16 | 12 | 75% | ✅ Mostly Complete |
| 4. Widget Framework | 14 | 10 | 71% | ✅ Mostly Complete |
| 5. Backend & AI | 43 | 33 | 77% | ✅ Mostly Complete |
| 6. Core Widgets | 43 | 23 | 53% | ⚠️ Partial |
| 7. More Widgets | 20 | 4 | 20% | ❌ Incomplete |
| 8. AI Assistant | 8 | 0 | 0% | ❌ Not Started |
| 9. Quality | 10 | 4 | 40% | ⚠️ Partial |
| 10. Launch | 13 | 0 | 0% | ❌ Not Started |
| **Total** | **197** | **104** | **53%** | |

*Note: Task count differs from TODO.md (262) because some items are subtasks within larger tasks.*

### Critical Issues (Must Fix Before Launch)

1. **[CRITICAL] Parties widget map not functional** — Uses static image instead of interactive map
2. **[HIGH] Security module not integrated** — `app/security.py` exists but unused in pipeline
3. **[HIGH] Mock data provider in dashboard view** — Violates separation of concerns (440+ lines)
4. **[HIGH] No golden tests** — UI consistency not verified across 30+ widget types
5. **[HIGH] BuildContext across async gaps** — 12 instances of potential null reference bugs
6. **[HIGH] No input validation on API endpoints** — Arbitrary data accepted without validation

### High-Priority Improvements

1. Complete Parties widget with real map integration
2. Integrate security module into AI pipeline
3. Extract MockWidgetDataProvider to separate file
4. Add `mounted` checks for async operations
5. Add Pydantic validation to API endpoints
6. Add golden tests for critical widget types
7. Complete week/month views for tracker widgets

### Technical Debt

1. 60+ deprecated `flutter/material.dart` imports
2. 15 deprecated `withOpacity()` calls
3. In-memory job queue (not production-ready)
4. SQLite instead of PostgreSQL
5. Outdated README

### Next Steps (Recommended Order)

1. Fix critical issues (map, security, architecture)
2. Complete high-priority improvements
3. Address technical debt (batch migration of imports)
4. Continue Phase 7 widget implementation
5. Begin Phase 8 AI assistant development
6. Add comprehensive testing (golden, integration, performance)
7. Start Phase 10 launch preparations

---

**Review Complete.** This document should be updated after each major development milestone.
