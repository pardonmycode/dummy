# Widgetly Phase-by-Phase Code Quality Review

**Date:** November 26, 2026
**Reviewer:** Hermes Agent
**Methodology:** flutter-review + comprehensive-code-quality skills
**Build Health:** Flutter analyze: 114 issues (0 errors, 9 warnings, 105 info) | Flutter tests: 37/37 passed | Backend tests: 66/66 passed

---

## Phase 0: Entscheidungen (Decisions)

**Status:** 10/11 complete (legal requirements pending)

| Severity | Count | Findings |
|----------|-------|----------|
| CRITICAL | 0 | - |
| HIGH | 0 | - |
| MEDIUM | 0 | - |
| LOW | 1 | Legal requirements (DSGVO, health data, scraping) not yet addressed |

**Findings:**

[LOW] Legal compliance not finalized
- File: TODO.md:46
- Issue: DSGVO, health data regulations, location data, and scraping legalities not yet clarified. This is a risk for production launch but not a code issue.
- Fix: Consult legal counsel or prepare privacy documentation before launch.

**Assessment:** All critical architecture decisions are documented and reflected in the codebase (Riverpod, FastAPI, OpenAI, OSM). Low risk.

---

## Phase 1: Projekt-Setup

**Status:** 10/10 complete

| Severity | Count | Findings |
|----------|-------|----------|
| CRITICAL | 0 | - |
| HIGH | 0 | - |
| MEDIUM | 1 | Weak linting configuration |
| LOW | 2 | Unused dependencies, no strict analysis |

**Findings:**

[MEDIUM] Lint rules too permissive
- File: analysis_options.yaml
- Issue: Only uses default flutter_lints without any additional strict rules. `avoid_print` is commented out (not enforced).
- Fix: Enable `avoid_print`, add `prefer_final_fields`, `always_specify_types`, and other strict lints.

[LOW] No strict static analysis configured
- File: analysis_options.yaml
- Issue: Missing `errors:` section to treat certain lints as errors.
- Fix: Add `analyzer.errors: avoid_print: warning` and similar strictness settings.

[LOW] Potentially unused dependencies
- File: pubspec.yaml
- Issue: Dependencies like `fluttertoast` and `material_design_icons_flutter` should be verified as used.
- Fix: Run `flutter pub deps` and verify all imports are active.

**Build Health:**
- ✅ Feature-first folder structure: `lib/features/{dashboard,widgets,settings}`
- ✅ CI configured (.github/workflows/ci.yml)
- ✅ Environments defined (dev/staging/prod)
- ✅ Routing via go_router
- ✅ Localization via intl + flutter_localizations
- ✅ README with setup instructions

**Assessment:** Solid foundation. Minor improvements to linting strictness recommended.

---

## Phase 2: Design System

**Status:** 8/9 complete (widget gallery pending)

| Severity | Count | Findings |
|----------|-------|----------|
| CRITICAL | 0 | - |
| HIGH | 1 | Material-UI migration incomplete |
| MEDIUM | 2 | Deprecated widget usage, hardcoded values |
| LOW | 3 | Minor style issues |

**Findings:**

[HIGH] Material-UI migration incomplete (massive deprecation warnings)
- Files: All 30+ widget files import `package:flutter/material.dart`
- Issue: 70+ `deprecated_member_use` warnings — the entire codebase still uses Flutter's Material widgets while `material_ui` is declared as a dependency. Both export the same symbols (MaterialApp, ThemeData, etc.) creating ambiguity risk.
- Fix: Complete the migration per comprehensive-code-quality skill: use import prefixes (`import 'package:flutter/material.dart' as flutter;`), replace standard Material widgets with material_ui equivalents, or remove material_ui dependency if not actually needed.

[MEDIUM] Hardcoded colors in _buildPlaceholder
- File: lib/features/dashboard/ui/views/dashboard_view.dart:671-687
- Issue: Uses `Colors.white`, `Colors.grey.shade200` instead of theme tokens.
- Fix: Use `AppTheme.lightBackground` or `Theme.of(context).colorScheme`.

