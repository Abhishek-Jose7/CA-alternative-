from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
from services.ai_service import ai_service as gemini_service
import shutil
import os

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

@router.post("/chat/vision")
async def chat_with_vision(
    message: str = Form(...),
    file: UploadFile = File(...)
):
    try:
        # Save temp file locally
        temp_file = f"temp_{file.filename}"
        with open(temp_file, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        result = await gemini_service.chat_with_vision(message, temp_file)
        
        # Cleanup
        if os.path.exists(temp_file):
            os.remove(temp_file)
        
        return {"status": "success", "data": result}
    except Exception as e:
        if 'temp_file' in locals() and os.path.exists(temp_file):
             os.remove(temp_file)
        raise HTTPException(status_code=500, detail=str(e))

