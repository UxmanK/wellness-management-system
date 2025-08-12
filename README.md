# Wellness Management System

A simple system for wellness professionals to manage clients and appointments.

## 🚀 Quick Start

```bash
# Start everything with Docker
./start.sh

# Open http://localhost:3001
```

## 🛑 Stop

```bash
docker-compose down
```

## 📚 What It Does

- Manage clients and appointments
- Sync with external wellness platforms
- Modern web interface

## 🔧 Manual Setup (if you prefer)

```bash
# Backend
cd api
bundle install
bundle exec rails server

# Frontend (new terminal)
cd wellness_ui
npm install
npm start
```

---

**That's it!** Just run `./start.sh` and you're ready to go.
