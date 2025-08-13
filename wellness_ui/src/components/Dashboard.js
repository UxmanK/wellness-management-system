import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { Users, Calendar, Clock, TrendingUp, Plus } from "lucide-react";
import { format } from "date-fns";
import API_CONFIG from "../config/api";

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalClients: 0,
    totalAppointments: 0,
    upcomingAppointments: 0,
    recentAppointments: [],
  });

  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      // Fetch clients count
      const clientsResponse = await fetch(API_CONFIG.getClientsUrl());
      const clientsData = await clientsResponse.json();

      // Fetch appointments count and upcoming appointments
      const appointmentsResponse = await fetch(API_CONFIG.getAppointmentsUrl());
      const appointmentsData = await appointmentsResponse.json();

      const now = new Date();
      const upcoming = appointmentsData.filter(
        (apt) => new Date(apt.time) > now
      );

      // Recent appointments: appointments from the last 7 days
      const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      const recent = appointmentsData
        .filter((apt) => {
          const aptDate = new Date(apt.time);
          return aptDate >= sevenDaysAgo && aptDate <= now;
        })
        .sort((a, b) => new Date(b.time) - new Date(a.time))
        .slice(0, 5);

      setStats({
        totalClients: clientsData.length || 0,
        totalAppointments: appointmentsData.length || 0,
        upcomingAppointments: upcoming.length || 0,
        recentAppointments: recent,
      });
    } catch (error) {
      console.error("Error fetching dashboard data:", error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <div className="flex space-x-3">
          <Link
            to="/appointments/new"
            className="btn-success flex items-center space-x-2"
          >
            <Plus size={16} />
            <span>New Appointment</span>
          </Link>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="card">
          <div className="flex items-center">
            <div className="p-3 rounded-full bg-primary-100 text-primary-600">
              <Users size={24} />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Total Clients</p>
              <p className="text-2xl font-semibold text-gray-900">
                {stats.totalClients}
              </p>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center">
            <div className="p-3 rounded-full bg-wellness-100 text-wellness-600">
              <Calendar size={24} />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">
                Total Appointments
              </p>
              <p className="text-2xl font-semibold text-gray-900">
                {stats.totalAppointments}
              </p>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center">
            <div className="p-3 rounded-full bg-yellow-100 text-yellow-600">
              <Clock size={24} />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-600">Upcoming</p>
              <p className="text-2xl font-semibold text-gray-900">
                {stats.upcomingAppointments}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Recent Appointments */}
      <div className="card">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold text-gray-900">
            Recent Appointments
          </h2>
          <Link
            to="/appointments"
            className="text-primary-600 hover:text-primary-700 text-sm font-medium"
          >
            View All
          </Link>
        </div>

        {stats.recentAppointments.length > 0 ? (
          <div className="space-y-3">
            {stats.recentAppointments.map((appointment) => (
              <div
                key={appointment.id}
                className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
              >
                <div className="flex items-center space-x-3">
                  <div className="w-2 h-2 bg-wellness-500 rounded-full"></div>
                  <div>
                    <p className="font-medium text-gray-900">
                      {appointment.client_name}
                    </p>
                    <p className="text-sm text-gray-600">
                      {format(
                        new Date(appointment.time),
                        "MMM dd, yyyy h:mm a"
                      )}
                    </p>
                  </div>
                </div>
                <span className="text-sm text-gray-500">
                  {appointment.status || "No status"}
                </span>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-8 text-gray-500">
            <Calendar size={48} className="mx-auto mb-4 text-gray-300" />
            <p>No appointments in the last 7 days</p>
            {stats.totalAppointments > 0 ? (
              <p className="text-sm text-gray-400 mt-1">
                You have {stats.totalAppointments} total appointments
              </p>
            ) : (
              <Link
                to="/appointments/new"
                className="text-primary-600 hover:text-primary-700 font-medium"
              >
                Schedule your first appointment
              </Link>
            )}
          </div>
        )}
      </div>

      {/* Quick Actions */}
      <div className="card">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">
          Quick Actions
        </h2>
        <div className="grid grid-cols-1 gap-4">
          <Link
            to="/appointments"
            className="p-4 border border-gray-200 rounded-lg hover:border-primary-300 hover:bg-primary-50 transition-colors duration-200"
          >
            <div className="flex items-center space-x-3">
              <Calendar size={20} className="text-primary-600" />
              <div>
                <p className="font-medium text-gray-900">View Schedule</p>
                <p className="text-sm text-gray-600">
                  Check upcoming appointments and schedule new ones
                </p>
              </div>
            </div>
          </Link>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
