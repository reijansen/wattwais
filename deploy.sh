#!/bin/bash

# WattwAIs Deployment Script
# Deploys Flutter web to Vercel + ensures Render backend is active

set -e

echo "🚀 WattwAIs Deployment Script"
echo "================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "⚠️  Vercel CLI not found. Installing..."
    npm install -g vercel
fi

echo "📦 Step 1: Building Flutter web..."
flutter clean
flutter pub get
flutter build web --release --no-tree-shake-icons

echo "✅ Flutter build complete!"
echo ""

echo "🌐 Step 2: Testing Render backend..."
BACKEND_URL="https://wattwais.onrender.com/"
if curl -s "$BACKEND_URL" > /dev/null 2>&1; then
    echo "✅ Backend is running: $BACKEND_URL"
else
    echo "⚠️  Backend may be starting (cold start). Will retry in 10s..."
    sleep 10
    if curl -s "$BACKEND_URL" > /dev/null 2>&1; then
        echo "✅ Backend is now running!"
    else
        echo "❌ Backend not responding. Check Render service."
        exit 1
    fi
fi
echo ""

echo "📤 Step 3: Deploying to Vercel..."
echo "Press Enter to continue or Ctrl+C to cancel..."
read -p ""

vercel --prod

echo ""
echo "================================"
echo "✅ Deployment complete!"
echo ""
echo "📊 Deployment URLs:"
echo "   Frontend (Web): https://wattwais.vercel.app"
echo "   Backend (API):  https://wattwais.onrender.com"
echo ""
echo "🔍 Next steps:"
echo "   1. Test at https://wattwais.vercel.app"
echo "   2. Check browser console for errors"
echo "   3. Verify API calls succeed"
echo ""
