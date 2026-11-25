import json
from abc import ABC, abstractmethod
from typing import Dict, List, Any, Optional
from dataclasses import dataclass

@dataclass
class AIResponse:
    content: str
    model: str
    tokens_used: int
    sources: List[str]

class AIProvider(ABC):
    @abstractmethod
    async def chat(self, messages: List[Dict[str, str]], model: Optional[str] = None) -> AIResponse:
        pass
    
    @abstractmethod
    async def structured_output(self, messages: List[Dict[str, str]], schema: Dict, model: Optional[str] = None) -> Dict:
        pass

class OpenAIProvider(AIProvider):
    def __init__(self, api_key: str):
        import openai
        self.client = openai.AsyncOpenAI(api_key=api_key)
    
    async def chat(self, messages: List[Dict[str, str]], model: Optional[str] = None) -> AIResponse:
        from app.config import settings
        response = await self.client.chat.completions.create(
            model=model or settings.OPENAI_MODEL,
            messages=messages,
            temperature=0.7,
        )
        content = response.choices[0].message.content or ""
        return AIResponse(
            content=content,
            model=response.model,
            tokens_used=getattr(response.usage, 'total_tokens', 0),
            sources=[]
        )
    
    async def structured_output(self, messages: List[Dict[str, str]], schema: Dict, model: Optional[str] = None) -> Dict:
        from app.config import settings
        response = await self.client.chat.completions.create(
            model=model or settings.OPENAI_MODEL,
            messages=messages,
            response_format={"type": "json_object"},
        )
        content = response.choices[0].message.content or "{}"
        try:
            return json.loads(content)
        except json.JSONDecodeError:
            return {"error": "invalid_json", "raw": content}

def get_provider() -> AIProvider:
    from app.config import settings
    if settings.OPENAI_API_KEY:
        return OpenAIProvider(settings.OPENAI_API_KEY)
    else:
        return MockProvider()

class MockProvider(AIProvider):
    async def chat(self, messages: List[Dict[str, str]], model: Optional[str] = None) -> AIResponse:
        return AIResponse(
            content="Mock AI response",
            model="mock",
            tokens_used=10,
            sources=[]
        )
    
    async def structured_output(self, messages: List[Dict[str, str]], schema: Dict, model: Optional[str] = None) -> Dict:
        return {"status": "ok", "mock": True}