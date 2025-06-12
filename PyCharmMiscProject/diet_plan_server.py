from flask import Flask, jsonify, request, send_from_directory
import json
import os

app = Flask(__name__)

# Load the diet plan data
def load_diet_plan():
    with open('sample_diet_plan_with_alerts.json', 'r') as f:
        return json.load(f)

@app.route('/', methods=['GET'])
def index():
    """Serve the static HTML page"""
    return send_from_directory('static', 'index.html')

@app.route('/diet-plan', methods=['GET'])
def get_diet_plan():
    """Return the full diet plan"""
    return jsonify(load_diet_plan())

@app.route('/diet-plan/daily/<int:day>', methods=['GET'])
def get_daily_plan(day):
    """Return a specific day's diet plan"""
    diet_plan = load_diet_plan()
    
    # Find the requested day in the weekly plan
    for daily_plan in diet_plan['dietPlan']['weeklyPlan']:
        if daily_plan['day'] == day:
            return jsonify(daily_plan)
    
    return jsonify({"error": f"Day {day} not found"}), 404

@app.route('/diet-plan/meal/<int:day>/<meal_name>', methods=['GET'])
def get_meal(day, meal_name):
    """Return a specific meal from a day's diet plan"""
    diet_plan = load_diet_plan()
    
    # Find the requested day and meal
    for daily_plan in diet_plan['dietPlan']['weeklyPlan']:
        if daily_plan['day'] == day and meal_name in daily_plan['meals']:
            return jsonify(daily_plan['meals'][meal_name])
    
    return jsonify({"error": f"Meal {meal_name} for day {day} not found"}), 404

@app.route('/diet-plan/allergies', methods=['GET'])
def get_allergy_info():
    """Return allergy information from the diet plan"""
    diet_plan = load_diet_plan()
    
    allergy_info = {
        "allergyWarning": diet_plan['dietPlan'].get('allergyWarning', ''),
        "allergyAlerts": diet_plan['dietPlan'].get('allergyAlerts', {})
    }
    
    return jsonify(allergy_info)

if __name__ == '__main__':
    app.run(debug=True, port=5000)