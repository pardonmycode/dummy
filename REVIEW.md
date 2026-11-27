# Widgetly Code-Review Report

**Datum:** 2026-11-25
**Reviewer:** Hermes Code Agent (4 parallele unabhängige Reviews)
**Projekt:** Widgetly - KI-gesteuerte Widget-Plattform (Flutter Web + FastAPI Backend)
**Scope:** Alle 64 Source-Dateien (Backend: Python/FastAPI, Frontend: Dart/Flutter)

## Zusammenfassung

| Kategorie | Critical | High | Medium | Low | Total |
|-----------|----------|------|--------|-----|-------|
| Backend API & Architektur | 4 | 8 | 17 | 9 | 38 |
| AI Infrastructure | 0 | 5 | 11 | 13 | 29 |
| Flutter Frontend | 1 | 7 | 17 | 8 | 33 |
| Architektur & Infrastruktur | 0 | 4 | 6 | 4 | 14 |
| **Total** | **5** | **24** | **51** | **34** | **114** |

---

## 1. Backend API & Architektur (38 Issues)

### Critical (4)

**C1. Hardcoded SECRET_KEY** — `config.py:8`
```python
SECRET_KEY = os.getenv("SECRET_KEY", "widgetly-secret-key-2025")
```
Standardwert ist ein statischer String. Ohne Umgebungsvariable kann jeder JWT-Token fälschen.

**C2. ENCRYPTION_KEY wird bei jedem Neustart neu generiert** — `security.py:8`
```python
ENCRYPTION_KEY = secrets.token_bytes(32)
```
Alle "verschlüsselten" Daten sind nach Neustart unlesbar. Sicherheitsgarantie ist illusorisch.

**C3. Mock-User mit Klartext-Passwort im Code** — `api/auth.py:10`
```python
MOCK_USER = {"email": "test@example.com", "password": "password123", ...}
```
Legacy-Code bleibt im Repository.

**C4. Passwörter im Klartext im Speicher** — `api/auth.py:37`
Registrierte Passwörter werden nicht gehasht (kein bcrypt), nur im in-memory Dict gespeichert.

### High (8)

**H1. SHA-256 ist kein Encryption** — `security.py:10`
`encrypt_data()` verwendet eine One-Way Hash-Funktion. Daten können nicht zurück-dekodiert werden. Funktionsname ist irreführend.

**H2. CORS mit Wildcard und Credentials** — `main.py:36`
```python
allow_origins=["*"], allow_credentials=True
```
Browser können Cookies an jede Domain senden — CORS-Schutz ist wirkungslos.

**H3. Dashboards nicht persistent** — `api/dashboard.py:8`
In-memory Dict, kein DB-Zugriff auf das Dashboard-SQLAlchemy-Modell. Alle Daten beim Neustart verloren.

**H4. Keine Auth auf Dashboard-Endpunkten** — `api/dashboard.py:27`
Alle CRUD-Operationen sind öffentlich.

**H5. Tracker-Daten nicht persistent** — `api/tracker.py:9`
Gleiches Problem wie H3 — in-memory Dict, kein DB-Zugriff.

**H6. Keine Auth auf Tracker-Endpunkten** — `api/tracker.py:23`
Alle Tracker-Operationen sind öffentlich.

**H7. Hardcoded Mock-Token** — `api/auth.py:29`
Login gibt immer `mock_token_123` zurück, kein echter JWT.

**H8. /me gibt Mock-User zurück** — `api/auth.py:43`
Egal wer eingeloggt ist, immer der Test-User.

### Medium (17)

- Fragiler DB-Sessions-Generator-Muster (`scheduler.py:9`, `api/widgets.py:78`)
- Keine try/except auf `int(user_id)` (`auth.py:40`)
- Async-Funktion in APScheduler ohne Async-Executor (`scheduler.py:30`)
- Nicht-thread-sichere ID-Generierung (`api/dashboard.py:38`, `api/tracker.py:41`)
- `entry.dict()` ist deprecated (Pydantic v2) (`api/tracker.py:40`)
- Zu einfaches Prompt-Injection-Sanitizing (`security.py:24`)
- Race-Condition bei Registrierung (`auth.py:59`)
- Keine E-Mail-Format-Validierung (`auth.py:49`)
- Keine Passwort-Stärke-Regeln (`auth.py:49`)
- AI-Pipeline blockiert SSE-Stream (`api/widgets.py:42`)
- Kein Widget-ID-Validieren vor AI-Call (`api/widgets.py:23`)
- Kein max_instances bei Scheduler-Jobs (`scheduler.py:28`)
- Verwirrende Parameter-Namen (`scheduler.py:14`)
- JWT-Fehlerdetails an Client (`auth.py:33`)

### Low (9)

