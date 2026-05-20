from fastapi import FastAPI
from fastapi import HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from pydantic import Field
from typing import List, Optional, Any, Dict
import pandas as pd
import numpy as np
import joblib
from datetime import datetime
import hashlib
import os
import json
import time
import threading
from urllib import request as urllib_request
from urllib import error as urllib_error
from pathlib import Path

app = FastAPI(title="wattwais prediction api")
_ai_insights_cache: Dict[str, Dict[str, Any]] = {}
_ai_insights_cache_lock = threading.Lock()
_model_list_cache: Dict[str, Any] = {"expires_at": 0.0, "names": []}
_model_list_cache_lock = threading.Lock()

def _get_allowed_origins():
    env = os.getenv("ENV", "development").lower()
    raw = os.getenv("CORS_ORIGINS", "").strip()

    if raw:
        return [origin.strip() for origin in raw.split(",") if origin.strip()]

    # Development convenience: allow everything.
    if env != "production":
        return ["*"]

    # Production default: require explicit allowlist.
    return []


allowed_origins = _get_allowed_origins()
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MODEL_PATH = "models/wattwais_iflex_xgboost.pkl"
model_path = Path(MODEL_PATH)


def _sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


try:
    model = joblib.load(MODEL_PATH)
except Exception as e:
    model = None
    model_load_error = str(e)
else:
    model_load_error = None


class ApplianceInput(BaseModel):
    name: str = Field(min_length=1, max_length=80)
    quantity: int = Field(ge=1, le=1000)
    watts: float = Field(ge=0.0, le=100000.0)
    hours_per_day: float = Field(ge=0.0, le=24.0)
    days_per_week: int = Field(ge=0, le=7)


class PredictionRequest(BaseModel):
    appliances: List[ApplianceInput]
    base_rate: float = Field(ge=0.0, le=1000.0)
    six_month_total_bill: float = Field(ge=0.0)
    six_month_total_kwh: float = Field(ge=0.0)
    monthly_budget: Optional[float] = Field(default=None, ge=0.0, le=1e9)


class InsightApplianceInput(BaseModel):
    name: str = Field(default="Appliance", min_length=1, max_length=80)
    quantity: int = Field(default=1, ge=1, le=1000)
    watts: float = Field(default=0.0, ge=0.0, le=100000.0)
    hours_per_day: float = Field(default=0.0, ge=0.0, le=24.0)
    days_per_week: int = Field(default=7, ge=0, le=7)


class InsightRequest(BaseModel):
    name: str = Field(default="User", min_length=1, max_length=80)
    budget_kwh: Optional[float] = Field(default=None, ge=0.0, le=1e9)
    estimated_monthly_kwh: float = Field(ge=0.0, le=1e9)
    historical_monthly_kwh: float = Field(ge=0.0, le=1e9)
    estimated_bill: float = Field(ge=0.0, le=1e12)
    exceeds_budget: Optional[bool] = None
    top_appliance_name: Optional[str] = Field(default=None, max_length=80)
    top_appliance_percent: Optional[float] = Field(default=None, ge=0.0, le=1000.0)
    top_appliance_kwh: Optional[float] = Field(default=None, ge=0.0, le=1e9)
    top_appliance_cost: Optional[float] = Field(default=None, ge=0.0, le=1e12)
    appliances: List[InsightApplianceInput] = Field(default_factory=list)


@app.get("/")
def health_check():
    return {"status": "ok", "message": "wattwais backend running"}


@app.get("/version")
def version():
    build_time = os.getenv("BUILD_TIME") or datetime.utcnow().isoformat() + "Z"
    if model_path.exists():
        try:
            model_sha256 = _sha256_file(model_path)
        except Exception as e:
            model_sha256 = None
            sha_err = str(e)
        else:
            sha_err = None
    else:
        model_sha256 = None
        sha_err = "model file not found"

    return {
        "build_time": build_time,
        "env": os.getenv("ENV", "development"),
        "model_file": str(model_path),
        "model_sha256": model_sha256,
        "model_loaded": model is not None,
        "model_load_error": model_load_error,
        "sha256_error": sha_err,
    }


