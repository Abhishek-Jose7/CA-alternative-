# test.py
from google import genai

API_KEY = "AIzaSyDiJ0fp7C9zBjbjryVYV-ShX-EWIv2ezO4"

def test_gemini():
    try:
        client = genai.Client(api_key=API_KEY)

        response = client.models.generate_content(
            model="gemini-2.0",
            contents="Respond exactly: Gemini API key working"
        )

        print("\nResponse:", response.text)
        print("\nYour Gemini API key is valid.")
    except Exception as e:
        print("\nError:", e)
        print("\nYour Gemini API key may be invalid or restricted.")

if __name__ == "__main__":
    test_gemini()
