import React, { useState } from 'react';
import { IntroScreen } from './components/IntroScreen';
import { OnboardingScreen } from './components/OnboardingScreen';
import { HomeScreen } from './components/HomeScreen';
import { CreateEventScreen } from './components/CreateEventScreen';
import { FriendsSubmissionScreen } from './components/FriendsSubmissionScreen';
import { GroupMatchResultScreen } from './components/GroupMatchResultScreen';

type Screen = 'intro' | 'onboarding' | 'home' | 'createEvent' | 'friendsSubmission' | 'groupMatch';

export interface UserData {
  name: string;
  nickname?: string;
  avatar?: string;
  interests?: string[];
  availableTimes?: string[];
  budget?: string;
  locationPermission?: boolean;
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
  const [currentScreen, setCurrentScreen] = useState<Screen>('intro');
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

  const navigateToScreen = (screen: Screen) => {
    setCurrentScreen(screen);
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
              navigateToScreen('home');
            }}
          />
        )}
        {currentScreen === 'home' && (
          <HomeScreen
            userData={userData}
            onCreateEvent={() => navigateToScreen('createEvent')}
            onNavigate={(screen) => navigateToScreen(screen as Screen)}
          />
        )}
        {currentScreen === 'createEvent' && (
          <CreateEventScreen
            onComplete={handleCreateEventComplete}
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
      </div>
    </div>
  );
}

export default App;
