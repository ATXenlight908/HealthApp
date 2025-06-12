import json

def check_food_for_allergies(food_item, allergies):
    """Check if a food item contains or may contain allergens"""
    # This is a simplified example - in a real system, you would have a more comprehensive
    # database of foods and their potential allergens
    
    # Convert food name and allergens to lowercase for case-insensitive matching
    food_lower = food_item.lower()
    
    for allergy in allergies:
        allergen = allergy['name'].lower()
        severity = allergy['severity']
        
        # Check for direct mentions of the allergen
        if allergen in food_lower:
            return severity
        
        # Check for common cross-contamination or related foods
        if allergen == "shellfish" and any(x in food_lower for x in ["seafood", "chowder", "paella", "bouillabaisse"]):
            return severity
            
    return "NONE"

def analyze_meal_for_allergies(meal, allergies):
    """Analyze a meal for potential allergens"""
    alerts = []
    
    for item in meal['items']:
        alert_level = check_food_for_allergies(item['food'], allergies)
        if alert_level != "NONE":
            alerts.append({
                "food": item['food'],
                "allergyLevel": alert_level,
                "recommendation": f"Avoid this food due to {alert_level.lower()} allergy risk"
            })
    
    return alerts

def process_diet_plan_for_allergies(diet_plan, patient_data):
    """Process a diet plan to add allergy alerts"""
    allergies = patient_data['health']['patientHealthProfile']['allergies']
    
    # Add allergy alerts to each food item
    for day in diet_plan['dietPlan']['weeklyPlan']:
        for meal_name, meal in day['meals'].items():
            alerts = analyze_meal_for_allergies(meal, allergies)
            
            # Add allergyAlert field to each food item
            for item in meal['items']:
                item['allergyAlert'] = check_food_for_allergies(item['food'], allergies)
            
            # Add meal-level warning if needed
            if any(alert['allergyLevel'] == "Severe" for alert in alerts):
                meal['allergyWarning'] = "SEVERE ALLERGY ALERT: This meal contains foods that may trigger severe allergic reactions."
    
    # Add overall allergy information
    diet_plan['dietPlan']['allergyAlerts'] = {
        "severeAllergens": [allergy['name'] for allergy in allergies if allergy['severity'] == "Severe"],
        "moderateAllergens": [allergy['name'] for allergy in allergies if allergy['severity'] == "Moderate"],
        "emergencyInstructions": "If accidental exposure occurs, seek immediate medical attention"
    }
    
    return diet_plan

# Add this to the generate_json_diet_plan function in the notebook
def generate_json_diet_plan_with_allergy_alerts():
    """Generate a structured diet plan in JSON format with allergy alerts using Cedric API"""
    # Load patient data
    patient_data = load_patient_data()
    
    # Create prompt
    prompt = create_diet_plan_prompt(patient_data)
    
    # Process through Cedric
    print("Generating JSON diet plan...")
    response = pipeline.process_text(prompt)
    
    # Parse the response as JSON
    try:
        diet_plan = json.loads(response)
        
        # Add allergy alerts to the diet plan
        diet_plan = process_diet_plan_for_allergies(diet_plan, patient_data)
        
        # Save the response to a JSON file
        with open('cedric_diet_plan_with_alerts.json', 'w') as f:
            json.dump(diet_plan, f, indent=2)
        
        print("Diet plan with allergy alerts generated and saved to 'cedric_diet_plan_with_alerts.json'")
        return diet_plan
    except json.JSONDecodeError:
        print("Warning: Response is not valid JSON. Saving as text instead.")
        with open('cedric_diet_plan.txt', 'w') as f:
            f.write(response)
        print("Diet plan saved as text to 'cedric_diet_plan.txt'")
        return response