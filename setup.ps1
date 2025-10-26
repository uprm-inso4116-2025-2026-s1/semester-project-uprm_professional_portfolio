# Developer Setup Script for Windows
# Run this after cloning the repository

Write-Host "🚀 Setting up UPRM Professional Portfolio..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if .env exists
if (Test-Path ".env") {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
} else {
    Write-Host "📄 Creating .env file from template..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "✅ .env file created" -ForegroundColor Green
}

Write-Host ""

# Step 2: Install Flutter dependencies
Write-Host "📦 Installing Flutter dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install Flutter dependencies. Please check the error above." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 To run the app:" -ForegroundColor Cyan
Write-Host "   flutter run" -ForegroundColor White
Write-Host ""
Write-Host "📚 For more information, see README.md" -ForegroundColor Cyan
