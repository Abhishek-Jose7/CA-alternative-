from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import notice, invoice, chatbot
import os

app = FastAPI(title="VyaparGuard API", version="1.0")

# Enable CORS for Flutter Web (localhost)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Include Routes
app.include_router(notice.router, prefix="/notice", tags=["Notice"])
app.include_router(invoice.router, prefix="/invoice", tags=["Invoice"])
app.include_router(chatbot.router, prefix="/api", tags=["Chatbot"])

@app.get("/")
def read_root():
    return {"message": "VyaparGuard Backend is Running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8000)))
