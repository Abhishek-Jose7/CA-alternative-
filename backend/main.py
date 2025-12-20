from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from routes import notice, invoice
import os

app = FastAPI(title="VyaparGuard API", version="1.0")

# Include Routes
app.include_router(notice.router, prefix="/notice", tags=["Notice"])
app.include_router(invoice.router, prefix="/invoice", tags=["Invoice"])

@app.get("/")
def read_root():
    return {"message": "VyaparGuard Backend is Running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8000)))
