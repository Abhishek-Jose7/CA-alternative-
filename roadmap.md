# 🇮🇳 VyaparGuard: India-First Roadmap

To win the Indian market (Kirana/MSME), the app must move beyond "Scanning" to "Daily Utility". 
Here are 5 high-impact features tailored for the Indian ecosystem.

## 1. 🗣️ "Boliye Seth-ji" (Voice-First GST Assistant)
**Why:** Kirana owners prefer **Voice Notes** over typing.
**Feature:** 
- User taps mic button.
- Asks in Hinglish: *"Kya dukan ke AC par input tax credit milega?"*
- AI replies with audio: *"Ha, agar AC dukan mei laga hai toh claim kar sakte hain."*
**Tech:** Gemini Multimodal (Audio) or Google Speech-to-Text.

## 2. 📱 WhatsApp "Forward-to-File" Bot
**Why:** 90% of B2B invoices come via WhatsApp, not email.
**Feature:** 
- User forwards a PDF/Image to your dedicated WhatsApp Number.
- Backend (Twilio/Interakt) catches it -> calls your Invoice API.
- App sends push notification: *"Bill from Rakesh Traders saved! GST: ₹450"*.
**Tech:** WhatsApp Business API + Webhook.

## 3. 🔍 "Sahi HSN" (Smart HSN Finder)
**Why:** finding the right HSN code and Tax Rate is the #1 confusion.
**Feature:**
- User types/speaks: *"Plastic Chair"* 
- App shows: *HSN 9403, GST 18%*
- App shows: *"Wooden Chair"* 
- App shows: *HSN 9403, GST 12%* (Context aware).
**Tech:** Vertex AI Search (indexed huge HSN database).

## 4. 📒 Udhaar & Payment Reminders
**Why:** "Udhaar" (Credit) is the lifeblood of Indian trade.
**Feature:**
- When scanning an invoice, AI detects "Payment Due Date".
- App auto-schedules a WhatsApp reminder for the vendor/customer.
- *"Rakesh ji, payment due in 2 days."*
**Tech:** Firestore triggers + WhatsApp/SMS URL launcher.

## 5. 📊 "Kaccha vs Pakka" Bill Detector
**Why:** Many traders receive invalid (Kaccha) bills and unknowingly claim GST, leading to notices.
**Feature:**
- AI analyzes invoice for critical missing fields (GSTIN, Invoice Signup, Date).
- Flags it: *"⚠️ This bill is 'Kaccha'. Do not claim ITC on this."*
**Tech:** Existing Gemini Invoice API (Enhanced Prompts).

---

## 🚀 Recommended Next Step (Hackathon Winner)
**Implement #1 (Voice)** or **#3 (HSN Search)**. 
Judges love Accessibility.

**Shall we build the "HSN Code Finder" tab? It is low effort, high value.**
