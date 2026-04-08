import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { api } from '../api/client';

const statusColors: Record<string, string> = {
  Open: 'bg-yellow-900/50 text-yellow-300 border-yellow-700',
  Processing: 'bg-blue-900/50 text-blue-300 border-blue-700',
  Resolved: 'bg-green-900/50 text-green-300 border-green-700',
};

export function TicketListPage() {
  const { data: tickets, isLoading, isError } = useQuery({
    queryKey: ['tickets'],
    queryFn: api.getTickets,
  });

  if (isLoading) return <p className="text-gray-500">Loading…</p>;
  if (isError) return <p className="text-red-400">Failed to load tickets.</p>;

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">My Tickets</h1>
        <Link
          to="/tickets/new"
          className="bg-blue-600 hover:bg-blue-700 text-sm px-4 py-2 rounded-lg transition-colors"
        >
          + New ticket
        </Link>
      </div>
      {tickets?.length === 0 && (
        <p className="text-gray-500 text-sm">No tickets yet.</p>
      )}
      <ul className="space-y-3">
        {tickets?.map(ticket => (
          <li key={ticket.id}>
            <Link
              to={`/tickets/${ticket.id}`}
              className="flex items-center justify-between bg-gray-900 border border-gray-800 rounded-xl px-5 py-4 hover:border-gray-600 transition-colors"
            >
              <div>
                <p className="font-medium text-sm">{ticket.title}</p>
                <p className="text-xs text-gray-500 mt-1">
                  {new Date(ticket.createdAt).toLocaleDateString()} · {ticket.category}
                </p>
              </div>
              <span
                className={`text-xs border px-2 py-0.5 rounded-full ${statusColors[ticket.status] ?? 'bg-gray-800 text-gray-400'}`}
              >
                {ticket.status}
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}
