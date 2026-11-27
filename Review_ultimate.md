# Widgetly: Ultimate Review

**Date:** 2026-11-27  
**Scope:** the whole repository on `main` at commit `043bd59`: the Flutter app, the FastAPI backend, CI, `TODO.md` and the earlier review documents.  
**Bottom line:** Widgetly is a tidy UI prototype with a backend skeleton, and it looks further along than it is. Do not deploy it and do not put real user data into it yet. Most fixes are small, and section 7 lays out a path to a real MVP.

---

## How this review was done

- I read every backend module and the core Flutter code: framework, dashboard, sync, config and a sample of widgets. I skimmed all 30 widget files, CI, `pubspec.yaml`, `TODO.md` and the 10 earlier review files.
- I ran the backend test suite on a scratch copy of the repo (Python 3.12, fresh `pip install -r requirements.txt`). Result: **45 passed, 6 failed, 15 errors**.
- I wrote a probe script and ran it against a scratch copy of the running backend. It confirmed 9 of the bugs below, and its output is in Appendix A. For the probe only, I pinned `bcrypt<4.1` so that login works (see H1).
- **Not done:** Flutter is not installed on this machine, so I could not run `flutter analyze`, `flutter test` or the app itself. All Flutter findings come from reading the code.
- Nothing in the repository was changed apart from adding this file.

---

## 1. Verdict

| Area | Score /10 | Why |
|---|---|---|
| Product idea | 8 | Strong and different from existing apps. The real risks are data sources and AI cost, not the UI. |
| UI and design system | 6 | Clean cards, design tokens, light and dark themes, and loading, empty and error states. But the dashboard is one 1,479-line file and several widgets render empty. |
| Widget framework (Flutter) | 5 | Good registry and definition abstraction. Validation and caching exist but don't actually protect anything. |
| Backend architecture | 4 | Sensible module split. All important state lives in process memory, and synchronous DB calls run inside async handlers. |
| AI pipeline | 2 | Tool calling crashes with a real API key. There is no structured output, and the budget and evals are not real. |
| Security and privacy | 1 | Login backdoor, health data with no authentication, and a cross-user data leak. |
| Tests and CI | 3 | Over 100 tests exist. But the backend tests don't run in CI, the Flutter CI job cannot resolve the SDK, and the AI evals are fake. |
| Docs and process | 3 | Ten overlapping review files that overstate how complete things are. |

**The core promise is not connected anywhere yet.** The idea is that the AI fetches data and returns JSON, and the widget renders it. In reality, the app renders hard-coded mock data for every widget and never calls the AI backend. In the backend, the AI tool-calling path crashes as soon as a real OpenAI key is set, and even a successful AI answer would be stored as free text that no widget can render.

---

## 2. Reality check: what `TODO.md` marks as done vs. what the code does

| TODO item marked `[x]` | What the code actually does | Evidence |
|---|---|---|
| Authentication (email) | Works only with an old bcrypt version. On a fresh install, registration and login crash. The mock OAuth endpoint is a login backdoor. | H1, C1 |
| Rate limits per user and widget (slowapi) | Not active. 130 requests in a row all returned 200. | H7, Appendix A |
| Tool-calling layer | Crashes with a real OpenAI key (`TypeError`). It only works with the mock provider. | H2 |
| Enforce structured output per widget schema | Never used. The pipeline returns free text as `data`. | H3 |
| Server-side validation, automatic JSON repair | The functions exist, but the pipeline imports them and never calls them. | H3 |
| Fall back to last valid data | The opposite happens: a refresh overwrites stored data with the error JSON. | H4 |
| Enforce sources for facts | Checked, logged, then ignored. The "sources" are search-query strings, not URLs. | M4 |
| Cache by widget, location and time window | Exists, and leaks one user's data to other users. | C2 |
| Token and cost tracking, budget limits, kill switch | Calls without tools count 0 tokens. Everything is in memory, the budget never resets, and nothing can trigger the kill switch. | C4 |
| Store traces without sensitive content | The trace stores the full user message, including tracker data. | M8 |
| Eval suite with golden examples | An example "passes" if it has an `input` key. The model is never called. | M5 |
| Weather data from API, AI summary | The app shows a hard-coded "22 °C Sonnig", labelled "Quelle: OpenWeatherMap API". | H5 |
| Parties: map with pins | A "Simulated map background" with no map package. The widget also gets no data, so it renders empty. | H11 |
| Quick entry, edit, delete for trackers | The "+ 250ml" button adds to a temporary object that is thrown away. The backend tracker API keeps everything in memory with no authentication. | H11, C3 |
| 20 individual trackers | They render mock data. Carbs, water and steps get no mock data and show nothing. | H11 |
| CI for analysis, tests and builds | Flutter CI pins 3.27.0 (Dart 3.6), but `pubspec.yaml` needs Dart `^3.14.0`. Backend tests are not in CI. | H12 |
| "52 tests: 18 Flutter + 34 backend" | There are actually 37 Flutter and 66 backend tests. On a clean checkout, 21 backend tests fail. | Appendix B |

