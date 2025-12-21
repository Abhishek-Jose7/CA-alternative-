from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from services.ai_service import ai_service as gemini_service

router = APIRouter()

class SearchQuery(BaseModel):
    query: str

class ChatQuery(BaseModel):
    message: str

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
        result = await gemini_service.chat_with_ca(body.message)
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
