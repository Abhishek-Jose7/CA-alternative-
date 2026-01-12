
from fastapi import APIRouter
from services.ai_service import ai_service

router = APIRouter()

@router.get("/queue")
async def get_ca_queue():
    """Returns the list of documents awaiting CA review."""
    return {
        "status": "success",
        "count": len(ai_service.ca_queue),
        "queue": ai_service.ca_queue
    }

@router.post("/review/{doc_id}")
async def approve_document(doc_id: str, action: str = "approve", comments: str = ""):
    """Simulates CA approving or flagging a document in the queue."""
    for item in ai_service.ca_queue:
        if item["id"] == doc_id:
            item["status"] = "reviewed"
            item["ca_comments"] = comments
            item["ca_action"] = action
            return {"status": "success", "message": f"Document {doc_id} {action}ed."}
    
    return {"status": "error", "message": "Document not found in queue."}
