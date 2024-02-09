import os
import json
from dotenv import load_dotenv
from fastapi import FastAPI
import requests
import google.generativeai as genai

app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"], 
    allow_headers=["*"], 
)

load_dotenv()
api_key = os.getenv("GEMINI_APIKEY")
genai.configure(api_key=api_key)

model = genai.GenerativeModel("gemini-pro")

@app.get('/')
def root():
    return generate_phrase()

def generate_phrase():
    prompt = "Can you give me a new phrase up to 5 words less than 10 that is\
            a recommendation of a task for an elderly person?\
            Make it super simple like 'have you drank water today?'\
            Make it health-conscious or mental-health related."
    try:
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        return {"error": str(e)}



# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="0.0.0.0", port=8000)