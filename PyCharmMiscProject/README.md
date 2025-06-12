# Diet Plan API Server

A simple Flask server that serves diet plan data with allergy alerts.

## Setup

1. Install dependencies:
```
pip install -r requirements.txt
```

2. Run the server:
```
python diet_plan_server.py
```

The server will start on http://localhost:5000

## API Endpoints

- `GET /diet-plan` - Get the full diet plan
- `GET /diet-plan/daily/{day}` - Get a specific day's diet plan (e.g., /diet-plan/daily/1)
- `GET /diet-plan/meal/{day}/{meal_name}` - Get a specific meal (e.g., /diet-plan/meal/1/breakfast)
- `GET /diet-plan/allergies` - Get allergy information

## Example Usage

```
curl http://localhost:5000/diet-plan
curl http://localhost:5000/diet-plan/daily/1
curl http://localhost:5000/diet-plan/meal/1/breakfast
curl http://localhost:5000/diet-plan/allergies
```