[MEDIUM] Missing design system for empty states
- Issue: Widget empty states show "empty" text without consistent visual treatment.
- Fix: Build dedicated EmptyState component in design_system.dart.

[LOW] Unnecessary string interpolation braces
- Files: calories_tracker_widget.dart:53, carbs_tracker_widget.dart:99, heart_rate_tracker_widget.dart:55, etc.
- Issue: Multiple instances of `{$variable}` where `${variable}` is not needed.
- Fix: Remove unnecessary braces.

**Assessment:** Design system core is solid (tokens, themes, WidgetCard, loaders). The Material-UI migration is the biggest open item — it's creating massive technical debt in the form of 70+ deprecation warnings.

---

## Phase 3: Flexibles Dashboard

**Status:** 12/18 complete

| Severity | Count | Findings |
|----------|-------|----------|
| CRITICAL | 0 | - |
| HIGH | 3 | BuildContext across async gaps, deprecated API, oversized widget |
| MEDIUM | 2 | Missing const, error handling |
| LOW | 1 | Dead code |

**Findings:**

[HIGH] BuildContext used across async gaps (multiple occurrences)
- File: lib/features/dashboard/ui/views/dashboard_view.dart:877, 878, 881, 882, 918, 919, 922, 928, 929, 933, 934
- Issue: `ScaffoldMessenger.of(context)` called after `await` without `context.mounted` check. Can crash if widget is disposed during async operation.
- Fix: Capture context before async call (`final syncContext = ctx;`), then check `if (!syncContext.mounted) return;` before using it, or use a global navigator key.

[HIGH] Deprecated `onReorder` API
- File: lib/features/dashboard/ui/views/dashboard_view.dart:393
- Issue: `onReorder` is deprecated; should use `onReorderItem`.
- Fix: Replace with `onReorderItem` callback.

[HIGH] Oversized DashboardView widget (1032 lines)
- File: lib/features/dashboard/ui/views/dashboard_view.dart
- Issue: Single file contains providers, state notifiers, grid configuration, view logic, and multiple dialogs. Violates single responsibility.
- Fix: Extract dialogs into separate files, move ResponsiveGridConfig to utils, split providers into dedicated files.

[MEDIUM] Missing `const` on static text in template dialogs
- File: lib/features/dashboard/ui/views/dashboard_view.dart:965-970
- Issue: `const Text('Fitness')` is good, but other dynamic text could be const where possible.
- Fix: Use const constructors for static widget subtrees.

[MEDIUM] Unnecessary rethrow
- File: lib/features/dashboard/ui/views/dashboard_view.dart:639
- Issue: `throw e;` should be `rethrow;` to preserve stack trace.
- Fix: Replace with `rethrow;`.

[LOW] Unused imports in widget_background_refresh.dart
- File: lib/features/widgets/framework/widget_background_refresh.dart:6, 8
- Issue: Imports `widget_instance.dart` and `widget_local_cache.dart` but doesn't use them.
- Fix: Remove unused imports.

**Assessment:** Dashboard functionality is comprehensive (drag & drop, resize, undo/redo, multiple dashboards, sync). The BuildContext async gap issues are the most critical — they can cause runtime crashes.

---

## Phase 4: Widget-Framework

**Status:** 11/16 complete

| Severity | Count | Findings |
|----------|-------|----------|
| CRITICAL | 0 | - |
| HIGH | 0 | - |
| MEDIUM | 3 | Schema validator issues, print statements, dead code |
| LOW | 2 | Unused imports |

**Findings:**

[MEDIUM] Schema validator has dead code and null-aware issues
- File: lib/features/widgets/framework/widget_schema_validator.dart:22-23
- Issue: `dead_code` and `dead_null_aware_expression` warnings indicate logic errors in validation flow.
- Fix: Review and simplify validation logic to remove unreachable branches.

