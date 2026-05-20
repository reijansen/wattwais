# WattwAIs

Flutter app + FastAPI backend for electricity usage/bill prediction.

## Backend (local)

From `wattwais-backend/`:

```bash
pip install -r requirements-render.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

## App run commands

- Firebase config is now read from compile-time env values.
  - Copy `.env.example` to `.env` and fill in your real Firebase values.
  - Run with `--dart-define-from-file=.env`.

- Android emulator (backend running on your machine):
  - `flutter run --dart-define-from-file=.env --dart-define=PREDICT_API_BASE_URL=http://10.0.2.2:8000`
- Physical phone / Web (use Render backend):
  - `flutter run --dart-define-from-file=.env --dart-define=PREDICT_API_BASE_URL=https://wattwais.onrender.com`

Note: In release builds, the app falls back to the URL in `lib/core/config/app_config.dart` if `PREDICT_API_BASE_URL` is not provided.
