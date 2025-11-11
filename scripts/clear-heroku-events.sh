#!/bin/bash

# Script to delete all events from Heroku database (keeps users)
# Usage: ./scripts/clear-heroku-events.sh [app-name]

APP_NAME=${1:-"funradar-b8f29a7d90f1"}

echo "🗑️  Deleting all events from Heroku database..."
echo "App: $APP_NAME"
echo ""
echo "This will delete:"
echo "  - All events"
echo "  - All invitations"
echo "  - All preferences"
echo "  - All activity suggestions"
echo ""
echo "Users will be kept."
echo ""
read -p "Continue? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
  echo "❌ Cancelled. No data was deleted."
  exit 1
fi

echo ""
echo "🗑️  Deleting events and related data..."

# Run Rails console command to delete all events (cascade will handle related records)
heroku run rails runner "
  puts 'Deleting all events...'
  count = Event.count
  Event.destroy_all
  puts \"Deleted #{count} events and all related data (invitations, preferences, activity suggestions)\"
  puts 'Done!'
" -a $APP_NAME

echo ""
echo "✅ All events deleted!"
echo ""
echo "📝 Users will still be logged in. They need to clear localStorage to log out."