[MEDIUM] Print statements in production code
- Files: lib/features/widgets/framework/widget_background_refresh.dart:12, widget_data_provider.dart:34,36, widget_schema_migration.dart:90
- Issue: `print()` used instead of proper logging framework.
- Fix: Use `debugPrint` for debug-only or integrate a logging package (e.g., `logger`).

[MEDIUM] Duplicate dashboards_notifier files
- Files: lib/features/dashboard/ui/domain/dashboards_notifier.dart AND lib/features/dashboard/domain/dashboards_notifier.dart
- Issue: Two notifiers with similar names in different directories. Potential confusion about which is used.
- Fix: Consolidate to a single location (prefer domain layer).

[LOW] Unused import in widget_action_menu.dart
- File: lib/features/widgets/ui/components/widget_action_menu.dart:3
- Issue: Imports theme.dart but doesn't use it.
- Fix: Remove unused import.

**Assessment:** Widget framework architecture is sound: registry, instance model, data provider, schema validation, caching, and migration are all implemented. The framework properly isolates widget errors so one failing widget doesn't break the dashboard.

---

## Phase 5: Backend und KI-Orchestrator

**Status:** 30/44 complete (tools, streaming, job queue, security, privacy pending)

| Severity | Count | Findings |
|----------|-------|----------|
| CRITICAL | 1 | In-memory user storage |
| HIGH | 3 | Hardcoded token, Pydantic deprecation, missing auth on /me |
| MEDIUM | 4 | Global state, broad exception catching, missing logging, CORS too wide |
| LOW | 3 | Deprecation warnings, env variable handling |

**Findings:**

[CRITICAL] Users stored in in-memory dict
- File: backend/app/api/auth.py:12-18
- Issue: `users = {...}` is an in-memory dictionary. All registered users are lost on server restart. Test credentials are hardcoded with a real bcrypt hash.
- Fix: Store users in PostgreSQL database with proper User model. Use environment variable for demo credentials.

[HIGH] Hardcoded mock token in /me endpoint
- File: backend/app/api/auth.py:64
- Issue: `get_user_from_token("mock_token_123")` — the /me endpoint uses a hardcoded token instead of reading the Authorization header from the request.
- Fix: Accept `Authorization: Bearer <token>` header and validate it properly.

[HIGH] Pydantic V1-style validator deprecated
- File: backend/app/api/widgets.py:34
- Issue: `@validator('widget_id')` is Pydantic V1 syntax; V2 requires `@field_validator`.
- Fix: Replace with `@field_validator('widget_id')`.

[HIGH] Global mutable state for token tracking
- File: backend/app/ai/pipeline.py:17
- Issue: `token_usage: Dict[str, Dict] = {}` is a global mutable dict. Not thread-safe and not persisted across restarts.
- Fix: Use database-backed token tracking with proper locking.

[MEDIUM] Broad exception catching in pipeline
- File: backend/app/ai/pipeline.py:160, 186
- Issue: `except Exception as e` catches all errors including programming errors.
- Fix: Catch specific exceptions (httpx.HTTPError, json.JSONDecodeError) and let unexpected errors propagate.

[MEDIUM] CORS allows all methods and headers
- File: backend/app/main.py:50-54
- Issue: `allow_methods=["*"]` and `allow_headers=["*"]` is too permissive.
- Fix: Specify exact methods (GET, POST) and headers (Authorization, Content-Type).

[MEDIUM] Missing logging configuration
- File: backend/app/main.py
- Issue: No logging level, format, or output configuration.
- Fix: Configure logging with appropriate level and JSON format for production.

[MEDIUM] No rate limiting per user, only per IP
- File: backend/app/main.py:19
- Issue: Rate limiting uses `get_remote_address` (IP), not user ID. Behind NAT or proxy, all users share one limit.
- Fix: Implement per-user rate limiting after authentication.

[LOW] SECRET_KEY warning only in production
- File: backend/app/config.py:11
- Issue: Warning about unset SECRET_KEY only fires in production, not during development.
- Fix: Warn in all environments or enforce via test.

