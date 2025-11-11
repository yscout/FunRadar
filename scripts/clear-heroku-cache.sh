#!/bin/bash

# Script to clear Heroku cache and force a fresh build
# Usage: ./scripts/clear-heroku-cache.sh [app-name]

APP_NAME=${1:-"funradar-b8f29a7d90f1"}

echo "🧹 Clearing Heroku cache for app: $APP_NAME"
echo ""

# Clear Heroku build cache
echo "1. Clearing Heroku build cache..."
heroku builds:cache:purge -a $APP_NAME

# Optionally, you can also clear the slug cache by doing a rebuild
echo ""
echo "2. To force a complete rebuild, run:"
echo "   heroku builds:create -a $APP_NAME"
echo ""
echo "Or simply push a new commit:"
echo "   git commit --allow-empty -m 'Force rebuild'"
echo "   git push heroku main"
echo ""
echo "✅ Cache clearing commands executed!"
echo ""
echo "📝 Additional steps to ensure fresh cache:"
echo "   - Users should hard refresh their browsers (Cmd+Shift+R / Ctrl+Shift+R)"
echo "   - Or clear browser cache manually"
echo "   - The new cache headers will prevent stale content going forward"

