
import os
import json
import numpy as np
import google.generativeai as genai
from typing import List, Dict

class RAGService:
    def __init__(self):
        self.api_key = os.getenv("GEMINI_API_KEY")
        if self.api_key:
            genai.configure(api_key=self.api_key)
        
        # In-memory "Knowledge Base" of GST Circulars/Templates
        self.knowledge_base = [
            {
                "id": "GST-001",
                "title": "Section 16(2)(c) - ITC Mismatch",
                "content": "Circular regarding mismatch between GSTR-3B and GSTR-2A. If supplier has not paid tax, ITC can be blocked under Section 16(2)(c).",
                "guidance": "Verify if the supplier has filed GSTR-1 and paid tax. Ask for a payment confirmation receipt."
            },
            {
                "id": "GST-002",
                "title": "Rule 86B - 1% Cash Payment",
                "content": "Rule 86B restricts use of ITC to 99% of tax liability for businesses with turnover > 50L. 1% must be paid in cash.",
                "guidance": "Ensure that at least 1% of the output tax liability is paid through the electronic cash ledger."
            },
            {
                "id": "GST-003",
                "title": "HSN Code Misclassification",
                "content": "Notices often arise from using wrong HSN codes (e.g., 12% vs 18%). Common for furniture, textile, and electronics.",
                "guidance": "Check the exact HSN code from the official CBIC directory and ensure rate consistency."
            },
            {
                "id": "GST-004",
                "title": "Interest on Delayed Payment",
                "content": "Section 50 mandates 18% interest on net tax liability if delayed beyond due date.",
                "guidance": "Calculate interest from the day after the due date until the actual date of payment."
            }
        ]
        self.embeddings = []
        self._initialize_embeddings()

    def _initialize_embeddings(self):
        """Pre-computes embeddings for the knowledge base."""
        if not self.api_key:
            return
        
        try:
            texts = [item["content"] for item in self.knowledge_base]
            result = genai.embed_content(
                model="models/embedding-001",
                content=texts,
                task_type="retrieval_document"
            )
            self.embeddings = result['embedding']
        except Exception as e:
            print(f"Error initializing RAG embeddings: {e}")

    def _cosine_similarity(self, v1, v2):
        dot_product = np.dot(v1, v2)
        norm_v1 = np.linalg.norm(v1)
        norm_v2 = np.linalg.norm(v2)
        return dot_product / (norm_v1 * norm_v2)

    async def query_knowledge_base(self, query_text: str, top_k: int = 1) -> List[Dict]:
        """Finds the most relevant GST circular for a given notice/query."""
        if not self.api_key or not self.embeddings:
            return []

        try:
            # Embed the query
            query_embedding_res = genai.embed_content(
                model="models/embedding-001",
                content=query_text,
                task_type="retrieval_query"
            )
            query_embedding = query_embedding_res['embedding']

            # Calculate similarities
            similarities = [self._cosine_similarity(query_embedding, doc_emb) for doc_emb in self.embeddings]
            
            # Sort and get top_k
            top_indices = np.argsort(similarities)[::-1][:top_k]
            
            results = []
            for idx in top_indices:
                score = float(similarities[idx])
                if score > 0.6: # Confidence threshold
                    results.append({
                        "doc": self.knowledge_base[idx],
                        "score": score
                    })
            
            return results
        except Exception as e:
            print(f"RAG Query Error: {e}")
            return []

rag_service = RAGService()
