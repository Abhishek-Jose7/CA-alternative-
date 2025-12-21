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
        # "gemini-1.5-pro" for complex reasoning (Notices)
        self.notice_model = genai.GenerativeModel('gemini-1.5-pro')
        # "gemini-1.5-flash" for speed/cost (Invoices) 
        self.invoice_model = genai.GenerativeModel('gemini-1.5-flash')

    async def decode_notice(self, image_path: str) -> dict:
        """
        Uses Gemini 1.5 Pro to understand a legal GST Notice with strict JSON output.
        """
        prompt = """
        You are a GST compliance expert for Indian MSMEs.
        Analyze this image of a government notice.
        
        Return a STRICT JSON object (no markdown, no extra text) with this schema:
        {
            "status": "success",
            "type": "notice",
            "confidence": <float between 0.0 and 1.0>,
            "data": {
                "noticeType": "<string: e.g. Address Verification, Show Cause>",
                "summary": "<string: Simple 1-sentence explanation in plain English>",
                "summaryHindi": "<string: Simple 1-sentence explanation in Hindi>",
                "deadline": "<string: DD MMM YYYY or null>",
                "penalty": "<string: e.g. 'No penalty' or 'Rs 5000'>",
                "actionRequired": "<string: clear next step>",
                "riskLevel": "<string: Safe, Needs Review, or Action Required>"
            }
        }
        
        Risk Logic:
        - "Safe": Information only, no negative consequence.
        - "Needs Review": Minor discrepancy or info needed.
        - "Action Required": Deadlines, penalties, or show-cause.
        """
        
        img = Image.open(image_path)
        response = self.notice_model.generate_content([prompt, img])
        return self._clean_json(response.text)

    async def parse_invoice(self, image_path: str) -> dict:
        """
        Uses Gemini 1.5 Flash to extract structured data from an Invoice.
        """
        prompt = """
        Extract data from this invoice image into strict JSON format:
        {
            "status": "success",
            "type": "invoice",
            "confidence": <float between 0.0 and 1.0>,
            "data": {
                "vendorName": "<string>",
                "gstin": "<string>",
                "invoiceNumber": "<string>",
                "date": "<string>",
                "totalAmount": "<string>",
                "tax": {
                    "cgst": "<string>",
                    "sgst": "<string>",
                    "igst": "<string>"
                }
            }
        }
        If fields are speculative or unclear, lower the confidence score.
        """
        
        img = Image.open(image_path)
        response = self.invoice_model.generate_content([prompt, img])
        return self._clean_json(response.text)

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
