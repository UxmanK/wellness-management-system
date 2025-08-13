import React from "react";
import { Link, useLocation } from "react-router-dom";
import { Calendar, Users, Home } from "lucide-react";

const Navbar = () => {
  return (
    <nav className="bg-white shadow-sm border-b border-gray-200">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center">
            <Link to="/" className="flex items-center space-x-2">
              <div className="w-8 h-8 bg-wellness-600 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-lg">W</span>
              </div>
              <span className="text-xl font-semibold text-gray-900">
                Wellness
              </span>
            </Link>
          </div>

          <div className="hidden md:flex items-center space-x-1">
            <NavLink to="/" icon={<Home size={18} />}>
              Dashboard
            </NavLink>
            <NavLink to="/clients" icon={<Users size={18} />}>
              Clients
            </NavLink>
            <NavLink to="/appointments" icon={<Calendar size={18} />}>
              Appointments
            </NavLink>
          </div>
        </div>
      </div>
    </nav>
  );
};

const NavLink = ({ to, icon, children, isActive }) => {
  const location = useLocation();
  const active =
    isActive ||
    (to === "/" ? location.pathname === "/" : location.pathname.startsWith(to));

  return (
    <Link
      to={to}
      className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors duration-200 flex items-center space-x-2 ${
        active
          ? "bg-primary-100 text-primary-700"
          : "text-gray-600 hover:text-gray-900 hover:bg-gray-100"
      }`}
    >
      {icon}
      <span>{children}</span>
    </Link>
  );
};

export default Navbar;
