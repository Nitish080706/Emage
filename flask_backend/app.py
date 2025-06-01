# app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
from knowledge_base import EMERGENCY_KNOWLEDGE
from speech_service import SpeechService

app = Flask(__name__)
CORS(app)

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("emergency_api")

# Initialize speech service with knowledge base
speech_service = SpeechService(EMERGENCY_KNOWLEDGE)

@app.route('/api/process_query', methods=['POST'])
def process_query():
    data = request.json
    
    if not data or 'query' not in data:
        return jsonify({"error": "No query provided"}), 400
    
    query = data['query']
    logger.info(f"Received query: {query}")
    
    # Process the query
    result = speech_service.process_query(query)
    
    return jsonify(result)

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)