- Deprecated `@app.on_event()` (`main.py:47`)
- `Base.metadata.create_all()` statt Migration (`main.py:49`)
- Kein DB-Pool-Config (`models.py:7`)
- `datetime.utcnow()` deprecated (`models.py:23`)
- Importe innerhalb von Funktionen (`security.py:18`, `security.py:27`)
- `print()` statt Logging (`scheduler.py:22`, `api/widgets.py:91`)
- Keine Layout-Validierung (`models.py:32`)
- Redundante Modell-Definitionen (`api/dashboard.py:1`)

---

## 2. AI Infrastructure (29 Issues)

### High (5)

**AI-H1. Keine Timeout auf OpenAI API Calls** — `ai/provider.py:29,44`
API-Requests können ewig hängen.

**AI-H2. Unbegrenztes token_usage Dict** — `ai/pipeline.py:12`
Memory-Leak — Dict wächst ewig ohne Cleanup/TTL.

**AI-H3. Keine Timeout auf chat() in pipeline** — `ai/pipeline.py:62`
Gleiches Problem wie AI-H1.

**AI-H4. Keine Timeout auf httpx Weather-Request** — `ai/pipeline.py:171`
Wetter-API-Request kann hängen.

**AI-H5. Keine Timeout auf call_with_tools() chat()** — `ai/pipeline.py:110`
Tool-Calling-Chat kann hängen.

### Medium (11)

- OpenAI Client nie geschlossen (`ai/provider.py:23`)
- Keine Retry-Logik bei API-Fehlern (`ai/provider.py:29`)
- Kein Logging auf API-Calls (`ai/provider.py:15`)
- MockProvider special-cased für Tools (`ai/pipeline.py:56`)
- **Prompt-Injection-Risiko**: user_context wird via f-string injiziert (`ai/pipeline.py:190`)
- **Prompt-Injection-Risiko**: Tracker-Daten ohne Escape injiziert (`ai/pipeline.py:194`)
- Unbekannte Tool-Namen nicht geloggt (`ai/pipeline.py:142`)
- Innere Exceptions nicht geloggt (`ai/pipeline.py:74`)
- `datetime.utcnow()` deprecated (`ai/pipeline.py:206`)
- Bare `except:` fängt alle Exceptions (`ai/validation.py:90`)
- `repair_json()` Regex entfernt Kommas global (`ai/validation.py:81`)
- Fallback `{data: "..."}` ist schwach (`ai/validation.py:89`)
- Keine Schema-Validierung wenn kein Schema existiert (`ai/validation.py:59`)
- Cache-Dict wächst unbegrenzt (`ai/cache.py:8`)
- Trace-Liste wächst unbegrenzt (`ai/tracing.py:6`)
- `run_evals()` ist ein Stub (`ai/evals.py:33`)
- `get_prompt()` fallt still auf Standard zurück (`ai/prompts.py:30`)

### Low (13)

- MD5 für Cache-Key (nicht kryptografisch sicher) (`ai/cache.py:13`)
- Kein automatisches Cleanup verfallener Cache-Einträge (`ai/cache.py:24`)
- O(n) Scan bei `clear_cache()` (`ai/cache.py:36`)
- O(n) Scan bei `add_trace_step()` (`ai/tracing.py:25`)
- O(n) Scan bei `complete_trace()` (`ai/tracing.py:36`)
- Trace-ID-Kollision möglich (`ai/tracing.py:10`)

---

## 3. Flutter Frontend (33 Issues)

### Critical (1)

**FE-C1. Massive Code-Duplikation über alle 27 Widget-Typen**
Jedes Widget reimplementiert manuell die gleiche 8-Feld-Klassenstruktur (id, name, description, category, icon, color, defaultSize, buildView). Jedes wiederholt identischen Boilerplate-Code. Sollte eine Factory-Funktion oder Basisklasse verwenden.

### High (7)

**FE-H1. Identischer Progress-Ring UI-Code in 6 Widgets**
`CircularProgressIndicator` + Stack-Layout ist in Steps, Calories, Sleep, Protein, Fat, Water kopiert. Sollte ein gemeinsames `TrackerProgressRing`-Komponent sein.

**FE-H2. Identische Meal-List Rendering in 5 Widgets**
`ListView.builder` mit Meal-Name/Zeit/Wert-Zeilen ist in Protein, Fat, Calories, Fiber, Sugar kopiert. Sollte ein gemeinsames `MealList`-Komponent sein.

**FE-H3. MockWidgetDataProvider hat 27 identische if-Blocks**
Jeder gibt fast identisches JSON zurück. Sollte data-driven mit Template sein.

**FE-H4. FutureBuilder erstellt neues Future bei jedem Rebuild**
Kein Caching oder Memoization — Daten werden neu geladen bei jedem Dashboard-Re-Render.

**FE-H5. Ganzes Dashboard rebuildet bei jedem Widget-Change**
Kein Keyed per-Widget State-Isolation.

**FE-H6. widgetRegistryProvider erstellt neue Registry bei jedem Zugriff**
Alle 27 Widgets werden bei jedem Zugriff neu registriert. Sollte ein Singleton-Provider sein.

