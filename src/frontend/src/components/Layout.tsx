import { Link, Outlet } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';

export function Layout() {
  const { user, logout } = useAuth();

  return (
    <div className="min-h-screen bg-gray-950 text-gray-100">
      <header className="border-b border-gray-800 px-6 py-4 flex items-center justify-between">
        <span className="text-lg font-semibold tracking-tight">AI Support Desk</span>
        {user && (
          <div className="flex items-center gap-6 text-sm">
            {user.role === 'admin' ? (
              <Link className="text-gray-400 hover:text-white transition-colors" to="/admin/tickets">
                Admin Dashboard
              </Link>
            ) : (
              <>
                <Link className="text-gray-400 hover:text-white transition-colors" to="/tickets">
                  My Tickets
                </Link>
                <Link className="text-gray-400 hover:text-white transition-colors" to="/tickets/new">
                  New Ticket
                </Link>
              </>
            )}
            <button
              onClick={logout}
              className="text-gray-500 hover:text-red-400 transition-colors"
            >
              Sign out ({user.username})
            </button>
          </div>
        )}
      </header>
      <main className="max-w-4xl mx-auto px-6 py-8">
        <Outlet />
      </main>
    </div>
  );
}
