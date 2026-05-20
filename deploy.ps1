# WattwAIs Deployment Script (Windows PowerShell)
# Deploys Flutter web to Vercel + ensures Render backend is active

Write-Host "🚀 WattwAIs Deployment Script (Windows)" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutter) {
    Write-Host "❌ Flutter not found. Please install Flutter first." -ForegroundColor Red
    exit 1
}

# Check if Vercel CLI is installed
$vercel = Get-Command vercel -ErrorAction SilentlyContinue
if (-not $vercel) {
    Write-Host "⚠️  Vercel CLI not found. Installing..." -ForegroundColor Yellow
    npm install -g vercel
}

Write-Host "📦 Step 1: Building Flutter web..." -ForegroundColor Cyan
flutter clean
flutter pub get
flutter build web --release --no-tree-shake-icons

Write-Host "✅ Flutter build complete!" -ForegroundColor Green
Write-Host ""

Write-Host "🌐 Step 2: Testing Render backend..." -ForegroundColor Cyan
$backendUrl = "https://wattwais.onrender.com/"

try {
    $response = Invoke-WebRequest -Uri $backendUrl -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✅ Backend is running: $backendUrl" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Backend may be starting (cold start). Waiting 10 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    try {
        $response = Invoke-WebRequest -Uri $backendUrl -TimeoutSec 5 -ErrorAction Stop
        Write-Host "✅ Backend is now running!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Backend not responding. Check Render service." -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

Write-Host "📤 Step 3: Deploying to Vercel..." -ForegroundColor Cyan
Write-Host "Press Enter to continue or Ctrl+C to cancel..."
$null = Read-Host

vercel --prod

Write-Host ""
Write-Host "=======================================" -ForegroundColor Green
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Deployment URLs:" -ForegroundColor Cyan
Write-Host "   Frontend (Web): https://wattwais.vercel.app"
Write-Host "   Backend (API):  https://wattwais.onrender.com"
Write-Host ""
Write-Host "🔍 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Test at https://wattwais.vercel.app"
Write-Host "   2. Check browser console for errors"
Write-Host "   3. Verify API calls succeed"
Write-Host ""
