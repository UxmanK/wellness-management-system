const API_CONFIG = {
  BASE_URL: process.env.REACT_APP_API_URL || 'http://localhost:3000',
  BASE_PATH: process.env.REACT_APP_API_BASE_PATH || '/api/v1',
  
  // Endpoints
  CLIENTS: '/clients',
  APPOINTMENTS: '/appointments',
  
  // Full URLs
  getClientsUrl: () => `${API_CONFIG.BASE_URL}${API_CONFIG.BASE_PATH}${API_CONFIG.CLIENTS}`,
  getClientUrl: (id) => `${API_CONFIG.BASE_URL}${API_CONFIG.BASE_PATH}${API_CONFIG.CLIENTS}/${id}`,
  getAppointmentsUrl: () => `${API_CONFIG.BASE_URL}${API_CONFIG.BASE_PATH}${API_CONFIG.APPOINTMENTS}`,
  getAppointmentUrl: (id) => `${API_CONFIG.BASE_URL}${API_CONFIG.BASE_PATH}${API_CONFIG.APPOINTMENTS}/${id}`,
};

export default API_CONFIG;
