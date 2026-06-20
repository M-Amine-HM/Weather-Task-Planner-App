import google.generativeai as genai
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
from dotenv import load_dotenv
import os
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional
from datetime import datetime
import httpx
from typing import Dict
from typing import Optional, Dict

app = FastAPI()

origins = [
    "http://localhost:8000",
    "http://127.0.0.1:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

load_dotenv()
print(f"API Key loaded: {os.getenv('GEMINI_API_KEY')[:10]}...")

MONGODB_URL = os.getenv(
    "MONGODB_URL", "mongodb://localhost:27017/fastApi_ToDoApp")
client = AsyncIOMotorClient(MONGODB_URL)
db = client.fastApi_ToDoApp
plans_collection = db.plans


class Plan(BaseModel):
    title: str
    description: str
    date: Optional[str] = None


class PlanResponse(BaseModel):
    id: str
    title: str
    description: str
    date: Optional[str] = None


def plan_helper(plan) -> dict:
    return {
        "id": str(plan["_id"]),
        "title": plan["title"],
        "description": plan["description"],
        "date": plan.get("date"),
    }


@app.get("/")
def root():
    return {"message": "Hello, World! Connected to Local MongoDB"}


@app.post("/plans/addplan/", response_model=PlanResponse)
async def create_plan(plan: Plan):
    new_plan = await plans_collection.insert_one({
        "title": plan.title,
        "description": plan.description,
        "date": plan.date,
    })
    created_plan = await plans_collection.find_one({"_id": new_plan.inserted_id})
    return plan_helper(created_plan)


@app.get("/plans/getallplans/", response_model=list[PlanResponse])
async def read_all_plans():
    plans = []
    async for plan in plans_collection.find():
        plans.append(plan_helper(plan))
    return plans


@app.get("/plans/search/{title}", response_model=list[PlanResponse])
async def search_plans_by_title(title: str):
    plans = []
    async for plan in plans_collection.find({"title": {"$regex": title, "$options": "i"}}):
        plans.append(plan_helper(plan))
    if not plans:
        raise HTTPException(
            status_code=404, detail=f"No plans found with title: {title}")
    return plans


@app.get("/plans/{plan_id}", response_model=PlanResponse)
async def read_plan(plan_id: str):
    if not ObjectId.is_valid(plan_id):
        raise HTTPException(status_code=400, detail="Invalid plan ID")
    plan = await plans_collection.find_one({"_id": ObjectId(plan_id)})
    if plan:
        return plan_helper(plan)
    raise HTTPException(status_code=404, detail="Plan not found")


@app.put("/plans/modifyplan/{plan_id}", response_model=PlanResponse)
async def update_plan(plan_id: str, plan: Plan):
    if not ObjectId.is_valid(plan_id):
        raise HTTPException(status_code=400, detail="Invalid plan ID")
    updated_plan = await plans_collection.find_one_and_update(
        {"_id": ObjectId(plan_id)},
        {"$set": {"title": plan.title, "description": plan.description, "date": plan.date}},
        return_document=True
    )
    if updated_plan:
        return plan_helper(updated_plan)
    raise HTTPException(status_code=404, detail="Plan not found")


@app.delete("/plans/deleteplan/{plan_id}")
async def delete_plan(plan_id: str):
    if not ObjectId.is_valid(plan_id):
        raise HTTPException(status_code=400, detail="Invalid plan ID")
    result = await plans_collection.delete_one({"_id": ObjectId(plan_id)})
    if result.deleted_count:
        return {"message": "Plan deleted successfully"}
    raise HTTPException(status_code=404, detail="Plan not found")


# ── HELPERS ───────────────────────────────────────────────────────────────────

async def get_coordinates(city: str) -> Optional[Dict]:
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                "https://geocoding-api.open-meteo.com/v1/search",
                params={"name": city, "count": 1,
                        "language": "en", "format": "json"}
            )
            if response.status_code == 200:
                data = response.json()
                if data.get("results"):
                    result = data["results"][0]
                    return {
                        "latitude": result["latitude"],
                        "longitude": result["longitude"],
                        "name": result["name"],
                        "country": result.get("country", "")
                    }
            return None
    except Exception as e:
        print(f"Geocoding error: {e}")
        return None


