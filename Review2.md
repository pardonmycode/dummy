# Review2 – Widgetly (Flutter + FastAPI)

**Datum:** 2026-11-28
**Geprüfter Stand:** `e59059f` („viel“)
**Umgebung:** Flutter 3.50.1 (stable), Dart 3.14.0, Linux
**Ausgeführt:** `flutter pub get`, `flutter analyze`, `flutter test`, manuelles Code-Review von `lib/`, `test/`, `backend/`, CI und Repo-Struktur.
**Nicht ausgeführt:** Backend-Tests (`pytest`), `flutter build web`, App auf einem Gerät gestartet.

---

## 0. Fazit (TL;DR)

**Das Projekt ist so nicht lauffähig/auslieferbar.**

| Prüfung | Ergebnis |
|---|---|
| `flutter pub get` | ✅ ok (11 Pakete mit inkompatiblen neueren Versionen) |
| `flutter analyze` | ⚠️ **377 Issues** (0 Errors, 45 Warnings, 332 Infos) – CI läuft mit `--fatal-infos` → **CI ist rot** |
| `flutter test` | ❌ **79 bestanden, 18 fehlgeschlagen**, Lauf dauert **~10 Minuten**, weil ein Test hängt |
| Persistenz | ❌ Dashboards gehen bei jedem Neustart verloren / werden nie geladen |
| Backend ↔ App | ❌ URLs, Widget-IDs und Auth passen nicht zusammen – die App kann nie echte Daten laden |
| Sicherheit Backend | ❌ OAuth-Mock erlaubt Login als beliebiger User, Tracker-API ohne Auth, Rate-Limit wirkungslos |

Die Hauptprobleme sind keine Stilfragen, sondern **strukturell**: drei bis vier parallele Implementierungen derselben Sache (Dashboard-State, Undo/Redo, Data-Provider, Widgets), viel toter Code, Mock-Code der als „fertig“ markiert ist, und Tests die das Fehlverhalten nicht abfangen.

---

## 1. Testergebnisse im Detail

### 1.1 Hängender Test (Ursache für 10 Minuten Laufzeit)

`test/golden_widget_test.dart:19`

```dart
testWidgets('Weather widget renders at medium size', (tester) async {
  await Future.delayed(const Duration(milliseconds: 100));   // ← hängt
```

`testWidgets` läuft in einer **FakeAsync-Zone**. Ein echtes `Future.delayed` wird dort nie fertig, solange niemand `tester.pump()` aufruft → der Test hängt bis zum Timeout. Fix: Zeile löschen oder `await tester.pump(const Duration(milliseconds: 100))`.

### 1.2 Fehlgeschlagene Tests (18)

**a) 13× `Null check operator used on a null value` in `AppLocalizationsX.l10n`**
(`lib/core/i18n/app_localizations.dart:446`)

```dart
AppLocalizations get l10n =>
    Localizations.of<AppLocalizations>(this, AppLocalizations)!;
```

Die Widgets wurden auf `context.l10n` umgestellt (Commit `c28eb47`), die Tests bauen aber ein `MaterialApp` **ohne** `AppLocalizationsDelegate`. Betroffen:

- `more_widgets_test.dart`: Body Fat, Heart Rate, Mood, Tasks
- `new_widgets_test.dart`: Sleep, Tagesbriefing, Weight
- `widget_states_test.dart`: 7 Weather-/Protein-Tests (loading, ready, error, empty, missing fields, empty arrays)

Hier passen zwei Dinge nicht: Die Tests haben kein gemeinsames Test-Harness (es gibt `test/test_helpers.dart`, aber es wird nicht genutzt). Und `l10n` mit `!` lässt jeden Widget-Build abstürzen, wenn kein Delegate da ist. Die Delegates laden außerdem asynchron über `rootBundle`. In Tests braucht es deshalb `pumpAndSettle`, sonst ist beim ersten Frame noch nichts geladen.

**b) 5× `golden_widget_test.dart` – „Found 0 widgets with type WidgetCard“**
Parties (large), Protein (medium), Water (medium), Weather (medium), Steps. Folgefehler aus 1.1 und fehlender Lokalisierung. Außerdem:

- **Das sind keine Golden-Tests.** Es gibt kein einziges `matchesGoldenFile`. Der Name lügt, die Commit-Message „add golden tests for all widget types“ auch.
- Die Testdaten passen nicht zum Schema (Weather-Test ohne `location`/`current`, siehe `widget_schema_validator.dart`).

### 1.3 Qualität der Tests allgemein