These items do look real from reading the code, though I could not run them: local layout saving, drag and drop, resizing, undo/redo, multiple dashboards, the widget catalog and the design tokens.

---

## 3. Findings

Severity levels:
- **Critical:** can be exploited, or loses or leaks data, right now.
- **High:** a core feature is broken or the MVP is blocked.
- **Medium:** will hurt soon.
- **Low:** cleanup.

"Verified" means I reproduced it on a running copy (Appendix A). The other findings come from reading the code.

### Critical

**C1. The mock OAuth endpoint lets anyone log in as other OAuth users.** Verified.  
[backend/app/auth.py:92](backend/app/auth.py#L92)
- Any token is accepted. The account is chosen only by provider name plus the first 8 characters of the token ([auth.py:97](backend/app/auth.py#L97)). So two different tokens that start with the same 8 characters log into the same account.
- Every OAuth user also gets the fixed password `"oauth"` ([auth.py:103](backend/app/auth.py#L103)), so a normal `/login` with that password works too.
- **Fix:** delete the endpoint now. When you add real Sign in with Apple or Google, verify the provider's ID token signature and audience. Never set a known password; make `password_hash` nullable for OAuth users.

**C2. Health data leaks between users through the shared cache.** Verified.  
[backend/app/ai/cache.py:46](backend/app/ai/cache.py#L46) and [cache.py:28](backend/app/ai/cache.py#L28)
- Every result is also written under a "shared" key built only from widget type and location.
- For `health_insights`, `meal_suggestions` and any unknown widget type, location is `None`, so all users share one key. `get_cached` reads the shared key first.
- In the probe, user 2 received user 1's "Gewicht 92kg, Schlaf 4h".
- **Fix:** share cache entries only for widget types that are explicitly public, such as weather by rounded location. Key everything else by user ID only.

**C3. The tracker API has no authentication and one global store.** Verified.  
[backend/app/api/tracker.py:22](backend/app/api/tracker.py#L22)
- No endpoint uses `get_current_user`, and all data sits in one module-level dict.
- Anyone on the internet can read, add or delete everyone's entries. The probe did an unauthenticated POST and GET and both returned 200.
- Everything is lost on restart. The `TrackerEntry` database model already exists but is never used.
- **Fix:** add authentication, use the database, filter by user, and validate values and units per tracker type.

**C4. Anyone can run up unlimited AI costs.**
- Signup is open, and C1 makes it unverified.
- Rate limiting is off (H7).
- `POST /api/widgets/{id}/schedule` accepts any interval and any widget ID, with no limit on how many schedules a user creates ([widgets.py:123](backend/app/api/widgets.py#L123)).
- Unknown widget IDs fall back to the health prompt and the most expensive model ([pipeline.py:55](backend/app/ai/pipeline.py#L55), [prompts.py:31](backend/app/ai/prompts.py#L31)).
- Calls without tools never add tokens to the budget, because `tokens_used` is missing on that path ([pipeline.py:146](backend/app/ai/pipeline.py#L146)).
- So one script can schedule hundreds of fake widgets every minute and nothing stops it.
- **Fix:**
  - Allow-list widget types and return 404 for unknown ones.
  - Set a minimum interval (at least 15 minutes) and a maximum number of schedules per user.
  - Count tokens on every path and keep the budget in persistent storage.
  - Turn on rate limiting.

### High

**H1. A fresh install cannot register or log in.** Verified by the test run.
- `requirements.txt` pins passlib 1.7.4 but not bcrypt. pip therefore installs bcrypt 5.0.0, which raises `ValueError: password cannot be longer than 72 bytes` during passlib's internal self-test. Every password hash fails, and 5 auth tests fail.
- **Fix:** drop passlib and call `bcrypt` directly, or use argon2 via `pwdlib`. Pin all dependencies, including indirect ones, in a lock file (pip-tools or uv).

**H2. AI tool calling crashes with a real provider.** Verified.
- `OpenAIProvider.chat()` has no `tools` parameter, but `call_with_tools` passes one ([provider.py:27](backend/app/ai/provider.py#L27), [pipeline.py:202](backend/app/ai/pipeline.py#L202)). The result is `TypeError: unexpected keyword argument 'tools'`.
- Even after fixing that, three more things are broken:
  - `AIResponse` has no `tool_calls` field.
  - The assistant message containing the tool calls is never added before the tool results, which the OpenAI API requires.
  - The selected model is not passed on.
- All four prompts declare tools, so with a real key every AI widget returns an error.
- The tests stay green because the pipeline checks for the class name `MockProvider` and skips tools entirely ([pipeline.py:139](backend/app/ai/pipeline.py#L139)).

**H3. There is no structured output or validation in the pipeline.**
- `build_widget_json` puts the model's raw text into `data` ([pipeline.py:331](backend/app/ai/pipeline.py#L331)). The Flutter widgets expect objects (for example `data['current']['temperature']`), so even a successful run would render nothing.
- `validate_widget_data` and `repair_json` are imported but never called.
- The last fallback in `repair_json` wraps any text as `{"data": "..."}`, so it never fails and hides broken output ([validation.py:88](backend/app/ai/validation.py#L88)).
- **Fix:** request JSON-schema output from the model and validate it against the widget schema. Retry once. If it still fails, keep the last valid data and mark it stale.

**H4. A refresh destroys the last good data.**
- The pipeline returns error dictionaries instead of raising exceptions.
- Both the manual refresh ([widgets.py:138](backend/app/api/widgets.py#L138)) and the scheduler ([scheduler.py:20](backend/app/scheduler.py#L20)) write that error dictionary into `widget.data`. One failed API call therefore wipes the widget.

**H5. The app never talks to the AI backend.**
- All widget data comes from `MockWidgetDataProvider` ([dashboard_view.dart:101](lib/features/dashboard/ui/views/dashboard_view.dart#L101) and [dashboard_view.dart:555](lib/features/dashboard/ui/views/dashboard_view.dart#L555)).
- There is no login screen, and the auth header is commented out ([dashboard_sync_service.dart:156](lib/features/dashboard/domain/dashboard_sync_service.dart#L156)). Every sync request would get a 401.
- The mock weather data is shown as "Quelle: OpenWeatherMap API" (see `docs/dashboard_screenshot.png`). That breaks the project's own rule that sources must be real.
- **Fix:** add a login screen and store the token in secure storage, not SharedPreferences. Build one API data source and switch widgets over one at a time. Show a source only when the data really came from it.

**H6. Downloading synced layouts and listing templates both fail with 422.** Verified.
- `GET /{dashboard_id}` is declared before `GET /sync` and `GET /templates` ([dashboard.py:48](backend/app/api/dashboard.py#L48)). FastAPI tries to read "sync" as an integer ID and fails with 422.
- The same problem makes `GET /api/widgets/jobs/stats` return 404 ([widgets.py:219](backend/app/api/widgets.py#L219)).
- **Fix:** declare the fixed paths first, or use `{dashboard_id:int}`.

**H7. Rate limiting is not active.** Verified.
- A `Limiter` object is created ([main.py:19](backend/app/main.py#L19)), but `SlowAPIMiddleware` is never added and no route has a `@limiter.limit` decorator, so the default limits never apply.
- The `RATE_LIMIT` environment variable is ignored because [config.py:27](backend/app/config.py#L27) hard-codes the value.

**H8. Job results can be read by other users.** Verified.
- `GET /api/widgets/jobs/{job_id}` does not check who owns the job ([widgets.py:203](backend/app/api/widgets.py#L203)), and the result can contain health insights.
- The job dictionary also grows forever ([job_queue.py:47](backend/app/ai/job_queue.py#L47)).

**H9. All important state lives in process memory.**
- This covers the cache, token usage, budget, kill switch, traces, jobs, scheduled refreshes, tracker data and the push-notification log.
- A restart loses all of it. Running more than one worker makes it inconsistent.
- If `SECRET_KEY` is not set, each worker generates its own random key. Tokens then fail at random depending on which worker answers ([config.py:9](backend/app/config.py#L9)).
- Phase 0 of `TODO.md` chose Redis and Celery, but neither is used.

**H10. The backend identifies a widget by its type, not by its instance.**
- The backend stores one widget per user and type ([widgets.py:32](backend/app/api/widgets.py#L32)), and the location is hard-coded to Berlin ([widgets.py:41](backend/app/api/widgets.py#L41)).
- So two weather widgets for two cities are impossible, and the widget configuration from the app never reaches the backend.
- **Fix:** let the app create a UUID for each widget instance, and send the configuration with each request.

**H11. Three of the six MVP widgets render empty, and tracker entry doesn't work.**
- Parties, carbs, water and steps are registered, but the mock provider returns `{}` for them. That includes parties, carbs and steps from the MVP list.
- The parties "map" is a placeholder ([parties_widget.dart:70](lib/features/widgets/ui/types/parties/parties_widget.dart#L70)), and no map package is in `pubspec.yaml`.
- "+ 250ml" adds to a `TrackerBase` object that is created during `build` and then thrown away, so nothing happens ([water_tracker_widget.dart:119](lib/features/widgets/ui/types/water/water_tracker_widget.dart#L119)).

**H12. CI cannot pass, and the backend is not tested in CI at all.**
- [ci.yml:16](.github/workflows/ci.yml#L16) pins Flutter 3.27.0, which ships Dart 3.6. [pubspec.yaml:22](pubspec.yaml#L22) requires Dart `^3.14.0`, and `material_ui` needs Flutter 3.47 or newer, so `flutter pub get` cannot resolve.
- There is no backend job, so H1 and the 21 failing backend tests went unnoticed.

### Medium

**M1. Server-sent progress events are never sent.**
- The pipeline calls `on_progress(...)` without `await`, but the streaming endpoint's callback is `async` ([widgets.py:50](backend/app/api/widgets.py#L50), [pipeline.py:76](backend/app/ai/pipeline.py#L76)).
- Every progress call creates a coroutine that never runs. Clients only ever see "starting" and "complete".

**M2. The notification list is always empty.** Verified.
- The filter `"_sa_instance_state" not in n.__dict__` removes every database object ([notifications.py:120](backend/app/api/notifications.py#L120)).
- The probe got `count: 1` with an empty list.

**M3. Sync is destructive: the last device to sync wins.**
- `POST /sync` deletes all of a user's dashboards and then inserts the client's copy ([dashboard.py:145](backend/app/api/dashboard.py#L145)). A second device silently wipes the first.
- There is no version number or conflict handling, and no size limit on layout or import JSON.

**M4. The source check is only cosmetic.**
- The "factual data" regex matches any digit ([validation.py:107](backend/app/ai/validation.py#L107)).
- Sources are query labels like `"DuckDuckGo search: events party Berlin"`.
- A failed check is only logged ([pipeline.py:172](backend/app/ai/pipeline.py#L172)).
- **Fix:** require each fact-bearing item to carry its own source URL from a tool result, and drop items that don't have one.

**M5. The AI evals are fake.**
- An example counts as passed if it has an `input` field ([evals.py:40](backend/app/ai/evals.py#L40)), and the model is never called.
- **Fix:** run 20 to 50 golden inputs per AI widget against the real model, for example nightly. Measure the schema pass rate and spot-check facts.

**M6. The party data source cannot work, and this is the biggest product risk.**
- `search_events` takes DuckDuckGo search results and relabels them as events ([tools.py:462](backend/app/ai/tools.py#L462)).
- Those results have no dates, venues or coordinates, so the model would have to invent them, which is exactly what the project rules forbid.
- Scraping DuckDuckGo's HTML page is brittle. That page is built for browsers, not programs, and blocks automated traffic, which also makes it a terms-of-use risk ([tools.py:217](backend/app/ai/tools.py#L217)).
- **Fix:** decide on the data strategy before building more UI. Options are event submissions from organizers or users with moderation, plus one licensed API for big events (for example Ticketmaster Discovery; check its terms). Use the model only for deduplication and categorization.

**M7. The public OpenStreetMap services are used beyond what their policies allow.**
- Nominatim allows at most 1 request per second for the whole app, requires caching, and forbids heavy use.
- The OSRM demo server is for testing only and routes by car only. As far as I can tell, `walk` and `bike` requests silently return car routes ([tools.py:401](backend/app/ai/tools.py#L401)).
- The rate limiter works only within one process and has race conditions.
- The User-Agent names `widgetly.app`, a domain you may not own ([tools.py:24](backend/app/ai/tools.py#L24)).
- **Fix:** use a paid provider or self-host both before launch.

**M8. Secrets and encryption have gaps.**
- `SECRET_KEY` falls back to a random value, even in production.
- [.env.example:12](backend/.env.example#L12) says to generate `ENCRYPTION_KEY` with `secrets.token_hex(32)`. That is not a valid Fernet key, so `security.py` raises an error at import time.
- The fallback key file in `~/.widgetly` disappears on every container redeploy, making encrypted data unreadable.
- In practice, health data is not encrypted at all, because `encrypt_data` is never used.
- Traces store the full prompt, including tracker data ([pipeline.py:129](backend/app/ai/pipeline.py#L129)).

**M9. Dependencies are old or unmaintained.**
- Pins date from early 2024, and there is no lock file.
- `python-jose` 3.3.0 is affected by CVE-2024-33663 and CVE-2024-33664, fixed in 3.4.0. With the HS256 setup used here the direct exposure is low, but the library is barely maintained. Switch to PyJWT.
- `openai` 1.35 is old.
- Alembic is listed, but the schema is created with `create_all`, so there are no migrations.

**M10. There is no real defense against prompt injection.**
- `sanitize_text` and `_sanitize_input` escape backticks and strip brackets, which does not stop prompt injection.
- Web page content goes straight into the model through tool results.
- **Fix:**
  - Treat tool output strictly as data.
  - Force schema-shaped output.
  - Allow-list link domains.
  - Never let model output trigger a write without the user confirming.

**M11. The Flutter-side validation doesn't block anything.**
- Data that fails schema validation is still rendered with the state "ready" ([widget_data_provider.dart:31](lib/features/widgets/framework/widget_data_provider.dart#L31)).
- `print()` is used in production code.
- `clearCache` matches by prefix and ignores `instanceId`, so clearing `steps` also clears `steps_tracker` ([widget_data_provider.dart:123](lib/features/widgets/framework/widget_data_provider.dart#L123)).

**M12. The Flutter code structure will slow you down.**
- `dashboard_view.dart` is 1,479 lines. It mixes providers, about 450 lines of mock data, the state notifier, the grid and dialogs.
- There are two `dashboards_notifier.dart` files, and one of them is dead code.
- Global singletons (`widgetDataProvider`, `widgetBackgroundRefresh`, `_sharedRegistry`) bypass Riverpod, which makes testing and overriding them hard.
- `riverpod_annotation` and `riverpod_generator` are installed but unused.
- The imports mix `material_ui` with old `flutter/material` aliases. `material_ui` and `cupertino_ui` are the official packages that Material and Cupertino moved into (Flutter 3.47+), so keep them and finish the migration with consistent imports and no `as flutter` aliases.
- **Fix:** split the file into mock data, providers and views, and keep one notifier.

**M13. Background refresh only works while the app is open.**
- It is a `Timer` running in the app, so it stops when the app goes to the background on iOS and Android.
- **Fix:** refresh on the server and send a push notification, or use the operating systems' background schedulers. Treat the in-app timer as "refresh while open" only.

**M14. The app config contains placeholder API keys.**
- It has placeholders for OpenAI, Mapbox and Supabase keys ([app_config.dart:50](lib/core/config/app_config.dart#L50)).
- Supabase is not used.
- A real OpenAI key in the app could be extracted from the binary and would break the project's own rule against API keys in the app.
- **Fix:** remove them.

**M15. Async endpoints make blocking database calls.**
- Every route is `async def`, but the SQLAlchemy calls are synchronous, so they block the event loop under load.
- `get_db().__next__()` is used outside the request lifecycle.
- **Fix:** use plain `def` routes, which FastAPI runs in a thread pool, or switch to async SQLAlchemy.

### Low

- **L1. Files that shouldn't be in git:** `backend/widgetly.db` (contains a test user with a bcrypt hash; the tests write into it), `.idea/` and `widgetly.iml`. Add them to `.gitignore` and remove them from git.
- **L2. Dead code:**
  - `backend/app/api/auth.py` is not mounted, but it contains a hard-coded `test@example.com` / `password123` login.
  - Most helpers in `security.py` are unused.
  - The `WidgetRun` and `TrackerEntry` models are unused.
  - The budget, news, ÖPNV and stocks widgets exist but are not registered.
- **L3. Auth details:**
  - `tokenUrl="/api/auth/token"` points to an endpoint that doesn't exist, so the "Authorize" button in the API docs is broken.
  - Invalid-token responses include internal JWT error text.
  - There is no email validation or password policy.
  - Tokens last 24 hours with no refresh or revocation.
- **L4. Traces:** trace IDs are millisecond timestamps, so parallel runs can collide ([tracing.py:13](backend/app/ai/tracing.py#L13)).
- **L5. Model settings:**
  - Data generation uses temperature 0.7.
  - Model names are hard-coded in three places, and the per-prompt `model` field is ignored.
  - The default model is the expensive one.
- **L6. Device tokens:** when a device token is "already registered to another user", the app refuses it. That breaks switching accounts on the same phone.
- **L7. Push:** push notifications are mocked but logged as "sent", and the list of sent messages grows forever.
- **L8. Tests are not self-contained:** `TestClient` is not used as a context manager, so on a fresh database the tables never get created (15 errors). The tests depend on the committed `widgetly.db`.
- **L9. Review files:** ten review files with about 2,000 lines overlap and are partly wrong; for example `review-backend-status.md` says rate limiting is "✅ Implemented". None of them caught C1's account takeover, C2 or C3. Merge what's still true into one `STATUS.md` and delete the rest.
- **L10. Layout:** the protein card at size M has a large empty gap (visible in the screenshot).

---

## 4. Architecture and product

### 4.1 "The AI runs the backend" needs a budget model

A quick calculation that doesn't depend on any provider's prices:

- Take 8 AI widgets refreshing every 30 minutes, the default in the code. That is 8 × 48 × 30 = **11,520 model runs per user per month**.
- At about 1,500 tokens per run (system prompt, tool results and answer), that is about **17 million tokens per user per month**.
- The code's budget is 50,000 tokens, and `TODO.md` says 500,000. The free tier would run out after about 2 hours of background refresh.

The way out is to make the model the exception, not the default. Split widgets into three tiers:

| Tier | What it covers | How it runs |
|---|---|---|
| **1. No model** | Weather, public transport, fuel prices, stocks, parcels, calendar, all trackers | Data API, then a normalizer that turns its response into JSON matching the widget schema. Cheap, fast and correct. |
| **2. Model on top of fetched data** | Weather tip ("take a jacket"), daily briefing, weekly tracker insights | Runs once a day or when the user asks. Low temperature, schema-shaped output, shared cache for public inputs. |
| **3. Model with tools** | Trip planner, "build me a dashboard", parsing "2 eggs and a toast" | Only when the user triggers it, with a hard per-user budget, and the user confirms before anything is written. |

### 4.2 One data contract shared by app and backend

Today the widget schemas live in three places that disagree: `validation.py`, `weather_schema.json` and the Dart widget code. Use one envelope for every widget:

```json
{
  "schemaVersion": 1,
  "widgetType": "weather",
  "instanceId": "uuid",
  "status": "ok | stale | error",
  "data": { },
  "sources": [{ "name": "OpenWeatherMap", "url": "https://…", "retrievedAt": "…" }],
  "generatedAt": "…",
  "expiresAt": "…"
}
```

Keep one JSON Schema file per widget in a shared folder. The backend validates against it with Pydantic or jsonschema. The app validates with `json_schema`, which is already in `pubspec.yaml`, or with Dart models generated from the schema.

### 4.3 Infrastructure that matches the decisions in `TODO.md`

- **Postgres** for everything that must persist, with Alembic migrations.
- **Redis** for the cache, locks, rate limits, budgets and the kill switch.
- **A real worker and a persistent scheduler** (Celery, arq or RQ). That makes the API stateless, so you can run several copies.

### 4.4 Data sources decide which widgets are possible

Before building the UI for any of the 20 extra widgets, write down for each one: data source, license and cost, rate limit, and whether a model is needed at all. Two widgets need this most:

- **Parties:** no open, reliable data source for club parties exists (M6).
- **Steps:** needs Apple HealthKit and Android Health Connect (for example the `health` package), not manual entry.

### 4.5 Model choice

Make the model a configuration value per tier, and add real evals (M5). Then switching to a newer or cheaper model, or another provider, becomes a measured decision instead of a guess. The current code pins 2024-era model names in three places.

---

## 5. Privacy, legal and app stores

This section is not legal advice, but each point needs an answer before launch.

- **Health data** is a special category under GDPR Art. 9. It needs explicit consent, a data protection impact assessment is very likely required, and it must be encrypted, exportable and deletable. Today it has no authentication, is shared across users (C2, C3), and is sent to an AI provider without any consent flow.
- **Sending data to a US AI provider** needs a data processing agreement and a legal basis for the transfer. Send only the minimum data, and make it opt-in for health data.
- **Location:** a rounding helper exists but is never used. Send a city or a coarse area, not exact coordinates.
- **Third-party services:** DuckDuckGo, Nominatim and the OSRM demo server all have usage terms that this code would break at scale (M6, M7).
- **App stores:** health data needs privacy disclosures on iOS and Android. Health Connect needs a declaration in Google Play. Health data must never be used for ads.
- **Wellness vs. medical:** insights and the medications tracker must stay non-medical. Personalized medical advice can turn the app into a regulated medical device.
- **AI transparency:** label AI-generated content as such, to meet the EU AI Act's transparency duties.

---

## 6. What's good (keep it)

- **A clear widget abstraction:** `WidgetDefinition`, the registry, sizes and loading, empty, error and stale states. Adding a widget is easy.
- **The design system:** tokens, light and dark themes, and a reusable sources footer.
- **Solid app basics:** feature-first folders, Riverpod, layouts saved locally, undo/redo and multiple dashboards.
- **A backend split that already matches the target design:** the `api`, `ai`, `tools`, `validation` and `cache` modules map well onto it. Tool implementations have timeouts and error handling, and the dashboard and notification queries consistently filter by user.
- **The right rules:** the principles in `TODO.md` (schema contract, required sources, confirm before writing) are correct. The code just doesn't enforce them yet.
- **Fast progress:** 29 commits in 4 days. The structure is there. Now it needs depth.

---

## 7. Action plan

### Phase A: fix the security holes (1–2 days)

1. Delete `/api/auth/oauth/{provider}` and `backend/app/api/auth.py` (C1, L2).
2. Remove shared-cache writes for everything that is not explicitly public (C2).
3. Put the tracker API behind authentication and the database, using the existing `TrackerEntry` model (C3).
4. Add an ownership check on jobs. Allow-list widget types. Set a minimum schedule interval and a maximum number of schedules per user. Count tokens on every path (C4, H8).
5. Turn on rate limiting. Use the user ID as the key when logged in, and the IP address otherwise (H7).
6. Replace passlib, switch to PyJWT, and add a dependency lock file (H1, M9).
7. Refuse to start without `SECRET_KEY` outside development (H9, M8).
8. Remove `widgetly.db` and `.idea/` from git. Give the tests a temporary database and use `with TestClient(app)` (L1, L8).
9. CI: add a backend `pytest` job and match the Flutter version to `pubspec.yaml` (H12).

### Phase B: make one widget real end to end (about 1 week)

Use weather, because it has the simplest data.

1. Add a backend endpoint keyed by widget instance, such as `GET /api/widgets/instances/{id}/data`, that receives the widget's configuration (H10).
2. Write a weather adapter that calls the weather API without a model and returns validated JSON. Add the AI tip as an optional, separate field with structured output (H3, section 4.1).
3. Keep the last valid data when an error happens (H4).
4. In the app, add login and secure token storage, plus one API data source that replaces the mock behind a feature flag (H5).
5. Fix the route order (H6) and add version numbers to sync (M3).

### Phase C: MVP (weeks 2–4)

1. **Trackers:** store entries in the database with a real quick-entry flow. Read steps from HealthKit and Health Connect.
2. **Daily briefing:** build it as a tier-2 job that runs once a day.
3. **Parties:** spend 2–3 days testing data sources first. Then build a real map with `flutter_map` and a tile provider whose terms allow production use.
4. **Infrastructure:** Postgres, Redis, a worker, a persistent scheduler and Alembic.
5. **Real evals:** golden inputs, schema pass rate and fact checks, run nightly.
6. **Privacy:** consent and privacy screens, a data processing agreement with the AI provider, and a draft impact assessment.

### Phase D: later

The 20 extra widgets (each with a data-source sheet first), native home-screen widgets (WidgetKit on iOS, Glance on Android), and "build my dashboard from a prompt".

### Change the definition of done

Mark `[x]` only when all three are true:

1. It works against the real backend, not against mock data.
2. A test exists that would fail if it broke.
3. Someone has seen it working in the running app.

---

## Appendix A: Probe output

The probe ran against a scratch copy of the backend with a fresh database, no OpenAI key (so the mock provider was used), and `bcrypt<4.1` installed so login works.

```text
1 oauth same account: True oauth_google_VICTIM12@example.com
1b login as oauth user with password 'oauth': 200
2 tracker add w/o auth: 200 | read w/o auth: {'entries': [{'value': 42.0, 'unit': 'g', ..., 'id': 'e_1'}]}
3 GET /api/dashboard/sync: 422
3 GET /api/dashboard/templates: 422
3 GET /api/widgets/jobs/stats: 404
4 notifications: {'notifications': [], 'count': 1}
5 130 requests -> status codes: {200}
6 other user reads job: 200
7 user 2 gets: {'data': 'User 1: Gewicht 92kg, Schlaf 4h'}
8 tools path: OpenAIProvider.chat() got an unexpected keyword argument 'tools'
9 model for unknown widget: gpt-4o
```

## Appendix B: Backend test run on a clean checkout

`pip install -r requirements.txt` on Python 3.12, then `pytest`: **45 passed, 6 failed, 15 errors.**

| Failing tests | Cause |
|---|---|
| 5 in `test_auth.py`, 1 in `test_api.py` | bcrypt 5.0.0 together with passlib 1.7.4 raises `ValueError` on every password hash (H1). |
| 15 in `test_notifications.py` | `no such table: users`. The tests depend on the committed `widgetly.db` and never run the app's startup step that creates the tables (L8). |

## Appendix C: Sources for the external facts

- OSRM demo server is car-only: [OSRM-talk mailing list (2016)](https://lists.openstreetmap.org/pipermail/osrm-talk/2016-October/001330.html), [OSM help: OSRM routing on foot](https://help.openstreetmap.org/questions/58890/osrm-routing-on-foot), [osrm-backend issue #6258](https://github.com/Project-OSRM/osrm-backend/issues/6258). These sources are older, so check the live server before relying on this.
- python-jose CVEs fixed in 3.4.0: [NVD CVE-2024-33663](https://nvd.nist.gov/vuln/detail/cve-2024-33663), [NVD CVE-2024-33664](https://nvd.nist.gov/vuln/detail/CVE-2024-33664), [GitLab advisory](https://advisories.gitlab.com/pypi/python-jose/CVE-2024-33663/).
