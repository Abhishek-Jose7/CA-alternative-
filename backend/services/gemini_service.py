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
        Uses Gemini 1.5 Pro to understand a legal GST Notice.
        """
        prompt = """
        You are a GST compliance expert for Indian MSMEs.
        Analyze this image of a government notice.
        
        Extract the following strictly in JSON format:
        1. "noticeType": What kind of notice is this? (e.g., "Address Verification", "Demand Notice", "Show Cause")
        2. "summary": A simple 1-sentence explanation in plain English.
        3. "summaryHindi": A simple 1-sentence explanation in Hindi.
        4. "deadline": Extract the response deadline date (YYYY-MM-DD format if possible, else text).
        5. "penalty": Does it mention a penalty? (Yes/No and amount if applicable).
        6. "actionRequired": What should the user do next?
        7. "riskLevel": Assess risk (Low/Medium/High).
        """
        
        # Load image (assuming local path for MVP, or bytes)
        img = Image.open(image_path)
        
        response = self.notice_model.generate_content([prompt, img])
        
        # In a real app, we would add robust JSON parsing here
        # For MVP, we assume the model follows instructions well or use response.text
        return self._clean_json(response.text)

    async def parse_invoice(self, image_path: str) -> dict:
        """
        Uses Gemini 1.5 Flash to extract structured data from an Invoice.
        """
        prompt = """
        Extract data from this invoice image into strict JSON format with these keys:
        - "vendorName": Name of the seller
        - "gstin": Seller's GSTIN
        - "invoiceNumber": Invoice No.
        - "date": Invoice Date
        - "totalAmount": Grand Total
        - "lineItems": List of objects with {"description", "hsn", "amount"}
        - "tax": Object with {"cgst", "sgst", "igst"} values
        
        If a field is missing, use null.
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