def parse_hourly(data: dict) -> list:
    """
    Extract today's hourly slots (every 3 hours: 00,03,06,09,12,15,18,21)
    from Open-Meteo hourly response and return a clean list.

    Open-Meteo hourly format:
      data["hourly"]["time"]            → ["2026-06-20T00:00", "2026-06-20T01:00", ...]
      data["hourly"]["temperature_2m"]  → [22.1, 21.8, ...]
      data["hourly"]["weather_code"]    → [0, 1, ...]
    """
    today = datetime.now().strftime("%Y-%m-%d")
    hourly = data.get("hourly", {})
    times = hourly.get("time", [])
    temps = hourly.get("temperature_2m", [])
    codes = hourly.get("weather_code", [])

    slots = []
    target_hours = {0, 3, 6, 9, 12, 15, 18, 21}

    for i, t in enumerate(times):
        # t looks like "2026-06-20T06:00"
        if not t.startswith(today):
            continue
        hour = int(t[11:13])  # extract HH from "YYYY-MM-DDTHH:MM"
        if hour not in target_hours:
            continue

        code = codes[i] if i < len(codes) else 0
        condition, _ = get_weather_description(code)

        slots.append({
            "time": f"{hour:02d}:00",
            "temperature": round(temps[i], 1) if i < len(temps) else 0,
            "condition": condition,
            "icon": get_weather_icon(code),
        })

    return slots


# ── WEATHER ENDPOINTS ─────────────────────────────────────────────────────────

@app.get("/weather/current/coords")
async def get_weather_by_coordinates(lat: float, lon: float):
    """Get current weather + today's hourly slots by coordinates"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                "https://api.open-meteo.com/v1/forecast",
                params={
                    "latitude": lat,
                    "longitude": lon,
                    "current": "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,apparent_temperature",
                    "hourly": "temperature_2m,weather_code",  # ← NEW
                    "forecast_days": 1,                        # ← only today needed for hourly
                    "timezone": "auto"
                }
            )

            if response.status_code == 200:
                data = response.json()
                current = data["current"]
                weather_code = current["weather_code"]
                condition, description = get_weather_description(weather_code)

                return {
                    "city": "Your Location",
                    "temperature": round(current["temperature_2m"], 1),
                    "feels_like": round(current["apparent_temperature"], 1),
                    "condition": condition,
                    "description": description,
                    "humidity": current["relative_humidity_2m"],
                    "wind_speed": round(current["wind_speed_10m"], 1),
                    "icon": get_weather_icon(weather_code),
                    "hourly": parse_hourly(data),              # ← NEW
                }
            else:
                raise HTTPException(
                    status_code=500, detail="Failed to fetch weather data")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@app.get("/weather/forecast/coords")
async def get_forecast_by_coordinates(lat: float, lon: float, days: int = 7):
    """Get weather forecast by coordinates"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                "https://api.open-meteo.com/v1/forecast",
                params={
                    "latitude": lat,
                    "longitude": lon,
                    "daily": "weather_code,temperature_2m_max,temperature_2m_min",
                    "forecast_days": min(days, 16),
                    "timezone": "auto"
                }
            )

            if response.status_code == 200:
                data = response.json()
                daily = data["daily"]
                forecast_list = []

                for i in range(len(daily["time"])):
                    weather_code = daily["weather_code"][i]
                    condition, description = get_weather_description(
                        weather_code)
                    forecast_list.append({
                        "date": daily["time"][i],
                        "temperature_max": round(daily["temperature_2m_max"][i], 1),
                        "temperature_min": round(daily["temperature_2m_min"][i], 1),
                        "condition": condition,
                        "description": description,
                        "icon": get_weather_icon(weather_code)
                    })

                return {"city": "Your Location", "forecast": forecast_list}
            else:
                raise HTTPException(
                    status_code=500, detail="Failed to fetch forecast data")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@app.get("/weather/current/{city}")
