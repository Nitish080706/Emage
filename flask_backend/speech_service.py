# speech_service.py
import speech_recognition as sr
from fuzzywuzzy import process
import pyttsx3
import threading
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("emergency_bot")

class SpeechService:
    def __init__(self, knowledge_base):
        self.knowledge_base = knowledge_base
        self.recognizer = sr.Recognizer()
        
    def process_query(self, query):
        """Process user query using fuzzy matching"""
        logger.info(f"Processing query: '{query}'")
        
        # Simple tokenization by splitting on spaces
        keywords = query.lower().split()
        
        # Use fuzzywuzzy to match query with knowledge base
        key_to_value = {key: value for keys, value in self.knowledge_base.items() for key in keys}
        
        best_match, score = process.extractOne(" ".join(keywords), key_to_value.keys())
        logger.info(f"Best match: '{best_match}' with score: {score}")

        if score > 20:  # Threshold for better matching
            response = key_to_value[best_match]
            logger.info(f"Match found with score {score}. Responding with info for '{best_match}'")
        else:
            response = "I'm sorry, I don't have information on that emergency. Please try again with keywords like 'heart attack', 'burns', or 'choking'."
            logger.info(f"No good match found (score: {score}). Using default response.")

        return {"response": response, "match": best_match, "score": score}