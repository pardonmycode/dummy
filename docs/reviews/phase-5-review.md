# Phase 5 Review: Backend & KI-Orchestrator

**Reviewed:** November 25, 2026
**Scope:** All Phase 5 tasks marked `[x]` in TODO.md
**Backend Directory:** `~/projects/dummy/backend/app/`

---

## Summary

Phase 5 has solid infrastructure: auth, data models, API endpoints, AI pipeline, caching, tracing, and token tracking are all implemented. However, several "done" tasks are partially implemented or not wired into the actual pipeline — validation, JSON repair, and structured output are defined but never invoked when running a widget.

### Verdict by Section

| Section | Tasks Done | Issues Found |
|---------|-----------|--------------|
| API & Data | 7/7 | Rate limiting is IP-based, not per-user/widget |
| KI-Pipeline | 11/11 | 4 tasks are stubs or not wired into pipeline |
| Tests | — | All 34 tests pass |

---

## Detailed Task Review

### API und Daten

#### 1. Authentifizierung bauen (E-Mail)
**Status:** ✅ Done

- **Evidence:** `app/auth.py` lines 1-111 — complete JWT auth with bcrypt password hashing via passlib, OAuth2PasswordBearer token scheme, `/register`, `/login`, `/me` endpoints
- **Evidence:** `app/api/auth.py` lines 1-67 — older mock auth implementation (redundant but doesn't interfere; `app/auth.py` is the one mounted in `main.py`)
- **Evidence:** `app/models.py` lines 17-25 — User model with email, password_hash, name
- **Tests:** `tests/test_auth.py` — 13 tests covering password hashing, token generation, and validation
- **Notes:** OAuth endpoints for Apple/Google exist as stubs (lines 88-111 of `app/auth.py`)

#### 2. Datenmodell für Nutzer, Dashboards, Widgets, Runs und Tracker-Einträge entwerfen
**Status:** ✅ Done

- **Evidence:** `app/models.py` lines 17-73 — all five models implemented with SQLAlchemy ORM:
  - `User` (lines 17-25): id, email, password_hash, name, created_at, relationships to dashboards and tracker entries
  - `Dashboard` (lines 27-34): id, user_id, name, layout (JSON), created_at
  - `WidgetInstance` (lines 36-46): id, user_id, widget_type, size, config, data, generated_at, expires_at
  - `WidgetRun` (lines 48-61): id, user_id, widget_id, status, prompt, response, sources, tokens_used, timestamps
  - `TrackerEntry` (lines 63-73): id, user_id, tracker_type, value, unit, timestamp, note, meal_name
- **Evidence:** `app/main.py` line 48 — `Base.metadata.create_all(bind=engine)` on startup
- **Notes:** Relationships and cascades are properly configured

#### 3. Endpoint GET /widgets/{id}/data bauen
**Status:** ✅ Done

- **Evidence:** `app/api/widgets.py` lines 22-33
- **Behavior:** Returns stored widget data if available, otherwise runs the AI pipeline and returns fresh data
- **Auth:** Uses `get_current_user` dependency

#### 4. Endpoint POST /widgets/{id}/refresh bauen
**Status:** ✅ Done

- **Evidence:** `app/api/widgets.py` lines 62-93
- **Behavior:** Accepts `force` parameter, runs refresh in background task, returns immediately with "refreshing" status
- **Notes:** Background task uses proper DB session handling

#### 5. Endpoint für Widget-Aktionen bauen
**Status:** ✅ Done

- **Evidence:** `app/api/widgets.py` lines 95-106
- **Behavior:** Accepts `action` and optional `data`, acknowledges receipt
- **Notes:** Action handling is minimal (just acknowledgment), but endpoint exists as required

#### 6. Scheduler für regelmäßige Updates bauen (APScheduler)
**Status:** ✅ Done

- **Evidence:** `app/scheduler.py` — complete APScheduler integration with `AsyncIOScheduler`
- **Evidence:** `app/main.py` lines 46-53 — scheduler starts on app startup, shuts down on app exit
- **Functionality:** `schedule_widget_refresh(widget_id, user_id, interval_minutes)` adds interval jobs with proper ID and `replace_existing=True`
- **Notes:** Jobs are defined but no code currently calls `schedule_widget_refresh` to actually schedule any jobs — this may be intentional for now

#### 7. Rate-Limits pro Nutzer und Widget bauen (slowapi)
**Status:** ⚠️ Partial

- **Evidence:** `app/main.py` lines 15-31 — slowapi Limiter configured with `get_remote_address` key function
- **Issue:** Rate limiting is per IP address, not per user and per widget as the task specifies
- **Evidence:** `app/config.py` line 24 — `RATE_LIMIT = "100/minute"` defined but not actually used (hardcoded in main.py)
- **Missing:** No per-user or per-widget rate limits; would require custom key function and additional limiters

---

### KI-Pipeline

#### 8. Provider-Abstraktion für KI-Modelle bauen (OpenAI/Mock)
**Status:** ✅ Done

- **Evidence:** `app/ai/provider.py` lines 1-74 — clean abstraction with:
  - `AIProvider` abstract base class (lines 13-20)
  - `OpenAIProvider` implementation using AsyncOpenAI client (lines 22-55)
  - `MockProvider` for development/testing (lines 64-74)
  - `get_provider()` factory function (lines 57-62) that selects based on config
- **Behavior:** Supports both chat and structured_output operations

#### 9. Prompt-Registry mit Versionierung bauen
**Status:** ✅ Done

- **Evidence:** `app/ai/prompts.py` lines 1-31 — `PROMPT_REGISTRY` dictionary with versioned prompts for weather_summary, party_recommendations, health_insights, and meal_suggestions
- **Versioning:** Each prompt entry has a `version` field (currently all version 1)
- **Evidence:** `get_prompt(widget_id)` function returns prompt config or falls back to health_insights

#### 10. Tool-Calling-Schicht bauen
**Status:** ✅ Done

- **Evidence:** `app/ai/tools.py` lines 1-157 — 9 tool definitions (weather, web_search, geocoding, tracker_data, food_database, events, maps, calendar, news) with proper OpenAI function schema format
- **Evidence:** `app/ai/pipeline.py` lines 114-155 — `call_with_tools()` implements the tool-calling loop with max iterations, `execute_tool()` dispatches to actual tool implementations
- **Behavior:** Tools return JSON results that are fed back into the conversation

#### 11. Structured Output pro Widget-Schema erzwingen
**Status:** ⚠️ Partial

- **Evidence:** `app/ai/provider.py` lines 43-55 — `OpenAIProvider.structured_output()` method exists and uses `response_format={"type": "json_object"}`
- **Evidence:** `app/ai/validation.py` lines 5-51 — `WIDGET_SCHEMAS` defines JSON schemas for weather_summary and party_recommendations
- **Issue:** The pipeline never calls `structured_output()` — it always uses `chat()` and treats the response as plain text
- **Issue:** Widget schemas exist but are not passed to the AI provider or used to enforce structure
- **Result:** The AI returns free-form text, not validated structured JSON matching the widget schema

#### 12. Serverseitige Validierung bauen
**Status:** ⚠️ Partial

- **Evidence:** `app/ai/validation.py` lines 53-71 — `validate_widget_data()` function validates data against widget schemas
- **Evidence:** `tests/test_ai_validation.py` — 5 tests covering valid data, missing fields, non-dict data, unknown widgets, and party events
- **Issue:** `validate_widget_data()` is never called in the pipeline — `build_widget_json()` (line 230 of pipeline.py) simply wraps the AI response without validation
- **Result:** Invalid JSON from the AI passes through to the frontend unvalidated

#### 13. Automatischen Reparaturversuch bei ungültigem JSON bauen
**Status:** ⚠️ Partial

- **Evidence:** `app/ai/validation.py` lines 73-91 — `repair_json()` function exists with multiple repair strategies (trailing comma removal, quote wrapping)
- **Evidence:** `tests/test_ai_validation.py` — 5 tests covering valid JSON, trailing commas, whitespace, and unparseable text
- **Issue:** `repair_json()` is never called in the pipeline
- **Result:** No repair attempt is made when AI returns malformed JSON

#### 14. Fallback auf letzte gültige Daten bauen
**Status:** ⚠️ Partial

- **Evidence:** `app/api/widgets.py` lines 29-30 — `get_widget_data()` returns stored `widget.data` if available
- **Issue:** This is not a true fallback mechanism — it's just returning cached data. When the AI pipeline fails or returns invalid data, there's no fallback to the last known good data
- **Missing:** No logic to detect pipeline failure and serve previous valid data instead

#### 15. Cache nach Widget, Ort und Zeitfenster bauen (OrderedDict + TTL)
**Status:** ✅ Done

- **Evidence:** `app/ai/cache.py` lines 1-52 — complete in-memory cache implementation with:
  - `OrderedDict` with 500 entry maximum
  - Cache keys generated from widget_id + MD5 hash of parameters (including location)
  - TTL-based expiration with `time.time()` checks
  - Eviction of oldest entries when max size exceeded
- **Evidence:** Integrated in pipeline at `app/ai/pipeline.py` lines 37-42 (get) and 98 (set)
- **Behavior:** Cache key includes location parameter as required; 5-minute default TTL

#### 16. Token- und Kosten-Tracking pro Nutzer bauen
**Status:** ✅ Done (in-memory)

- **Evidence:** `app/ai/pipeline.py` lines 13-21 — `token_usage` dictionary keyed by user_id
- **Evidence:** Lines 77-82 — tokens tracked on each AI response and accumulated per user
- **Evidence:** Lines 241-248 — `get_token_usage()` and `reset_token_usage()` functions
- **Notes:** Tracking is in-memory only; lost on restart. No persistence to database or cost calculation. No budget enforcement.

#### 17. Traces aller KI-Läufe speichern (ohne sensible Inhalte)
**Status:** ✅ Done

- **Evidence:** `app/ai/tracing.py` lines 1-64 — complete tracing implementation with:
  - `start_trace()` creates trace with user_id, widget_id, prompt
  - `add_trace_step()` records each pipeline step with timestamp
  - `complete_trace()` marks completion with token count
  - `get_traces()` filters by widget/user, strips sensitive data (only returns metadata, not full response)
  - `deque(maxlen=100)` limits trace storage
- **Evidence:** Integrated throughout pipeline at lines 32, 40, 41, 56, 74, 85, 100, 104, 105

#### 18. Eval-Suite pro Widget mit Golden-Beispielen bauen
**Status:** ⚠️ Partial

- **Evidence:** `app/ai/evals.py` lines 1-68 — `EVAL_EXAMPLES` dictionary with golden examples for weather_summary (2 examples) and party_recommendations (1 example)
- **Issue:** `run_evals()` doesn't actually run the pipeline against examples — it just checks if the `input` field exists in the example definition (lines 42-45)
- **Issue:** No actual validation of AI output against expected fields or expected values
- **Result:** The eval suite is a stub that always passes if examples are defined with an input field

---

## Issues Summary

### Critical (affect core functionality)
1. **Validation not wired into pipeline** — `validate_widget_data()` exists but is never called. AI output passes to frontend unvalidated.
2. **Structured output not enforced** — `structured_output()` method exists but pipeline uses plain `chat()`. Widget schemas not passed to provider.
3. **JSON repair not integrated** — `repair_json()` never called when AI returns malformed JSON.

### Moderate (incomplete implementation)
4. **Fallback not truly implemented** — Returns stored data on get, but no fallback mechanism when pipeline fails.
5. **Eval suite is a stub** — Doesn't actually run pipeline or validate output; just checks example definitions.
6. **Rate limiting is IP-based** — Task specifies per-user and per-widget, but only IP-level is implemented.

### Minor (works but could be improved)
7. **Token tracking is in-memory only** — Lost on restart; no cost calculation or budget enforcement.
8. **Duplicate auth implementations** — `app/auth.py` (real) and `app/api/auth.py` (mock) both exist.
9. **No scheduled jobs actually created** — Scheduler infrastructure exists but `schedule_widget_refresh()` is never called.

---

## Test Results

All 34 tests pass:
- `tests/test_auth.py`: 13 tests (password hashing, JWT tokens)
- `tests/test_api.py`: 7 tests (root, health, API prefix)
- `tests/test_ai_validation.py`: 14 tests (widget validation, JSON repair, sources)

```
======================== 34 passed, 9 warnings in 2.45s ========================
```

---

## Recommendations

1. **Wire validation into pipeline:** Call `validate_widget_data()` in `build_widget_json()` and return error state if invalid.
2. **Use structured output:** Update pipeline to call `provider.structured_output()` with the widget schema instead of `chat()`.
3. **Add repair logic:** Call `repair_json()` before validation when JSON parsing fails.
4. **Implement real fallback:** Store last valid data per widget and return it when pipeline fails.
5. **Make evals real:** Have `run_evals()` actually invoke the pipeline and compare output against expected fields.
6. **Fix rate limiting:** Implement per-user rate limiting using a custom key function that extracts user ID from token.
7. **Persist token tracking:** Store token usage in database for accurate billing and budget tracking.
