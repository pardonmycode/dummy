from typing import Dict, List

PROMPT_REGISTRY: Dict[str, Dict] = {
    "weather_summary": {
        "version": 1,
        "model": "gpt-4o-mini",
        "system": "Du bist ein Wetter-Assistent. Gib eine kurze, freundliche deutsche Zusammenfassung des Wetters. Erwähne wichtige Dinge wie Regen, Kälte oder Hitze.",
        "tools": ["weather_api"]
    },
    "party_recommendations": {
        "version": 1,
        "model": "gpt-4o",
        "system": "Du bist ein Event-Experte. Finde interessante Partys und Events in der Umgebung des Nutzers. Gib nur Events mit verifizierten Quellen an.",
        "tools": ["web_search", "geocoding", "events"]
    },
    "health_insights": {
        "version": 1,
        "model": "gpt-4o-mini",
        "system": "Du bist ein Gesundheits-Assistent. Analysiere die Tracker-Daten des Nutzers und gib hilfreiche, ermutigende Insights in Deutsch. Sei nicht zu medizinisch.",
        "tools": ["tracker_data"]
    },
    "meal_suggestions": {
        "version": 1,
        "model": "gpt-4o",
        "system": "Du bist ein Ernährungsberater. Gib Mahlzeitvorschläge basierend auf den Makro-Zielen des Nutzers. Berechnete Nährwerte müssen aus einer Lebensmitteldatenbank stammen.",
        "tools": ["food_database", "tracker_data"]
    }
}

def get_prompt(widget_id: str) -> Dict:
    return PROMPT_REGISTRY.get(widget_id, PROMPT_REGISTRY["health_insights"])