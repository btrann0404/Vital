# Backend Setup

## Environment Variables

This project requires certain environment variables to be set. Create a `.env` file in the root directory with the following variables:

```
GEMINI_API_KEY=your_gemini_api_key_here
```

⚠️ **Important:** Never commit your `.env` file to the repository. The `.gitignore` file is configured to exclude it.

## Installation

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Run the server:
```bash
python main.py 