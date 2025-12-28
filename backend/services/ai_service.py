
import os
import json
import base64
import requests
from groq import Groq

from pathlib import Path
from dotenv import load_dotenv

env_path = Path(__file__).parent.parent / '.env'
load_dotenv(dotenv_path=env_path)

# API Key provided by user
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
OCR_API_KEY = "K88270237388957"

class AIService:
    def __init__(self):
        self.client = Groq(api_key=GROQ_API_KEY)
        # Models
        self.chat_model = "llama-3.1-8b-instant" 
        
        # Simple In-Memory History (For Hackathon)
        # Format: {user_id: [{"role": "user", "content": "msg"}, ...]}
        self.history = {}

    async def _perform_ocr(self, image_path: str) -> str:
        """Extracts text from image using OCR.space API."""
        print(f"DEBUG: Starting OCR for {image_path}")
        try:
            with open(image_path, 'rb') as f:
                # Use isTable=true for better table parsing
                payload = {
                    'apikey': OCR_API_KEY,
                    'language': 'eng',
                    'isTable': 'true',
                    'scale': 'true',
                    'detectOrientation': 'true',
                    'OCREngine': '2' # Engine 2 is often better for numbers/tables
                }
                response = requests.post(
                    'https://api.ocr.space/parse/image',
                    files={'filename': f},
                    data=payload,
                    timeout=30 # Add timeout
                )
            
            print(f"DEBUG: OCR Status Code: {response.status_code}")
            
            if response.status_code != 200:
                print(f"DEBUG: OCR Failed with status {response.status_code} - {response.text}")
                return ""

            result = response.json()
            if result.get("IsErroredOnProcessing") == True:
                print(f"DEBUG: OCR API Error: {result.get('ErrorMessage')}")
                return ""
            
            parsed_text = ""
            if result.get("ParsedResults"):
                for parsed_result in result["ParsedResults"]:
                     text = parsed_result.get("ParsedText", "")
                     parsed_text += text + "\n"
            
            print(f"DEBUG: Extracted Text Length: {len(parsed_text)}")
            if len(parsed_text) < 10:
                 print(f"DEBUG: Low extraction confidence. Raw: {parsed_text}")
            
            return parsed_text.strip()
        except Exception as e:
            print(f"OCR Exception: {e}")
            return ""
    def _clean_json(self, text):
        """Helper to clean Markdown JSON blocks from response."""
        text = text.replace("```json", "").replace("```", "").strip()
        return json.loads(text)

    async def decode_notice(self, image_path: str) -> dict:
        ocr_text = await self._perform_ocr(image_path)
        
        prompt = f"""
        Analyze this text extracted from an Indian GST Notice:
        
        ---
        {ocr_text}
        ---

        Extract the following fields and return ONLY a valid JSON object:
        Fields:
        - notice_type
        - deadline (The date by which reply is needed)
        - penalty (The total amount demanded)
        - reason (summary in Hinglish)
        - riskLevel (High, Medium, Low, or Safe)
        - action_required (Hinglish)
        - summary (Hinglish)

        JSON Format:
        {{
          "notice_type": "string",
          "deadline": "string (Date or 'None')",
          "penalty": "string (Amount or 'None')",
          "reason": "string",
          "riskLevel": "string (High, Medium, Low, or Safe)",
          "action_required": "string",
          "summary": "string"
        }}
        """

        chat_completion = self.client.chat.completions.create(
            messages=[{"role": "user", "content": prompt}],
            model=self.chat_model,
            temperature=0.1,
            response_format={"type": "json_object"}
        )

        response_text = chat_completion.choices[0].message.content
        return self._clean_json(response_text)

    async def parse_invoice(self, image_path: str) -> dict:
        ocr_text = await self._perform_ocr(image_path)
        
        prompt = f"""
        Extract ALL data from this invoice text into a detailed JSON structure. 
        
        ---
        {ocr_text}
        ---
        
        CRITICAL EXTRACTION RULES:
        1. **Invoice Number**: STRICTLY look for the value under "Invoice No.". It is likely a small integer (e.g., "1", "2"). It is NOT the Date (e.g., "01-09-2021"). 
        2. **Line Items Columns**: 
           - **Item Name**: Description.
           - **Qty**: The quantity count (e.g., "1", "10", "25"). distinct from Unit.
           - **Unit**: The unit (e.g., "BOR", "PCS", "KGS").
           - **Rate**: The price per unit (e.g., "2760.00", "70.0").
           - **Amount**: The total line amount (Qty * Rate).
           - **Tax**: The tax amount if visible.
           - **Discount**: Discount amount if visible.
        3. **Logic Check**: Qty * Rate should roughly equal Amount. If your extracted Qty * Rate >> Amount, you likely swapped Qty and Rate.
        4. **Summary**:
           - **Received Amount**: Look for "Received Amount" or "Paid". If not found, assume 0.
           - **Balance Amount**: Look for "Balance Due" or "Balance Amount".
        5. **Tax Analysis**: Extract the table showing Taxable Value, CGST, SGST by %.
        
        JSON Structure:
        {{
          "invoiceDetails": {{
            "invoiceNumber": "string",
            "invoiceDate": "string",
            "dueDate": "string",
            "totalAmount": numeric,
            "receivedAmount": numeric,
            "balanceAmount": numeric
          }},
          "vendor": {{
            "name": "string",
            "address": "string",
            "gstin": "string",
            "mobile": "string"
          }},
          "customer": {{
            "name": "string",
            "address": "string",
            "mobile": "string"
          }},
          "lineItems": [
            {{
              "sNo": "string",
              "description": "string",
              "hsn": "string",
              "qty": numeric,
              "unit": "string",
              "rate": numeric,
              "discount": numeric,
              "taxAmount": numeric,
              "amount": numeric
            }}
          ],
          "taxAnalysis": [
             {{
               "rate": "string",
               "taxableValue": numeric,
               "cgst": numeric,
               "sgst": numeric,
               "igst": numeric
             }}
          ],
          "summary": {{
             "totalTaxable": numeric,
             "totalTax": numeric,
             "roundOff": numeric,
             "grandTotal": numeric
          }}
        }}
        
        JSON ONLY.
        """

        chat_completion = self.client.chat.completions.create(
            messages=[{"role": "user", "content": prompt}],
            model=self.chat_model,
            temperature=0.1,
            response_format={"type": "json_object"}
        )

        response_text = chat_completion.choices[0].message.content
        return self._clean_json(response_text)

    async def search_hsn(self, query: str) -> dict:
        prompt = f"""
        You are a GST expert. The user is asking: "{query}".
        Identify if they are looking for an HSN code.
        Return a JSON object with:
        - hsn_code (The most likely HSN code)
        - gst_rate (The applicable GST rate like "5%", "12%", "18%")
        - reason (A short explanation in Hinglish)
        
        JSON ONLY.
        """
        
        chat_completion = self.client.chat.completions.create(
            messages=[
                {"role": "user", "content": prompt}
            ],
            model=self.chat_model,
            temperature=0.3,
            response_format={"type": "json_object"}
        )
        
        response_text = chat_completion.choices[0].message.content
        return json.loads(response_text)

    async def chat_with_ca(self, message: str, language: str = "en", user_id: str = None) -> dict:
        lang_instruction = "Speak in **Hinglish** (Natural mix of Hindi and English)."
        if language == 'hi':
            lang_instruction = "Speak in pure, formal but friendly **Hindi** (Devanagari script)."
        elif language == 'mr':
            lang_instruction = "Speak in **Marathi** (Devanagari script) effectively like a helpful local CA."
        elif language == 'gu':
            lang_instruction = "Speak in **Gujarati**."
        elif language == 'ta':
            lang_instruction = "Speak in **Tamil**."
            
        system_prompt = f"""
        You are a friendly, knowledgeable Indian Chartered Accountant (CA).
        Your client is a small Kirana store owner.
        
        Instructions:
        1. {lang_instruction}
        2. Be authoritative but calm. 
        3. Do not give illegal advice.
        4. Keep answers concise (under 3 sentences unless asked for detail).
        
        Example (if Hinglish):
        User: "Mera ITC block ho gaya."
        You: "Chinta mat kariye. Usually ye tab hota hai jab supplier ne return file nahi kiya. Aap 2A/2B check kijiye, main help karta hoon."
        """
        
        # Initialize history
        messages = [{"role": "system", "content": system_prompt}]
        
        if user_id:
            if user_id not in self.history:
                self.history[user_id] = []
            
            # Append history (Last 10 messages for context)
            messages.extend(self.history[user_id][-10:])
            # Append current message
            messages.append({"role": "user", "content": message})
        else:
            messages.append({"role": "user", "content": message})

        chat_completion = self.client.chat.completions.create(
            messages=messages,
            model=self.chat_model,
            temperature=0.7,
        )
        
        reply = chat_completion.choices[0].message.content
        
        # Save to history
        if user_id:
            self.history[user_id].append({"role": "user", "content": message})
            self.history[user_id].append({"role": "assistant", "content": reply})
            
        return {"reply": reply}

    async def chat_with_vision(self, message: str, image_path: str) -> dict:
        ocr_text = await self._perform_ocr(image_path)
        
        prompt = f"""
        User Question: {message}
        
        Context (Extracted text from image):
        ---
        {ocr_text}
        ---
        
        Answer the user's question based on the extracted text.
        """

        chat_completion = self.client.chat.completions.create(
            messages=[{"role": "user", "content": prompt}],
            model=self.chat_model,
            temperature=0.2,
        )

        response_text = chat_completion.choices[0].message.content
        return {"reply": response_text}

# Export singleton
ai_service = AIService()
