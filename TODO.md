# TODO: KI-gesteuerte Widget-App (Flutter)

**Idee:** Nutzer stellen sich ihr UI frei aus Widgets zusammen. Das Backend wird weitgehend von KI gesteuert: Die KI sammelt Daten und liefert JSON, das Widget zeigt dieses JSON nur an.

```text
Flutter-App  ->  Backend/API  ->  KI-Orchestrator  ->  Tools (Wetter, Karten, Web, Health ...)
    ^                                   |
    +---- validiertes Widget-JSON <-----+
```

## Grundregeln

- Jedes Widget hat ein versioniertes JSON-Schema als Vertrag zwischen KI und UI.
- KI-Antworten werden immer serverseitig validiert, bevor sie die App erreichen.
- Widgets rufen nie direkt die KI auf und enthalten keine API-Keys.
- Fakten wie Orte, Zeiten, Preise und Links müssen aus einem Tool stammen und eine Quelle haben. Die KI darf sie nicht erfinden.
- Eigene Messwerte (Schritte, Makros, Gewicht) werden direkt gespeichert. Die KI liest, interpretiert und schlägt vor, verändert sie aber nie ohne Bestätigung.

## Definition of Done für jedes Widget

- [ ] JSON-Schema (`schemaVersion`, `data`, `sources`, `generatedAt`, `expiresAt`) definiert
- [ ] Prompt und erlaubte Tools definiert
- [ ] Zustände Laden, Leer, Fehler, Veraltet und Offline umgesetzt
- [ ] Größen S, M und L responsiv umgesetzt
- [ ] Einstellungen des Widgets umgesetzt
- [ ] Light Mode, Dark Mode und Accessibility geprüft
- [ ] Texte lokalisiert (DE, EN)
- [ ] Refresh-Intervall und Cache-Dauer festgelegt
- [ ] Unit-, Widget- und Schema-Tests mit Beispiel-JSON geschrieben
- [ ] Im Widget-Katalog registriert

---

## Phase 0: Entscheidungen

- [x] Produktname festlegen
- [x] Zielplattformen für v1 festlegen (iOS, Android, Web)
- [ ] MVP-Widgets final auswählen
- [ ] Zielgruppe und wichtigste Nutzungsszenarien definieren
- [ ] KI-Anbieter und Modelle pro Aufgabe festlegen
- [ ] Backend-Stack festlegen (z. B. Supabase, Firebase oder eigene API)
- [x] State Management festlegen (Empfehlung: Riverpod)
- [ ] Kartenanbieter festlegen (Mapbox, Google Maps oder OpenStreetMap)
- [ ] Geschäftsmodell festlegen (Free, Abo, KI-Credits)
- [ ] Monatliches KI-Budget pro Nutzer festlegen
- [ ] Rechtliche Anforderungen klären (DSGVO, Gesundheitsdaten, Standortdaten, Scraping)

## Phase 1: Projekt-Setup

- [x] Flutter SDK installieren (aktuell auf diesem Rechner nicht vorhanden)
- [x] Flutter-Projekt erstellen
- [ ] Feature-first-Ordnerstruktur anlegen
- [ ] Linting und Formatierung einrichten
- [ ] Umgebungen dev, staging und prod anlegen
- [ ] Routing einrichten
- [ ] Lokalisierung einrichten
- [ ] Logging und Crash-Reporting einrichten
- [ ] CI für Analyse, Tests und Builds einrichten
- [ ] README mit Setup-Anleitung schreiben

## Phase 2: Design System

- [x] Farben, Typografie, Abstände und Radien als Tokens definieren
- [x] Light und Dark Theme bauen
- [ ] Basis-`WidgetCard` bauen
- [ ] Skeleton-Loader bauen
- [ ] Fehler- und Leer-Zustände bauen
- [ ] Wiederverwendbare Charts bauen (Ring, Balken, Linie, Sparkline)
- [ ] Listen, Chips, Buttons und Eingabefelder bauen
- [ ] Quellen-Anzeige für KI-Daten bauen
- [ ] Widget-Galerie für die Entwicklung bauen

