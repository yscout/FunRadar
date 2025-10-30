import React, { useState, useEffect } from 'react';
import { IntroScreen } from './components/IntroScreen';
import { OnboardingScreen } from './components/OnboardingScreen';
import { HomeScreen } from './components/HomeScreen';
import { CreateEventScreen } from './components/CreateEventScreen';
import { FriendsSubmissionScreen } from './components/FriendsSubmissionScreen';
import { GroupMatchResultScreen } from './components/GroupMatchResultScreen';
import { EventDetailsScreen } from './components/EventDetailsScreen';
import { EventPendingScreen } from './components/EventPendingScreen';
import { createSession, createEvent as apiCreateEvent, fetchEventProgress, type ApiEvent } from './api';

type Screen = 'intro' | 'onboarding' | 'home' | 'createEvent' | 'friendsSubmission' | 'groupMatch' | 'eventDetails' | 'eventPending';

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
  ideas: string;
}

function App() {
  // Initialize screen from URL hash or default to 'intro'
  const getScreenFromHash = (): Screen => {
    const hash = window.location.hash.slice(1);
    const validScreens: Screen[] = ['intro', 'onboarding', 'home', 'createEvent', 'friendsSubmission', 'groupMatch'];
    return validScreens.includes(hash as Screen) ? (hash as Screen) : 'intro';
  };

  const [currentScreen, setCurrentScreen] = useState<Screen>(getScreenFromHash());
  const [userData, setUserData] = useState<UserData>({
    name: '',
    interests: [],
    availableTimes: [],
    budget: '',
  });
  const [eventData, setEventData] = useState<EventData>({});
  const [organizerPreference, setOrganizerPreference] = useState<FriendPreference | null>(null);
  const [friendPreferences, setFriendPreferences] = useState<FriendPreference[]>([]);
  const [currentFriendIndex, setCurrentFriendIndex] = useState(0);
  const [invitedFriends, setInvitedFriends] = useState<string[]>([]);
  const [selectedEvent, setSelectedEvent] = useState<any>(null);
  const [userId, setUserId] = useState<number | null>(null);
  const [events, setEvents] = useState<ApiEvent[]>([]);

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

  // Sample data for pending event
  const samplePendingEventData = {
    participants: [
      { name: "Alex (You)", submitted: true },
      { name: "Sam", submitted: true },
      { name: "Jordan", submitted: false },
      { name: "Taylor", submitted: false },
      { name: "Morgan", submitted: true },
    ],
    submittedPreferences: [
      {
        name: "Alex (You)",
        availableTimes: ["Fri 7:00 PM", "Sat 7:00 PM"],
        activities: ["Movie", "Dinner"],
        budgetRange: [12, 45] as [number, number],
        ideas: "Love action movies and pizza",
      },
      {
        name: "Sam",
        availableTimes: ["Fri 7:00 PM", "Fri 8:00 PM"],
        activities: ["Movie", "Dinner"],
        budgetRange: [15, 50] as [number, number],
        ideas: "Comedy or thriller movies",
      },
      {
        name: "Morgan",
        availableTimes: ["Fri 7:00 PM", "Sat 7:00 PM", "Sat 8:00 PM"],
        activities: ["Movie"],
        budgetRange: [10, 35] as [number, number],
        ideas: "Any movie is fine",
      },
    ],
  };

  // Handle browser back/forward buttons
  useEffect(() => {
    const handlePopState = () => {
      const screen = getScreenFromHash();
      setCurrentScreen(screen);
    };

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  const navigateToScreen = (screen: Screen) => {
    setCurrentScreen(screen);
    // Update URL hash without triggering a page reload
    window.history.pushState({ screen }, '', `#${screen}`);
  };

  const handleCreateEventComplete = (data: EventData) => {
    setEventData(data);
    setInvitedFriends(data.invitedFriends || []);
    
    // Store organizer's preference
    const organizerPref: FriendPreference = {
      name: `${userData.name} (You)`,
      availableTimes: data.availableTimes || [],
      activities: data.activityType?.split(', ') || [],
      budgetRange: data.budgetRange || [0, 0],
      ideas: data.notes || '',
    };
    setOrganizerPreference(organizerPref);
    
    // Start friend submission flow
    setCurrentFriendIndex(0);
    setFriendPreferences([]);
    navigateToScreen('friendsSubmission');
  };

  const handleFriendSubmit = (preference: FriendPreference) => {
    const updatedPreferences = [...friendPreferences, preference];
    setFriendPreferences(updatedPreferences);
    
    // Check if there are more friends to collect preferences from
    if (currentFriendIndex < invitedFriends.length - 1) {
      setCurrentFriendIndex(currentFriendIndex + 1);
    } else {
      // All friends submitted, go to group match
      navigateToScreen('groupMatch');
    }
  };

  const getCurrentFriendName = () => {
    return invitedFriends[currentFriendIndex] || 'Friend';
  };

  const getAllPreferences = (): FriendPreference[] => {
    return organizerPreference ? [organizerPreference, ...friendPreferences] : friendPreferences;
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
                  setEvents(res.organized_events || []);
                  navigateToScreen('home');
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
            onCreateEvent={() => navigateToScreen('createEvent')}
            onNavigate={(screen, data) => {
              if (screen === 'eventDetails' || screen === 'eventPending') {
                setSelectedEvent(data);
                navigateToScreen(screen as Screen);
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
              if (!userId) return;
              try {
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
                  invited_friends: data.invitedFriends || [],
                };
                const { event } = await apiCreateEvent(userId, payload);
                setEvents((prev) => [event, ...prev]);
                setSelectedEvent(event);
                // Try to fetch progress for pending screen
                try {
                  const prog = await fetchEventProgress(userId, event.id);
                  const participants = (prog.progress || []).map((p: any) => ({
                    name: p.name,
                    submitted: p.status === 'submitted',
                  }));
                  // Navigate to pending view with real data by reusing selectedEvent payload
                  navigateToScreen('eventPending');
                  setSelectedEvent({ ...event, participants });
                } catch {
                  navigateToScreen('eventPending');
                }
              } catch (e) {
                // Ignore API errors for now and stay on local flow
              }
            }}
            onBack={() => navigateToScreen('home')}
          />
        )}
        {currentScreen === 'friendsSubmission' && (
          <FriendsSubmissionScreen
            eventData={eventData}
            friendName={getCurrentFriendName()}
            organizerName={userData.name}
            onSubmit={handleFriendSubmit}
          />
        )}
        {currentScreen === 'groupMatch' && (
          <GroupMatchResultScreen
            onBackToHome={() => navigateToScreen('home')}
            allPreferences={getAllPreferences()}
          />
        )}
        {currentScreen === 'eventDetails' && (
          <EventDetailsScreen
            eventId={selectedEvent?.id || 1}
            eventTitle={selectedEvent?.title || 'Event'}
            onBack={() => navigateToScreen('home')}
            allPreferences={sampleCompletedEventData.allPreferences}
            matchResults={sampleCompletedEventData.matchResults}
          />
        )}
        {currentScreen === 'eventPending' && (
          <EventPendingScreen
            eventId={selectedEvent?.id || 0}
            eventTitle={selectedEvent?.title || 'New Hangout'}
            organizerName={userData.name}
            participants={selectedEvent?.participants || []}
            submittedPreferences={[]}
            onBack={() => navigateToScreen('home')}
          />
        )}
      </div>
    </div>
  );
}

export default App;