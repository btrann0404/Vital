import pathlib
import textwrap
import google.generativeai as genai
from IPython.display import display
from IPython.display import Markdown
from flask import Flask, jsonify

GEMINI_API_KEY = 'AIzaSyAjQJtJPCY7jWHoALMYRl_If2T-tWA7iQk'

app = Flask(__name__)
@app.route('/api/data', methods=['GET'])

def get_data():
    
    genai.configure(api_key=GEMINI_API_KEY)
    
    model = genai.GenerativeModel('gemini-pro')
    response = model.generate_content("Can you give me a new phrase up to 5 words that is\
                                      a recommendation of a task for an elderly person?\
                                      Make it super simple like 'have you drank water today?'\
                                      Make it health-conscious or mental-health related.")
    data = {'recommendation': response.text}
    
    return jsonify(data)

if __name__ == '__main__':
    app.run(debug=True)