## Phase 3: Flexibles Dashboard

- [ ] Grid-Layout für Smartphone, Tablet und Desktop bauen
- [ ] Widgets per Drag & Drop verschieben
- [ ] Widget-Größe ändern
- [ ] Widget hinzufügen, duplizieren und entfernen
- [ ] Bearbeitungsmodus bauen
- [ ] Undo/Redo im Bearbeitungsmodus
- [ ] Mehrere Dashboards (z. B. Morgens, Fitness, Wochenende)
- [ ] Layout als JSON lokal speichern
- [ ] Layout geräteübergreifend synchronisieren
- [ ] Layout-Vorlagen anbieten
- [ ] Layouts teilen und importieren
- [ ] Widget-Katalog mit Suche und Kategorien
- [ ] Vorschau im Katalog mit Beispieldaten
- [ ] Dashboard per Prompt erstellen ("Bau mir ein Fitness-Dashboard")
- [ ] Automatische Dashboard-Wechsel nach Uhrzeit oder Ort

## Phase 4: Widget-Framework

- [x] Interface `AppWidgetDefinition` definieren
- [x] `WidgetRegistry` bauen
- [x] `WidgetInstance` mit ID, Typ, Größe und Konfiguration modellieren
- [ ] Generischen `WidgetDataProvider` bauen
- [ ] Schema-Validierung im Client ergänzen
- [ ] Schema-Versionen und Migrationen unterstützen
- [ ] Konfigurationsformular aus Schema generieren
- [ ] Fehlergrenze pro Widget bauen, damit ein Fehler nicht das Dashboard zerstört
- [ ] Lokalen Cache pro Widget-Instanz bauen
- [ ] Pull-to-Refresh und manuellen Refresh bauen
- [ ] Hintergrund-Refresh bauen
- [ ] Widget-Aktionen standardisieren (öffnen, teilen, speichern, eintragen)
- [ ] Homescreen-Widgets für iOS und Android evaluieren

## Phase 5: Backend und KI-Orchestrator

### API und Daten
- [ ] Authentifizierung bauen (E-Mail, Apple, Google)
- [ ] Datenmodell für Nutzer, Dashboards, Widgets, Runs und Tracker-Einträge entwerfen
- [ ] Endpoint `GET /widgets/{id}/data` bauen
- [ ] Endpoint `POST /widgets/{id}/refresh` bauen
- [ ] Endpoint für Widget-Aktionen bauen
- [ ] Streaming-Status an die App senden (SSE oder WebSocket)
- [ ] Job-Queue für KI-Läufe bauen
- [ ] Scheduler für regelmäßige Updates bauen
- [ ] Push-Benachrichtigungen bauen
- [ ] Rate-Limits pro Nutzer und Widget bauen

### KI-Pipeline
- [ ] Provider-Abstraktion für KI-Modelle bauen
- [ ] Prompt-Registry mit Versionierung bauen
- [ ] Tool-Calling-Schicht bauen
- [ ] Structured Output pro Widget-Schema erzwingen
- [ ] Serverseitige Validierung bauen
- [ ] Automatischen Reparaturversuch bei ungültigem JSON bauen
- [ ] Fallback auf letzte gültige Daten bauen
- [ ] Quellenpflicht für Fakten prüfen
- [ ] Modell-Routing bauen (günstig für Einfaches, stark für Komplexes)
- [ ] Cache nach Widget, Ort und Zeitfenster bauen
- [ ] Gleiche Anfragen mehrerer Nutzer zusammenfassen
- [ ] Token- und Kosten-Tracking pro Nutzer bauen
- [ ] Budget-Limits und Kill-Switch bauen
- [ ] Traces aller KI-Läufe speichern (ohne sensible Inhalte)
- [ ] Eval-Suite pro Widget mit Golden-Beispielen bauen

