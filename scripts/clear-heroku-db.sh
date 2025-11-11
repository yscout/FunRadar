#!/bin/bash

# Script to clear Heroku database (WARNING: This will delete ALL data!)
# Usage: ./scripts/clear-heroku-db.sh [app-name]

APP_NAME=${1:-"funradar-b8f29a7d90f1"}

echo "⚠️  WARNING: This will DELETE ALL DATA from the Heroku database!"
echo "App: $APP_NAME"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
  echo "❌ Cancelled. No data was deleted."
  exit 1
fi

echo ""
echo "🗑️  Clearing database..."

# Reset the database (drops all tables and recreates them)
heroku pg:reset DATABASE -a $APP_NAME --confirm $APP_NAME

# Run migrations to recreate schema
echo ""
echo "🔄 Running migrations..."
heroku run rails db:migrate -a $APP_NAME

echo ""
echo "✅ Database cleared and reset!"
echo ""
echo "📝 Note: Users will need to clear their browser localStorage to log out."
echo "   They can do this by:"
echo "   1. Opening browser DevTools (F12)"
echo "   2. Going to Application/Storage tab"
echo "   3. Clearing Local Storage for your domain"
echo "   Or use the logout button in the app (if added)"

