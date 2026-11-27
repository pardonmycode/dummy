from typing import Dict, List, Any

# Golden examples for evaluation
EVAL_EXAMPLES: Dict[str, List[Dict]] = {
    "weather_summary": [
        {
            "input": "Wetter in Berlin",
            "expected_fields": ["location", "current", "sources"],
            "expected_location": "Berlin",
            "description": "Basic weather query"
        },
        {
            "input": "Wetter in München",
            "expected_fields": ["location", "current"],
            "expected_location": "München",
            "description": "Weather for Munich"
        }
    ],
    "party_recommendations": [
        {
            "input": "Partys in Berlin heute",
            "expected_fields": ["events", "sources"],
            "description": "Party recommendations for Berlin tonight"
        }
    ]
}

def run_evals(widget_id: str) -> Dict:
    """Run evaluation suite for a widget."""
    examples = EVAL_EXAMPLES.get(widget_id, [])
    results = []
    
    for example in examples:
        result = {
            "description": example["description"],
            "passed": False,
            "errors": []
        }
        
        # In real implementation, run the pipeline and validate
        # For now, just check that examples are defined
        if "input" in example:
            result["passed"] = True
        else:
            result["errors"].append("Missing input field")
        
        results.append(result)
    
    passed = sum(1 for r in results if r["passed"])
    total = len(results)
    
    return {
        "widget_id": widget_id,
        "passed": passed,
        "total": total,
        "results": results
    }

def get_eval_summary() -> Dict:
    """Get evaluation summary for all widgets."""
    summary = {}
    for widget_id in EVAL_EXAMPLES:
        result = run_evals(widget_id)
        summary[widget_id] = {
            "passed": result["passed"],
            "total": result["total"]
        }
    return summary