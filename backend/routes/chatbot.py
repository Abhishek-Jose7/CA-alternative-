from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from services.ai_service import ai_service as gemini_service

router = APIRouter()

class SearchQuery(BaseModel):
    query: str

from typing import Optional

class ChatQuery(BaseModel):
    message: str
    language: str = "en"
    user_id: Optional[str] = None

@router.post("/hsn")
async def search_hsn(body: SearchQuery):
    try:
        result = await gemini_service.search_hsn(body.query)
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/chat")
async def chat_expert(body: ChatQuery):
    try:
        result = await gemini_service.chat_with_ca(body.message, body.language, body.user_id)
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