def compute_appliance_monthly_kwh(appliances: List[ApplianceInput]):
    appliance_breakdown = []
    total_monthly_kwh = 0

    for item in appliances:
        daily_kwh = (item.watts * item.quantity * item.hours_per_day) / 1000
        weekly_kwh = daily_kwh * item.days_per_week
        monthly_kwh = weekly_kwh * 4.345

        total_monthly_kwh += monthly_kwh

        appliance_breakdown.append({
            "name": item.name,
            "quantity": item.quantity,
            "watts": item.watts,
            "hours_per_day": item.hours_per_day,
            "days_per_week": item.days_per_week,
            "monthly_kwh": round(monthly_kwh, 2)
        })

    return total_monthly_kwh, appliance_breakdown


def build_model_features(avg_hourly_kwh: float):
    now = datetime.now()

    hour = now.hour
    day_of_week = now.weekday()
    month = now.month
    day = now.day
    is_weekend = 1 if day_of_week in [5, 6] else 0

    features = pd.DataFrame([{
        "hour": hour,
        "day_of_week": day_of_week,
        "month": month,
        "day": day,
        "is_weekend": is_weekend,

        "Experiment_price_NOK_kWh": 1.0,
        "Temperature": 28.0,
        "Temperature24": 28.0,
        "Temperature48": 28.0,
        "Temperature72": 28.0,

        "lag_1": avg_hourly_kwh,
        "lag_24": avg_hourly_kwh,
        "lag_168": avg_hourly_kwh,
        "rolling_24": avg_hourly_kwh,
        "rolling_168": avg_hourly_kwh,

        "Region": "Oslo",
        "Municipality": "Oslo",
        "Participation_Phase": "Phase_2",
        "Control_Price_Phase2": "Price group",
        "Group_Phase2": "H1"
    }])

    return features


def _insights_models() -> List[str]:
    models = [
        os.getenv("GEMINI_RECO_MAIN_MODEL", "gemini-3.5-flash"),
        os.getenv("GEMINI_RECO_BACKUP_MODEL_1", "gemini-3"),
        os.getenv("GEMINI_RECO_BACKUP_MODEL_2", "gemini-3.1-flash-lite"),
        os.getenv("GEMINI_RECO_BACKUP_MODEL_3", "gemini-2.5-flash-lite"),
    ]
    configured = [m.strip() for m in models if m and m.strip()]
    available = _list_generate_content_models()
    if not available:
        return configured
    available_set = set(available)
    filtered = [m for m in configured if m in available_set]
    return filtered if filtered else configured


def _list_generate_content_models() -> List[str]:
    api_key = os.getenv("GEMINI_API_KEY", "").strip()
    if not api_key:
        return []

    now = time.time()
    with _model_list_cache_lock:
        expires_at = float(_model_list_cache.get("expires_at", 0))
        names = _model_list_cache.get("names", [])
        if expires_at > now and isinstance(names, list):
            return [str(n) for n in names]

    endpoint = f"https://generativelanguage.googleapis.com/v1beta/models?key={api_key}"
    req = urllib_request.Request(endpoint, method="GET")
    try:
        with urllib_request.urlopen(req, timeout=15) as response:
            raw = response.read().decode("utf-8")
            parsed = json.loads(raw)
    except Exception:
        return []

    out: List[str] = []
    for model in parsed.get("models", []):
        if not isinstance(model, dict):
            continue
        methods = model.get("supportedGenerationMethods", [])
        if "generateContent" not in methods:
            continue
        name = str(model.get("name", ""))
        if name.startswith("models/"):
            name = name.split("/", 1)[1]
        if name:
            out.append(name)

    with _model_list_cache_lock:
        _model_list_cache["names"] = out
        _model_list_cache["expires_at"] = time.time() + 600
    return out


def _insights_cache_ttl_seconds() -> int:
    raw = os.getenv("GEMINI_RECO_CACHE_TTL_SECONDS", "900").strip()
    try:
        value = int(raw)
    except ValueError:
        return 900
    return max(0, value)


