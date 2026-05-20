# Deployment Guide

## Architecture
- **Frontend:** Flutter Web → Vercel (CDN-hosted, zero-config deployment)
- **Backend:** FastAPI → Render (serverless Python app)

---

## Deploy Frontend (Flutter Web) to Vercel

### Prerequisites
- Vercel CLI: `npm install -g vercel`
- Flutter SDK with web support
- GitHub repo synced

### Build Note
Build uses `--no-tree-shake-icons` flag due to dynamic IconData instances in appliance models. This is safe and doesn't affect functionality, just includes all Material icons in the bundle.

### Option A: CLI Deployment (Quick)

```bash
# 1. Build Flutter web
flutter build web --release --no-tree-shake-icons

# 2. Deploy to Vercel
vercel --prod
```

### Option B: GitHub Integration (Recommended)

1. Go to [vercel.com](https://vercel.com)
2. Click "New Project"
3. Select "Import Git Repository" 
4. Find and import your WattwAIs repo
5. **Project Settings:**
   - **Framework Preset:** Other
   - **Build Command:** `flutter build web --release --no-tree-shake-icons`
   - **Output Directory:** `build/web`
   - **Install Command:** Skip (leave blank)
6. **Environment Variables:** (optional, if using dynamic backend URL)
   - `PREDICT_API_BASE_URL` = `https://wattwais.onrender.com` (optional)
7. Click "Deploy"

**Result:** Vercel auto-deploys on every `main` branch push!

---

## Verify Backend URL in App

Ensure your web build points to Render:

### File: `lib/core/config/app_config.dart`

```dart
if (kIsWeb) {
  return _defaultProductionBaseUrl;  // Returns: https://wattwais.onrender.com
}
```

✅ Already configured to use `wattwais.onrender.com`

---

## Test Web Deployment

Once deployed to Vercel, you'll get a URL like:
```
https://wattwais.vercel.app
```

Or you can set a custom domain.

### Quick Test
```bash
# Build locally and test before deploying
flutter build web --release
cd build/web
python -m http.server 8080
# Open http://localhost:8080
```

---

## Environment Variables (if needed)

If you want to override the backend URL in Vercel, add to `vercel.json`:

```json
{
  "env": {
    "PREDICT_API_BASE_URL": "https://wattwais.onrender.com"
  }
}
```

Then in Dart:
```dart
const String dartDefineBaseUrl = String.fromEnvironment('PREDICT_API_BASE_URL');
```

---

## Rollback / Redeploy

To rollback to a previous deployment:
```bash
vercel --prod --confirm
```

---

## Common Issues

### 1. Build Fails on Vercel
- Ensure `flutter` is available in your path
- Check that `pubspec.yaml` has no local path dependencies
- Try building locally first: `flutter build web --release`

### 2. Blank Page on Vercel
- Check browser console for errors
- Ensure `build/web/index.html` is being served
- Verify Render backend is responding to `/` health check

### 3. Backend API Calls Fail
- Verify `PREDICT_API_BASE_URL` is correct
- Check CORS on Render backend
- Ensure Render service is running: `curl https://wattwais.onrender.com/`

---

## Next: Backend on Render (Already Deployed)

Your FastAPI backend is already on Render at:
```
https://wattwais.onrender.com
```

No additional setup needed! The web app will connect to this URL automatically.

---

## Deploy Both (One Command)

```bash
# From project root
flutter build web --release --no-tree-shake-icons && vercel --prod
```

Or create a script: `deploy.sh`

```bash
#!/bin/bash
echo "Building Flutter web..."
flutter build web --release --no-tree-shake-icons

echo "Deploying to Vercel..."
vercel --prod

echo "✅ Deployment complete!"
echo "Web: https://wattwais.vercel.app"
echo "API: https://wattwais.onrender.com"
```

Make executable:
```bash
chmod +x deploy.sh
./deploy.sh
```

---

## Files Created for Vercel

- `vercel.json` - Vercel build configuration
- `.vercelignore` - Files to exclude from Vercel build
- `.env.example` - Environment variables template

All set! 🚀

---

## Optional: Icon Tree-Shaking Optimization

Currently, builds use `--no-tree-shake-icons` because `ApplianceModel` creates IconData dynamically from Firestore data. If you want to optimize bundle size later, refactor to use a mapping function:

```dart
// lib/utils/icon_map.dart
Map<String, IconData> applianceIconMap = {
  'Air Conditioner': Icons.ac_unit_rounded,
  'Phone': Icons.phone_iphone_rounded,
  'Laptop': Icons.laptop_mac_rounded,
  // ... etc
};

// Then use: applianceIconMap[appliance.name] ?? Icons.devices
```

This allows Flutter to tree-shake unused icons and reduce web bundle size ~50KB.

For now, the current approach works fine and is more maintainable. 🚀
