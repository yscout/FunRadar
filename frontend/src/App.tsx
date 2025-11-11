import React, { useState, useEffect } from 'react';
import { IntroScreen } from './components/IntroScreen';
import { OnboardingScreen } from './components/OnboardingScreen';
import { HomeScreen } from './components/HomeScreen';
import { CreateEventScreen } from './components/CreateEventScreen';
import { FriendsSubmissionScreen } from './components/FriendsSubmissionScreen';
import { EventDetailsScreen } from './components/EventDetailsScreen';
import { EventPendingScreen } from './components/EventPendingScreen';
import { createSession, createEvent as apiCreateEvent, fetchEventProgress, submitPreference, type ApiEvent, type ApiInvitation } from './api';
import { Toaster } from './components/ui/sonner';
import { toast } from 'sonner';

type Screen =
  | 'intro'
  | 'onboarding'
  | 'home'
  | 'createEvent'
  | 'eventDetails'
  | 'eventPending'
  | 'inviteResponse';

const getScreenFromHash = (): Screen => {
  const hash = window.location.hash.slice(1);
  const validScreens: Screen[] = [
    'intro',
    'onboarding',
    'home',
    'createEvent',
    'eventDetails',
    'eventPending',
    'inviteResponse',
  ];
  return validScreens.includes(hash as Screen) ? (hash as Screen) : 'intro';
};

export interface UserData {
  name: string;
  nickname?: string;
  avatar?: string;
  interests?: string[];
  availableTimes?: string[];
  budget?: string;
  locationPermission?: boolean;
  location?: {
    latitude: number;
    longitude: number;
  };
}

export interface EventData {
  availableTimes?: string[];
  activityType?: string;
  budgetRange?: [number, number];
  notes?: string;
  invitedFriends?: string[];
}

export interface FriendPreference {
  name: string;
  availableTimes: string[];
  activities: string[];
  budgetRange: [number, number];
  ideas?: string;
}

type LoadedEvent = {
  event: ApiEvent;
  progress?: ApiProgressEntry[];
  matches?: ApiMatch[];
  preferences?: FriendPreference[];
};

const mapPreferences = (prefs?: ApiPreferenceSummary[]): FriendPreference[] => {
  return (prefs || []).map((pref) => ({
    name: pref.name || 'Friend',
    availableTimes: pref.available_times || [],
    activities: pref.activities || [],
    budgetRange: [
      pref.budget_min ?? 0,
      pref.budget_max ?? 0,
    ] as [number, number],
    ideas: pref.ideas || '',
  }));
};

