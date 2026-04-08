import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { api } from '../../api/client';

const statusColors: Record<string, string> = {
  Open: 'bg-yellow-900/50 text-yellow-300 border-yellow-700',
  Processing: 'bg-blue-900/50 text-blue-300 border-blue-700',
  Resolved: 'bg-green-900/50 text-green-300 border-green-700',
};

export function AdminTicketListPage() {
  const { data: tickets, isLoading, isError } = useQuery({
    queryKey: ['admin-tickets'],
    queryFn: api.getTickets,
  });

  if (isLoading) return <p className="text-gray-500">Loading…</p>;
  if (isError) return <p className="text-red-400">Failed to load tickets.</p>;

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-semibold">All Tickets</h1>
      {tickets?.length === 0 && <p className="text-gray-500 text-sm">No tickets yet.</p>}
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="text-left text-gray-500 border-b border-gray-800">
              <th className="pb-3 font-medium">Title</th>
              <th className="pb-3 font-medium">User</th>
              <th className="pb-3 font-medium">Category</th>
              <th className="pb-3 font-medium">Status</th>
              <th className="pb-3 font-medium">Date</th>
              <th />
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-800">
            {tickets?.map(ticket => (
              <tr key={ticket.id} className="hover:bg-gray-900/50">
                <td className="py-3 font-medium max-w-xs truncate">{ticket.title}</td>
                <td className="py-3 text-gray-400">{ticket.userId}</td>
                <td className="py-3 text-gray-400">{ticket.category}</td>
                <td className="py-3">
                  <span
                    className={`text-xs border px-2 py-0.5 rounded-full ${statusColors[ticket.status] ?? ''}`}
                  >
                    {ticket.status}
                  </span>
                </td>
                <td className="py-3 text-gray-500 text-xs">
                  {new Date(ticket.createdAt).toLocaleDateString()}
                </td>
                <td className="py-3">
                  <Link
                    to={`/admin/tickets/${ticket.id}`}
                    className="text-blue-400 hover:text-blue-300 transition-colors"
                  >
                    Review →
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
