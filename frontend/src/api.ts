export type ApiUser = {
  id: number;
  name: string;
  location_permission?: boolean;
  location?: {
    latitude: number;
    longitude: number;
  } | null;
};

export type ApiProgressEntry = {
  id: number;
  name: string;
  role: 'organizer' | 'participant';
  status: 'pending' | 'submitted';
  responded_at?: string | null;
  invitee_id?: number | null;
};

export type ApiMatch = {
  id: number;
  title: string;
  compatibility: number;
  image: string;
  location: string;
  price: string;
  time: string;
  emoji: string;
  votes: number;
  description: string;
};

export type ApiPreferenceSummary = {
  name?: string;
  available_times?: string[];
  activities?: string[];
  budget_min?: number | null;
  budget_max?: number | null;
  ideas?: string | null;
  role?: 'organizer' | 'participant';
  invitee_id?: number | null;
  submitted_at?: string | null;
};

export type ApiEvent = {
  id: number;
  title: string;
  notes?: string | null;
  status: 'collecting' | 'pending_ai' | 'ready';
  submitted_count?: number;
  participant_count?: number;
  created_at?: string;
  updated_at?: string;
  share_token?: string;
  organizer?: { id: number; name: string };
  progress?: ApiProgressEntry[];
  matches?: ApiMatch[];
  preferences?: ApiPreferenceSummary[];
  ai_generated_at?: string | null;
};

export type ApiInvitation = {
  id: number;
  role: 'organizer' | 'participant';
  status: 'pending' | 'submitted';
  name: string;
  responded_at?: string | null;
  event_id: number;
  invitee_id?: number | null;
  access_token: string;
  event: ApiEvent;
};

export type SessionResponse = {
  user: ApiUser;
  invitations: ApiInvitation[];
  organized_events: ApiEvent[];
  first_time: boolean;
};

export type PreferenceRequest = {
  available_times?: string[];
  activities?: string[];
  budget_min?: number;
  budget_max?: number;
  ideas?: string;
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

export async function updateUser(
  userId: number,
  payload: {
    location_permission: boolean;
    location_latitude?: number;
    location_longitude?: number;
  },
): Promise<{ user: ApiUser }> {
  return request<{ user: ApiUser }>('/api/users', {
    method: 'PUT',
    headers: { 'X-User-Id': String(userId) },
    body: JSON.stringify({ user: payload }),
  });
}

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
): Promise<{ event: ApiEvent; progress: ApiProgressEntry[] }> {
  return request(`/api/events/${eventId}/progress`, {
    headers: { 'X-User-Id': String(userId) },
  });
}

export async function fetchEventResults(
    userId: number,
    eventId: number,
): Promise<{ event: ApiEvent; matches: ApiMatch[] }> {
  return request(`/api/events/${eventId}/results`, {
    headers: { 'X-User-Id': String(userId) },
  });
}

export async function fetchEvents(userId: number): Promise<{ events: ApiEvent[] }> {
  return request('/api/events', {
    headers: { 'X-User-Id': String(userId) },
  });
}

export async function submitPreference(
  invitationToken: string,
  preference: PreferenceRequest,
  userId?: number | null,
): Promise<{ invitation: ApiInvitation }> {
  return request(`/api/preferences?invitation_token=${encodeURIComponent(invitationToken)}`, {
    method: 'POST',
    headers: userId ? { 'X-User-Id': String(userId) } : undefined,
    body: JSON.stringify({ preference }),
  });
}