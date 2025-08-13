import React, { useState, useEffect, useCallback } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { ArrowLeft, Save, Calendar, User } from "lucide-react";
import API_CONFIG from "../config/api";

const AppointmentForm = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const isEditing = Boolean(id);

  const [formData, setFormData] = useState({
    client_id: "",
    time: "",
    status: "Pending",
    notes: "",
  });

  const [isPastAppointment, setIsPastAppointment] = useState(false);

  const [clients, setClients] = useState([]);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  const fetchAppointment = useCallback(async () => {
    try {
      setLoading(true);
      const response = await fetch(API_CONFIG.getAppointmentUrl(id));
      const appointment = await response.json();

      console.log("Fetched appointment:", appointment); // Debug log
      console.log("Appointment time value:", appointment.time); // Debug log
      console.log("Appointment time type:", typeof appointment.time); // Debug log

      // Format the datetime for the input field
      let formattedDateTime = "";
      if (appointment.time) {
        try {
          const appointmentDate = new Date(appointment.time);
          if (!isNaN(appointmentDate.getTime())) {
            formattedDateTime = appointmentDate.toISOString().slice(0, 16);
          } else {
            console.warn("Invalid date value:", appointment.time);
            formattedDateTime = "";
          }
        } catch (error) {
          console.warn("Error parsing date:", error);
          formattedDateTime = "";
        }
      }

      console.log("Formatted datetime:", formattedDateTime); // Debug log

      // Check if appointment is in the past
      const appointmentDate = new Date(appointment.time);
      const now = new Date();
      const isPast = appointmentDate < now;
      setIsPastAppointment(isPast);

      setFormData({
        client_id: appointment.client_id || "",
        time: formattedDateTime,
        status: appointment.status || "Pending",
        notes: appointment.notes || "",
      });

      console.log("Set form data:", {
        client_id: appointment.client_id || "",
        time: formattedDateTime,
        status: appointment.status || "Pending",
        notes: appointment.notes || "",
      }); // Debug log
    } catch (error) {
      console.error("Error fetching appointment:", error);
      alert(`Error fetching appointment: ${error.message}`);
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    fetchClients();
    if (isEditing) {
      fetchAppointment();
    }
  }, [id, isEditing, fetchAppointment]);

  const fetchClients = async () => {
    try {
      const response = await fetch(API_CONFIG.getClientsUrl());
      const data = await response.json();
      setClients(data);
    } catch (error) {
      console.error("Error fetching clients:", error);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);

    try {
      const url = isEditing
        ? API_CONFIG.getAppointmentUrl(id)
        : API_CONFIG.getAppointmentsUrl();
      const method = isEditing ? "PUT" : "POST";

      const response = await fetch(url, {
        method,
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ appointment: formData }),
      });

      if (response.ok) {
        navigate("/appointments");
      } else {
        const error = await response.json();
        if (error.details && Array.isArray(error.details)) {
          alert(`Validation Error:\n${error.details.join("\n")}`);
        } else {
          alert(
            `Error: ${error.error || error.message || "Something went wrong"}`
          );
        }
      }
    } catch (error) {
      console.error("Error saving appointment:", error);
      alert("Error saving appointment. Please try again.");
    } finally {
      setSaving(false);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
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
      <div className="flex items-center space-x-4">
        <button
          onClick={() => navigate("/appointments")}
          className="p-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors duration-200"
        >
          <ArrowLeft size={20} />
        </button>
        <h1 className="text-3xl font-bold text-gray-900">
          {isEditing ? "Edit Appointment" : "New Appointment"}
        </h1>
      </div>

      {isPastAppointment && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <svg
                className="h-5 w-5 text-yellow-400"
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path
                  fillRule="evenodd"
                  d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
                  clipRule="evenodd"
                />
              </svg>
            </div>
            <div className="ml-3">
              <h3 className="text-sm font-medium text-yellow-800">
                Past Appointment
              </h3>
              <div className="mt-2 text-sm text-yellow-700">
                <p>
                  This appointment is in the past. You can only update notes and
                  status to "Completed" or "Cancelled".
                </p>
              </div>
            </div>
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="card">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Appointment Details
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="client_id" className="form-label">
                <User size={16} className="inline mr-2" />
                Client *
              </label>
              <select
                id="client_id"
                name="client_id"
                value={formData.client_id || ""}
                onChange={handleChange}
                required
                disabled={isPastAppointment}
                className={`input-field ${
                  isPastAppointment ? "bg-gray-100 cursor-not-allowed" : ""
                }`}
              >
                <option value="">Select a client</option>
                {clients.map((client) => (
                  <option key={client.id} value={client.id}>
                    {client.name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label htmlFor="time" className="form-label">
                <Calendar size={16} className="inline mr-2" />
                Date & Time *
              </label>
              <input
                type="datetime-local"
                id="time"
                name="time"
                value={formData.time || ""}
                onChange={handleChange}
                required
                disabled={isPastAppointment}
                className={`input-field ${
                  isPastAppointment ? "bg-gray-100 cursor-not-allowed" : ""
                }`}
                min={new Date().toISOString().slice(0, 16)}
              />
            </div>

            <div>
              <label htmlFor="status" className="form-label">
                Status
              </label>
              <select
                id="status"
                name="status"
                value={formData.status || "Pending"}
                onChange={handleChange}
                className="input-field"
              >
                {!isPastAppointment ? (
                  <>
                    <option value="Pending">Pending</option>
                    <option value="Confirmed">Confirmed</option>
                    <option value="Cancelled">Cancelled</option>
                    <option value="Completed">Completed</option>
                  </>
                ) : (
                  <>
                    <option value="Completed">Completed</option>
                    <option value="Cancelled">Cancelled</option>
                  </>
                )}
              </select>
            </div>
          </div>
        </div>

        <div className="card">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Additional Information
          </h2>

          <div>
            <label htmlFor="notes" className="form-label">
              Notes
            </label>
            <textarea
              id="notes"
              name="notes"
              value={formData.notes || ""}
              onChange={handleChange}
              rows={4}
              className="input-field"
              placeholder="Add any additional notes about the appointment..."
            />
          </div>
        </div>

        <div className="flex justify-end space-x-4">
          <button
            type="button"
            onClick={() => navigate("/appointments")}
            className="btn-secondary"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={saving}
            className="btn-success flex items-center space-x-2"
          >
            <Save size={16} />
            <span>
              {saving
                ? "Saving..."
                : isEditing
                ? isPastAppointment
                  ? "Update Notes & Status"
                  : "Update Appointment"
                : "Schedule Appointment"}
            </span>
          </button>
        </div>
      </form>
    </div>
  );
};

export default AppointmentForm;
