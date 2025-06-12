import json
from check_food_allergies import add_allergy_alerts_to_diet_plan

# Load sample diet plan
with open('sample_diet_plan.json', 'r') as f:
    diet_plan = json.load(f)

# Sample allergies from patient data
allergies = [
    {
        "type": "Food",
        "name": "Shellfish",
        "severity": "Severe",
        "reaction": "Anaphylaxis"
    },
    {
        "type": "Medication",
        "name": "Sulfa drugs",
        "severity": "Moderate",
        "reaction": "Skin rash and itching"
    }
]

# Add allergy alerts to the diet plan
diet_plan_with_alerts = add_allergy_alerts_to_diet_plan(diet_plan, allergies)

# Save the updated diet plan
with open('sample_diet_plan_with_alerts.json', 'w') as f:
    json.dump(diet_plan_with_alerts, f, indent=2)

print("Diet plan with allergy alerts has been created and saved to 'sample_diet_plan_with_alerts.json'")

# Example of how to use this in the notebook
"""
def generate_json_diet_plan():
    # Existing code...
    
    try:
        diet_plan = json.loads(response)
        
        # Add allergy alerts
        allergies = patient_data['health']['patientHealthProfile']['allergies']
        diet_plan = add_allergy_alerts_to_diet_plan(diet_plan, allergies)
        
        # Save the response to a JSON file
        with open('cedric_diet_plan.json', 'w') as f:
            json.dump(diet_plan, f, indent=2)
        
        print("Diet plan generated and saved to 'cedric_diet_plan.json'")
        return diet_plan
    except json.JSONDecodeError:
        # Existing error handling...
"""