**FE-H7. Dashboard-View ist 922 Zeilen**
Enthält Provider, Mock-Daten-Provider, State-Notifier, Grid-Config UND View-Logik. Verletzt Single-Responsibility-Prinzip.

### Medium (17)

- Magic numbers: 0.00076 (Step-Länge), 60 (Kal/km), 250ml (Wasser-Glas), 8 (Gläser), 25g Protein, 20g Fett, 200ms (Mock-Delay)
- `Uuid()` wird bei jedem WidgetInstance erstellt (sollte Singleton sein)
- DashboardWidgetsNotifier hat kein `dispose()`
- **API-Keys sind Placeholder-Strings im Code** (`lib/core/config/app_config.dart`)
- Inkonsistente Farbpalette (AppTheme.success vs Colors.green vs Colors.red)
- Inkonsistente Scroll-Wraps (einige haben SingleChildScrollView, andere nicht)
- Inkonsistente AspectRatio-Nutzung
- **Deutsche Strings hardcoded** (kein i18n)
- Alle Widget-Daten verwenden `Map<String, dynamic>` (kein Typ-Safety)
- MockProvider gibt leerem Map für unbekannte Widgets zurück (kein Fehler)
- Fehlerbehandlung verwendet `print()` (kein Logging)
- LayoutBuilder um ganzes Grid (zu viel Rebuild)

### Low (8)

- `defaultRefreshInterval` definiert aber nie genutzt
- `supportedSizes` definiert aber nie genutzt
- `WidgetAction` enum definiert aber nie genutzt
- `WidgetCard` fehlt Key-Management
- Progress-Indikatoren ohne semantische Labels
- Wasserglas-Icons ohne Semantik
- IconButton ohne Tooltip/Semantik

---

## 4. Architektur & Infrastruktur (14 Issues)

### High (4)

**A-H1. Fehlt `.env.example`**
README referenziert `cp .env.example .env` — Datei existiert nicht. Developer können Setup nicht folgen.

**A-H2. Keine Backend-Tests**
Backend hat kein tests/ Verzeichnis. Auth, API, AI, Scheduler sind ungetestet. Nur Frontend-Tests existieren.

**A-H3. Outdated Python-Dependencies**
Alle Pakete sind auf Mid-2024-Versionen: fastapi 0.109.0 (aktuell 0.120+), uvicorn 0.27.0 (aktuell 0.34+), openai 1.35.0 (aktuell 2.x), httpx 0.27.0 (aktuell 0.28.x).

**A-H4. Hardcoded SECRET_KEY** (Duplikat mit C1)
Siehe C1 oben.

### Medium (6)

- **7 ungenutzte Frontend-Dependencies**: material_ui, json_schema, fl_chart, fluttertoast, flutter_staggered_grid_view, cached_network_image, intl
- **1 ungenutzte Backend-Dependency**: alembic==1.13.1
- `riverpod_generator` + `build_runner` deklariert aber keine `.g.dart`-Dateien generiert
- **README ist inkorrekt**: Sagt "Supabase (Auth, DB)" und "Mapbox" — aber Implementation verwendet FastAPI + SQLite + python-jose, kein Supabase/Mapbox
- CI testet nur Frontend — kein Python linting, keine Backend-Tests, kein Backend-Build
- **Docs sind minimal**: Nur ein Screenshot in docs/. Keine API-Docs, Architektur, Deployment-Guide

### Low (4)

- pubspec.yaml hat Platzhalter-Beschreibung ("A new Flutter project.")
- Version ist noch 1.0.0+1 (keine Semver-Strategie)
- Keine Dockerisierung (kein Dockerfile/docker-compose.yml)
- Keine requirements-dev.txt für Test-/Lint-Dependencies

---

## Top 10 Prioritäten für Fixes

1. **SECRET_KEY + ENCRYPTION_KEY** — echte Secrets via Env-Vars (C1, C2, A-H4)
2. **Passwort-Hashing mit bcrypt** — kein Klartext mehr (C4)
3. **Persistent DB für Dashboards & Tracker** — nicht in-memory (H3, H5)
4. **Auth auf allen Endpunkten** — Dashboard & Tracker sind öffentlich (H4, H6)
5. **Timeouts auf allen API/HTTP-Calls** — Provider, Pipeline, Weather (AI-H1, AI-H2, AI-H3, AI-H4, AI-H5)
6. **Prompt-Injection-Schutz** — user_context und Tracker-Daten sanitize (AI-M10, AI-M11)
7. **Backend-Tests schreiben** — kein Test-Coverage (A-H2)
8. **Dependencies aktualisieren** — Mid-2024 ist veraltet (A-H3)
9. **Code-Duplikation reduzieren** — Factory-Pattern für Widgets (FE-C1, FE-H1, FE-H2)
10. **Performance-Optimierung** — Singleton Registry, Future-Caching, per-Widget Rebuild (FE-H4, FE-H5, FE-H6)