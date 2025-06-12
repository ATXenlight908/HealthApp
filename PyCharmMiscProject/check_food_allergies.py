def check_food_for_allergies(food_item, allergies):
    """Check if a food item contains or may contain allergens"""
    food_lower = food_item.lower()
    
    for allergy in allergies:
        allergen = allergy['name'].lower()
        severity = allergy['severity']
        
        # Check for direct mentions of the allergen
        if allergen in food_lower:
            return severity.upper()
        
        # Check for common cross-contamination or related foods
        if allergen == "shellfish" and any(x in food_lower for x in ["seafood", "chowder", "paella", "bouillabaisse"]):
            return "SEVERE"
            
    return "NONE"

def add_allergy_alerts_to_diet_plan(diet_plan, allergies):
    """Add allergy alerts to each food item in the diet plan"""
    # Add allergyAlert field to each food item
    if 'dietPlan' in diet_plan and 'weeklyPlan' in diet_plan['dietPlan']:
        for day in diet_plan['dietPlan']['weeklyPlan']:
            if 'meals' in day:
                for meal_name, meal in day['meals'].items():
                    if 'items' in meal:
                        for item in meal['items']:
                            item['allergyAlert'] = check_food_for_allergies(item['food'], allergies)
                            
                            # Add warning note if severe allergy detected
                            if item['allergyAlert'] == "SEVERE":
                                item['allergyNotes'] = f"CONTAINS {allergies[0]['name'].upper()} - DO NOT CONSUME. Replace with alternative."
                                meal['allergyWarning'] = f"SEVERE ALLERGY ALERT: This meal contains {allergies[0]['name']}. Replace with alternative."
    
    # Add overall allergy information
    diet_plan['dietPlan']['allergyAlerts'] = {
        "severeAllergens": [allergy['name'] for allergy in allergies if allergy['severity'].lower() == "severe"],
        "moderateAllergens": [allergy['name'] for allergy in allergies if allergy['severity'].lower() == "moderate"],
        "emergencyInstructions": "If accidental exposure occurs, seek immediate medical attention"
    }
    
    return diet_plan