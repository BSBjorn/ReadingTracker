#!/bin/bash
# Helper script for managing PostgreSQL in LOCAL DEVELOPMENT MODE
# This creates a separate container from podman-compose to avoid conflicts

CONTAINER_NAME="reading-tracker-db-dev"
DB_USER="reading_user"
DB_NAME="reading_tracker"
DB_PASSWORD="reading_pass"
DB_PORT="5432"

echo "🔧 Local Development Database Manager"
echo "   Container: $CONTAINER_NAME"
echo "   Port: $DB_PORT"
echo ""

case "$1" in
  start)
    echo "🚀 Starting PostgreSQL (Development)..."

    # Check if container already exists
    if podman ps -a | grep -q $CONTAINER_NAME; then
      if podman ps | grep -q $CONTAINER_NAME; then
        echo "✅ Development database is already running"
        exit 0
      else
        echo "▶️  Starting existing container..."
        podman start $CONTAINER_NAME
        echo "✅ PostgreSQL started on port $DB_PORT"
        exit 0
      fi
    fi

    # Create new container
    podman run -d \
      --name $CONTAINER_NAME \
      -e POSTGRES_USER=$DB_USER \
      -e POSTGRES_PASSWORD=$DB_PASSWORD \
      -e POSTGRES_DB=$DB_NAME \
      -p $DB_PORT:5432 \
      -v /home/bamfjord/Projects/ReadingTracker/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql:Z \
      postgres:16-alpine
    
    echo "✅ Development database started on port $DB_PORT"
    echo "💡 This is separate from podman-compose (reading-tracker-db)"
    ;;

  stop)
    echo "🛑 Stopping PostgreSQL (Development)..."
    podman stop $CONTAINER_NAME
    echo "✅ Development database stopped"
    ;;

  restart)
    echo "🔄 Restarting PostgreSQL (Development)..."
    podman restart $CONTAINER_NAME
    echo "✅ Development database restarted"
    ;;

  remove)
    echo "🗑️  Removing PostgreSQL container (Development)..."
    podman stop $CONTAINER_NAME 2>/dev/null
    podman rm $CONTAINER_NAME
    echo "✅ Development container removed"
    ;;

  reset)
    echo "⚠️  Resetting development database (all data will be lost)..."
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
      podman stop $CONTAINER_NAME 2>/dev/null
      podman rm -v $CONTAINER_NAME 2>/dev/null
      $0 start
      echo "✅ Development database reset complete"
    else
      echo "❌ Reset cancelled"
    fi
    ;;

  logs)
    echo "📋 Showing logs (Ctrl+C to exit)..."
    podman logs -f $CONTAINER_NAME
    ;;

  status)
    echo "🔍 Checking development database status..."
    echo ""
    if podman ps | grep -q $CONTAINER_NAME; then
      echo "✅ Development database is running"
      podman ps | grep $CONTAINER_NAME
    else
      echo "❌ Development database is not running"
      if podman ps -a | grep -q $CONTAINER_NAME; then
        echo "💡 Container exists but is stopped. Run: ./db.sh start"
      fi
    fi
    echo ""
    echo "📦 Docker Compose status:"
    if podman ps | grep -q "reading-tracker-db"; then
      echo "✅ Docker Compose database is running"
    else
      echo "❌ Docker Compose database is not running"
    fi
    ;;

  psql)
    echo "🔌 Connecting to development database..."
    podman exec -it $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME
    ;;

  backup)
    BACKUP_FILE="backup_dev_$(date +%Y%m%d_%H%M%S).sql"
    echo "💾 Creating backup: $BACKUP_FILE"
    podman exec $CONTAINER_NAME pg_dump -U $DB_USER $DB_NAME > $BACKUP_FILE
    echo "✅ Backup saved to $BACKUP_FILE"
    ;;

  restore)
    if [ -z "$2" ]; then
      echo "❌ Please provide backup file: $0 restore <backup-file.sql>"
      exit 1
    fi
    echo "📥 Restoring from: $2"
    podman exec -i $CONTAINER_NAME psql -U $DB_USER $DB_NAME < $2
    echo "✅ Restore complete"
    ;;

  info)
    echo "ℹ️  Development Database Information:"
    echo "   Container: $CONTAINER_NAME"
    echo "   Host: localhost"
    echo "   Port: $DB_PORT"
    echo "   Database: $DB_NAME"
    echo "   User: $DB_USER"
    echo "   Password: $DB_PASSWORD"
    echo "   Connection String: postgresql://$DB_USER:$DB_PASSWORD@localhost:$DB_PORT/$DB_NAME"
    echo ""
    echo "💡 This is separate from Docker Compose (reading-tracker-db on port 5433)"
    ;;

  *)
    echo "📚 Reading Tracker - Local Development Database Manager"
    echo ""
    echo "Usage: $0 {command}"
    echo ""
    echo "Commands:"
    echo "  start     - Start development database"
    echo "  stop      - Stop development database"
    echo "  restart   - Restart development database"
    echo "  remove    - Remove development container (keeps data)"
    echo "  reset     - Remove container and all data (fresh start)"
    echo "  logs      - View container logs"
    echo "  status    - Check if databases are running"
    echo "  psql      - Connect to database with psql"
    echo "  backup    - Create database backup"
    echo "  restore   - Restore from backup file"
    echo "  info      - Show connection information"
    echo ""
    echo "🐳 For Docker Compose (full stack):"
    echo "   podman-compose up -d     # Start all services"
    echo "   podman-compose down      # Stop all services"
    echo ""
    exit 1
    ;;
esac