### Tools für die KI
- [ ] Websuche und Webseiten-Abruf
- [ ] Wetter-API
- [ ] Geocoding und Orte
- [ ] Karten und Routen
- [ ] Event-Quellen
- [ ] Lebensmittel-Datenbank
- [ ] HealthKit- und Health-Connect-Daten (nur mit Freigabe)
- [ ] Kalender (nur mit Freigabe)
- [ ] Interner Zugriff auf eigene Tracker-Daten
- [ ] Nachrichten, Finanzdaten und ÖPNV

### Sicherheit und Datenschutz
- [ ] Schutz vor Prompt Injection aus Webseiten einbauen
- [ ] Externe Inhalte strikt als Daten behandeln
- [ ] Tool-Rechte pro Widget beschränken (Least Privilege)
- [ ] Schreibende KI-Aktionen nur nach Bestätigung ausführen
- [ ] URLs aus KI-Antworten prüfen
- [ ] Gesundheitsdaten verschlüsselt speichern
- [ ] Einwilligungen pro Datenquelle verwalten
- [ ] Standort nur so genau wie nötig an die KI senden
- [ ] Datenexport und Konto-Löschung bauen
- [ ] Datenschutzerklärung und AV-Verträge vorbereiten

---

## Phase 6: Kern-Widgets

### Wetter
- [x] Schema: Ort, aktuell, stündlich, 7 Tage, Warnungen
- [ ] Wetterdaten über Wetter-API abrufen
- [ ] KI-Zusammenfassung ("Nimm heute Abend eine Jacke mit")
- [x] Größen S (Temperatur), M (Stunden), L (7 Tage)
- [ ] Mehrere Orte und aktueller Standort
- [ ] Unwetterwarnungen als Push

### Parties in der Umgebung
- [ ] Schema: Name, Location, Koordinaten, Start, Ende, Genre, Preis, Link, Quelle, Konfidenz
- [ ] Karte mit Standort und Party-Pins bauen
- [ ] Interner KI-Prompt aus Kartenausschnitt, Datum und Vorlieben
- [ ] Event-Quellen recherchieren und rechtlich prüfen
- [ ] Adressen per Geocoding verifizieren
- [ ] Duplikate aus mehreren Quellen zusammenführen
- [ ] Vergangene und abgesagte Events herausfiltern
- [ ] Pin-Clustering bei vielen Events
- [ ] Filter nach Datum, Genre, Preis, Entfernung
- [ ] Detailansicht mit Quelle, Ticketlink und Route
- [ ] Event merken und in den Kalender übernehmen
- [ ] Falsche Events melden
- [ ] Neu laden beim Verschieben der Karte (mit Debounce und Cache)

### Tracker-Basis
- [ ] Gemeinsames Modell für Ziel, Einheit, Eintrag und Zeitraum
- [ ] Schnelleintrag, Bearbeiten und Löschen
- [ ] Tages-, Wochen- und Monatsansicht
- [ ] Ziele und Streaks
- [ ] Erinnerungen
- [ ] Offline-Einträge mit Synchronisierung
- [ ] Sync mit Apple Health und Health Connect
- [ ] KI-Eingabe in natürlicher Sprache ("2 Eier und ein Toast")
- [ ] Bestätigungsdialog vor dem Speichern von KI-Schätzungen
- [ ] Wöchentliche KI-Auswertung
- [ ] CSV-Export

### Einzelne Tracker (jeweils eigenes Widget)
- [ ] Proteine
- [ ] Kohlenhydrate
- [ ] Fett
- [ ] Kalorien
- [ ] Ballaststoffe
- [ ] Zucker
- [ ] Wasser
- [ ] Koffein
- [ ] Schritte
- [ ] Aktive Minuten
- [ ] Distanz
- [ ] Schlaf
- [ ] Gewicht
- [ ] Körperfett
- [ ] Puls und Ruhepuls
- [ ] Stimmung
- [ ] Stress
- [ ] Bildschirmzeit
- [ ] Medikamente und Supplements
- [ ] Eigener Tracker (Name, Einheit und Ziel frei wählbar)

