# Wellness UI Frontend

A modern React-based frontend for the Wellness Management System.

## Features

- **Dashboard**: Overview of clients and appointments
- **Client Management**: Add, edit, and manage client information
- **Appointment Scheduling**: Create and manage appointments
- **Responsive Design**: Works on desktop and mobile devices
- **Modern UI**: Built with Tailwind CSS and Lucide React icons

## Quick Start

### Using Docker (Recommended)

```bash
# Start the entire system
cd ..
./start.sh

# Frontend will be available at http://localhost:3001
```

### Manual Development Setup

```bash
# Install dependencies
npm install

# Start development server
npm start

# The app will open at http://localhost:3000
```

## Available Scripts

- `npm start` - Start development server
- `npm run build` - Build for production
- `npm test` - Run tests
- `npm run eject` - Eject from Create React App

## Project Structure

```
src/
├── components/          # React components
│   ├── Dashboard.js    # Main dashboard view
│   ├── Clients.js      # Client list and management
│   ├── Appointments.js # Appointment list and management
│   ├── AppointmentForm.js # Add/edit appointment form
│   └── Navbar.js       # Navigation component
├── App.js              # Main app component with routing
├── index.js            # App entry point
└── index.css           # Global styles with Tailwind CSS
```

## API Integration

The frontend integrates with the Rails API backend:

- **Base URL**: `http://localhost:3000` (configured via proxy)
- **Endpoints**:
  - `GET /api/v1/clients` - List all clients
  - `POST /api/v1/clients` - Create new client
  - `PUT /api/v1/clients/:id` - Update client
  - `DELETE /api/v1/clients/:id` - Delete client
  - `GET /api/v1/appointments` - List all appointments
  - `POST /api/v1/appointments` - Create new appointment
  - `PUT /api/v1/appointments/:id` - Update appointment
  - `DELETE /api/v1/appointments/:id` - Delete appointment

## Styling

- **Tailwind CSS**: Utility-first CSS framework
- **Custom Components**: Reusable button, form, and card styles
- **Responsive Design**: Mobile-first approach
- **Color Scheme**: Primary blues and wellness greens

## Dependencies

- **React 18**: Modern React with hooks
- **React Router**: Client-side routing
- **Tailwind CSS**: Utility-first CSS framework
- **Lucide React**: Beautiful, customizable icons
- **date-fns**: Date utility library
- **Axios**: HTTP client (for future API calls)

## Development

### Adding New Components

1. Create a new component file in `src/components/`
2. Import and add to `App.js` routing if needed
3. Use existing CSS classes for consistent styling

### Styling Guidelines

- Use Tailwind CSS utility classes when possible
- Create custom component classes in `index.css` for repeated patterns
- Follow the existing color scheme (primary blues, wellness greens)
- Ensure responsive design for mobile devices

### API Integration

- Use the existing fetch patterns for API calls
- Handle loading and error states consistently
- Use the proxy configuration for local development

## Building for Production

```bash
npm run build
```

The build output will be in the `build/` directory, optimized for production deployment.

## Docker

- **Development**: `Dockerfile.dev` for hot reloading
- **Production**: `Dockerfile` with nginx for optimized serving
- **Nginx Config**: Configured for SPA routing and performance
