import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { api } from '../api/client';

export function NewTicketPage() {
  const navigate = useNavigate();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');

  const mutation = useMutation({
    mutationFn: () => api.createTicket(title, description),
    onSuccess: ticket => navigate(`/tickets/${ticket.id}`),
  });

  return (
    <div className="max-w-2xl space-y-6">
      <h1 className="text-xl font-semibold">Submit a support ticket</h1>
      <form
        onSubmit={e => { e.preventDefault(); mutation.mutate(); }}
        className="space-y-4 bg-gray-900 border border-gray-800 rounded-xl p-6"
      >
        {mutation.isError && (
          <p className="text-sm text-red-400 bg-red-900/30 border border-red-800 rounded px-3 py-2">
            {(mutation.error as Error).message}
          </p>
        )}
        <div className="space-y-1">
          <label className="text-sm text-gray-400">Title</label>
          <input
            className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            value={title}
            onChange={e => setTitle(e.target.value)}
            placeholder="Brief summary of your issue"
            required
            maxLength={200}
          />
        </div>
        <div className="space-y-1">
          <label className="text-sm text-gray-400">Description</label>
          <textarea
            className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
            value={description}
            onChange={e => setDescription(e.target.value)}
            placeholder="Describe your issue in detail…"
            rows={6}
            required
            maxLength={4000}
          />
        </div>
        <button
          type="submit"
          disabled={mutation.isPending}
          className="bg-blue-600 hover:bg-blue-700 disabled:opacity-50 rounded-lg px-5 py-2 text-sm font-medium transition-colors"
        >
          {mutation.isPending ? 'Submitting…' : 'Submit ticket'}
        </button>
      </form>
    </div>
  );
}