---

## Phase 7: 20 weitere Widgets

### 1. Tagesbriefing
- [ ] Wetter, Termine, Aufgaben und News zu einer Zusammenfassung verbinden
- [ ] Uhrzeit und Inhalte konfigurierbar machen
- [ ] Optional vorlesen

### 2. Kalender
- [ ] Apple- und Google-Kalender anbinden
- [ ] Nächste Termine anzeigen
- [ ] Termin per Sprache oder Text anlegen, mit Bestätigung
- [ ] Freie Zeitfenster vorschlagen

### 3. Aufgaben
- [ ] Listen, Fälligkeit und Prioritäten
- [ ] Aufgaben aus natürlicher Sprache erzeugen
- [ ] KI zerlegt große Aufgaben in Schritte
- [ ] Tagesfokus vorschlagen

### 4. Schnellnotizen
- [ ] Text-, Sprach- und Fotonotizen
- [ ] Automatische Tags und Zusammenfassung
- [ ] Semantische Suche über alle Notizen

### 5. Persönliche News
- [ ] Themen und Quellen wählen
- [ ] Artikel zusammenfassen und mit Originalquelle verlinken
- [ ] Doppelte Meldungen bündeln
- [ ] Feedback für bessere Auswahl

### 6. ÖPNV-Abfahrten
- [ ] Haltestellen in der Nähe finden
- [ ] Live-Abfahrten und Verspätungen anzeigen
- [ ] Favoriten speichern

### 7. Pendeln und Verkehr
- [ ] Strecke Zuhause/Arbeit konfigurieren
- [ ] Fahrzeit mit Verkehr anzeigen
- [ ] Beste Abfahrtszeit und Störungs-Push

### 8. Restaurants in der Nähe
- [ ] Karte und Liste mit Öffnungszeiten
- [ ] Filter nach Küche, Preis und Ernährung
- [ ] KI-Empfehlung passend zu Vorlieben und Tagesmakros

### 9. Rezept aus dem Kühlschrank
- [ ] Zutaten per Text oder Foto erfassen
- [ ] Rezepte mit Nährwerten vorschlagen
- [ ] Rezept in Ernährungs-Tracker übernehmen
- [ ] Allergien hart berücksichtigen und Warnhinweis anzeigen

### 10. Essensplaner und Einkaufsliste
- [ ] Wochenplan nach Zielen und Budget erstellen
- [ ] Einkaufsliste automatisch zusammenfassen
- [ ] Liste mit anderen teilen

### 11. Mahlzeit per Foto
- [ ] Foto aufnehmen und Lebensmittel erkennen
- [ ] Portion und Makros als Schätzung anzeigen
- [ ] Korrektur und Bestätigung vor dem Speichern
- [ ] Barcode-Scanner ergänzen

### 12. Trainingsplan
- [ ] Plan nach Ziel, Level und Equipment erstellen
- [ ] Sätze, Wiederholungen und Gewichte loggen
- [ ] Progression vorschlagen
- [ ] Sicherheitshinweise und Pausentage einbauen

### 13. Budget und Ausgaben
- [ ] Ausgaben manuell oder per Beleg-Foto erfassen
- [ ] Automatische Kategorien
- [ ] Monatsbudget und Warnungen
- [ ] Open-Banking-Anbindung evaluieren

### 14. Abos und Verträge
- [ ] Abos mit Preis und Kündigungsfrist erfassen
- [ ] Erinnerung vor Fristende
- [ ] Monatliche Gesamtkosten und Sparvorschläge