**Assessment:** Backend architecture is impressive — full AI pipeline with tool calling, caching, validation, Quellenpflicht, token tracking, and eval suite. However, the in-memory user storage and hardcoded token are serious issues for production.

---

## Phase 6: Kern-Widgets

**Status:** Core widgets implemented (weather, parties, 21 trackers)

| Severity | Count | Findings |
|----------|-------|----------|
| CRITICAL | 0 | - |
| HIGH | 0 | - |
| MEDIUM | 2 | Weather API error handling, parties incomplete |
| LOW | 2 | Minor UI issues |

**Findings:**

[MEDIUM] Weather API error response not fully handled
- File: backend/app/ai/pipeline.py:303
- Issue: Returns `{"error": "Weather API error", "status_code": response.status_code}` without details.
- Fix: Include response body or more specific error information.

[MEDIUM] Parties widget incomplete (internal KI-Prompt not implemented)
- File: TODO.md:177
- Issue: Parties widget has schema and map but no AI prompt for recommendations from map viewport, date, and preferences.
- Fix: Implement parties recommendation prompt using search_events tool.

[LOW] Unnecessary `.toList()` in spreads
- Files: budget_widget.dart:163,190, calendar_widget.dart:123, medications_tracker_widget.dart:152, news_widget.dart:164, quick_notes_widget.dart:115
- Issue: Spreading `.toList()` is unnecessary; spread the collection directly.
- Fix: Remove `.toList()` before spread operators.

**Assessment:** All core widget types are implemented with proper state handling (loading, error, empty, ready). Tracker widgets share a common model pattern. Weather and parties are the most feature-complete.

---

## Phase 7: 20 weitere Widgets

**Status:** 10/20 widget types have UI shells implemented

| Severity | Count | Findings |
|----------|-------|----------|
| CRITICAL | 0 | - |
| HIGH | 0 | - |
| MEDIUM | 1 | Many widgets are UI-only without backend integration |
| LOW | 0 | - |

**Findings:**

[MEDIUM] Most Phase 7 widgets are UI shells without backend data
- Issue: Widgets like budget, stocks, OPNV, restaurants, recipes, etc. have Flutter UI components but no corresponding backend endpoints, AI prompts, or tools.
- Fix: For production, implement backend support for each widget or mark them as mock-only.

**Assessment:** All 20 widget types have UI components registered in the widget registry. However, only some have actual backend data pipelines. This is acceptable for an MVP/demo but needs completion for production.

---

## Phase 8: KI-Assistent in der App

**Status:** 0/8 complete

| Severity | Count | Findings |
|----------|-------|----------|
| CRITICAL | 0 | - |
| HIGH | 0 | - |
| MEDIUM | 1 | Feature not started |
| LOW | 0 | - |

**Findings:**

[MEDIUM] No in-app AI assistant
- Issue: Global text/voice input, prompt-to-widget-action translation, widget-adding via voice, cross-widget questions, and proactive suggestions are all unimplemented.
- Fix: Design and implement assistant UI and backend integration.

**Assessment:** This phase is entirely future work. No code exists yet.

---

## Phase 9: Qualität und Performance

**Status:** 3/11 complete

| Severity | Count | Findings |
|----------|-------|----------|
| CRITICAL | 0 | - |
| HIGH | 2 | No integration tests, no golden tests |
| MEDIUM | 3 | No performance testing, no accessibility audit, no security review |
| LOW | 0 | - |

**Findings:**

[HIGH] No integration tests for dashboard editing
- Issue: TODO.md lists integration tests for dashboard editing as incomplete. No integration tests exist.
- Fix: Write integration tests for add/reorder/remove/resize widgets on a real dashboard.

[HIGH] No golden tests
- Issue: TODO.md confirms "no golden tests yet." Visual regression testing is missing.
- Fix: Add golden tests for key widgets (weather, tracker cards, dashboard grid).

