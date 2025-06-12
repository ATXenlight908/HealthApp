import requests
import json

class CedricClient:
    """Client for interacting with the Cedric API and the diet plan server"""
    
    def __init__(self, cedric_api_url, cedric_api_key, diet_server_url="http://localhost:5000"):
        self.cedric_api_url = cedric_api_url
        self.cedric_api_key = cedric_api_key
        self.diet_server_url = diet_server_url
        self.headers = {
            'Content-Type': 'application/json'
        }
        
        if cedric_api_key:
            self.headers['Authorization'] = f'Bearer {cedric_api_key}'
    
    def process_text(self, text, **kwargs):
        """Process text through the Cedric API"""
        payload = {
            'text': text,
            **kwargs
        }
        
        try:
            response = requests.post(
                self.cedric_api_url,
                headers=self.headers,
                data=json.dumps(payload),
                timeout=30
            )
            response.raise_for_status()
            
            result = response.json()
            return result.get('text', '')
            
        except requests.exceptions.RequestException as e:
            raise Exception(f"Error making API call to Cedric: {str(e)}")
    
    def get_diet_plan(self):
        """Get the full diet plan from the server"""
        response = requests.get(f"{self.diet_server_url}/diet-plan")
        response.raise_for_status()
        return response.json()
    
    def get_daily_plan(self, day):
        """Get a specific day's diet plan"""
        response = requests.get(f"{self.diet_server_url}/diet-plan/daily/{day}")
        response.raise_for_status()
        return response.json()
    
    def get_meal(self, day, meal_name):
        """Get a specific meal from a day's diet plan"""
        response = requests.get(f"{self.diet_server_url}/diet-plan/meal/{day}/{meal_name}")
        response.raise_for_status()
        return response.json()
    
    def get_allergy_info(self):
        """Get allergy information from the diet plan"""
        response = requests.get(f"{self.diet_server_url}/diet-plan/allergies")
        response.raise_for_status()
        return response.json()

# Example usage
if __name__ == "__main__":
    client = CedricClient(
        cedric_api_url="https://api.cedric.example.com/process",
        cedric_api_key="your_api_key_here"
    )
    
    # Get the full diet plan
    diet_plan = client.get_diet_plan()
    print(f"Diet plan for {diet_plan['dietPlan']['patientName']}")
    
    # Get a specific day's plan
    day1 = client.get_daily_plan(1)
    print(f"Day 1 meals: {', '.join(day1['meals'].keys())}")
    
    # Get allergy information
    allergies = client.get_allergy_info()
    print(f"Severe allergens: {', '.join(allergies['allergyAlerts'].get('severeAllergens', []))}")