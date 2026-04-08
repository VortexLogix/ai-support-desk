import { useParams, Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { api } from '../api/client';

const statusColors: Record<string, string> = {
  Open: 'bg-yellow-900/50 text-yellow-300 border-yellow-700',
  Processing: 'bg-blue-900/50 text-blue-300 border-blue-700',
  Resolved: 'bg-green-900/50 text-green-300 border-green-700',
};

export function TicketDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data: ticket, isLoading, isError } = useQuery({
    queryKey: ['ticket', id],
    queryFn: () => api.getTicket(id!),
    enabled: !!id,
  });

  if (isLoading) return <p className="text-gray-500">Loading…</p>;
  if (isError || !ticket) return <p className="text-red-400">Ticket not found.</p>;

  return (
    <div className="space-y-6 max-w-2xl">
      <Link to="/tickets" className="text-sm text-gray-500 hover:text-white transition-colors">
        ← Back to tickets
      </Link>
      <div className="bg-gray-900 border border-gray-800 rounded-xl p-6 space-y-4">
        <div className="flex items-start justify-between gap-4">
          <h1 className="text-xl font-semibold">{ticket.title}</h1>
          <span
            className={`shrink-0 text-xs border px-2 py-0.5 rounded-full ${statusColors[ticket.status] ?? ''}`}
          >
            {ticket.status}
          </span>
        </div>
        <p className="text-sm text-gray-400 whitespace-pre-wrap">{ticket.description}</p>
        <p className="text-xs text-gray-600">
          Submitted {new Date(ticket.createdAt).toLocaleString()} · Category: {ticket.category}
        </p>
      </div>

      {ticket.approvedReply && (
        <div className="bg-green-900/20 border border-green-800 rounded-xl p-5 space-y-2">
          <p className="text-sm font-medium text-green-400">Support reply</p>
          <p className="text-sm text-gray-200 whitespace-pre-wrap">{ticket.approvedReply}</p>
        </div>
      )}

      {!ticket.approvedReply && ticket.status === 'Processing' && (
        <p className="text-sm text-gray-500 italic">Our team is reviewing your ticket — hang tight.</p>
      )}
    </div>
  );
}