def _insights_cache_key(payload: InsightRequest) -> str:
    canonical = json.dumps(payload.model_dump(), sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def _get_cached_insights(cache_key: str) -> Optional[Dict[str, Any]]:
    ttl = _insights_cache_ttl_seconds()
    if ttl <= 0:
        return None
    now = time.time()
    with _ai_insights_cache_lock:
        entry = _ai_insights_cache.get(cache_key)
        if not entry:
            return None
        expires_at = float(entry.get("expires_at", 0))
        if expires_at <= now:
            _ai_insights_cache.pop(cache_key, None)
            return None
        data = entry.get("data")
        if not isinstance(data, dict):
            return None
        return data


def _set_cached_insights(cache_key: str, data: Dict[str, Any]) -> None:
    ttl = _insights_cache_ttl_seconds()
    if ttl <= 0:
        return
    expires_at = time.time() + ttl
    with _ai_insights_cache_lock:
        _ai_insights_cache[cache_key] = {
            "data": data,
            "expires_at": expires_at,
        }


def _gemini_generate_json(prompt: str) -> Dict[str, Any]:
    api_key = os.getenv("GEMINI_API_KEY", "").strip()
    if not api_key:
        raise HTTPException(status_code=503, detail="GEMINI_API_KEY is not configured")

    temperature = float(os.getenv("GEMINI_RECO_TEMPERATURE", "0.3"))
    max_tokens = int(os.getenv("GEMINI_RECO_MAX_OUTPUT_TOKENS", "600"))
    models = _insights_models()
    if not models:
        raise HTTPException(status_code=503, detail="No Gemini models configured")

    generation_config = {
        "temperature": temperature,
        "maxOutputTokens": max_tokens,
        "responseMimeType": "application/json",
    }

    request_payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": generation_config,
    }

    errors: List[str] = []

    for model_name in models:
        endpoint = (
            f"https://generativelanguage.googleapis.com/v1beta/models/"
            f"{model_name}:generateContent?key={api_key}"
        )
        body_bytes = json.dumps(request_payload).encode("utf-8")
        req = urllib_request.Request(
            endpoint,
            data=body_bytes,
            headers={"Content-Type": "application/json"},
            method="POST",
        )

        try:
            with urllib_request.urlopen(req, timeout=20) as response:
                raw = response.read().decode("utf-8")
                parsed = json.loads(raw)
                parts = (
                    parsed.get("candidates", [{}])[0]
                    .get("content", {})
                    .get("parts", [])
                )
                text = ""
                if parts:
                    text = parts[0].get("text", "")
                if not text:
                    raise ValueError("Empty Gemini response text")
                data = json.loads(text)
                data["_meta"] = {"model": model_name}
                return data

        except urllib_error.HTTPError as e:
            detail = e.read().decode("utf-8", errors="ignore")
            errors.append(f"{model_name}: http {e.code} {detail[:220]}")
            if e.code == 429:
                time.sleep(0.5)
            continue
        except Exception as e:
            errors.append(f"{model_name}: {str(e)[:220]}")
            continue

    raise HTTPException(
        status_code=503,
        detail=f"All Gemini models failed. {' | '.join(errors)}",
    )


def _build_insights_prompt(payload: InsightRequest) -> str:
    appliances_json = json.dumps(
        [a.model_dump() for a in payload.appliances],
        ensure_ascii=True,
    )
    return f"""
You are an electricity optimization assistant for a household energy app.
Use the provided prediction and appliance data to generate page-specific insights.

Return STRICT JSON only (no markdown, no extra text).
Do not invent missing data.
Recommendations must be practical, specific, and short.

Output schema:
{{
  "home_insight": {{
    "headline": "string",
    "message": "string",
    "priority": "low|medium|high"
  }},
  "stats_insight": {{
    "headline": "string",
    "message": "string",
    "key_driver": "string"
  }},
  "tips_list": [
    {{
      "title": "string",
      "recommendation": "string",
      "estimated_impact": "string",
      "difficulty": "easy|medium|hard"
    }}
  ],
  "alerts": [
    {{
      "type": "budget|usage_spike|appliance_risk",
      "message": "string"
    }}
  ]
}}

Generate cross-page electricity insights from this data.

User:
- Name: {payload.name}
- Budget kWh: {payload.budget_kwh}

Prediction:
- Estimated monthly kWh: {payload.estimated_monthly_kwh}
- Historical monthly kWh: {payload.historical_monthly_kwh}
- Estimated bill PHP: {payload.estimated_bill}
- Exceeds budget: {payload.exceeds_budget}

Appliance summary:
- Top appliance: {payload.top_appliance_name}
- Top appliance share: {payload.top_appliance_percent}%
- Top appliance monthly kWh: {payload.top_appliance_kwh}
- Top appliance monthly cost PHP: {payload.top_appliance_cost}

Appliances:
{appliances_json}

Rules:
- home_insight: 1 short message for dashboard card.
- stats_insight: explain trend and main driver.
- tips_list: 4 to 6 actionable tips, prioritized by impact.
- include at least one no-cost tip.
- keep each recommendation <= 2 sentences.
""".strip()