- Viele Tests prüfen nur `find.byType(Column), findsWidgets` – das ist immer wahr, sobald irgendwas gerendert wird.
- `integration_edit_restart_test.dart` testet „Neustart“, obwohl die App Daten nie aus `SharedPreferences` lädt (siehe 2.1) – der Test kann das Kernproblem also gar nicht finden.
- Tests importieren `cupertino_ui`, das nicht in `pubspec.yaml` steht (`depend_on_referenced_packages`).
- 19 ungenutzte Imports, 9 überflüssige `!` in Tests.
- Coverage-Gate in CI (40 %) für „kritische Pakete“ – bei 18 roten Tests und hängendem Lauf irrelevant.

---

## 2. Kritische Bugs (App-Logik)

### 2.1 Dashboard-Persistenz ist kaputt – Datenverlust bei jedem Neustart

Es gibt **vier** verschiedene Speichermechanismen, die sich gegenseitig ignorieren:

| Klasse | Datei | Storage-Key | Lädt? | Speichert? |
|---|---|---|---|---|
| `DashboardNotifier` | `features/dashboard/domain/dashboard_notifier.dart` | `dashboards` | ❌ nie | ✅ |
| `DashboardsNotifier` (plain class) | `features/dashboard/domain/dashboards_notifier.dart` | `dashboards`, `active_dashboard` | ✅ async im Konstruktor | ✅ |
| `DashboardsNotifier` (Riverpod) | `features/dashboard/ui/domain/dashboards_notifier.dart` | `dashboards` | ❌ nie (`_loadActiveId` setzt `null`) | ✅ |
| `DashboardWidgetsNotifier` | `features/dashboard/ui/views/dashboard_view.dart` | `dashboard_widgets` | ✅ | ✅ |

Folgen:
- `DashboardsNotifier.build()` erzeugt bei **jedem Start** ein neues „Mein Dashboard“ mit **neuer UUID**. Danach überschreibt `_saveDashboards()` den Key `dashboards`, und alle früher gespeicherten Dashboards sind weg.
- Zwei Klassen schreiben in denselben Key `dashboards`, aber mit **unterschiedlichen Modellen** (`Dashboard` freezed vs. `Dashboard` handgeschrieben vs. `DashboardModel`).
- Die UI arbeitet nur mit `dashboardWidgetsProvider` (eine einzige flache Widget-Liste). Mehrere Dashboards gibt es in der UI also gar nicht; `saveActive` beim Verlassen des Edit-Modus schreibt nur eine Kopie in den kaputten Notifier.
- `loadActiveWidgets()` ist ein No-Op, `_saveActiveId()` ist leer („Simplified — would write to prefs“).
- `_activeIdKey` wird deklariert und nie benutzt; `_loadActiveId()` im `DashboardNotifier` wird nie aufgerufen.

### 2.2 Neu hinzugefügte Widgets haben alle die ID `''`

`dashboard_view.dart:116`

```dart
void addWidget(String widgetType, {Map<String, dynamic>? config}) {
  final widget = WidgetInstance(widgetType: widgetType, config: config ?? {});
```

`WidgetInstance.id` hat `@Default('')`. Jedes über den Katalog hinzugefügte Widget bekommt deshalb `id == ''`. Folgen:
- `Key(instance.id)` doppelt → **Crash** in `ReorderableListView` („Duplicate keys“) und im StaggeredGrid, sobald zwei Widgets hinzugefügt werden.
- `widgetDataProvider(instance.id)` liefert für alle neuen Widgets **dasselbe** Future. `firstWhere` findet immer das erste → falsche Daten.
- `removeWidget('')` löscht **alle** neu hinzugefügten Widgets auf einmal.
- Lokaler Cache-Key `widget_cache_<type>:` kollidiert.

Fix: `id` als `required` machen oder im Factory/Notifier immer `uuid.v4()` setzen.

### 2.3 `widgetDataProvider` lädt bei jeder Änderung alle Widgets neu

`dashboard_view.dart:65`

```dart
final dashboardWidgets = ref.watch(dashboardWidgetsProvider);
final instance = dashboardWidgets.firstWhere((w) => w.id == instanceId);
```

- `ref.watch` auf die **gesamte** Liste: Jedes Resize, Reorder oder Hinzufügen invalidiert **jeden** Widget-Provider. Alle Widgets laden neu und flackern auf „loading“.
- `firstWhere` ohne `orElse` → **StateError**, sobald ein Widget entfernt wird, während sein Provider noch lebt.
- Der Provider hat Seiteneffekte (schreibt in den Cache) und ist nicht `autoDispose` → Speicherleck pro gelöschtem Widget.

