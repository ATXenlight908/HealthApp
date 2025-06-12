# How to Update the Notebook with Allergy Alerts

To add allergy alerts to the diet plan functionality in your notebook, follow these steps:

## Step 1: Import the allergy checking functions

Add this import at the top of your notebook:

```python
from check_food_allergies import add_allergy_alerts_to_diet_plan
```

## Step 2: Update the `generate_json_diet_plan` function

Modify the function to add allergy alerts to the diet plan:

```python
def generate_json_diet_plan():
    """Generate a structured diet plan in JSON format using Cedric API"""
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
        allergies = patient_data['health']['patientHealthProfile']['allergies']
        diet_plan = add_allergy_alerts_to_diet_plan(diet_plan, allergies)
        
        # Save the response to a JSON file
        with open('cedric_diet_plan.json', 'w') as f:
            json.dump(diet_plan, f, indent=2)
        
        print("Diet plan generated and saved to 'cedric_diet_plan.json'")
        return diet_plan
    except json.JSONDecodeError:
        print("Warning: Response is not valid JSON. Saving as text instead.")
        with open('cedric_diet_plan.txt', 'w') as f:
            f.write(response)
        print("Diet plan saved as text to 'cedric_diet_plan.txt'")
        return response
```

## Step 3: Update the display code to show allergy alerts

Add this to the code that displays the diet plan summary:

```python
# Display allergy alerts if present
if isinstance(diet_plan, dict) and 'dietPlan' in diet_plan and 'allergyAlerts' in diet_plan['dietPlan']:
    print("\nAllergy Alerts:")
    print(f"- Severe allergens: {', '.join(diet_plan['dietPlan']['allergyAlerts'].get('severeAllergens', []))}")
    print(f"- Moderate allergens: {', '.join(diet_plan['dietPlan']['allergyAlerts'].get('moderateAllergens', []))}")
    
    # Check first day's meals for allergy warnings
    if diet_plan['dietPlan']['weeklyPlan']:
        day1 = diet_plan['dietPlan']['weeklyPlan'][0]
        for meal_name, meal_data in day1.get('meals', {}).items():
            if 'allergyWarning' in meal_data:
                print(f"\n⚠️ {meal_data['allergyWarning']}")
```

These changes will add allergy alerts to the diet plan and display them in the notebook output.