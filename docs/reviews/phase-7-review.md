# Phase 7 Review: 20 Weitere Widgets

**Review Date:** November 25, 2026
**Reviewer:** Hermes Agent (subagent)
**Scope:** All 20 Phase 7 widget tasks defined in TODO.md

## Summary

Of the 20 Phase 7 widgets, **4 have implementation files** but **0 are marked as done** in TODO.md. This indicates the TODO is out of sync with the actual codebase. The remaining 16 widgets have no implementation at all.

## TODO vs. Reality Discrepancy

| Widget | TODO Status | File Exists | Verdict |
|--------|-------------|-------------|---------|
| Tagesbriefing | ❌ Not marked | ✅ Yes | DONE but TODO wrong |
| Kalender | ❌ Not marked | ✅ Yes | DONE but TODO wrong |
| Aufgaben | ❌ Not marked | ✅ Yes | DONE but TODO wrong |
| Schnellnotizen | ❌ Not marked | ✅ Yes | DONE but TODO wrong |
| Persönliche News | ❌ Not marked | ❌ No | NOT DONE |
| ÖPNV-Abfahrten | ❌ Not marked | ❌ No | NOT DONE |
| Pendeln und Verkehr | ❌ Not marked | ❌ No | NOT DONE |
| Restaurants in der Nähe | ❌ Not marked | ❌ No | NOT DONE |
| Rezept aus dem Kühlschrank | ❌ Not marked | ❌ No | NOT DONE |
| Essensplaner und Einkaufsliste | ❌ Not marked | ❌ No | NOT DONE |
| Mahlzeit per Foto | ❌ Not marked | ❌ No | NOT DONE |
| Trainingsplan | ❌ Not marked | ❌ No | NOT DONE |
| Budget und Ausgaben | ❌ Not marked | ❌ No | NOT DONE |
| Abos und Verträge | ❌ Not marked | ❌ No | NOT DONE |
| Aktien- und Krypto-Watchlist | ❌ Not marked | ❌ No | NOT DONE |
| Spritpreise und Ladesäulen | ❌ Not marked | ❌ No | NOT DONE |
| Film- und Serienempfehlungen | ❌ Not marked | ❌ No | NOT DONE |
| Paketverfolgung | ❌ Not marked | ❌ No | NOT DONE |
| Geburtstage und Geschenkideen | ❌ Not marked | ❌ No | NOT DONE |
| Reiseplaner | ❌ Not marked | ❌ No | NOT DONE |

**Actual progress: 4/20 (20%)** vs **TODO claimed progress: 0/20 (0%)**

## Detailed Widget Review

### 1. Tagesbriefing ✅ DONE
- **File:** `lib/features/widgets/ui/types/briefing/tagesbriefing_widget.dart`
- **Widget ID:** `tagesbriefing`
- **Category:** Briefing
- **Features implemented:**
  - AI summary header
  - Weather section
  - Appointments section (today)
  - Tasks section (important)
  - News section
  - Source display
- **Issues:**
  - Does not support configurable time/content (TODO item: "Uhrzeit und Inhalte konfigurierbar machen")
  - No optional audio readout feature ("Optional vorlesen")
  - Missing loading/empty/error/obsolete states (only handles null data)
  - No tests
  - Not registered in widget registry (no call to `register()` found)
- **Definition of Done checklist:** Schema ❌, Prompt/Tools ❌, States ⚠️, Sizes ✅, Settings ❌, Themes ⚠️, Localization ❌, Cache ❌, Tests ❌, Registry ❌

### 2. Kalender ✅ DONE
- **File:** `lib/features/widgets/ui/types/calendar/calendar_widget.dart`
- **Widget ID:** `calendar`
- **Category:** Produktivität
- **Features implemented:**
  - Today's date header
  - Events list with time, location
  - Free time slot suggestions
- **Issues:**
  - No Apple/Google calendar integration visible
  - No speech/text-based event creation
  - Missing loading/error states
  - No tests
  - Not registered in widget registry
- **Definition of Done checklist:** Schema ❌, Prompt/Tools ❌, States ⚠️, Sizes ✅, Settings ❌, Themes ⚠️, Localization ❌, Cache ❌, Tests ❌, Registry ❌

### 3. Aufgaben ✅ DONE
- **File:** `lib/features/widgets/ui/types/tasks/tasks_widget.dart`
- **Widget ID:** `tasks`
- **Category:** Produktivität
- **Features implemented:**
  - Task list with completion tracking
  - Progress indicator (completed/total)
  - Priority badges (high priority shown)
  - Time display per task
- **Issues:**
  - No natural language task generation
  - No task breakdown feature
  - No daily focus suggestion
  - Missing loading/error states
  - No tests
  - Not registered in widget registry