async def get_current_weather(city: str):
    """Get current weather + today's hourly slots for a city"""
    try:
        location = await get_coordinates(city)
        if not location:
            raise HTTPException(status_code=404, detail="City not found")

        async with httpx.AsyncClient() as client:
            response = await client.get(
                "https://api.open-meteo.com/v1/forecast",
                params={
                    "latitude": location["latitude"],
                    "longitude": location["longitude"],
                    "current": "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,apparent_temperature",
                    "hourly": "temperature_2m,weather_code",  # ← NEW
                    "forecast_days": 1,                        # ← only today needed for hourly
                    "timezone": "auto"
                }
            )

            if response.status_code == 200:
                data = response.json()
                current = data["current"]
                weather_code = current["weather_code"]
                condition, description = get_weather_description(weather_code)

                return {
                    "city": f"{location['name']}, {location['country']}",
                    "temperature": round(current["temperature_2m"], 1),
                    "feels_like": round(current["apparent_temperature"], 1),
                    "condition": condition,
                    "description": description,
                    "humidity": current["relative_humidity_2m"],
                    "wind_speed": round(current["wind_speed_10m"], 1),
                    "icon": get_weather_icon(weather_code),
                    "hourly": parse_hourly(data),              # ← NEW
                }
            else:
                raise HTTPException(
                    status_code=500, detail="Failed to fetch weather data")

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@app.get("/weather/forecast/{city}")
async def get_weather_forecast(city: str, days: int = 7):
    """Get weather forecast for a city"""
    try:
        location = await get_coordinates(city)
        if not location:
            raise HTTPException(status_code=404, detail="City not found")

        async with httpx.AsyncClient() as client:
            response = await client.get(
                "https://api.open-meteo.com/v1/forecast",
                params={
                    "latitude": location["latitude"],
                    "longitude": location["longitude"],
                    "daily": "weather_code,temperature_2m_max,temperature_2m_min",
                    "forecast_days": min(days, 16),
                    "timezone": "auto"
                }
            )

            if response.status_code == 200:
                data = response.json()
                daily = data["daily"]
                forecast_list = []

                for i in range(len(daily["time"])):
                    weather_code = daily["weather_code"][i]
                    condition, description = get_weather_description(
                        weather_code)
                    forecast_list.append({
                        "date": daily["time"][i],
                        "temperature_max": round(daily["temperature_2m_max"][i], 1),
                        "temperature_min": round(daily["temperature_2m_min"][i], 1),
                        "condition": condition,
                        "description": description,
                        "icon": get_weather_icon(weather_code)
                    })

                return {
                    "city": f"{location['name']}, {location['country']}",
                    "forecast": forecast_list
                }
            else:
                raise HTTPException(
                    status_code=500, detail="Failed to fetch forecast data")

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


# ── WEATHER CODE HELPERS ──────────────────────────────────────────────────────

def get_weather_description(code: int) -> tuple:
    weather_codes = {
        0: ("Clear", "Clear sky"),
        1: ("Clear", "Mainly clear"),
        2: ("Clouds", "Partly cloudy"),
        3: ("Clouds", "Overcast"),
        45: ("Fog", "Foggy"),
        48: ("Fog", "Depositing rime fog"),
        51: ("Drizzle", "Light drizzle"),
        53: ("Drizzle", "Moderate drizzle"),
        55: ("Drizzle", "Dense drizzle"),
        61: ("Rain", "Slight rain"),
        63: ("Rain", "Moderate rain"),
        65: ("Rain", "Heavy rain"),
        71: ("Snow", "Slight snow"),
        73: ("Snow", "Moderate snow"),
        75: ("Snow", "Heavy snow"),
        77: ("Snow", "Snow grains"),
        80: ("Rain", "Slight rain showers"),
        81: ("Rain", "Moderate rain showers"),
        82: ("Rain", "Violent rain showers"),
        85: ("Snow", "Slight snow showers"),
        86: ("Snow", "Heavy snow showers"),
        95: ("Thunderstorm", "Thunderstorm"),
        96: ("Thunderstorm", "Thunderstorm with slight hail"),
        99: ("Thunderstorm", "Thunderstorm with heavy hail"),
    }
    return weather_codes.get(code, ("Unknown", "Unknown"))


