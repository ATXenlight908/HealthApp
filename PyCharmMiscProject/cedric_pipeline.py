import requests
import json
from typing import Dict, Any, Optional


class CedricPipeline:
    """
    A pipeline for making API calls to Cedric, processing text input and returning text output.
    """
    
    def __init__(self, api_url: str, api_key: Optional[str] = None, timeout: int = 30):
        """
        Initialize the Cedric pipeline.
        
        Args:
            api_url: The URL for the Cedric API
            api_key: Optional API key for authentication
            timeout: Request timeout in seconds
        """
        self.api_url = api_url
        self.api_key = api_key
        self.timeout = timeout
        self.headers = {
            'Content-Type': 'application/json'
        }
        
        if api_key:
            self.headers['Authorization'] = f'Bearer {api_key}'
    
    def process_text(self, text: str, **kwargs) -> str:
        """
        Process text through the Cedric API.
        
        Args:
            text: The input text to process
            **kwargs: Additional parameters to send to the API
            
        Returns:
            The processed text from Cedric
        """
        payload = {
            'text': text,
            **kwargs
        }
        
        try:
            response = requests.post(
                self.api_url,
                headers=self.headers,
                data=json.dumps(payload),
                timeout=self.timeout
            )
            response.raise_for_status()
            
            result = response.json()
            return result.get('text', '')
            
        except requests.exceptions.RequestException as e:
            raise Exception(f"Error making API call to Cedric: {str(e)}")
    
    def batch_process(self, texts: list[str], **kwargs) -> list[str]:
        """
        Process multiple texts through the Cedric API.
        
        Args:
            texts: List of input texts to process
            **kwargs: Additional parameters to send to the API
            
        Returns:
            List of processed texts from Cedric
        """
        return [self.process_text(text, **kwargs) for text in texts]


# Example usage
if __name__ == "__main__":
    # Replace with actual Cedric API URL and key
    CEDRIC_API_URL = "https://api.cedric.example.com/process"
    CEDRIC_API_KEY = "your_api_key_here"
    
    # Create the pipeline
    pipeline = CedricPipeline(api_url=CEDRIC_API_URL, api_key=CEDRIC_API_KEY)
    
    # Process a single text
    input_text = "This is a sample text to process."
    output_text = pipeline.process_text(input_text)
    print(f"Input: {input_text}")
    print(f"Output: {output_text}")
    
    # Process multiple texts
    input_texts = [
        "First sample text.",
        "Second sample text.",
        "Third sample text."
    ]
    output_texts = pipeline.batch_process(input_texts)
    
    for i, (input_text, output_text) in enumerate(zip(input_texts, output_texts)):
        print(f"\nBatch {i+1}:")
        print(f"Input: {input_text}")
        print(f"Output: {output_text}")