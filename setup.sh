#!/bin/bash
# Developer Setup Script for Linux/Mac
# Run this after cloning the repository

echo "🚀 Setting up UPRM Professional Portfolio..."
echo ""

# Step 1: Check if .env exists
if [ -f ".env" ]; then
    echo "✅ .env file already exists"
else
    echo "📄 Creating .env file from template..."
    cp .env.example .env
    echo "✅ .env file created"
fi

echo ""

# Step 2: Install Flutter dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to install Flutter dependencies. Please check your Flutter installation and try again."
    exit 1
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📱 To run the app:"
echo "   flutter run"
echo ""
echo "📚 For more information, see README.md"
