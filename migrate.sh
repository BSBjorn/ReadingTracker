#!/bin/bash
# Migration Helper Script

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📚 Reading Tracker - Migration Helper${NC}"
echo ""

# Check if migration file is provided
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: $0 <migration-file.sql> [environment]${NC}"
    echo ""
    echo "Environments:"
    echo "  dev     - Development database (reading-tracker-db-dev)"
    echo "  docker  - Docker Compose database (reading-tracker-db)"
    echo "  both    - Both databases (default if not specified)"
    echo ""
    echo "Examples:"
    echo "  $0 migrations/add_reading_dates.sql"
    echo "  $0 migrations/add_reading_dates.sql dev"
    echo "  $0 migrations/add_reading_dates.sql docker"
    echo "  $0 migrations/add_reading_dates.sql both"
    echo ""
    exit 1
fi

MIGRATION_FILE="$1"
ENV="${2:-both}"

# Check if file exists
if [ ! -f "$MIGRATION_FILE" ]; then
    echo -e "${RED}❌ Error: File not found: $MIGRATION_FILE${NC}"
    exit 1
fi

echo -e "📄 Migration file: ${GREEN}$MIGRATION_FILE${NC}"
echo ""

# Function to run migration
run_migration() {
    local container=$1
    local name=$2
    
    if podman ps | grep -q "$container"; then
        echo -e "${BLUE}🔄 Running migration on $name...${NC}"
        if podman exec -i "$container" psql -U reading_user -d reading_tracker < "$MIGRATION_FILE"; then
            echo -e "${GREEN}✅ $name migration complete${NC}"
            return 0
        else
            echo -e "${RED}❌ $name migration failed${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  $name database not running${NC}"
        return 2
    fi
}

# Run migrations based on environment
case "$ENV" in
    dev)
        run_migration "reading-tracker-db-dev" "Development"
        ;;
    docker)
        run_migration "reading-tracker-db" "Docker Compose"
        ;;
    both)
        run_migration "reading-tracker-db-dev" "Development"
        echo ""
        run_migration "reading-tracker-db" "Docker Compose"
        ;;
    *)
        echo -e "${RED}❌ Invalid environment: $ENV${NC}"
        echo "Valid options: dev, docker, both"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Migration process complete!${NC}"
