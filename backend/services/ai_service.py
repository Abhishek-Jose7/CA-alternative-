
import os
import json
import base64
from groq import Groq

from pathlib import Path
from dotenv import load_dotenv

env_path = Path(__file__).parent.parent / '.env'
load_dotenv(dotenv_path=env_path)

# API Key provided by user
GROQ_API_KEY = os.getenv("GROQ_API_KEY")

class AIService:
    def __init__(self):
        self.client = Groq(api_key=GROQ_API_KEY)
        # Models
        self.vision_model = "llama-3.2-11b-vision-preview" 
        self.chat_model = "llama-3.1-8b-instant" 
        
        # Simple In-Memory History (For Hackathon)
        # Format: {user_id: [{"role": "user", "content": "msg"}, ...]}
        self.history = {}

    def _encode_image(self, image_path):
        with open(image_path, "rb") as image_file:
            return base64.b64encode(image_file.read()).decode('utf-8')

    def _clean_json(self, text):
        """Helper to clean Markdown JSON blocks from response."""
        text = text.replace("```json", "").replace("```", "").strip()
        return json.loads(text)

    async def decode_notice(self, image_path: str) -> dict:
        base64_image = self._encode_image(image_path)
        
        prompt = """
        Analyze this Indian GST Notice image carefully. 
        Extract the following fields and return ONLY a valid JSON object. 
        Do not add any explanation.

        Fields:
        - notice_type (e.g., "ASMT-10", "DRC-01", "Show Cause Notice", "Defective Return")
        - date_of_issue (DD/MM/YYYY)
        - amount_demanded (Extract total amount if mentioned, else 0. numeric only)
        - reason (Summarize the reason for the notice in simple Hinglish)
        - risk_score (Calculated 1-100 based on severity. 80+ for immediate action, 40-70 for warning)
        - action_required (What should the user do next? In Hinglish)
        - summary (A brief, friendly explanation of the notice in Hinglish)

        JSON Format:
        {
          "notice_type": "string",
          "date_of_issue": "string",
          "amount_demanded": 0,
          "reason": "string",
          "risk_score": 0,
          "action_required": "string",
          "summary": "string"
        }
        """

        chat_completion = self.client.chat.completions.create(
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}",
                            },
                        },
                    ],
                }
            ],
            model=self.vision_model,
            temperature=0.1,
        )

        response_text = chat_completion.choices[0].message.content
        return self._clean_json(response_text)

    async def parse_invoice(self, image_path: str) -> dict:
        base64_image = self._encode_image(image_path)
        
        prompt = """
        Extract data from this invoice as a JSON object.
        Focus on extracting the line items properly.
        
        Fields:
        - invoice_number
        - date
        - total_amount (numeric)
        - vendor_name
        - line_items (Array of objects with: description, hsn_code, quantity, rate, amount)
        - gst_summary (Object with: total_taxable_value, cgst, sgst, igst)
        
        JSON ONLY. No markdown.
        """

        chat_completion = self.client.chat.completions.create(
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}",
                            },
                        },
                    ],
                }
            ],
            model=self.vision_model,
            temperature=0.1,
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

# Export singleton
ai_service = AIService()
