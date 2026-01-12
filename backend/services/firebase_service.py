
import firebase_admin
from firebase_admin import credentials, firestore
import os

class FirebaseService:
    def __init__(self):
        self.db = None
        try:
            # Check for service account key file path in ENV
            cred_path = os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH")
            if cred_path and os.path.exists(cred_path):
                cred = credentials.Certificate(cred_path)
                firebase_admin.initialize_app(cred)
                self.db = firestore.client()
                print("Firebase Admin Initialized")
            else:
                # Fallback or initialized from different method
                if not firebase_admin._apps:
                    firebase_admin.initialize_app()
                self.db = firestore.client()
        except Exception as e:
            print(f"Firebase Admin Init Failed: {e}. Storing data locally.")

    def save_document(self, user_id, doc_type, data):
        if not self.db or not user_id:
            return
        
        doc_ref = self.db.collection('users').document(user_id).collection(doc_type).document()
        doc_ref.set(data)

    def get_history(self, user_id):
        if not self.db or not user_id:
            return []
        
        docs = self.db.collection('users').document(user_id).collection('history').order_by('timestamp', direction=firestore.Query.DESCENDING).stream()
        return [doc.to_dict() for doc in docs]

firebase_service = FirebaseService()
