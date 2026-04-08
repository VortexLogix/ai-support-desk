import { useParams, Link } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useState, useEffect } from 'react';
import { api } from '../../api/client';

export function AdminTicketDetailPage() {
  const { id } = useParams<{ id: string }>();
  const queryClient = useQueryClient();
  const [reply, setReply] = useState('');

  const { data: ticket, isLoading, isError } = useQuery({
    queryKey: ['admin-ticket', id],
    queryFn: () => api.getTicket(id!),
    enabled: !!id,
  });

  // Pre-fill with AI suggestion when ticket loads
  useEffect(() => {
    if (ticket?.aiSuggestedReply && !reply) {
      setReply(ticket.aiSuggestedReply);
    }
  }, [ticket?.aiSuggestedReply]);

  const mutation = useMutation({
    mutationFn: () => api.patchTicket(id!, reply, true),
    onSuccess: updated => {
      queryClient.setQueryData(['admin-ticket', id], updated);
      queryClient.invalidateQueries({ queryKey: ['admin-tickets'] });
    },
  });

  if (isLoading) return <p className="text-gray-500">Loading…</p>;
  if (isError || !ticket) return <p className="text-red-400">Ticket not found.</p>;

  const isResolved = ticket.status === 'Resolved';

  return (
    <div className="space-y-6 max-w-2xl">
      <Link to="/admin/tickets" className="text-sm text-gray-500 hover:text-white transition-colors">
        ← Back to all tickets
      </Link>

      <div className="bg-gray-900 border border-gray-800 rounded-xl p-6 space-y-4">
        <div className="flex items-start justify-between gap-4">
          <h1 className="text-xl font-semibold">{ticket.title}</h1>
          <span className="shrink-0 text-xs border px-2 py-0.5 rounded-full bg-gray-800 text-gray-400">
            {ticket.status}
          </span>
        </div>
        <p className="text-sm text-gray-400 whitespace-pre-wrap">{ticket.description}</p>
        <p className="text-xs text-gray-600">
          User: {ticket.userId} · Category: {ticket.category} · {new Date(ticket.createdAt).toLocaleString()}
        </p>
      </div>

      <div className="bg-gray-900 border border-gray-800 rounded-xl p-6 space-y-4">
        <p className="text-sm font-medium text-gray-300">Reply to user</p>
        {ticket.aiSuggestedReply && (
          <p className="text-xs text-blue-400 bg-blue-900/20 border border-blue-800 rounded px-3 py-2">
            AI suggestion pre-filled below — review and edit before approving.
          </p>
        )}
        <textarea
          className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none disabled:opacity-50"
          rows={6}
          value={reply}
          onChange={e => setReply(e.target.value)}
          placeholder="Write or edit the reply…"
          disabled={isResolved}
        />
        {mutation.isError && (
          <p className="text-sm text-red-400">{(mutation.error as Error).message}</p>
        )}
        <button
          onClick={() => mutation.mutate()}
          disabled={mutation.isPending || isResolved || !reply.trim()}
          className="bg-green-600 hover:bg-green-700 disabled:opacity-50 rounded-lg px-5 py-2 text-sm font-medium transition-colors"
        >
          {isResolved ? 'Ticket resolved' : mutation.isPending ? 'Approving…' : 'Approve & resolve'}
        </button>
      </div>
    </div>
  );
}
