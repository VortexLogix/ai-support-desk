export interface Ticket {
  id: string;
  title: string;
  description: string;
  category: string;
  status: string;
  userId: string;
  aiSuggestedReply: string | null;
  approvedReply: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface LoginResponse {
  token: string;
  role: string;
  username: string;
}