Fix: `ref.watch(dashboardWidgetsProvider.select((l) => l.firstWhereOrNull(...)))` plus `autoDispose`.

### 2.4 Drei verschiedene Dinge heißen `widgetDataProvider`

| Datei | Typ | Verhalten |
|---|---|---|
| `dashboard_view.dart:65` | `FutureProvider.family` | Mock-Daten + Migration + Cache |
| `framework/widget_instance_data_provider.dart:15` | `FutureProvider.family` | liefert **immer** `'weather'`-Daten, egal welches Widget |
| `framework/widget_data_provider.dart:158` | globale Instanz von `WidgetDataProvider` (Klasse) | eigener In-Memory-Cache, nie benutzt |

Wer den falschen Import erwischt, bekommt für jedes Widget Wetterdaten. Klassischer Copy-Paste-Unfall.

### 2.5 `FutureBuilder` mit neuem Future in jedem Build

`dashboard_view.dart:503`

```dart
return FutureBuilder<Map<String, dynamic>?>(
  future: cache.getCachedData(...),   // neues Future bei jedem Rebuild
```

Der Builder startet bei jedem Rebuild neu und springt kurz auf „kein Snapshot“ → Flackern zwischen Loading und Stale. Das Future gehört in einen Provider.

### 2.6 Schema-Validierungsfehler werden als `ready` gemeldet

- `dashboard_view.dart:566` → `state: WidgetDataState.ready, data: null`
- `widget_data_provider.dart:39` → `onComplete(..., WidgetDataState.ready, errors)`

Ein ungültiges Payload ist kein „ready“. Konsumenten, die nur auf `state` schauen, rendern `parseData(null)`.

### 2.7 Validator wird bei jedem Build neu kompiliert

`widget_schema_validator.dart:73`

```dart
final schema = getSchemaForWidget(widgetType);
final validator = WidgetSchemaValidator(schema);   // JsonSchema.create bei jedem Aufruf
```

Das läuft in `build()` jedes Widgets. Für genau diesen Zweck existiert `WidgetSchemaCache`, er wird aber nirgends benutzt und „kompiliert“ auch nichts („In a real implementation, this would compile …“).

### 2.8 Schema-IDs passen nicht zu Widget-IDs

- Der Validator kennt `protein_tracker`, `sleep_tracker` … mit Feldern wie `consumed`/`slept`.
- Die registrierten Nutrient-Widgets heißen `protein_tracker`, `water_tracker` usw. (`'${nutrient}_tracker'`), erwarten aber eigene Feldnamen.
- Für unbekannte Typen gibt `getSchemaForWidget` vermutlich das Basisschema zurück. Dann wird praktisch nichts validiert.

### 2.9 Undo/Redo dreifach implementiert, keins davon korrekt

1. `undoHistoryProvider`/`redoHistoryProvider` (`StateProvider<List<List<…>>>`) in `dashboard_view.dart` – **unbegrenzt**, wächst endlos.
2. `_undoStack`/`_redoStack` in `DashboardNotifier` – nie benutzt.
3. Jeder Button-Handler pusht manuell (`update((s) => [...s, widgets])`) – sechsmal copy-paste. `widgets` ist dabei die beim **Build** gecapturte Liste, nicht der aktuelle State.
4. Undo/Redo ist nur im Edit-Modus sichtbar. Widgets lassen sich aber auch außerhalb hinzufügen (Katalog-Button), und das landet trotzdem im Undo-Stack.
5. Keine `canUndo`-Deaktivierung der Buttons.

### 2.10 Widget-Registry ist nicht typsicher

`widget_registry.dart:12`

```dart
_widgets[widget.id] = widget as WidgetDefinition<Object>;
```

Das ganze „generische `WidgetDefinition<T>`“ (Commit `a414736`) wird durch diesen Cast ausgehebelt. Typfehler zwischen `parseData` und `buildView` kommen erst zur Laufzeit.

### 2.11 Konfig-Dialog: Widget wird nur instanziiert, um eine Methode aufzurufen

`dashboard_view.dart:516` und `:586`

```dart
onConfigure: () {
  final card = WidgetCard(definition: …, instance: …, data: …);
  card.showConfigForm(context, ref, instance);
},
```

Ein Widget nur zu bauen, um eine Methode darauf aufzurufen, ist ein Anti-Pattern. Außerdem wird `WidgetData.fromJson` doppelt geparst. `showConfigForm` gehört in eine eigene Funktion oder einen Service.

