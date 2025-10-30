import React, { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { MapPin, ChevronRight } from 'lucide-react';
import type { UserData } from '../App';

interface OnboardingScreenProps {
  onComplete: (data: UserData) => void;
}

export function OnboardingScreen({ onComplete }: OnboardingScreenProps) {
  const [step, setStep] = useState(1);
  const [name, setName] = useState('');
  const [isGettingLocation, setIsGettingLocation] = useState(false);

  const handleNameContinue = () => {
    if (name.trim()) {
      setStep(2);
    }
  };

  const handleLocationPermission = async (granted: boolean) => {
    if (!granted) {
      // User chose "Not Now"
      onComplete({
        name,
        locationPermission: false,
      });
      return;
    }

    // Try to get actual location
    if (!navigator.geolocation) {
      // Browser doesn't support geolocation
      onComplete({
        name,
        locationPermission: false,
      });
      return;
    }

    setIsGettingLocation(true);

    try {
      const position = await new Promise<GeolocationPosition>((resolve, reject) => {
        navigator.geolocation.getCurrentPosition(
          resolve,
          reject,
          {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 0,
          }
        );
      });

      // Successfully got location
      onComplete({
        name,
        locationPermission: true,
        location: {
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
        },
      });
    } catch (error) {
      // User denied permission or location unavailable
      console.log('Location error:', error);
      onComplete({
        name,
        locationPermission: false,
      });
    } finally {
      setIsGettingLocation(false);
    }
  };

  return (
    <div className="h-full min-h-[700px] md:min-h-[800px] bg-gradient-to-b from-purple-50 to-white flex flex-col">
      {/* Progress bar */}
      <div className="p-6 md:p-8 pb-2">
        <div className="flex gap-2 max-w-md mx-auto">
          {[1, 2].map((s) => (
            <div
              key={s}
              className={`h-1 flex-1 rounded-full transition-all ${
                s <= step ? 'bg-purple-500' : 'bg-gray-200'
              }`}
            />
          ))}
        </div>
      </div>

      <div className="flex-1 px-6 md:px-8 py-8 md:py-12 overflow-y-auto flex items-center justify-center">
        {step === 1 && (
            <div key="step1"
              className="w-full max-w-md md:max-w-lg">
              <div className="text-center mb-8 md:mb-12">
                <h2 className="mb-3 md:text-4xl">What's your name?</h2>
                <p className="text-gray-600 md:text-lg">Let's get to know you</p>
              </div>

              <div className="space-y-6">
                <div>
                  <Label htmlFor="name" className="sr-only">Full Name</Label>
                  <Input
                    id="name"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="Enter your full name"
                    className="h-14 md:h-16 text-center text-lg md:text-xl"
                    autoFocus
                    onKeyPress={(e) => {
                      if (e.key === 'Enter') {
                        handleNameContinue();
                      }
                    }}
                  />
                </div>
              </div>
            </div>
          )}

          {step === 2 && (
            <div
              className="w-full max-w-md md:max-w-lg">
              <div className="text-center mb-8 md:mb-12">
                <div
                  className="inline-flex items-center justify-center w-20 h-20 md:w-28 md:h-28 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full mb-6 md:mb-8">
                  <MapPin className="w-10 h-10 md:w-14 md:h-14 text-white" />
                </div>
                
                <h2 className="mb-3 md:text-4xl">Enable Location</h2>
                <p className="text-gray-600 md:text-lg">
                  Allow Funradar to use your location to suggest nearby hangouts
                </p>
              </div>

              <div className="space-y-3 md:space-y-4">
                <Button
                  onClick={() => handleLocationPermission(true)}
                  disabled={isGettingLocation}
                  className="w-full h-14 md:h-16 rounded-2xl bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 md:text-lg disabled:opacity-50"
                  size="lg"
                >
                  {isGettingLocation ? 'Getting location...' : 'Allow Access'}
                </Button>
                
                <Button
                  onClick={() => handleLocationPermission(false)}
                  disabled={isGettingLocation}
                  variant="outline"
                  className="w-full h-14 md:h-16 rounded-2xl md:text-lg disabled:opacity-50"
                  size="lg"
                >
                  Not Now
                </Button>
              </div>

              <p className="text-center text-sm md:text-base text-gray-500 mt-6 md:mt-8">
                You can change this later in settings
              </p>
            </div>
          )}
        </div>

      {step === 1 && (
        <div className="p-6 md:p-8 pt-2">
          <div className="max-w-md md:max-w-lg mx-auto">
            <Button
              onClick={handleNameContinue}
              disabled={!name.trim()}
              className="w-full h-14 md:h-16 rounded-2xl bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 md:text-lg"
              size="lg"
            >
              Continue
              <ChevronRight className="ml-2 w-5 h-5" />
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}