- **Definition of Done checklist:** Schema ❌, Prompt/Tools ❌, States ⚠️, Sizes ✅, Settings ❌, Themes ⚠️, Localization ❌, Cache ❌, Tests ❌, Registry ❌

### 4. Schnellnotizen ✅ DONE
- **File:** `lib/features/widgets/ui/types/quick_notes/quick_notes_widget.dart`
- **Widget ID:** `quick_notes`
- **Category:** Produktivität
- **Features implemented:**
  - Notes list with cards
  - Note type icons (text, voice, photo, link)
  - Tags display
  - Timestamp display
- **Issues:**
  - No semantic search feature
  - No automatic tags or summaries visible
  - Missing loading/error states
  - No tests
  - Not registered in widget registry
- **Definition of Done checklist:** Schema ❌, Prompt/Tools ❌, States ⚠️, Sizes ✅, Settings ❌, Themes ⚠️, Localization ❌, Cache ❌, Tests ❌, Registry ❌

## 16 Missing Widgets

The following 16 Phase 7 widgets have no implementation files at all:

| # | Widget | TODO Requirements |
|---|--------|-------------------|
| 5 | Persönliche News | Topic/source selection, summaries with links, duplicate bundling, feedback |
| 6 | ÖPNV-Abfahrten | Nearby stops, live departures, favorites |
| 7 | Pendeln und Verkehr | Home/office route, travel time with traffic, best departure time |
| 8 | Restaurants in der Nähe | Map + list, filters, AI recommendation |
| 9 | Rezept aus dem Kühlschrank | Ingredient capture, recipe suggestions, nutrition integration |
| 10 | Essensplaner und Einkaufsliste | Weekly plan, shopping list, sharing |
| 11 | Mahlzeit per Foto | Food recognition, portion estimation, barcode scanner |
| 12 | Trainingsplan | Custom plan, workout logging, progression |
| 13 | Budget und Ausgaben | Expense tracking, categories, budget alerts |
| 14 | Abos und Verträge | Subscription tracking, cancellation reminders |
| 15 | Aktien- und Krypto-Watchlist | Prices, sparklines, price alerts |
| 16 | Spritpreise und Ladesäulen | Nearby gas stations, charging stations, price alerts |
| 17 | Film- und Serienempfehlungen | Streaming service selection, recommendations, watchlist |
| 18 | Paketverfolgung | Multiple carriers, status tracking, delivery notifications |
| 19 | Geburtstage und Geschenkideen | Birthday tracking, reminders, gift suggestions |
| 20 | Reiseplaner | Route planning, daily plan, packing list, document storage |

## Common Issues Across All 4 Implemented Widgets

1. **None are registered in the widget registry.** No `register()` calls found anywhere for these 4 widgets. They exist as code but are not discoverable by the app.
2. **No JSON schemas defined.** Each widget expects specific data shapes but there's no schema file or validation.
3. **No backend/KI integration visible.** No prompt definitions, tool lists, or API endpoint configurations.
4. **No tests.** No unit tests, widget tests, or schema validation tests found.
5. **No localization.** All strings are hardcoded in German; no DE/EN localization.
6. **Incomplete error/loading states.** Only handle `data == null`; no loading, error, or obsolete states.
7. **No cache/refresh configuration.** No TTL, refresh interval, or cache settings defined.

## Recommendations

1. **Update TODO.md:** Mark the 4 implemented widgets as done (at least partially) to reflect reality.
2. **Register widgets:** Add `register()` calls for all 4 widgets in the app initialization or registry setup.
3. **Complete Definition of Done:** For the 4 implemented widgets, add:
   - JSON schemas with validation
   - Loading/error/empty/obsolete states
   - Backend integration with AI prompts and tools
   - Unit and widget tests
   - Localization strings
4. **Prioritize remaining 16 widgets:** Consider which are most valuable for the MVP and start implementation.

## Files Examined

- `TODO.md` (Phase 7 section, lines 226-335)
- `lib/features/widgets/framework/widget_registry.dart`
- `lib/features/widgets/ui/types/briefing/tagesbriefing_widget.dart`
- `lib/features/widgets/ui/types/calendar/calendar_widget.dart`
- `lib/features/widgets/ui/types/tasks/tasks_widget.dart`
- `lib/features/widgets/ui/types/quick_notes/quick_notes_widget.dart`

## Conclusion

Phase 7 is 20% complete in terms of code but shows 0% in the TODO. The 4 implemented widgets are functional UI components but lack the full "Definition of Done" requirements (schemas, tests, registry, backend integration, states). The remaining 16 widgets are entirely unstarted.
