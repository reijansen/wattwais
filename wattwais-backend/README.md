# WattwAIs Backend (FastAPI)

This is the ML inference backend for WattwAIs. It serves the trained model located at `models/wattwais_iflex_xgboost.pkl`.

## Endpoints

- `GET /` health check
- `POST /predict` predict usage + bill estimate
- `GET /version` model/version metadata

## Local run

From `wattwais-backend/`:

```bash
pip install -r requirements-render.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

Smoke test:

```bash
python scripts/smoke_test_predict.py
```

## Render deployment

Create a Render **Web Service** connected to this repo and configure:

- **Root Directory:** `wattwais-backend`
- **Build Command:** `pip install -r requirements-render.txt`
- **Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`
- **Health Check Path:** `/`

Python version is pinned via `../runtime.txt` (repo root).

### Faster builds

`requirements-render.txt` is intentionally minimal to avoid large ML libraries that slow down deployment (e.g., `catboost`, `lightgbm`, GPU extras). Keep it aligned with what `main.py` actually imports.

### Required env vars

- `ENV`:
  - set to `production` on Render
  - default: `development`
- `CORS_ORIGINS` (recommended in production):
  - comma-separated origins, e.g. `https://yourapp.web.app,https://wattwais.example.com`
  - if omitted in `production`, CORS defaults to **no allowed origins**

## Flutter app configuration

Point the Flutter app to your Render service URL:

```bash
flutter run --dart-define=PREDICT_API_BASE_URL=https://wattwais.onrender.com
```
