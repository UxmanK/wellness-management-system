#!/bin/bash

echo "🚀 Starting Wellness System..."

# Start services
docker-compose up 

echo ""
echo "✅ System started!"
echo "Frontend: http://localhost:3001"
echo "Backend:  http://localhost:3000"
echo ""
echo "Stop with: docker-compose down"
