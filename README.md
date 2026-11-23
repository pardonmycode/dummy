# Widgetly

KI-gesteuerte Widget-App mit flexiblem Dashboard. Nutzer stellen sich ihr UI frei aus Widgets zusammen, die von KI-Analysen und Echtzeitdaten angetrieben werden.

## Features

- **Flexibles Dashboard**: Widgets per Drag & Drop verschieben, Größen ändern
- **KI-gesteuerte Widgets**: Wetter, Health-Tracker, Events, Briefing und mehr
- **Schema-basierte Daten**: Jedes Widget hat ein versioniertes JSON-Schema
- **Dark/Light Mode**: Automatische Theme-Umschaltung
- **Lokalisierung**: Deutsch und Englisch

## Produkt-Entscheidungen

- **Name:** Widgetly
- **Zielplattformen:** iOS, Android, Web
- **Zielgruppe:** Gesundheitsbewusste Menschen (25-45), die persönliche Daten an einem Ort haben wollen
- **KI-Anbieter:** OpenAI (GPT-4o für komplexe Tasks, GPT-4o-mini für einfache), Claude als Alternative
- **Backend-Stack:** FastAPI (Python), PostgreSQL, Redis für Cache, Celery für Job-Queue
- **Karten:** OpenStreetMap + Leaflet (kostenlos, Open Source)
- **Geschäftsmodell:** Freemium - Basis kostenlos (10 Widgets), Premium für unbegrenzte Widgets und erweiterte KI
- **KI-Budget:** 500.000 Tokens/Monat für Free, unbegrenzt für Premium
- **MVP-Widgets:** Wetter, Parties in der Umgebung, Proteine, Kohlenhydrate, Schritte, Tagesbriefing
- **State Management:** Riverpod
- **Routing:** go_router
- **UI:** Material 3 mit Custom Design Tokens

## Architektur

```text
Flutter-App  ->  Backend/API  ->  KI-Orchestrator  ->  Tools (Wetter, Karten, Web, Health ...)
    ^                                   |
    +---- validiertes Widget-JSON <-----+
```

## Tech Stack

- **Frontend**: Flutter 3.27+ (iOS, Android, Web)
- **State Management**: Riverpod
- **Routing**: go_router
- **Backend**: Supabase (Auth, DB) + FastAPI (KI-Orchestrierung)
- **Karten**: Mapbox
- **KI**: OpenAI API (GPT-4 für komplexe Aufgaben, kleinere Modelle für Einfaches)

## Setup

```bash
# Clone repository
git clone https://github.com/zumazui123-creator/dummy.git
cd dummy

# Install dependencies
flutter pub get

# Configure environment variables
cp .env.example .env
# Edit .env with your API keys

# Run the app
flutter run
```

## Build

```bash
# Web
flutter build web --release

# iOS
flutter build ios --release

# Android
flutter build apk --release
```

## Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

## Project Structure

```
lib/
├── core/           # App-wide configuration, theme, routing
├── features/       # Feature modules (dashboard, widgets, ai, auth)
├── models/         # Data models
├── providers/      # Riverpod providers
├── services/       # API, storage, auth services
├── widgets/        # Reusable UI components
└── main.dart       # App entry point
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| SUPABASE_URL | Supabase project URL |
| SUPABASE_ANON_KEY | Supabase anon key |
| MAPBOX_TOKEN | Mapbox API token |
| OPENAI_API_KEY | OpenAI API key |
| API_BASE_URL | Backend API base URL |

## Roadmap

- [x] Project setup and architecture
- [x] Theme system (dark/light)
- [x] Widget framework and registry
- [ ] Dashboard with drag & drop
- [ ] Weather widget (end-to-end)
- [ ] Health tracker widgets
- [ ] Events/parties map widget
- [ ] AI orchestrator backend
- [ ] iOS/Android release builds

## License

MIT