function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>(getScreenFromHash());
  const [userData, setUserData] = useState<UserData>({
    name: '',
    interests: [],
    availableTimes: [],
    budget: '',
    locationPermission: false,
  });
  const [userId, setUserId] = useState<number | null>(null);
  const [events, setEvents] = useState<ApiEvent[]>([]);
  const [invitations, setInvitations] = useState<ApiInvitation[]>([]);
  const [isNewUser, setIsNewUser] = useState<boolean>(false);
  const [activeInvitation, setActiveInvitation] = useState<ApiInvitation | null>(null);

  // Sample data for completed event
  const sampleCompletedEventData = {
    matchResults: [
      {
        id: 1,
        title: "Free Jazz Picnic",
        compatibility: 95,
        image: "https://images.unsplash.com/photo-1603543900250-275a638755a9",
        location: "Central Park",
        price: "$15/person",
        time: "Saturday, 3:00 PM",
        emoji: "🎶",
        votes: 4,
        description: "Live jazz band with picnic setup and food trucks",
        groupRatings: [5, 4, 5, 4],
        ratedCount: 4,
      },
      {
        id: 2,
        title: "Rooftop Dinner",
        compatibility: 88,
        image: "https://images.unsplash.com/photo-1742002661612-771125d0c050?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyb29mdG9wJTIwZGlubmVyJTIwY2l0eXxlbnwxfHx8fDE3NjEyMzU0NTh8MA&ixlib=rb-4.1.0&q=80&w=1080",
        location: "Downtown Skybar",
        price: "$45/person",
        time: "Friday, 7:00 PM",
        emoji: "🍽️",
        votes: 4,
        description: "Italian cuisine with city views",
        groupRatings: [4, 3, 5, 4],
        ratedCount: 4,
      },
      {
        id: 3,
        title: "Coffee & Catch Up",
        compatibility: 85,
        image: "https://images.unsplash.com/photo-1721845706930-b3a05aa70baa?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2ZmZWUlMjBzaG9wJTIwZnJpZW5kc3xlbnwxfHx8fDE3NjExNzkzMTZ8MA&ixlib=rb-4.1.0&q=80&w=1080",
        location: "The Brew House",
        price: "$8/person",
        time: "Sunday, 10:00 AM",
        emoji: "☕",
        votes: 4,
        description: "Cozy cafe with board games",
        groupRatings: [4, 5, 3, 4],
        ratedCount: 4,
      },
    ],
    allPreferences: [
      {
        name: "Alex (You)",
        availableTimes: ["Sat 3:00 PM", "Sat 4:00 PM", "Sun 10:00 AM", "Sun 2:00 PM"],
        activities: ["Picnic", "Coffee", "Dinner"],
        budgetRange: [15, 60] as [number, number],
        ideas: "Love outdoor activities and good food",
      },
      {
        name: "Sam",
        availableTimes: ["Sat 2:00 PM", "Sat 3:00 PM", "Sat 7:00 PM"],
        activities: ["Picnic", "Dinner", "Coffee"],
        budgetRange: [20, 70] as [number, number],
        ideas: "Something casual and fun",
      },
      {
        name: "Jordan",
        availableTimes: ["Sat 3:00 PM", "Sat 4:00 PM", "Sun 10:00 AM"],
        activities: ["Coffee", "Picnic", "Dinner"],
        budgetRange: [10, 50] as [number, number],
        ideas: "Prefer something affordable",
      },
      {
        name: "Taylor",
        availableTimes: ["Sat 2:00 PM", "Sat 7:00 PM", "Sun 2:00 PM"],
        activities: ["Dinner", "Picnic"],
        budgetRange: [25, 80] as [number, number],
        ideas: "Really into food experiences",
      },
    ],
  };

  useEffect(() => {
    const storedName = localStorage.getItem('funradar_name');
    if (storedName && !userId) {
      createSession(storedName)
        .then((res) => handleSessionResponse(res))
        .catch(() => {
          localStorage.removeItem('funradar_name');
          localStorage.removeItem('funradar_user_id');
        });
    }
    const handlePopState = () => {
      setCurrentScreen(getScreenFromHash());
    };
    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  const navigateToScreen = (screen: Screen) => {
    setCurrentScreen(screen);
    window.history.pushState({ screen }, '', `#${screen}`);
  };

  const handleCreateEventComplete = (data: EventData) => {
    setEventData(data);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-100 via-sky-100 to-peach-100 flex items-center justify-center p-4 md:p-8">
      <div className="w-full max-w-md md:max-w-5xl bg-white rounded-3xl shadow-2xl overflow-hidden min-h-[700px] md:min-h-[800px] relative">
        {currentScreen === 'intro' && (
          <IntroScreen onGetStarted={() => navigateToScreen('onboarding')} />
        )}
        {currentScreen === 'onboarding' && (
          <OnboardingScreen
            onComplete={(data) => {
              setUserData(data);
              createSession(data.name)
                .then((res) => {
                  setUserId(res.user.id);
                  localStorage.setItem('funradar_name', res.user.name);
                  localStorage.setItem('funradar_user_id', String(res.user.id));
                  setEvents(res.organized_events || []);
                  setInvitations(res.invitations || []);
                  setIsNewUser(!!res.first_time);
                  const pending = (res.invitations || []).find((i) => i.status === 'pending');
                  if (pending) {
                    setActiveInvitation(pending);
                    navigateToScreen('inviteResponse');
                  } else {
                    navigateToScreen('home');
                  }
                })
                .catch(() => {
                  navigateToScreen('home');
                });
            }}
          />
        )}
        {currentScreen === 'home' && (
          <HomeScreen
            userData={userData}
            events={events}
            invitations={invitations}
            isNewUser={isNewUser}
            onCreateEvent={() => navigateToScreen('createEvent')}
            onNavigate={(screen, data) => {
              if (screen === 'eventDetails' || screen === 'eventPending') {
                setSelectedEvent(data);
                navigateToScreen(screen as Screen);
              } else if (screen === 'inviteResponse') {
                setActiveInvitation(data);
                navigateToScreen('inviteResponse');
              } else {
                navigateToScreen(screen as Screen);
              }
            }}
          />
        )}
        {currentScreen === 'createEvent' && (
          <CreateEventScreen
            onComplete={async (data) => {
              handleCreateEventComplete(data);
              try {
                if (userId) {
                  const title = data.activityType ? `${data.activityType} Hangout` : 'New Hangout';
                  const payload = {
                    title,
                    notes: data.notes,
                    organizer_preferences: {
                      available_times: data.availableTimes || [],
                      activities: data.activityType ? data.activityType.split(', ').filter(Boolean) : [],
                      budget_min: data.budgetRange ? data.budgetRange[0] : undefined,
                      budget_max: data.budgetRange ? data.budgetRange[1] : undefined,
                      ideas: data.notes || '',
                    },
                    // Always send names via invites[] so backend matches by name on login
                    invites: (data.invitedFriends || []).map((n) => ({ name: n })),
                  };
                  const { event } = await apiCreateEvent(userId, payload);
                  setEvents((prev) => [event, ...prev]);
                }
                toast.success('Invites sent!');
              } catch (e) {
                toast.success('Invites sent!');
              } finally {
                navigateToScreen('home');
              }
            }}
            onBack={() => navigateToScreen('home')}
          />
        )}

        {currentScreen === 'inviteResponse' && activeInvitation && activeInvitation.event && (
          <FriendsSubmissionScreen
            eventTitle={activeInvitation.event.title}
            eventData={{}}
            friendName={userData.name}
            organizerName={activeInvitation.event.organizer?.name || 'Organizer'}
            onSubmit={(pref) => handleInvitationSubmit(pref, activeInvitation)}
          />
        )}

        {currentScreen === 'eventDetails' && loadedEvent && (
          <EventDetailsScreen
            event={loadedEvent.event}
            matchResults={loadedEvent.matches || []}
            preferences={loadedEvent.preferences || []}
            onBack={() => navigateToScreen('home')}
          />
        )}

        {currentScreen === 'eventPending' && loadedEvent && (
          <EventPendingScreen
            eventTitle={loadedEvent.event.title}
            organizerName={loadedEvent.event.organizer?.name || userData.name}
            progress={loadedEvent.progress || loadedEvent.event.progress || []}
            onBack={() => navigateToScreen('home')}
          />
        )}
      </div>
      <Toaster position="top-center" richColors />
    </div>
  );
}

export default App;