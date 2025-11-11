import React, { useState, useEffect, useCallback } from 'react';
import { IntroScreen } from './components/IntroScreen';
import { OnboardingScreen } from './components/OnboardingScreen';
import { HomeScreen } from './components/HomeScreen';
import { CreateEventScreen } from './components/CreateEventScreen';
import { FriendsSubmissionScreen } from './components/FriendsSubmissionScreen';
import { EventDetailsScreen } from './components/EventDetailsScreen';
import { EventPendingScreen } from './components/EventPendingScreen';
import {
  createSession,
  createEvent as apiCreateEvent,
  fetchEventProgress,
  fetchEventResults,
  fetchEvents,
  submitPreference,
  updateUser,
  type ApiEvent,
  type ApiInvitation,
  type ApiMatch,
  type ApiProgressEntry,
  type ApiPreferenceSummary,
  type SessionResponse,
} from './api';
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
  const [loadedEvent, setLoadedEvent] = useState<LoadedEvent | null>(null);
  const [isEventLoading, setIsEventLoading] = useState(false);

  const navigateToScreen = useCallback((screen: Screen) => {
    setCurrentScreen(screen);
    window.history.pushState({ screen }, '', `#${screen}`);
  }, []);

  const handlePostLoginNavigation = useCallback(
    (invites: ApiInvitation[] = []) => {
      const pending = invites.find((inv) => inv.status === 'pending');
      if (pending) {
        setActiveInvitation(pending);
        navigateToScreen('inviteResponse');
      } else {
        navigateToScreen('home');
      }
    },
    [navigateToScreen],
  );

  const refreshEvents = useCallback(
    async (id?: number) => {
      const targetId = id ?? userId;
      if (!targetId) return;
      try {
        const { events: mergedEvents } = await fetchEvents(targetId);
        setEvents(mergedEvents);
      } catch (error) {
        console.warn('Unable to refresh events', error);
      }
    },
    [userId],
  );

  const bootstrapSession = useCallback(
    (res: SessionResponse) => {
      setUserId(res.user.id);
      setUserData((prev) => ({
        ...prev,
        name: res.user.name,
        locationPermission:
          typeof res.user.location_permission === 'boolean'
            ? res.user.location_permission
            : prev.locationPermission,
        location: res.user.location || prev.location,
      }));
      setEvents(res.organized_events || []);
      setInvitations(res.invitations || []);
      setIsNewUser(!!res.first_time);
      localStorage.setItem('funradar_name', res.user.name);
      localStorage.setItem('funradar_user_id', String(res.user.id));
    },
    [],
  );

  const persistLocation = useCallback(async (id: number, data: UserData) => {
    if (typeof data.locationPermission === 'undefined') return;
    try {
      await updateUser(id, {
        location_permission: data.locationPermission,
        location_latitude: data.location?.latitude,
        location_longitude: data.location?.longitude,
      });
    } catch (error) {
      console.warn('Unable to update user location', error);
    }
  }, []);

  const handleSessionResponse = useCallback(
    async (res: SessionResponse, onboardingPayload?: UserData) => {
      bootstrapSession(res);
      if (onboardingPayload) {
        await persistLocation(res.user.id, onboardingPayload);
      }
      await refreshEvents(res.user.id);
      handlePostLoginNavigation(res.invitations || []);
    },
    [bootstrapSession, handlePostLoginNavigation, persistLocation, refreshEvents],
  );

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
  }, [userId, handleSessionResponse]);

  useEffect(() => {
    const handlePopState = () => {
      setCurrentScreen(getScreenFromHash());
    };
    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  const handleOnboardingComplete = (data: UserData) => {
    setUserData(data);
    createSession(data.name)
      .then((res) => handleSessionResponse(res, data))
      .catch(() => {
        navigateToScreen('home');
      });
  };

  const handleCreateEvent = async (data: EventData) => {
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
          invites: (data.invitedFriends || []).map((name) => ({ name })),
        };
        const { event } = await apiCreateEvent(userId, payload);
        setEvents((prev) => [event, ...prev]);
        await refreshEvents();
      }
      toast.success('Invites sent!');
    } catch (error) {
      toast.error('Unable to create event');
    } finally {
      navigateToScreen('home');
    }
  };

  const openEvent = useCallback(
    async (event: ApiEvent) => {
      if (!userId) return;
      setIsEventLoading(true);
      try {
        if (event.status === 'ready') {
          const { event: eventPayload, matches } = await fetchEventResults(userId, event.id);
          setLoadedEvent({
            event: eventPayload,
            matches,
            preferences: mapPreferences(eventPayload.preferences),
          });
          navigateToScreen('eventDetails');
        } else {
          const { event: eventPayload, progress } = await fetchEventProgress(userId, event.id);
          setLoadedEvent({
            event: eventPayload,
            progress,
            preferences: mapPreferences(eventPayload.preferences),
          });
          navigateToScreen('eventPending');
        }
      } catch (error) {
        toast.error('Unable to load event');
      } finally {
        setIsEventLoading(false);
      }
    },
    [navigateToScreen, userId],
  );

  const handleInvitationSubmit = async (
    pref: FriendPreference,
    invitation: ApiInvitation,
  ): Promise<void> => {
    try {
      await submitPreference(
        invitation.access_token,
        {
          available_times: pref.availableTimes,
          activities: pref.activities,
          budget_min: pref.budgetRange?.[0],
          budget_max: pref.budgetRange?.[1],
          ideas: pref.ideas,
        },
        userId,
      );
      toast.success('Preferences submitted!');
      setInvitations((prev) => prev.filter((inv) => inv.id !== invitation.id));
      setActiveInvitation(null);
      await refreshEvents();
      navigateToScreen('home');
    } catch (error) {
      toast.error('Unable to submit preferences');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-100 via-sky-100 to-peach-100 flex items-center justify-center p-4 md:p-8">
      <div className="w-full max-w-md md:max-w-5xl bg-white rounded-3xl shadow-2xl overflow-hidden min-h-[700px] md:min-h-[800px]
relative">
        {currentScreen === 'intro' && (
          <IntroScreen onGetStarted={() => navigateToScreen('onboarding')} />
        )}

        {currentScreen === 'onboarding' && (
          <OnboardingScreen onComplete={handleOnboardingComplete} />
        )}

        {currentScreen === 'home' && (
          <HomeScreen
            userData={userData}
            events={events}
            invitations={invitations}
            isNewUser={isNewUser}
            loadingEvent={isEventLoading}
            onCreateEvent={() => navigateToScreen('createEvent')}
            onSelectEvent={openEvent}
            onRespondToInvite={(invitation) => {
              setActiveInvitation(invitation);
              navigateToScreen('inviteResponse');
            }}
          />
        )}

        {currentScreen === 'createEvent' && (
          <CreateEventScreen
            onComplete={handleCreateEvent}
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