### 15. Aktien- und Krypto-Watchlist
- [ ] Kurse und Sparklines anzeigen
- [ ] Preisalarme
- [ ] KI-Zusammenfassung relevanter News, ohne Anlageberatung

### 16. Spritpreise und Ladesäulen
- [ ] Günstigste Tankstellen in der Nähe anzeigen
- [ ] Ladesäulen mit Verfügbarkeit anzeigen
- [ ] Preisalarm

### 17. Film- und Serienempfehlungen
- [ ] Streaming-Dienste auswählen
- [ ] Empfehlungen nach Geschmack und Stimmung
- [ ] Watchlist und Kinoprogramm in der Nähe

### 18. Paketverfolgung
- [ ] Sendungsnummern manuell oder per Scan erfassen
- [ ] Status mehrerer Versanddienstleister bündeln
- [ ] Push bei Zustellung

### 19. Geburtstage und Geschenkideen
- [ ] Geburtstage importieren oder eintragen
- [ ] Erinnerungen mit Vorlauf
- [ ] KI-Geschenkideen nach Interessen und Budget

### 20. Reiseplaner
- [ ] Reiseroute per Prompt erstellen
- [ ] Tagesplan auf Karte anzeigen
- [ ] Packliste passend zum Wetter
- [ ] Buchungen und Dokumente sammeln

---

## Phase 8: KI-Assistent in der App

- [ ] Globale Eingabe per Text und Sprache
- [ ] Prompt in passende Widget-Aktion übersetzen
- [ ] Widgets per Sprache hinzufügen und anordnen
- [ ] Widget-übergreifende Fragen beantworten ("Wie wirkt sich mein Schlaf auf mein Training aus?")
- [ ] Langzeit-Präferenzen speichern, einsehen und löschen
- [ ] Proaktive Vorschläge mit Frequenz-Limit
- [ ] Neue Widgets aus sicherem, deklarativem UI-JSON generieren (Server-Driven UI)
- [ ] Generierte Widgets nur aus freigegebenen Bausteinen zusammensetzen

## Phase 9: Qualität und Performance

- [ ] Unit-Tests für Modelle und Logik
- [ ] Widget- und Golden-Tests
- [ ] Integrationstests für Dashboard-Bearbeitung
- [ ] Backend- und Schema-Vertragstests
- [ ] KI-Evals in CI ausführen
- [ ] Performance mit 30+ Widgets auf einem Dashboard testen
- [ ] Unnötige Rebuilds und API-Aufrufe vermeiden
- [ ] Akku- und Datenverbrauch messen
- [ ] Offline- und Schlechtnetz-Szenarien testen
- [ ] Accessibility-Audit durchführen
- [ ] Security-Review und Pentest durchführen

## Phase 10: Launch

- [ ] Onboarding mit Interessen und Starter-Dashboard
- [ ] Berechtigungen erst bei Bedarf und mit Erklärung abfragen
- [ ] Paywall und Abo-Verwaltung bauen
- [ ] Datenschutzerklärung, Impressum und AGB erstellen
- [ ] Medizinischen und finanziellen Haftungshinweis ergänzen
- [ ] App-Store-Datenschutzangaben ausfüllen
- [ ] Store-Screenshots und Texte erstellen
- [ ] TestFlight- und Play-Beta durchführen
- [ ] Datenschutzfreundliche Produktanalyse einrichten
- [ ] Feedback-Funktion einbauen
- [ ] Monitoring und Kosten-Alarme für Produktion einrichten
- [ ] Release-Prozess dokumentieren

---

## Vorschlag für das MVP

1. Dashboard mit Drag & Drop, Größenänderung und Speichern
2. Widget-Framework und KI-Pipeline mit Schema-Validierung
3. Wetter als erstes End-to-End-Widget
4. Proteine, Kohlenhydrate und Schritte als erste Tracker
5. Parties-Karte als Vorzeige-Feature
6. Tagesbriefing als widget-übergreifende KI-Funktion
