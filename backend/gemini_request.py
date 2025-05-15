import google.generativeai as genai
from flask import Flask, jsonify
import random
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')

app = Flask(__name__)

def generate_recommendation():
    heart_rate = '70'
    steps = '7560'
    hours_of_sleep = '9'

    genai.configure(api_key=GEMINI_API_KEY)
    model = genai.GenerativeModel('gemini-pro')
    recommendation = ''

    if int(heart_rate) < 50:
        recommendation = 'Heart Rate is dangerously low.\nSeek help if necessary.'
    elif int(heart_rate) > 160:
        recommendation = 'Heart Rate is dangerously high.\nSeek help if necessary.'
    else:
        response = model.generate_content("Can you give me a short phrase in text that is\
                                        an accessible recommendation of a task for an elderly person?\
                                        Make it super simple like 'have you drank water today?'\
                                        Make it health-conscious or mental-health related.\
                                        Heart rate is " + heart_rate + " steps are " + steps\
                                        + " and total sleep is " + hours_of_sleep + " hours.\
                                            You do not need to consider the health data in your response if it seems \
                                            normal")
        recommendation = response.text
        recommendation = recommendation.replace('"', '') # removes quotes 
    
    return recommendation, heart_rate, steps, hours_of_sleep

@app.route('/api/data', methods=['GET'])
def get_data():
    recommendation, heart_rate, steps, hours_of_sleep = generate_recommendation()    
    # if len(recommendation) > 36 and recommendation!= 'Heart Rate is dangerously low.\nSeek help if necessary.' and \
    #     recommendation != 'Heart Rate is dangerously high.\nSeek help if necessary.':
    #     recommendation = "Have you drank water today?"
    data = {
        'recommendation': recommendation,
        'heart_rate': heart_rate,
        'steps': steps,
        'hours_of_sleep': hours_of_sleep
    }

    return jsonify(data)

if __name__ == '__main__':
    app.run(debug=True)