[MEDIUM] No performance testing with 30+ widgets
- Issue: Performance with many concurrent widgets is untested.
- Fix: Write benchmark tests rendering 30+ widgets and measure frame rates.

[MEDIUM] No accessibility audit
- Issue: Semantic labels, tap targets, and text scaling not verified.
- Fix: Run Flutter accessibility inspector and fix issues.

[MEDIUM] No security review or pentest
- Issue: Security checklist in TODO.md is entirely unchecked.
- Fix: Conduct security review covering OWASP Top 10 for mobile and API.

**Assessment:** Testing is decent for unit/widget tests (37 Flutter + 66 backend = 103 total) but missing integration, golden, performance, accessibility, and security tests.

---

## Phase 10: Launch

**Status:** 0/14 complete

| Severity | Count | Findings |
|----------|-------|----------|
| CRITICAL | 0 | - |
| HIGH | 0 | - |
| MEDIUM | 1 | No onboarding, paywall, or legal docs |
| LOW | 0 | - |

**Findings:**

[MEDIUM] No production-ready launch components
- Issue: Onboarding, paywall, privacy policy, terms of service, medical/financial disclaimers, store screenshots, and beta testing are all unimplemented.
- Fix: These are product/marketing tasks rather than code quality issues.

**Assessment:** Launch preparation is entirely future work.

---

## Overall Summary

### Build Health
| Metric | Status |
|--------|--------|
| Flutter analyze errors | 0 |
| Flutter analyze warnings | 9 |
| Flutter analyze info | 105 |
| Flutter tests | 37/37 passed |
| Backend tests | 66/66 passed |
| Total test coverage | 103 tests |

### Severity Breakdown (All Phases)
| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 1 | block |
| HIGH | 7 | block |
| MEDIUM | 22 | info |
| LOW | 10 | note |

### Verdict: BLOCK
The project has solid architecture and comprehensive feature implementation, but several issues must be addressed before production:

**Must Fix (CRITICAL + HIGH):**
1. **In-memory user storage** — users lost on restart (auth.py)
2. **Hardcoded mock token** in /me endpoint (auth.py)
3. **BuildContext across async gaps** — 11 occurrences that can crash (dashboard_view.dart)
4. **Deprecated onReorder API** (dashboard_view.dart)
5. **Pydantic V1 validator** (widgets.py)
6. **Global mutable state** for token tracking (pipeline.py)
7. **Oversized DashboardView** — 1032 lines violates SRP (dashboard_view.dart)
8. **Material-UI migration incomplete** — 70+ deprecation warnings across all widgets

**Should Fix (MEDIUM):**
- Complete Material-UI migration or remove dependency
- Add proper logging instead of print()
- Implement per-user rate limiting
- Add integration and golden tests
- Conduct accessibility and security audits
- Fix CORS configuration

### Phase Completion
| Phase | Complete | Notes |
|-------|----------|-------|
| 0: Entscheidungen | 10/11 | Legal pending |
| 1: Projekt-Setup | 10/10 | ✅ |
| 2: Design System | 8/9 | Material-UI migration |
| 3: Flexibles Dashboard | 12/18 | BuildContext issues |
| 4: Widget-Framework | 11/16 | Schema migration pending |
| 5: Backend & KI | 30/44 | Auth, tools, security pending |
| 6: Kern-Widgets | ✅ | All core widgets |
| 7: 20 weitere Widgets | 10/20 UI | Backend integration partial |
| 8: KI-Assistent | 0/8 | Not started |
| 9: Qualität | 3/11 | Tests need expansion |
| 10: Launch | 0/14 | Not started |

### Recommendations
1. **Immediate:** Fix auth issues (in-memory users, hardcoded token) — these are production blockers
2. **Short-term:** Fix BuildContext async gaps and complete Material-UI migration
3. **Medium-term:** Expand test suite (integration, golden, performance)
4. **Long-term:** Complete backend tool integrations and security audit
