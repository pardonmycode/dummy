# TODO: Flutter-Review in Phasen

Diese Liste stammt aus dem Flutter-Review vom 27.11.2026 (Stand `d558b7f`). Die Probleme im Backend und deren Reihenfolge stehen in [Review_ultimate.md](Review_ultimate.md), Abschnitt 7.

**Wichtig:** Die Flutter-Punkte stammen aus dem Lesen des Codes. Die App und die Tests konnte ich nicht ausführen, weil auf dem Review-Rechner kein Flutter installiert war.

## Regel für `[x]`

Ein Punkt gilt erst als erledigt, wenn alle drei Bedingungen erfüllt sind:

1. Es gibt einen Test, der ohne den Fix fehlschlägt und mit dem Fix grün ist.
2. Es funktioniert in der laufenden App, nicht nur im Test.
3. Die CI ist grün.

---

## Phase 1: Fehler beheben (ca. 1–2 Tage)

Ziel: Was die App heute verspricht, funktioniert auch. Jeder Fix bekommt zuerst einen Test, der den Fehler zeigt.

- [ ] **1.1 Layout überlebt keinen Neustart.**
  - In [widget_instance.dart:65](lib/features/widgets/framework/widget_instance.dart#L65) schlägt `as Map<String, int>?` nach `jsonDecode` immer fehl, also lädt die App immer nur die Standard-Widgets.
  - Fix: Die Map Wert für Wert umwandeln, z. B. `(json['gridPosition'] as Map?)?.map((k, v) => MapEntry(k as String, (v as num).toInt()))`.
  - Test: Roundtrip über `jsonEncode`/`jsonDecode` sowie Speichern und Neuladen mit `SharedPreferences.setMockInitialValues`.
  - Betrifft auch Import und Download.
- [ ] **1.2 Verschieben nach unten springt eine Position zu kurz.**
  - Der Index wird zweimal korrigiert, in [dashboard_view.dart:394](lib/features/dashboard/ui/views/dashboard_view.dart#L394) und in `moveWidget` ([Zeile 176](lib/features/dashboard/ui/views/dashboard_view.dart#L176)). Wird ein Widget nur eine Position nach unten gezogen, passiert deshalb gar nichts.
  - Fix: genau eine der beiden Korrekturen entfernen.
  - Test: Verschieben um 1 nach unten, um 1 nach oben und an das Ende.
- [ ] **1.3 Der Refresh-Knopf und Pull-to-Refresh tun nichts.**
  - Die Karte lädt über einen `FutureBuilder`, dessen Future in `build` erzeugt wird ([dashboard_view.dart:503](lib/features/dashboard/ui/views/dashboard_view.dart#L503)). Der Knopf invalidiert dagegen den `widgetDataProvider`, den niemand beobachtet. Pull-to-Refresh wartet nur eine Sekunde ([Zeile 331](lib/features/dashboard/ui/views/dashboard_view.dart#L331)).
  - Nebenwirkung: Jeder Rebuild lädt alle Widgets neu und schreibt sie in SharedPreferences.
  - Fix für jetzt: Die Karte beobachtet `widgetDataProvider(instance.id)` mit `ref.watch`, und Pull-to-Refresh invalidiert alle Instanzen. Die saubere Lösung folgt in Phase 2.3.
- [ ] **1.4 Mehrere Dashboards sind nur eine Attrappe.**
  - In [dashboards_notifier.dart](lib/features/dashboard/ui/domain/dashboards_notifier.dart) gibt `_getActiveId()` immer `null` zurück, und `setActive` speichert nichts.
  - Der `Notifier` wird in [dashboard_view.dart:94](lib/features/dashboard/ui/views/dashboard_view.dart#L94) von Hand in einem `Provider` erzeugt, deshalb wirft jeder Zugriff auf `state` eine Exception.
  - Folgen: "Layout teilen" zeigt immer einen Fehler, "Hochladen" lädt nie etwas hoch, und beim Verlassen des Bearbeitungsmodus fliegt ein unbehandelter Fehler.
  - Fix: `NotifierProvider` verwenden und die aktive ID persistent speichern. Alternativ das Feature ausblenden, bis Phase 2.1 fertig ist.
- [ ] **1.5 Sync-Meldungen erscheinen nie.**
  - Das Bottom-Sheet wird vor dem `await` geschlossen, danach ist `syncContext.mounted` immer `false` ([dashboard_view.dart:863](lib/features/dashboard/ui/views/dashboard_view.dart#L863)).
  - Fix: `ScaffoldMessenger.of(context)` vor dem Schließen in einer Variable merken und danach diese verwenden.
- [ ] **1.6 "Kopieren" kopiert nicht.**
  - In [dashboard_view.dart:769](lib/features/dashboard/ui/views/dashboard_view.dart#L769) wird "kopiert" angezeigt, aber nichts in die Zwischenablage gelegt.
  - Fix: `Clipboard.setData(ClipboardData(text: layoutJson))` aufrufen.
- [ ] **1.7 Vorlagen nutzen falsche IDs und lassen sich nicht rückgängig machen.**
  - Die IDs `steps` und `water` existieren nicht; richtig sind `steps_tracker` und `water_tracker` ([dashboard_view.dart:979](lib/features/dashboard/ui/views/dashboard_view.dart#L979)).
  - Eine Vorlage ersetzt das ganze Dashboard ohne Undo-Eintrag und ohne Rückfrage.
  - Fix: IDs korrigieren, einen Undo-Eintrag anlegen und vorher einen Bestätigungsdialog zeigen.
- [ ] **1.8 Konfigurationsdialog.**
  - Ein Ja/Nein-Schalter lässt sich optisch nicht umlegen, weil nichts neu zeichnet ([widget_card.dart:269](lib/features/widgets/ui/base/widget_card.dart#L269)). Fix: `StatefulBuilder`.
  - Die Controller werden direkt nach `Navigator.pop` entsorgt, während der Dialog noch ausblendet. Fix: erst nach `await showDialog(...)` entsorgen, und auch beim Schließen durch Tippen außerhalb.
- [ ] **1.9 "+ 250ml" beim Wasser-Tracker hat keine Wirkung.**
  - Der Eintrag landet in einem Wegwerf-Objekt ([water_tracker_widget.dart:119](lib/features/widgets/ui/types/water/water_tracker_widget.dart#L119)).
  - Fix: den Eintrag über einen Notifier oder ein Repository speichern. Gilt für alle Schnelleinträge.
- [ ] **1.10 Die Karte verletzt die OSM-Regeln.**
  - Betrifft [parties_widget.dart:114](lib/features/widgets/ui/types/parties/parties_widget.dart#L114).
  - Fix: `{s}`-Subdomains entfernen, `userAgentPackageName` setzen und einen `RichAttributionWidget` mit "© OpenStreetMap contributors" anzeigen.
  - Für die Produktion einen Kachelanbieter wählen, dessen Bedingungen kommerzielle Apps erlauben.
- [ ] **1.11 Vier registrierte Widgets bekommen keine Mock-Daten.**
  - Betroffen sind Parties, Kohlenhydrate, Wasser und Schritte, die deshalb leer bleiben.
  - Fix: Mock-Daten in [mock_widget_data_provider.dart](lib/features/widgets/framework/mock_widget_data_provider.dart) ergänzen, mit Koordinaten für die Parties.

**Fertig, wenn:** Alle elf Punkte einen Test haben und eine kurze Vorführung zeigt, dass Layout, Neustart, Verschieben, Refresh, Teilen und Vorlagen funktionieren.

---

## Phase 2: Zustand und Datenfluss (ca. 3–5 Tage)

Ziel: Für jeden Zustand gibt es genau eine Quelle der Wahrheit, und die UI enthält keine Datenlogik mehr.

- [ ] **2.1 Einen einzigen `DashboardNotifier` bauen.**
  - Er verwaltet die Liste der Dashboards, die aktive ID und eine begrenzte Undo/Redo-Historie (z. B. 50 Schritte).
  - Dafür entfallen `dashboardWidgetsProvider`, `activeDashboardProvider`, die beiden Undo/Redo-`StateProvider` und die doppelte Datei [features/dashboard/domain/dashboards_notifier.dart](lib/features/dashboard/domain/dashboards_notifier.dart).
  - Die Undo-Einträge legt der Notifier selbst an, nicht sechs verschiedene Stellen in der View.
- [ ] **2.2 `WidgetDataRepository` als Schnittstelle einführen.**
  - Es gibt zwei Implementierungen, `MockWidgetDataRepository` und `ApiWidgetDataRepository`, bereitgestellt über einen Provider, damit Tests und Varianten ihn überschreiben können.
  - Die API-Version setzt die Backend-Phase B aus `Review_ultimate.md` voraus.
- [ ] **2.3 Pro Widget-Instanz einen `AsyncNotifier` (family) anlegen.**
  - Er zeigt zuerst die Daten aus dem lokalen Cache und lädt im Hintergrund frisch nach (stale-while-revalidate).
  - Er bietet eine `refresh()`-Methode und beobachtet mit `select` nur seine eigene Instanz.
  - Der `FutureBuilder`, der in `build` erzeugt wird, entfällt dann komplett.
- [ ] **2.4 Validierung, Migration und Cache ins Repository verschieben.**
  - Das `JsonSchema` wird einmal pro Widget-Typ kompiliert, nicht bei jedem Build.
- [ ] **2.5 Globale Singletons durch Provider ersetzen.**
  - Das betrifft `_sharedRegistry`, `widgetLocalCache`, `widgetMigrationRegistry` und `widgetBackgroundRefresh`.
  - Die ungenutzte Klasse `WidgetDataProvider` in [widget_data_provider.dart](lib/features/widgets/framework/widget_data_provider.dart) wird gelöscht.
- [ ] **2.6 [dashboard_view.dart](lib/features/dashboard/ui/views/dashboard_view.dart) aufteilen.**
  - Getrennte Dateien für die View, das Raster, die Bearbeitungsliste, den Katalog sowie die Dialoge für Teilen, Import, Sync und Vorlagen.
  - Die Registry wandert in eine eigene Datei, z. B. `widget_catalog.dart`.
- [ ] **2.7 Auf Riverpod 3 umsteigen.**
  - `StateNotifier` und `StateProvider` durch `Notifier` und `AsyncNotifier` ersetzen.
  - Entweder `riverpod_generator` wirklich nutzen oder die ungenutzten Pakete `riverpod_annotation` und `riverpod_generator` entfernen.
- [ ] **2.8 Den Exportblock für Tests aus `main.dart` entfernen.** Tests importieren die Provider direkt aus ihren Dateien.

**Fertig, wenn:** Keine View-Datei Daten lädt, cacht oder validiert, keine Datei mehr als etwa 300 Zeilen hat und der `DashboardNotifier` eigene Tests für Hinzufügen, Entfernen, Verschieben, Größe ändern, Undo und Redo hat.

---

## Phase 3: Typisierte Daten und weniger Duplikate (ca. 3–4 Tage)

Ziel: Ein fehlerhaftes Feld kann keine Karte mehr zum Absturz bringen, und neue Tracker brauchen keine eigene Datei.

- [ ] **3.1 Modelle mit `freezed` und `json_serializable` bauen.**
  - Zuerst für `WidgetInstance`, `Dashboard` und `WidgetData`.
  - Damit verschwindet die ganze Fehlerklasse aus 1.1.
- [ ] **3.2 Typisierte Datenmodelle pro Widget anlegen.**
  - Zuerst für Wetter, Protein, Schritte und Parties, danach für den Rest.
  - Geparst wird im Repository, nicht in `build()`.
- [ ] **3.3 `WidgetDefinition<T>` mit typisierten Daten einführen.**
  - `buildView` bekommt das fertige Modell statt `data.data['x'] as num?`.
  - Optional getrennte Builder für die Größen S, M und L.
- [ ] **3.4 Ein generisches `NutrientTrackerWidget` bauen.**
  - Es ersetzt die Tracker für Protein, Kohlenhydrate, Fett, Ballaststoffe, Zucker, Kalorien, Koffein und Wasser.
  - Die Dateien sind heute zu etwa 92 % identisch; Fett und Ballaststoffe unterscheiden sich in 26 von 155 Zeilen.
- [ ] **3.5 Ein generisches `MetricTrackerWidget` bauen.**
  - Es ersetzt die Tracker für Gewicht, Körperfett, Puls, Schlaf, Distanz und aktive Minuten, soweit sie gleich aufgebaut sind.
- [ ] **3.6 Widget-IDs als Konstanten oder Enum festlegen.**
  - Registry, Vorlagen, Mock-Daten und Backend nutzen dieselben IDs, damit Tippfehler wie in 1.7 nicht mehr möglich sind.
- [ ] **3.7 Clientseitige Schema-Migrationen entfernen.**
  - Die Versionen 1 → 2 in [widget_schema_migration.dart](lib/features/widgets/framework/widget_schema_migration.dart) gehören zu Widgets, die nie veröffentlicht wurden.
  - Versionierung gehört an die API-Grenze.

**Fertig, wenn:** In keinem Widget mehr `data.data['` vorkommt, und der Ordner `widgets/ui/types` deutlich kleiner ist (heute 30 Dateien mit rund 4.700 Zeilen).

---

## Phase 4: Raster, Navigation und App-Struktur (ca. 3–4 Tage)

Ziel: Die Kernfunktionen des Dashboards, also Größen, Drag & Drop und Seiten, funktionieren wirklich.

- [ ] **4.1 Ein echtes Dashboard-Raster bauen.**
  - Mit `StaggeredGrid.count` (das Paket `flutter_staggered_grid_view` ist schon installiert), wobei jede Größe eine feste Zahl Zellen belegt, z. B. S = 1×1, M = 2×1, L = 2×2.
  - Heute bekommen alle Karten das Seitenverhältnis des ersten Widgets ([dashboard_view.dart:366](lib/features/dashboard/ui/views/dashboard_view.dart#L366)).
- [ ] **4.2 Drag & Drop direkt im Raster ermöglichen**, nicht nur in einer separaten Listenansicht.
- [ ] **4.3 Den Router aktivieren.**
  - `MaterialApp.router` mit dem vorhandenen `appRouter` verwenden ([app_router.dart](lib/core/routing/app_router.dart)). Heute nutzt [main.dart:76](lib/main.dart#L76) `home:`.
  - Danach sind die Einstellungs- und die Katalog-Seite erreichbar, und Detailseiten pro Widget werden möglich.
- [ ] **4.4 Die Sprachauswahl verdrahten oder entfernen.** [localization_provider.dart](lib/core/i18n/localization_provider.dart) wirft heute `UnimplementedError`.
- [ ] **4.5 Den Hintergrund-Refresh ersetzen.**
  - Der Timer-Dienst ([widget_background_refresh.dart](lib/features/widgets/framework/widget_background_refresh.dart)) läuft, aber nie registriert sich etwas.
  - Ersatz: Mit `AppLifecycleListener` beim Zurückkehren in die App aktualisieren. Echte Hintergrund-Updates kommen später über Server-Push.
- [ ] **4.6 Karte im scrollbaren Raster.**
  - Das Verschieben der Karte und das Scrollen der Seite kommen sich in die Quere.
  - Fix: die Karte in der Kachel nur anzeigen und bei Tippen eine Vollbild-Karte öffnen.

**Fertig, wenn:** Eine Größenänderung das Layout sichtbar verändert, alle Seiten über die Navigation erreichbar sind und ein Widget-Test das Verschieben im Raster prüft.

---

## Phase 5: Theme, Übersetzungen und Barrierefreiheit (ca. 2–3 Tage)

Ziel: Dark Mode, Englisch und Bedienung mit Hilfstechnik funktionieren überall.

- [ ] **5.1 Theme auf `ColorScheme` und `ThemeExtension` umstellen.**
  - Eigene Farben wie Erfolg, Warnung und Kartenrand kommen in eine `ThemeExtension`.
  - Die rund 68 fest eingebauten Farben in `lib/features` werden ersetzt (`AppTheme.light*`, `Colors.white`, `Colors.grey` usw.), ebenso die Verzweigungen `isDark ? … : …`.
- [ ] **5.2 Auf Flutters gen-l10n mit ARB-Dateien umsteigen.**
  - Ersetzt den eigenen JSON-Loader in [app_localizations.dart](lib/core/i18n/app_localizations.dart).
  - Bringt Prüfung der Schlüssel beim Kompilieren und Pluralformen.
- [ ] **5.3 Die rund 95 fest eingebauten Texte (`Text('…')`) in die ARB-Dateien verschieben.**
  - Dazu gehören auch Tooltips wie "Layout teilen" und die Größen "Klein", "Mittel" und "Groß".
- [ ] **5.4 Falsch wiederverwendete Übersetzungen korrigieren.**
  - Der Titel `editDashboard` erscheint bei Teilen und Import.
  - `add` ist die Beschriftung des Kopieren-Knopfs.
  - `searchWidgets` ist der Platzhalter im Import-Feld.
  - Außerdem den Tippfehler "Produktivitäts-Widlets" beheben.
- [ ] **5.5 Imports vereinheitlichen.**
  - Überall nur `material_ui` und `cupertino_ui` verwenden, ohne `as flutter`-Aliase oder doppelte Imports wie heute in [main.dart](lib/main.dart).
- [ ] **5.6 Barrierefreiheit verbessern.**
  - `Semantics`-Beschriftungen für Karten und Fortschrittsringe ergänzen.
  - Status nicht nur über Farbe zeigen (heute orange und rote Icons).
  - Mit großer Systemschrift (Textskalierung 200 %) testen.

**Fertig, wenn:** Golden-Tests jedes Widget in Hell und Dunkel zeigen, eine Lint-Regel feste Texte verbietet und die App komplett auf Englisch lesbar ist.

---

## Phase 6: Qualität, Tests und CI (laufend, Start parallel zu Phase 1)

Ziel: Fehler wie in Phase 1 fallen automatisch auf, bevor sie gemerged werden.

- [ ] **6.1 CI auf die richtige Flutter-Version setzen.**
  - [ci.yml](.github/workflows/ci.yml) nutzt Flutter 3.27.0. `pubspec.yaml` verlangt aber Dart `^3.14.0`, und `material_ui` braucht Flutter 3.47 oder neuer.
  - Am besten die Version an einer einzigen Stelle festlegen, z. B. mit `flutter-version-file`.
- [ ] **6.2 Tests ergänzen, und zwar genau dort, wo die Fehler lagen.**
  - Speichern und Laden mit echtem JSON-Roundtrip, Verschieben, Undo/Redo, Vorlagen, Teilen und Import.
  - Sync mit gemocktem HTTP-Client und der Konfigurationsdialog.
- [ ] **6.3 Golden-Tests pro Widget und Größe**, jeweils in Hell und Dunkel.
- [ ] **6.4 Einen Integrationstest für den Ablauf** "Bearbeiten → Hinzufügen → Verschieben → Größe ändern → Neustart → Layout ist noch da".
- [ ] **6.5 Strengere Lints aktivieren**, z. B. `avoid_print`, `unawaited_futures`, `discarded_futures`, `use_build_context_synchronously` und `prefer_const_constructors`.
- [ ] **6.6 Crash-Reporting einbauen (z. B. Sentry) und einen Logger statt `print`/`debugPrint` verwenden.** `TODO.md` hakt das als erledigt ab, aber in `pubspec.yaml` ist keine passende Bibliothek.
- [ ] **6.7 Ungenutzte Pakete entfernen.**
  - Kandidaten: `fluttertoast`, `cached_network_image`, eventuell `riverpod_annotation`/`riverpod_generator` (siehe 2.7) und `json_schema` (falls die Validierung durch generierte Modelle ersetzt wird).
- [ ] **6.8 Eine Mindest-Testabdeckung in der CI festlegen**, z. B. 60 % für `lib/features/dashboard` und `lib/features/widgets/framework`.

**Fertig, wenn:** Jeder Pull Request ohne grüne CI nicht gemerged werden kann.

---

## Abhängigkeiten zwischen den Phasen

- Phase 1 und 6.1 sofort starten.
- Phase 2 nach Phase 1.
- Für die API-Version aus 2.2 muss zuerst die Backend-Phase B aus `Review_ultimate.md` fertig sein.
- Phase 3 nach Phase 2.
- Phase 4 kann nach 2.6 parallel zu Phase 3 laufen.
- Phase 5 kann jederzeit nach 2.6 laufen. Am wenigsten Arbeit macht sie nach Phase 3, weil dann weniger Widget-Dateien übrig sind.