Weitere Probleme im Konfig-Dialog (`widget_card.dart:228`):
- Zahlen werden **immer** als `double` gespeichert (`goal: 150` → `150.0`), Widgets lesen teils `as int`.
- Pflichtfeld-Validator gilt für **alle** Felder, auch optionale.
- `bool`-Felder bekommen ein leeres `SwitchListTile(title: SizedBox.shrink())`.

### 2.12 Zirkuläre Imports

- `widget_card.dart` importiert `dashboard_view.dart` (für `dashboardWidgetsProvider`, `mockDataProviderProvider`, `widgetDataProvider`).
- `dashboard_view.dart` importiert `widget_card.dart`.
- `dashboard_view.dart` re-exportiert `widgetRegistryProvider` aus `widget_catalog.dart`.

Dart kompiliert das, architektonisch heißt es aber: Die Basis-Komponente hängt von einem konkreten Screen ab. Providers gehören in eine eigene Datei/Schicht.

### 2.13 `WidgetCard` hängt fest am Mock

`widget_card.dart:170`: `onQuickAdd` schreibt **immer** in `mockDataProviderProvider`. Die API-Variante kann so nie funktionieren.

### 2.14 Hintergrund-Refresh macht nichts

- `widgetBackgroundRefresh.register(...)` wird **nirgends** aufgerufen → `refreshAllOnResume()` loggt immer „No refresh callbacks registered“.
- Es gibt die globale Instanz **und** `widgetBackgroundRefreshProvider` – zwei Objekte.
- `_prefs` wird nie gesetzt, nur auf `null` zurückgesetzt.
- `RefreshInterval` wird nirgends ausgewertet. Pro Widget definierte Intervalle sind wirkungslos.

### 2.15 Schema-Migration ist Attrappe

- `registerDefaultMigrations()` ist leer, wird aber in `main()` **und** im Provider aufgerufen.
- `getExpectedSchemaVersions()` gibt `{}` zurück → Zielversion immer 1 → `migrateData` tut nie etwas.
- Wenn keine Migration existiert, wird die Versionsnummer trotzdem hochgezählt („bump version anyway“). Das ist gefährlich: Daten werden als migriert markiert, obwohl sie es nicht sind.
- `getPendingMigrations` filtert `fromVersion >= currentVersion` und kann damit Lücken überspringen.

### 2.16 Weitere Logikfehler

- `WidgetDataProvider._errorStates` ist per **widgetType** statt per Instanz geschlüsselt; ein Fehler in einem Wetter-Widget markiert alle.
- `WidgetDataProvider.clearCache(instanceId:)` ignoriert `instanceId` und löscht alle Instanzen des Typs.
- `_cacheKey` nutzt `jsonEncode(config).hashCode`. String-Hashes sind nicht stabil, Kollisionen sind möglich.
- `DashboardsNotifier.active` (plain): `orElse: () => _dashboards.first` crasht bei leerer Liste.
- `rename()` verwirft beim Neubauen von `Dashboard` alle anderen Felder (statt `copyWith`).
- `delete()` setzt `_activeId` nicht neu, wenn das aktive Dashboard gelöscht wird (Riverpod-Variante).
- `resizeActiveWidget` nimmt `String size` und macht `firstWhere` ohne `orElse`. Ungültige Strings führen zum Crash.
- `clone()` erzeugt **immer** eine neue ID, auch bei `resizeWidget`/`updateConfig` (`w.clone(newSize: …)`). Damit ändert sich bei jedem Resize oder Config-Update die Widget-ID: Cache verwaist, Provider-Family-Key wechselt, und Undo-Snapshots zeigen auf andere IDs. **Schwerer Bug.** Für Updates gehört `copyWith` (freezed) verwendet.

---

## 3. Netzwerk / Backend-Integration

### 3.1 App und Backend reden aneinander vorbei

| Was | App | Backend |
|---|---|---|
| Widget-Daten-URL | `'$baseUrl/api/widgets/$widgetType'` mit `baseUrl = http://localhost:8092/api` → **`/api/api/widgets/weather`** | `/api/widgets/{widget_id}/data` |
| Widget-ID Wetter | `weather` | Allowlist kennt nur `weather_summary` → **400** |
| Widget-ID Parties | `parties` | `party_recommendations` → **400** |
| Auth | `_authHeaders()` schickt **kein Token** (`// TODO`) | alle Dashboard-/Widget-Routen verlangen `get_current_user` → **401** |
| Template anwenden | `applyTemplate(String, int dashboardId)` | Client-Dashboards haben **UUID-Strings** als ID |
| Login | – (kein Auth-Feature in der App, obwohl README es listet) | `/api/auth/login` |