@app.post("/predict")
def predict_bill(request: PredictionRequest):
    if model is None:
        raise HTTPException(
            status_code=503,
            detail="Model not loaded. Check /version for model_load_error.",
        )

    if request.six_month_total_kwh == 0 and request.base_rate == 0:
        raise HTTPException(
            status_code=400,
            detail="Provide base_rate > 0 when six_month_total_kwh is 0.",
        )

    appliance_monthly_kwh, appliance_breakdown = compute_appliance_monthly_kwh(request.appliances)

    historical_monthly_kwh = request.six_month_total_kwh / 6
    historical_monthly_bill = request.six_month_total_bill / 6

    historical_rate = (
        request.six_month_total_bill / request.six_month_total_kwh
        if request.six_month_total_kwh > 0
        else request.base_rate
    )

    effective_rate = request.base_rate if request.base_rate > 0 else historical_rate

    blended_monthly_kwh = (
        0.6 * historical_monthly_kwh +
        0.4 * appliance_monthly_kwh
    )

    avg_hourly_kwh = blended_monthly_kwh / 30 / 24

    features = build_model_features(avg_hourly_kwh)

    try:
        predicted_hourly_kwh = float(model.predict(features)[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {e}")
    model_monthly_kwh = predicted_hourly_kwh * 24 * 30

    estimated_monthly_kwh = (
        0.5 * historical_monthly_kwh +
        0.3 * appliance_monthly_kwh +
        0.2 * model_monthly_kwh
    )

    estimated_bill = estimated_monthly_kwh * effective_rate

    exceeds_budget = (
        estimated_bill > request.monthly_budget
        if request.monthly_budget is not None
        else None
    )

    return {
        "predicted_hourly_kwh": round(predicted_hourly_kwh, 3),
        "model_monthly_kwh": round(model_monthly_kwh, 2),
        "appliance_monthly_kwh": round(appliance_monthly_kwh, 2),
        "historical_monthly_kwh": round(historical_monthly_kwh, 2),
        "estimated_monthly_kwh": round(estimated_monthly_kwh, 2),
        "estimated_bill": round(estimated_bill, 2),
        "effective_rate": round(effective_rate, 2),
        "historical_monthly_bill": round(historical_monthly_bill, 2),
        "exceeds_budget": exceeds_budget,
        "appliance_breakdown": appliance_breakdown,
        "recommendation": "ai recommendation endpoint can use this prediction result plus appliance breakdown."
    }


@app.post("/ai/insights")
def generate_ai_insights(request: InsightRequest):
    cache_key = _insights_cache_key(request)
    cached = _get_cached_insights(cache_key)
    if cached is not None:
        cached_response = dict(cached)
        meta = cached_response.get("meta")
        if isinstance(meta, dict):
            meta = dict(meta)
            meta["cache_hit"] = True
            cached_response["meta"] = meta
        else:
            cached_response["meta"] = {"cache_hit": True}
        return cached_response

    prompt = _build_insights_prompt(request)
    result = _gemini_generate_json(prompt)

    home = result.get("home_insight") or {}
    stats = result.get("stats_insight") or {}
    tips = result.get("tips_list") or []
    alerts = result.get("alerts") or []

    response = {
        "home_insight": {
            "headline": str(home.get("headline", "Energy insight")),
            "message": str(home.get("message", "No insight available yet.")),
            "priority": str(home.get("priority", "medium")),
        },
        "stats_insight": {
            "headline": str(stats.get("headline", "Usage trend")),
            "message": str(stats.get("message", "No trend insight available yet.")),
            "key_driver": str(stats.get("key_driver", "Latest prediction")),
        },
        "tips_list": tips if isinstance(tips, list) else [],
        "alerts": alerts if isinstance(alerts, list) else [],
        "meta": {
            **(result.get("_meta", {}) if isinstance(result.get("_meta"), dict) else {}),
            "cache_hit": False,
        },
    }
    _set_cached_insights(cache_key, response)
    return response


@app.get("/ai/models/debug")
def ai_models_debug():
    configured = [
        os.getenv("GEMINI_RECO_MAIN_MODEL", "gemini-3.5-flash"),
        os.getenv("GEMINI_RECO_BACKUP_MODEL_1", "gemini-3"),
        os.getenv("GEMINI_RECO_BACKUP_MODEL_2", "gemini-3.1-flash-lite"),
        os.getenv("GEMINI_RECO_BACKUP_MODEL_3", "gemini-2.5-flash-lite"),
    ]
    available = _list_generate_content_models()
    selected = _insights_models()
    return {
        "configured": configured,
        "available_generate_content_models": available,
        "selected_for_fallback": selected,
    }
