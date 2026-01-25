#!/bin/bash
# Helper script for managing PostgreSQL with Podman

CONTAINER_NAME="reading-tracker-db"
DB_USER="reading_user"
DB_NAME="reading_tracker"
DB_PASSWORD="reading_pass"

case "$1" in
  start)
    echo "🚀 Starting PostgreSQL..."
    podman run -d \
      --name $CONTAINER_NAME \
      -e POSTGRES_USER=$DB_USER \
      -e POSTGRES_PASSWORD=$DB_PASSWORD \
      -e POSTGRES_DB=$DB_NAME \
      -p 5432:5432 \
      -v ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql:Z \
      postgres:16-alpine
    echo "✅ PostgreSQL started on port 5432"
    ;;
    
  stop)
    echo "🛑 Stopping PostgreSQL..."
    podman stop $CONTAINER_NAME
    echo "✅ PostgreSQL stopped"
    ;;
    
  restart)
    echo "🔄 Restarting PostgreSQL..."
    podman restart $CONTAINER_NAME
    echo "✅ PostgreSQL restarted"
    ;;
    
  remove)
    echo "🗑️  Removing PostgreSQL container..."
    podman stop $CONTAINER_NAME 2>/dev/null
    podman rm $CONTAINER_NAME
    echo "✅ Container removed"
    ;;
    
  reset)
    echo "⚠️  Resetting database (all data will be lost)..."
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
      podman stop $CONTAINER_NAME 2>/dev/null
      podman rm -v $CONTAINER_NAME 2>/dev/null
      $0 start
      echo "✅ Database reset complete"
    else
      echo "❌ Reset cancelled"
    fi
    ;;
    
  logs)
    echo "📋 Showing logs (Ctrl+C to exit)..."
    podman logs -f $CONTAINER_NAME
    ;;
    
  status)
    if podman ps | grep -q $CONTAINER_NAME; then
      echo "✅ PostgreSQL is running"
      podman ps | grep $CONTAINER_NAME
    else
      echo "❌ PostgreSQL is not running"
    fi
    ;;
    
  psql)
    echo "🔌 Connecting to database..."
    podman exec -it $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME
    ;;
    
  backup)
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
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
    echo "ℹ️  Database Information:"
    echo "   Host: localhost"
    echo "   Port: 5432"
    echo "   Database: $DB_NAME"
    echo "   User: $DB_USER"
    echo "   Password: $DB_PASSWORD"
    echo "   Connection String: postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
    ;;
    
  *)
    echo "📚 Reading Tracker - PostgreSQL Manager"
    echo ""
    echo "Usage: $0 {command}"
    echo ""
    echo "Commands:"
    echo "  start     - Start PostgreSQL container"
    echo "  stop      - Stop PostgreSQL container"
    echo "  restart   - Restart PostgreSQL container"
    echo "  remove    - Remove PostgreSQL container (keeps data)"
    echo "  reset     - Remove container and all data (fresh start)"
    echo "  logs      - View container logs"
    echo "  status    - Check if PostgreSQL is running"
    echo "  psql      - Connect to database with psql"
    echo "  backup    - Create database backup"
    echo "  restore   - Restore from backup file"
    echo "  info      - Show connection information"
    echo ""
    exit 1
    ;;
esac