Ergebnis: **Keine einzige echte API-Anfrage der App kann erfolgreich sein.** `ApiWidgetDataRepository` wird zudem nirgends verwendet; `widgetDataRepositoryProvider` liefert fest den Mock.

### 3.2 `dart:io` in geteiltem Code

`dashboard_sync_service.dart:3` importiert `dart:io` für `SocketException`. Web ist laut README Zielplattform. Im Web gibt es keine `SocketException`, der `on SocketException`-Zweig ist dort tot, und `dart:io` sollte im Web-Code gar nicht auftauchen. Besser: `http.ClientException` abfangen.

### 3.3 Sonstiges Netzwerk

- Kein Retry/Backoff, kein gemeinsamer `http.Client` (jeder Aufruf öffnet eine neue Verbindung), keine Cancellation.
- `static final _baseUrl = AppConfig.apiBaseUrl` – zur Laufzeit nicht änderbar und nicht testbar.
- Fehlermeldungen als rohe Strings (`Result<bool, String>`), nicht lokalisiert.
- `Result` erlaubt `Result.success(null)` → `isSuccess == true` mit `value == null`; `Result.error(null)` → `isSuccess == true`. Ein sealed class wäre richtig.

---

## 4. Backend (FastAPI) – Sicherheit & Korrektheit

### 4.1 🔴 OAuth-Mock = Login als beliebiger Nutzer

`backend/app/auth.py:190`

```python
email = f"oauth_{provider}_{request.token[:8]}@example.com"
```

Das Provider-Token wird **nicht verifiziert**. Wer die ersten 8 Zeichen kennt oder errät, bekommt ein gültiges JWT für diesen Account. Dazu kollidieren alle Tokens mit gleichem Präfix. Der Endpunkt ist produktiv erreichbar. **Entfernen oder hinter ein Dev-Flag stellen.**

### 4.2 🔴 Tracker-API ohne Authentifizierung, global geteilt

`backend/app/api/tracker.py` – **keine** Route hat `Depends(get_current_user)`. Die Einträge liegen in einem **modulglobalen Dict**:
- Jeder sieht und löscht die Gesundheitsdaten aller anderen (laut README ist die Zielgruppe „gesundheitsbewusst“; das sind sensible Daten, DSGVO Art. 9).
- Daten verschwinden beim Neustart und sind pro Worker verschieden.
- IDs `e_{len+1}` kollidieren nach einem Delete.
- Nur `protein`, `carbs`, `water` existieren; die App hat 25+ Tracker.

### 4.3 🔴 Rate-Limiting ist wirkungslos

`main.py` legt einen `Limiter` mit `default_limits` an, registriert aber **kein** `SlowAPIMiddleware`, und keine Route nutzt `@limiter.limit`. Damit gibt es keinerlei Rate-Limit, auch nicht auf `/login` (Brute-Force möglich). `settings.RATE_LIMIT` wird nie gelesen.

### 4.4 🟠 SECRET_KEY zufällig pro Prozess

`config.py:10`: Ohne `SECRET_KEY` wird bei jedem Start bzw. pro Worker ein neuer Key erzeugt. Dann werden alle Tokens nach einem Neustart ungültig, und bei mehreren Workern ist jede zweite Anfrage 401. In Production gibt es nur eine `warnings.warn`, statt hart abzubrechen.

### 4.5 🟠 Weitere Backend-Punkte

- **Route-Shadowing:** `GET /jobs/{job_id}` steht vor `GET /jobs/stats`. Der Pfad `/jobs/stats` landet damit in `get_job_status("stats")`.
- **Doppelte Pfade:** Router-Prefix `/api/notifications` plus Route `/notifications` ergibt `/api/notifications/notifications`.
- `OAuth2PasswordBearer(tokenUrl="/api/auth/token")`, den Endpunkt gibt es nicht (heißt `/login`). Swagger-Login funktioniert nicht.
- `decode_token` gibt die JWT-Fehlermeldung an den Client weiter (`f"Invalid token: {e}"`).
- Keine Passwort-Policy, `email: str` statt `EmailStr`, keine E-Mail-Verifizierung.
- Async-Endpunkte (`async def`) mit **synchroner** SQLAlchemy-Session blockieren den Event-Loop.
- `Base.metadata.create_all` im Lifespan, obwohl `alembic` in den Requirements steht. Migrationen gibt es keine.
- Die Widget-Allowlist ist zweimal identisch in `widgets.py` kopiert (`WidgetIdRequest` und `validate_widget_type`). Der Längencheck kommt **nach** dem Allowlist-Check und ist damit tot.
- `security.py`: Der Encryption-Key wird unverschlüsselt in `~/.widgetly/encryption.key` geschrieben. Auf Servern/Containern geht er beim Redeploy verloren, und damit alle verschlüsselten Daten.
- `sanitize_text` als „Prompt-Injection-Schutz“ entfernt nur `[...]` und literal `\n`. Das schützt vor nichts und erzeugt falsche Sicherheit.
- `FCM_API_KEY` deutet auf die **Legacy-FCM-API** hin, die von Google abgeschaltet wurde (HTTP v1 + Service-Account nötig).
- Uralte gepinnte Versionen (FastAPI 0.109, `python-jose` 3.3.0 mit bekannten CVEs, `passlib` unmaintained und mit neueren `bcrypt` kaputt).
- CORS erlaubt nur `localhost:8092`, das ist der Port der **API selbst**. Die Flutter-Web-App läuft auf einem anderen Port und wird geblockt.

