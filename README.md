# Wellness Management System

A simple, modern system for wellness professionals to manage clients and appointments. Built with React frontend and Rails backend.

## 🚀 What It Does

- **Manage Clients**: Store client info (name, email, phone)
- **Schedule Appointments**: Create and track wellness sessions
- **Sync Data**: Automatically sync with external wellness platforms
- **Work Anywhere**: Responsive design that works on different devices

## 🏗️ Quick Start

### 1. Get Everything Running

```bash
# Clone and setup
git clone <repository-url>
cd wellness

# Start backend
cd api
bundle install
bundle exec rails server

# Start frontend (new terminal)
cd wellness_ui
npm install
npm start
```

### 2. Open Your Browser

- **Frontend**: http://localhost:3001
- **Backend API**: http://localhost:3000/api/v1/clients

## 📱 What You'll See

- **Dashboard**: Overview of clients and appointments
- **Client List**: Add, edit, and manage client information
- **Appointments**: Schedule and track wellness sessions
- **Sync Status**: Monitor data synchronization health

## 🔧 Tech Stack

- **Frontend**: React with Tailwind CSS
- **Backend**: Ruby on Rails API
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq with Redis

## 📚 API Endpoints

### Clients

```
GET    /api/v1/clients          # List all clients
POST   /api/v1/clients          # Create new client
PUT    /api/v1/clients/:id      # Update client
DELETE /api/v1/clients/:id      # Delete client
```

### Appointments

```
GET    /api/v1/appointments           # List appointments
POST   /api/v1/appointments           # Create appointment
PUT    /api/v1/appointments/:id       # Update appointment
PATCH  /api/v1/appointments/:id/cancel # Cancel appointment
```

### Sync

```
GET    /api/v1/sync/status      # Check sync health
POST   /api/v1/sync/all         # Sync everything
```

## 🧪 Testing

```bash
# Backend tests
cd api
bundle exec rspec

```

## 🚨 Common Issues

**Backend won't start?**

- Check if PostgreSQL is running
- Check if Redis is running
- Look at `log/development.log`

**Frontend can't connect?**

- Make sure backend is running on port 3000
- Check browser console for errors

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📖 More Details

- **Backend Docs**: [api/README.md](api/README.md)
- **Frontend Docs**: [wellness_ui/README.md](wellness_ui/README.md)

---

**Need help?** Create an issue or check the detailed READMEs in each directory!
