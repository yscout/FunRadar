import React, { useMemo } from 'react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Avatar, AvatarFallback } from './ui/avatar';
import { Badge } from './ui/badge';
import { Plus, Users, Calendar, Loader2, LogOut } from 'lucide-react';
import type { UserData } from '../App';
import type { ApiEvent, ApiInvitation } from '../api';

interface HomeScreenProps {
  userData: UserData;
  events: ApiEvent[];
  invitations?: ApiInvitation[];
  isNewUser: boolean;
  loadingEvent?: boolean;
  onCreateEvent: () => void;
  onSelectEvent: (event: ApiEvent) => void;
  onRespondToInvite: (invitation: ApiInvitation) => void;
  onLogout?: () => void;
}

export function HomeScreen({
  userData,
  events,
  invitations = [],
  isNewUser,
  loadingEvent,
  onCreateEvent,
  onSelectEvent,
  onRespondToInvite,
  onLogout,
}: HomeScreenProps) {
  const sortedEvents = useMemo(
    () =>
      [...events].sort((a, b) => {
        const timeA = a.updated_at ? new Date(a.updated_at).getTime() : 0;
        const timeB = b.updated_at ? new Date(b.updated_at).getTime() : 0;
        return timeB - timeA;
      }),
    [events],
  );

  const activeEvents = sortedEvents.filter((event) => event.status !== 'completed');
  const completedEvents = sortedEvents.filter((event) => event.status === 'completed');
  const pendingInvitations = useMemo(
    () => invitations.filter((inv) => inv.status === 'pending'),
    [invitations],
  );

  return (
    <div className="h-full min-h-[700px] md:min-h-[800px] bg-white flex flex-col">
      <div className="bg-gradient-to-r from-purple-500 via-pink-500 to-orange-400 p-6 md:p-8 pb-8 md:pb-12 rounded-b-3xl">
        <div className="max-w-6xl mx-auto">
          <div className="flex items-center justify-between mb-6 md:mb-8">
            <div className="flex items-center gap-3 md:gap-4">
              <Avatar className="w-12 h-12 md:w-16 md:h-16 border-2 border-white">
                <AvatarFallback className="bg-gradient-to-br from-purple-400 to-pink-400 text-white md:text-xl">
                  {userData.name.charAt(0).toUpperCase()}
                </AvatarFallback>
              </Avatar>
              <div>
                <div className="text-white/80 text-sm md:text-base">Welcome back,</div>
                <div className="text-white md:text-xl">{userData.name || 'Friend'}</div>
              </div>
            </div>
            {onLogout && (
              <Button
                onClick={onLogout}
                variant="ghost"
                size="sm"
                className="text-white hover:bg-white/20 rounded-xl"
                title="Logout"
              >
                <LogOut className="w-4 h-4 md:w-5 md:h-5" />
              </Button>
            )}
          </div>

          <div className="max-w-2xl mx-auto">
            <Button
              onClick={onCreateEvent}
              className="w-full h-14 md:h-16 bg-white text-purple-600 hover:bg-white/90 rounded-2xl shadow-lg md:text-lg"
              size="lg"
            >
              <Plus className="w-5 h-5 md:w-6 md:h-6 mr-2" />
              Start a New Event
            </Button>
          </div>
        </div>
      </div>

      <div className="flex-1 p-6 md:p-8 overflow-y-auto">
        <div className="max-w-6xl mx-auto">
          {loadingEvent && (
            <div className="flex items-center gap-2 text-purple-600 mb-4 text-sm md:text-base">
              <Loader2 className="w-4 h-4 animate-spin" />
              Loading event details...
            </div>
          )}

          {pendingInvitations.length > 0 && (
            <div className="mb-6 space-y-3">
              {pendingInvitations.map((inv) => (
                <Card key={inv.id} className="p-4 md:p-5 border-2">
                  <div className="flex items-center justify-between gap-4">
                    <div className="min-w-0">
                      <div className="md:text-lg truncate">{inv.event.title}</div>
                      <div className="text-gray-500 text-sm truncate">
                        {inv.event.organizer?.name} invites you
                      </div>
                    </div>
                    <Button className="rounded-xl" onClick={() => onRespondToInvite(inv)}>
                      Respond
                    </Button>
                  </div>
                </Card>
              ))}
            </div>
          )}

          {completedEvents.length > 0 && (
            <div className="mb-8">
              <h3 className="md:text-2xl mb-3">On Your Calendar</h3>
              <div className="space-y-3">
                {completedEvents.map((event) => (
                  <Card key={`completed-${event.id}`} className="p-4 md:p-5 border-2 border-green-200">
                    <div className="flex items-center justify-between gap-4">
                      <div className="flex gap-3 items-start">
                        <div className="text-3xl md:text-4xl">{event.final_match?.emoji || '✅'}</div>
                        <div>
                          <div className="text-xs uppercase tracking-wide text-green-600">Confirmed</div>
                          <div className="md:text-lg font-semibold">
                            {event.final_match?.title || event.title}
                          </div>
                          <div className="text-sm text-gray-500">
                            {event.final_match?.time || event.final_match?.location || 'Ready to go!'}
                          </div>
                        </div>
                      </div>
                      <Badge className="bg-green-100 text-green-700">Together</Badge>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}

          <div className="flex items-center justify-between mb-4 md:mb-6">
            <h3 className="md:text-2xl">Upcoming Events</h3>
            <Badge variant="secondary" className="rounded-full md:text-base md:px-4 md:py-1">
              {activeEvents.length}
            </Badge>
          </div>

          {activeEvents.length > 0 && !isNewUser ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-3 md:gap-4">
              {activeEvents.map((event) => {
                const statusLabel =
                  event.status === 'pending_ai'
                    ? 'AI Matching'
                    : event.status === 'ready'
                    ? 'Rate Matches'
                    : 'Collecting';
                const createdAt = event.created_at ? new Date(event.created_at).toLocaleString() : '';
                const responded = event.submitted_count ?? 0;
                const total = event.participant_count ?? 0;
                const participantTotal = total || responded || 0;

                return (
                  <Card
                    key={event.id}
                    className={`p-4 md:p-5 border-2 hover:border-purple-300 transition-colors cursor-pointer ${
                      loadingEvent ? 'pointer-events-none opacity-70' : ''
                    }`}
                    onClick={() => onSelectEvent(event)}
                  >
                    <div className="flex gap-4">
                      <div className="w-14 h-14 md:w-16 md:h-16 bg-gradient-to-br from-purple-100 to-pink-100 rounded-2xl flex items-
center justify-center text-2xl md:text-3xl flex-shrink-0">
                        🎉
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="mb-1 md:text-lg flex items-center justify-between">
                          <span className="truncate">{event.title}</span>
                          <Badge
                            variant="secondary"
                            className={
                              event.status === 'ready'
                                ? 'bg-green-100 text-green-700'
                                : event.status === 'pending_ai'
                                ? 'bg-blue-100 text-blue-700'
                                : 'bg-orange-100 text-orange-700'
                            }
                          >
                            {statusLabel}
                          </Badge>
                        </div>
                        {createdAt && (
                          <div className="flex items-center gap-3 text-sm md:text-base text-gray-500">
                            <div className="flex items-center gap-1">
                              <Calendar className="w-4 h-4" />
                              {createdAt}
                            </div>
                          </div>
                        )}
                        <div className="flex items-center gap-3 text-sm md:text-base text-gray-500 mt-1">
                          <div className="flex items-center gap-1">
                            <Users className="w-4 h-4" />
                            {responded}/{participantTotal} responded
                          </div>
                        </div>
                      </div>
                    </div>
                  </Card>
                );
              })}
            </div>
          ) : (
            <Card className="p-8 md:p-12 text-center border-2 border-dashed border-gray-200">
              <div className="text-4xl md:text-5xl mb-3 md:mb-4">📅</div>
              <p className="text-gray-500 md:text-lg mb-4 md:mb-6">
                {isNewUser ? 'Start by creating your first event!' : 'No upcoming events yet'}
              </p>
              <Button onClick={onCreateEvent} variant="outline" className="rounded-xl md:h-12 md:text-base">
                Create your first event
              </Button>
            </Card>
          )}
        </div>
      </div>
    </div>
  );
}