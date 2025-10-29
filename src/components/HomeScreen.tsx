import React from 'react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Avatar, AvatarFallback } from './ui/avatar';
import { Badge } from './ui/badge';
import { Plus, MapPin, Users, Calendar } from 'lucide-react';
import type { UserData } from '../App';

interface HomeScreenProps {
  userData: UserData;
  onCreateEvent: () => void;
  onNavigate: (screen: string, data?: any) => void;
}

const upcomingEvents = [
  {
    id: 1,
    title: 'Weekend Hangout',
    date: 'Tomorrow, 10:00 AM',
    participants: 4,
    location: 'Various',
    emoji: '🎉',
    status: 'completed', // Shows results
  },
  {
    id: 2,
    title: 'Movie Night',
    date: 'Fri, 7:00 PM',
    participants: 5,
    location: 'Cinema Plaza',
    emoji: '🎬',
    status: 'pending', // Shows pending state
  },
];

export function HomeScreen({ userData, onCreateEvent, onNavigate }: HomeScreenProps) {
  return (
    <div className="h-full min-h-[700px] md:min-h-[800px] bg-white flex flex-col">
      {/* Header */}
      <div
        className="bg-gradient-to-r from-purple-500 via-pink-500 to-orange-400 p-6 md:p-8 pb-8 md:pb-12 rounded-b-3xl">
        <div className="max-w-6xl mx-auto">
          <div className="flex items-center justify-between mb-6 md:mb-8">
            <div className="flex items-center gap-3 md:gap-4">
              <Avatar className="w-12 h-12 md:w-16 md:h-16 border-2 border-white">
                <AvatarFallback className="bg-gradient-to-br from-purple-400 to-pink-400 text-white md:text-xl">
                  {userData.name.charAt(0)}
                </AvatarFallback>
              </Avatar>
              <div>
                <div className="text-white/80 text-sm md:text-base">Welcome back,</div>
                <div className="text-white md:text-xl">{userData.name}</div>
              </div>
            </div>
          </div>

          <div
            className="max-w-2xl mx-auto">
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

      {/* Content */}
      <div className="flex-1 p-6 md:p-8 overflow-y-auto">
        <div className="max-w-6xl mx-auto">
          <div>
            <div className="flex items-center justify-between mb-4 md:mb-6">
              <h3 className="md:text-2xl">Upcoming Events</h3>
              <Badge variant="secondary" className="rounded-full md:text-base md:px-4 md:py-1">
                {upcomingEvents.length}
              </Badge>
            </div>

            {upcomingEvents.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3 md:gap-4">
                {upcomingEvents.map((event, index) => (
                  <div key={event.id}>
                    <Card
                      className="p-4 md:p-5 border-2 hover:border-purple-300 transition-colors cursor-pointer"
                      onClick={() => {
                        if (event.status === 'completed') {
                          onNavigate('eventDetails', event);
                        } else if (event.status === 'pending') {
                          onNavigate('eventPending', event);
                        }
                      }}
                    >
                      <div className="flex gap-4">
                        <div className="w-12 h-12 md:w-14 md:h-14 bg-gradient-to-br from-purple-100 to-pink-100 rounded-2xl flex items-center justify-center text-2xl md:text-3xl flex-shrink-0">
                          {event.emoji}
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="mb-1 md:text-lg flex items-center justify-between">
                            {event.title}
                            {event.status === 'completed' && (
                              <Badge variant="secondary" className="bg-green-100 text-green-700">
                                Complete
                              </Badge>
                            )}
                            {event.status === 'pending' && (
                              <Badge variant="secondary" className="bg-orange-100 text-orange-700">
                                In Progress
                              </Badge>
                            )}
                          </div>
                          <div className="flex items-center gap-3 text-sm md:text-base text-gray-500">
                            <div className="flex items-center gap-1">
                              <Calendar className="w-4 h-4" />
                              {event.date}
                            </div>
                          </div>
                          <div className="flex items-center gap-3 text-sm md:text-base text-gray-500 mt-1">
                            <div className="flex items-center gap-1">
                              <Users className="w-4 h-4" />
                              {event.participants} friends
                            </div>
                            <div className="flex items-center gap-1">
                              <MapPin className="w-4 h-4" />
                              {event.location}
                            </div>
                          </div>
                        </div>
                      </div>
                    </Card>
                  </div>
                ))}
              </div>
            ) : (
              <Card className="p-8 md:p-12 text-center border-2 border-dashed border-gray-200">
                <div className="text-4xl md:text-5xl mb-3 md:mb-4">📅</div>
                <p className="text-gray-500 md:text-lg mb-4 md:mb-6">No upcoming events yet</p>
                <Button
                  onClick={onCreateEvent}
                  variant="outline"
                  className="rounded-xl md:h-12 md:text-base"
                >
                  Create your first event
                </Button>
              </Card>
            )}
          </div>
        </div>
      </div>


    </div>
  );
}