### 4.6 🔴 Datenbank mit echten Daten im Repo

`backend/widgetly.db` ist eingecheckt und enthält einen User inkl. **bcrypt-Hash** (`notif_test@example.com`) sowie Tabellen mit Notification-Logs. Datenbanken gehören nicht ins Git; aus der History entfernen (`git filter-repo`).

---

## 5. Architektur & Code-Qualität

### 5.1 Massiver toter bzw. duplizierter Code

**Nie registrierte und nirgends referenzierte Widgets** (0 Referenzen):
`BudgetWidget`, `NewsWidget`, `OpnvWidget`, `StocksWidget` – zusammen ca. 900 Zeilen.

**Durch Generika ersetzte, aber nicht gelöschte Copy-Paste-Widgets** (nur von sich selbst bzw. alten Tests referenziert):
`CarbsTrackerWidget`, `CaffeineTrackerWidget`, `CalorieTrackerWidget`, `FiberTrackerWidget`, `SugarTrackerWidget`, `FatTrackerWidget`, `ActiveMinutesTrackerWidget`, `ProteinTrackerWidget`, `WaterTrackerWidget`.

Beispiel `fat_tracker_widget.dart` vs. `fiber_tracker_widget.dart`: Bis auf Name, Icon, Farbe und Default-Ziel **zeichengleich** (166 Zeilen jeweils). Registriert ist stattdessen `NutrientTrackerWidget` mit **denselben IDs** (`protein_tracker`, `water_tracker`, …). Tests testen also teilweise Klassen, die die App gar nicht benutzt.

Weitere tote oder doppelte Artefakte:
- 3× Dashboard-Notifier, 2× `Dashboard`-Modell plus `DashboardModel` (siehe 2.1)
- `WidgetSchemaCache`, `WidgetDataProvider` (Klasse), `ApiWidgetDataRepository`, `widgetLocalCache` (globale Instanz neben dem Provider), `widgetMigrationRegistry` (global neben dem Provider), `activeDashboardProvider`, `isDark`, `_activeIdKey`
- `features/dashboard/ui/domain/` – eine „domain“ **innerhalb** von „ui“ neben `features/dashboard/domain/`
- Zwei Katalog-Implementierungen: `dashboard/ui/views/widget_catalog.dart` (Bottom Sheet inline in `dashboard_view.dart`) **und** `widgets/presentation/pages/widget_catalog_page.dart` (Route `/widgets`)
- Mischung aus Ordnerkonventionen: `ui/views`, `presentation/pages`, `ui/types`, `framework`, `data`, `domain`

### 5.2 God-File `dashboard_view.dart` (710 Zeilen)

Enthält Providers, einen StateNotifier mit Persistenz, Grid-Konfiguration, Undo/Redo-Logik, Datenlade-Logik, den Katalog-Dialog und die View. Aufteilen in `providers/`, `notifiers/` und `widgets/`.

### 5.3 Riverpod-Nutzung

- Mix aus `StateNotifierProvider` (Legacy), `StateProvider` (Legacy) und `NotifierProvider`. `flutter_riverpod: ^2.6.1` ist zudem veraltet (3.x verfügbar).
- `freezed`/`json_serializable` als Dev-Dependency, aber `freezed_annotation` als **Dev**-Dependency, obwohl es in `lib/` importiert wird. Es gehört in `dependencies`.
- Generierte Dateien (`*.freezed.dart`, `*.g.dart`) sind eingecheckt, aber `build_runner` ist nicht in CI. Sie können still veralten.
- `ref.read` mit Captured-Werten aus `build()` in Callbacks (siehe Undo).

### 5.4 Lokalisierung halbgar

