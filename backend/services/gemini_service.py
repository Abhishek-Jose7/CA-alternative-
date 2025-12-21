import google.generativeai as genai
import os
import json
from PIL import Image
import typing_extensions as typing

# Configure API Key (in production, use environment variables)
genai.configure(api_key=os.environ.get("GEMINI_API_KEY"))

class GeminiService:
    def __init__(self):
        # Initialize models
        # "gemini-2.0-flash-exp" for bleeding edge performance
        self.notice_model = genai.GenerativeModel('gemini-2.0-flash-exp')
        # "gemini-2.0-flash-exp" for speed/cost (Invoices) 
        self.invoice_model = genai.GenerativeModel('gemini-2.0-flash-exp')

    async def decode_notice(self, image_path: str) -> dict:
        """
        Uses Gemini 1.5 Pro to understand a legal GST Notice with strict JSON output.
        """
        # ... (Existing notice logic remains same, abstracted for brevity in this update)
        prompt = """
        You are a GST compliance expert for Indian MSMEs.
        Analyze this image of a government notice.
        Return a STRICT JSON object:
        { "status": "success", "data": { "noticeType": "...", "summary": "...", "riskLevel": "..." } }
        """
        img = Image.open(image_path)
        response = self.notice_model.generate_content([prompt, img])
        return self._clean_json(response.text)

    async def parse_invoice(self, image_path: str) -> dict:
        """
        Uses Gemini 1.5 Flash to extract structured data AND Payment Terms.
        """
        prompt = """
        Extract data from this invoice image into strict JSON format:
        {
            "status": "success",
            "type": "invoice",
            "confidence": 0.95,
            "data": {
                "vendorName": "<string>",
                "gstin": "<string>",
                "invoiceNumber": "<string>",
                "date": "<string>",
                "totalAmount": "<string>",
                "paymentDueDate": "<string or null if not found>",
                "isKacchaBill": <boolean>,
                "tax": { "cgst": "...", "sgst": "...", "igst": "..." }
            }
        }
        Logic: 
        1. If 'Payment Due' or 'Credit Days' mentioned, calculate 'paymentDueDate'.
        2. If GSTIN is missing, set 'isKacchaBill' to true.
        """
        img = Image.open(image_path)
        response = self.invoice_model.generate_content([prompt, img])
        return self._clean_json(response.text)

    async def search_hsn(self, query: str) -> dict:
        """ Uses Gemini to find HSN codes and Tax rates contextually. """
        prompt = f"""
        You are an HSN Code Expert for India GST.
        User Query: "{query}"
        
        Identify the correct HSN code and GST Rate.
        Return strict JSON:
        {{
            "hsn_code": "1234",
            "description": "Short official description",
            "gst_rate": "18%",
            "reason": "Why this rate applies (e.g. Branded vs Unbranded)"
        }}
        """
        response = self.invoice_model.generate_content(prompt)
        return self._clean_json(response.text)

    async def chat_with_ca(self, message: str) -> dict:
        """ Conversational AI for GST queries """
        prompt = f"""
        You are "VyaparGuard AI", a friendly Hindi-English (Hinglish) speaking GST expert for shop owners.
        User: "{message}"
        
        Answer short, simple, and safe. If legally risky, say "Consult CA".
        """
        response = self.notice_model.generate_content(prompt)
        return {"reply": response.text}

    def _clean_json(self, text: str) -> dict:
        """Helper to extract JSON from markdown code blocks if present."""
        try:
            cleaned = text.strip()
            if cleaned.startswith("```json"):
                cleaned = cleaned[7:-3]
            elif cleaned.startswith("```"):
                cleaned = cleaned[3:-3]
            return json.loads(cleaned)
        except Exception as e:
            print(f"JSON Parse Error: {e}")
            return {"raw_text": text, "error": "Failed to parse JSON"}

gemini_service = GeminiService()
