from fastapi import APIRouter, UploadFile, File, HTTPException
from services.ai_service import ai_service as gemini_service
import shutil
import os
import uuid

router = APIRouter()

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/decode")
async def decode_notice(file: UploadFile = File(...), language: str = "en"):
    try:
        # Save temp file
        file_ext = file.filename.split(".")[-1]
        filename = f"{uuid.uuid4()}.{file_ext}"
        file_path = os.path.join(UPLOAD_DIR, filename)
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # Call AI Service
        result = await gemini_service.decode_notice(file_path, language=language)
        
        # Cleanup (optional, or keep for Cloud Storage upload)
        # os.remove(file_path)
        
        return {
            "status": "success",
            "data": result
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
