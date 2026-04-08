import type { LoginResponse, Ticket } from './types';

// Token is held in module memory only — never written to localStorage
let memoryToken: string | null = null;

export const tokenStore = {
  get: () => memoryToken,
  set: (t: string | null) => { memoryToken = t; },
};

async function apiFetch<T>(path: string, init: RequestInit = {}): Promise<T> {
  const token = tokenStore.get();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(init.headers as Record<string, string>),
  };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const res = await fetch(path, { ...init, headers });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(body || res.statusText);
  }
  return res.json() as Promise<T>;
}

export const api = {
  login: (username: string, password: string) =>
    apiFetch<LoginResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ username, password }),
    }),

  createTicket: (title: string, description: string) =>
    apiFetch<Ticket>('/tickets', {
      method: 'POST',
      body: JSON.stringify({ title, description }),
    }),

  getTickets: () => apiFetch<Ticket[]>('/tickets'),

  getTicket: (id: string) => apiFetch<Ticket>(`/tickets/${id}`),

  patchTicket: (id: string, approvedReply: string, resolve: boolean) =>
    apiFetch<Ticket>(`/tickets/${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ approvedReply, resolve }),
    }),
};