- Eigene i18n-Klasse mit 447 Zeilen handgeschriebener Getter statt `flutter gen-l10n` (ARB) – keine Typsicherheit gegen fehlende Keys, keine Pluralformen.
- `shouldReload` gibt immer `true` zurück → lädt bei jedem Rebuild der Localizations die JSON-Dateien neu.
- Mindestens **49** hartcodierte `Text('…')` in `lib/`, u. a. `'Layout teilen'`, `'Klein'`, `'Mittel'`, `'Groß'`, `'Quelle: …'`, `'Schema-Fehler'`, `'Fehler beim Laden'`, `'Keine Daten'`, `'Abbrechen'`, `'Speichern'`, `'Bitte eingeben'`, `'Mein Dashboard'`, `'Hauptdashboard'`, sämtliche Widget-Namen und -Beschreibungen (`'Aktive Minuten'` …), Validator-Meldungen.
- `main.dart` importiert `GlobalWidgetsLocalizations` doppelt (einmal aus `material_ui`, einmal aus `flutter_localizations`) und `material_ui` zweimal (einmal mit Prefix, einmal ohne).

### 5.5 Theming / UI

- `scheme.surfaceVariant` ist deprecated (16× `deprecated_member_use`).
- Hartcodierte Farben (`Colors.white`, `Colors.grey.shade200`, `Colors.red`, `Colors.orange`) im Placeholder und in WidgetCard → **Dark Mode kaputt** (weiße Karte auf dunklem Hintergrund).
- `AppTheme.titleSmall` usw. als statische TextStyles statt `Theme.of(context).textTheme`. Damit ignorieren sie Dark Mode und Textskalierung.
- `StaggeredGrid.count` in `SingleChildScrollView` baut **alle** Widgets auf einmal, auch unsichtbare. Kein Lazy Building.
- Zwei verschachtelte `RefreshIndicator`s (Dashboard + jede WidgetCard) mit nicht scrollbarem Kind. Der innere funktioniert nicht.
- Drag-Handle-`IconButton` mit `onPressed: null` sieht klickbar aus, tut aber nichts.
- `ResponsiveGridConfig.getAspectRatio` wird nie benutzt; zwei der drei Zweige geben ohnehin denselben Wert zurück.
- Kein `Semantics`, keine Tooltips an Edit-Buttons (Kopieren/Löschen) → schlechte Accessibility.

### 5.6 Logging / Fehlerbehandlung

- Drei Logging-Arten parallel: `print` (11× `avoid_print`), `debugPrint`, `appLogger`. Commit `0dd047d` „replace print() calls“ hat das nur teilweise erledigt.
- `catch (e) { debugPrint(...) }` ohne Stacktrace und ohne Nutzerfeedback. Speichern kann still fehlschlagen.
- `try { firstWhere } catch (_) { return null; }` statt `firstWhereOrNull`.
- 24× `discarded_futures`: async Saves werden ohne `await` abgefeuert, Reihenfolge und Fehler gehen verloren (Race: zwei schnelle Änderungen können in umgekehrter Reihenfolge gespeichert werden).
- 8× `use_build_context_synchronously` → mögliche Crashes nach `await`.

### 5.7 Konfiguration & Secrets

- `AppConfig` enthält Platzhalter-Keys (`'YOUR_OPENAI_API_KEY'`) direkt im Dart-Code. **Ein OpenAI-Key gehört nie in eine Client-App**, auch nicht über `--dart-define`: Jeder kann ihn aus dem Binary extrahieren. Der Aufruf muss über das Backend laufen.
- `AppConfig.validateApiKeys()` wird nirgends aufgerufen.
- `Environment.staging` ist unerreichbar (nur `kReleaseMode` → prod/dev).
- Supabase-URLs `https://dev.supabase.co` sind Fantasiewerte; Supabase ist ohnehin nicht als Dependency eingebunden.
- README verweist auf `cp .env.example .env`, eine `.env.example` gibt es im Root nicht (nur `backend/.env.example`). Flutter liest `.env` ohnehin nicht (kein `flutter_dotenv`).

---

## 6. Repository, Build & CI

