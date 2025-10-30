export type ApiUser = {
    id: number;
    name: string;
  };
  
  export type ApiEvent = {
    id: number;
    title: string;
    status: 'collecting' | 'pending_ai' | 'ready';
    submitted_count?: number;
    participant_count?: number;
    created_at?: string;
    updated_at?: string;
  };
  
  export type SessionResponse = {
    user: ApiUser;
    invitations: any[];
    organized_events: ApiEvent[];
  };
  
  async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
    const res = await fetch(path, {
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {}),
      },
      ...options,
    });
    if (!res.ok) {
      const text = await res.text().catch(() => '');
      throw new Error(`Request failed ${res.status}: ${text || res.statusText}`);
    }
    return (await res.json()) as T;
  }
  
  export async function createSession(name: string): Promise<SessionResponse> {
    return request<SessionResponse>('/api/session', {
      method: 'POST',
      body: JSON.stringify({ name }),
    });
  }
  
// listEvents removed (unused)
  
  export type CreateEventRequest = {
    title?: string;
    notes?: string;
    organizer_preferences?: {
      available_times?: string[];
      activities?: string[];
      budget_min?: number;
      budget_max?: number;
      ideas?: string;
    };
    invited_friends?: string[];
    invites?: { name: string; email?: string }[];
  };
  
  export async function createEvent(
    userId: number,
    payload: CreateEventRequest,
  ): Promise<{ event: ApiEvent }> {
    return request<{ event: ApiEvent }>('/api/events', {
      method: 'POST',
      headers: { 'X-User-Id': String(userId) },
      body: JSON.stringify({ event: payload }),
    });
  }
  
  export async function fetchEventProgress(
    userId: number,
    eventId: number,
  ): Promise<{ event: ApiEvent; progress: Array<{ id: number; name: string; role: string; status: string }> }> {
    return request(`/api/events/${eventId}/progress`, {
      headers: { 'X-User-Id': String(userId) },
    });
  }
  