def get_weather_icon(code: int) -> str:
    if code == 0:
        return "01d"
    elif code in [1, 2]:
        return "02d"
    elif code == 3:
        return "03d"
    elif code in [45, 48]:
        return "50d"
    elif code in [51, 53, 55, 61, 63, 65, 80, 81, 82]:
        return "10d"
    elif code in [71, 73, 75, 77, 85, 86]:
        return "13d"
    elif code in [95, 96, 99]:
        return "11d"
    else:
        return "01d"


# ── GEMINI AI ─────────────────────────────────────────────────────────────────

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=GEMINI_API_KEY)


class ChatMessage(BaseModel):
    message: str
    context: Optional[str] = None


class ChatResponse(BaseModel):
    response: str


@app.post("/chat/ask", response_model=ChatResponse)
async def chat_with_ai(chat: ChatMessage):
    try:
        model = genai.GenerativeModel('gemini-2.5-flash')

        system_prompt = """You are an intelligent weather planning assistant with access to:
1. Current weather conditions
2. 7-day weather forecast
3. User's plans with specific dates

YOUR PRIMARY FUNCTION:
Match user's plans with forecast data to provide weather-based recommendations.

ANALYSIS CAPABILITIES:
- Compare plan dates with forecast dates
- Identify weather risks (rain, extreme temps, high winds, etc.)
- Suggest optimal timing for outdoor activities
- Recommend rescheduling when weather is unsuitable
- Provide specific weather details for each plan date

RESPONSE RULES:
1. **Match dates precisely**: If user asks "Should I go hiking tomorrow?", check tomorrow's forecast
2. **Reference specific data**: "Tomorrow's temperature is 15°C with rain" not "bad weather"
3. **Be proactive**: Warn about weather issues 2-3 days ahead
4. **Prioritize safety**: Strongly advise against dangerous weather conditions
5. **Suggest alternatives**: If outdoor plan has bad weather, suggest indoor backup or reschedule
6. **Use forecast range**: For "this week" questions, analyze all 7 days
7. **Be concise**: Max 200 words, prioritize most important weather impacts

EXAMPLE RESPONSES:
❌ Bad: "The weather looks okay for your plans"
✅ Good: "Your 'Beach Day' tomorrow has rain forecasted (75% chance) with 10°C temp. I'd recommend rescheduling to Thursday when it's sunny and 25°C."

❌ Bad: "You have some plans this week"
✅ Good: "This week: Monday-Tuesday (sunny, 22°C) perfect for your 'Hiking' plan. Wednesday (rain) - move your 'Picnic' to Thursday instead."
"""

        if chat.context and chat.context.strip():
            full_prompt = f"""{system_prompt}

=====================================================
CONTEXT DATA AVAILABLE TO YOU:
=====================================================
{chat.context}
=====================================================

USER QUESTION: "{chat.message}"

INSTRUCTIONS:
1. Parse the forecast data carefully - match plan dates with forecast dates
2. For "tomorrow" questions, use Day 2 of forecast (Day 1 = today)
3. For "next week" questions, analyze days 1-7
4. Always cite specific weather numbers (temp, condition) in your response
5. If a plan date matches a forecast date, explicitly state the weather for that day
6. Provide actionable advice: "reschedule to [date]" or "proceed but bring [item]"
"""
        else:
            full_prompt = f"""{system_prompt}

⚠️ NO CONTEXT AVAILABLE

USER QUESTION: "{chat.message}"

RESPONSE: Politely inform the user you need:
- Weather data (ask them to search for a city in the weather widget)
- Plans (ask them to create plans in the agenda)
Then you can provide weather-based recommendations.
"""

        print(f"[AI] Prompt length: {len(full_prompt)} chars")
        print(f"[AI] Context provided: {'YES' if chat.context else 'NO'}")

        response = model.generate_content(full_prompt)
        return ChatResponse(response=response.text)

    except Exception as e:
        print(f"Gemini API error: {e}")
        raise HTTPException(
            status_code=500, detail=f"AI service error: {str(e)}")