- **`.gitignore` ignoriert `*.lock`** → `pubspec.lock` (und jede Python-Lockfile) ist nicht eingecheckt. Für eine **App** muss `pubspec.lock` versioniert werden, sonst sind Builds nicht reproduzierbar.
- `.idea/`, `widgetly.iml`, `android/widgetly_android.iml` sind eingecheckt.
- `backend/widgetly.db` eingecheckt (siehe 4.6).
- Neun Markdown-Dateien im Root (`REVIEW.md`, `REVIEW_ALL_PHASES.md`, `Review_ultimate.md`, `review-architecture.md`, `review-backend-status.md`, `review-frontend-status.md`, `TODO.md`, `TODO_Review.md`, …) – teils widersprüchlich und mit Häkchen bei Dingen, die nicht funktionieren. Gehören nach `docs/` oder in Issues.
- `pubspec.yaml`: `description: "A new Flutter project."`, haufenweise Template-Kommentare, `cupertino_ui` fehlt als Dependency, `analyzer: ^14.0.0` als Dev-Dep (unnötig, kollidiert leicht mit `build_runner`).
- **CI:** `flutter analyze --fatal-infos` bei 332 Infos → **schlägt immer fehl**. Damit laufen auch `test` und `build_web` nie bis zum Ende. Backend-Tests sind gar nicht in CI.
- README widerspricht sich selbst: „Karten: OpenStreetMap + Leaflet“ vs. „Karten: Mapbox“; „Backend: FastAPI, PostgreSQL, Redis, Celery“ vs. „Supabase + FastAPI“, im Code dagegen SQLite, kein Redis, kein Celery. Die Clone-URL im README zeigt auf ein anderes Repo (`zumazui123-creator/dummy`).
- Commit-Messages wie `viel` und Sammelcommits mit gemischtem Inhalt erschweren Review und Bisect.

---

## 7. Analyzer-Statistik (`flutter analyze`)

| Lint | Anzahl |
|---|---|
| prefer_const_constructors | 188 |
| discarded_futures | 24 |
| unnecessary_brace_in_string_interps | 22 |
| unused_import | 19 |
| deprecated_member_use | 16 |
| prefer_const_literals_to_create_immutables | 12 |
| sized_box_for_whitespace | 11 |
| depend_on_referenced_packages | 11 |
| avoid_print | 11 |
| unnecessary_non_null_assertion | 9 |
| unnecessary_import | 9 |
| use_build_context_synchronously | 8 |
| unnecessary_to_list_in_spreads | 6 |
| prefer_initializing_formals | 6 |
| unused_field | 4 |
| unnecessary_null_comparison | 4 |
| sonstige | 17 |
| **Gesamt** | **377** |

Ein Großteil davon (const, Klammern, Imports) lässt sich mit `dart fix --apply` automatisch beheben. Ernst zu nehmen sind `discarded_futures`, `use_build_context_synchronously`, `depend_on_referenced_packages` und `deprecated_member_use`.

---

## 8. Empfohlener Fahrplan

**Phase 1 – Lauffähig machen (1–2 Tage)**
1. `Future.delayed` aus `golden_widget_test.dart` entfernen; gemeinsames `pumpApp()`-Helper mit allen Localization-Delegates in `test_helpers.dart` und überall nutzen.
2. `WidgetInstance.id` required machen bzw. im Notifier immer UUID vergeben (2.2).
3. `clone()` nur für Duplikate, sonst `copyWith` (2.16 letzter Punkt).
4. `dart fix --apply`, ungenutzte Imports entfernen, `cupertino_ui` und `freezed_annotation` korrekt in `dependencies`.
5. `pubspec.lock` einchecken, `*.lock` aus `.gitignore` entfernen, `widgetly.db` und `.idea` aus dem Repo.

**Phase 2 – Ein State-Modell (2–4 Tage)**
6. Genau **einen** `DashboardsNotifier` (AsyncNotifier) mit Laden, Speichern, aktivem Dashboard und begrenztem Undo/Redo. Alle anderen löschen.
7. Ein Repository-Interface (Mock/API) und einen einzigen `widgetDataProvider` (`autoDispose.family`, `select` auf die Instanz).
8. Validator-Cache, eindeutige Schema-IDs und `error`-State bei Validierungsfehlern.
9. Toten Code löschen (Abschnitt 5.1), `dashboard_view.dart` aufteilen, Zyklen auflösen.

**Phase 3 – Backend absichern (2–3 Tage)**
10. OAuth-Mock entfernen, Tracker-API mit Auth + DB, SlowAPI-Middleware aktivieren, SECRET_KEY verpflichtend.
11. API-Vertrag (OpenAPI) als Single Source of Truth für Widget-IDs/URLs; Client generieren oder dagegen testen.
12. `python-jose` → `PyJWT`, `passlib` → `bcrypt`/`argon2-cffi`, Abhängigkeiten aktualisieren, Backend-Tests in CI.

**Phase 4 – Qualität**
13. ARB-basierte Lokalisierung, alle hartcodierten Strings raus.
14. Theme-Farben aus `ColorScheme`, echte Golden-Tests mit `matchesGoldenFile`.
15. README und Doku konsolidieren, Review-/TODO-Dateien in Issues überführen.
