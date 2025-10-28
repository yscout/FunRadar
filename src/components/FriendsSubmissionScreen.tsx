import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { Slider } from './ui/slider';
import { Progress } from './ui/progress';
import { Label } from './ui/label';
import { Textarea } from './ui/textarea';
import { Check, X, Utensils, Film, Coffee, Music, TreePine, Palette, Gamepad2, Dumbbell, ShoppingBag, Book, Plane, Waves, Mountain, Heart, Building2, Glasses } from 'lucide-react';
import type { EventData, FriendPreference } from '../App';

interface FriendsSubmissionScreenProps {
  eventData: EventData;
  friendName: string;
  organizerName: string;
  onSubmit: (preference: FriendPreference) => void;
}

const activityOptions = [
  { icon: Utensils, label: 'Dinner', emoji: '🍽️', color: 'from-red-400 to-orange-400' },
  { icon: Film, label: 'Movie', emoji: '🎬', color: 'from-purple-400 to-pink-400' },
  { icon: Coffee, label: 'Coffee', emoji: '☕', color: 'from-amber-400 to-orange-400' },
  { icon: Music, label: 'Concert', emoji: '🎵', color: 'from-blue-400 to-purple-400' },
  { icon: TreePine, label: 'Picnic', emoji: '🌳', color: 'from-green-400 to-emerald-400' },
  { icon: Palette, label: 'Arts', emoji: '🎨', color: 'from-pink-400 to-rose-400' },
  { icon: Gamepad2, label: 'Gaming', emoji: '🎮', color: 'from-indigo-400 to-blue-400' },
  { icon: Dumbbell, label: 'Sports', emoji: '⚽', color: 'from-green-500 to-teal-400' },
  { icon: ShoppingBag, label: 'Shopping', emoji: '🛍️', color: 'from-pink-500 to-purple-400' },
  { icon: Book, label: 'Books', emoji: '📚', color: 'from-amber-500 to-orange-400' },
  { icon: Plane, label: 'Travel', emoji: '✈️', color: 'from-sky-500 to-blue-400' },
  { icon: Waves, label: 'Beach', emoji: '🏖️', color: 'from-cyan-400 to-blue-400' },
  { icon: Mountain, label: 'Hiking', emoji: '⛰️', color: 'from-green-600 to-emerald-500' },
  { icon: Heart, label: 'Wellness', emoji: '💆', color: 'from-pink-400 to-red-400' },
  { icon: Building2, label: 'Museums', emoji: '🏛️', color: 'from-gray-500 to-slate-400' },
  { icon: Glasses, label: 'Theater', emoji: '🎭', color: 'from-purple-500 to-indigo-400' },
];

const timeSlots = [
  '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
  '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM',
  '5:00 PM', '6:00 PM', '7:00 PM', '8:00 PM',
];

const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

interface TimeSlotSelection {
  day: string;
  time: string;
}

export function FriendsSubmissionScreen({ eventData, friendName, organizerName, onSubmit }: FriendsSubmissionScreenProps) {
  const [selectedActivities, setSelectedActivities] = useState<string[]>([]);
  const [selectedTimeSlots, setSelectedTimeSlots] = useState<TimeSlotSelection[]>([]);
  const [budgetRange, setBudgetRange] = useState<[number, number]>([20, 80]);
  const [ideas, setIdeas] = useState('');
  const [submitted, setSubmitted] = useState(false);

  // Reset form state whenever the friend name changes (new friend)
  useEffect(() => {
    setSelectedActivities([]);
    setSelectedTimeSlots([]);
    setBudgetRange([20, 80]);
    setIdeas('');
    setSubmitted(false);
  }, [friendName]);

  const toggleActivity = (activity: string) => {
    setSelectedActivities((prev) =>
      prev.includes(activity)
        ? prev.filter((a) => a !== activity)
        : [...prev, activity]
    );
  };

  const toggleTimeSlot = (day: string, time: string) => {
    setSelectedTimeSlots((prev) => {
      const exists = prev.find(slot => slot.day === day && slot.time === time);
      if (exists) {
        return prev.filter(slot => !(slot.day === day && slot.time === time));
      } else {
        return [...prev, { day, time }];
      }
    });
  };

  const handleSubmit = () => {
    setSubmitted(true);
    
    const preference: FriendPreference = {
      name: friendName,
      availableTimes: selectedTimeSlots.map(slot => `${slot.day} ${slot.time}`),
      activities: selectedActivities,
      budgetRange,
      ideas,
    };
    
    setTimeout(() => {
      onSubmit(preference);
      setSubmitted(false);
    }, 2000);
  };

  const canSubmit = selectedActivities.length > 0 && selectedTimeSlots.length > 0;

  if (submitted) {
    return (
      <div className="h-full min-h-[700px] md:min-h-[800px] bg-gradient-to-br from-green-400 via-emerald-400 to-teal-400 flex flex-col items-center justify-center p-8 md:p-16">
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ type: 'spring', duration: 0.6 }}
          className="text-center"
        >
          <div className="w-24 h-24 md:w-32 md:h-32 bg-white rounded-full flex items-center justify-center mb-6 md:mb-8 mx-auto shadow-lg">
            <Check className="w-12 h-12 md:w-16 md:h-16 text-green-500" />
          </div>
          <h2 className="text-white mb-3 md:text-4xl">Preferences Submitted! 🎉</h2>
          <p className="text-white/90 text-lg md:text-xl">
            Gathering everyone's vibes...
          </p>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="h-full min-h-[700px] md:min-h-[800px] bg-white flex flex-col">
      {/* Header */}
      <motion.div
        initial={{ y: -20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        className="bg-gradient-to-r from-purple-500 via-pink-500 to-orange-400 p-6 md:p-8 pb-8 md:pb-12 rounded-b-3xl"
      >
        <div className="max-w-3xl mx-auto">
          <div className="text-center mb-6 md:mb-8">
            <div className="text-5xl md:text-6xl mb-3 md:mb-4">🎉</div>
            <h2 className="text-white mb-2 md:text-3xl">{organizerName} invited you!</h2>
            <p className="text-white/90 md:text-lg">Help plan the perfect hangout</p>
          </div>
        </div>
      </motion.div>

      {/* Content */}
      <div className="flex-1 p-6 md:p-8 overflow-y-auto">
        <div className="max-w-3xl mx-auto">
          <motion.div
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.2 }}
            className="space-y-6 md:space-y-8"
          >
            {/* Activities */}
            <div>
              <h3 className="mb-3 md:mb-4 md:text-2xl">What activities interest you?</h3>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
                {activityOptions.map((activity) => {
                  const Icon = activity.icon;
                  const isSelected = selectedActivities.includes(activity.label);
                  return (
                    <button
                      key={activity.label}
                      onClick={() => toggleActivity(activity.label)}
                      className={`p-4 md:p-5 rounded-2xl border-2 transition-all ${
                        isSelected
                          ? 'border-purple-500 bg-purple-50'
                          : 'border-gray-200 bg-white'
                      }`}
                    >
                      <div className={`w-10 h-10 md:w-12 md:h-12 bg-gradient-to-br ${activity.color} rounded-xl flex items-center justify-center mb-2 mx-auto`}>
                        <Icon className="w-5 h-5 md:w-6 md:h-6 text-white" />
                      </div>
                      <div className="text-sm md:text-base">{activity.label}</div>
                    </button>
                  );
                })}
              </div>
              {selectedActivities.length > 0 && (
                <div className="bg-purple-50 rounded-xl p-4 md:p-6 mt-4">
                  <div className="text-sm md:text-base text-purple-700 mb-2">
                    {selectedActivities.length} activit{selectedActivities.length !== 1 ? 'ies' : 'y'} selected
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {selectedActivities.map((activity) => (
                      <div
                        key={activity}
                        className="bg-white px-3 py-1 md:px-4 md:py-2 rounded-full text-sm md:text-base"
                      >
                        {activity}
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Time Preferences */}
            <div>
              <h3 className="mb-3 md:mb-4 md:text-2xl">When works best for you?</h3>
              <p className="text-gray-600 text-sm md:text-base mb-4">Select multiple day and time combinations</p>
              
              <div className="grid grid-cols-4 md:grid-cols-7 gap-2 md:gap-3 mb-4">
                {days.map((day) => (
                  <div
                    key={day}
                    className="text-center p-2 md:p-3 rounded-xl bg-sky-50 border border-sky-200"
                  >
                    <div className="text-sm md:text-base">{day}</div>
                  </div>
                ))}
              </div>

              <div className="grid grid-cols-7 gap-1 md:gap-2 max-h-64 overflow-y-auto p-1">
                {days.map((day) => (
                  <div key={day} className="space-y-1">
                    {timeSlots.map((time) => {
                      const isSelected = selectedTimeSlots.some(
                        slot => slot.day === day && slot.time === time
                      );
                      return (
                        <button
                          key={`${day}-${time}`}
                          onClick={() => toggleTimeSlot(day, time)}
                          className={`w-full p-1.5 md:p-2 rounded-lg border transition-all text-xs md:text-sm ${
                            isSelected
                              ? 'border-sky-500 bg-sky-500 text-white'
                              : 'border-gray-200 bg-white hover:border-sky-300'
                          }`}
                          title={`${day} ${time}`}
                        >
                          {time.replace(' AM', 'a').replace(' PM', 'p')}
                        </button>
                      );
                    })}
                  </div>
                ))}
              </div>
            </div>

            {/* Budget */}
            <div>
              <h3 className="mb-3 md:mb-4 md:text-2xl">Your budget preference</h3>
              <div className="bg-gradient-to-br from-orange-50 to-pink-50 rounded-2xl p-6 md:p-8">
                <div className="text-center mb-6 md:mb-8">
                  <div className="text-2xl md:text-3xl mb-1">
                    ${budgetRange[0]} - ${budgetRange[1]}
                  </div>
                  <p className="text-sm md:text-base text-gray-600">per person</p>
                </div>

                <Slider
                  value={budgetRange}
                  onValueChange={(value) => setBudgetRange(value as [number, number])}
                  min={0}
                  max={200}
                  step={10}
                  className="mb-4"
                />

                <div className="flex justify-between text-sm md:text-base text-gray-500">
                  <span>$0</span>
                  <span>$200+</span>
                </div>
              </div>
            </div>

            {/* Specific Ideas */}
            <div>
              <h3 className="mb-3 md:mb-4 md:text-2xl">Any specific ideas?</h3>
              <p className="text-gray-600 text-sm md:text-base mb-3">Share your thoughts (Optional)</p>
              <Textarea
                value={ideas}
                onChange={(e) => setIdeas(e.target.value)}
                placeholder="e.g., I'd love something outdoorsy with good food options nearby..."
                className="min-h-32 md:min-h-40 md:text-lg"
              />
            </div>
          </motion.div>
        </div>
      </div>

      {/* Footer */}
      <div className="p-6 md:p-8 pt-2 border-t border-gray-100">
        <div className="max-w-3xl mx-auto">
          <Button
            onClick={handleSubmit}
            disabled={!canSubmit}
            className="w-full h-14 md:h-16 rounded-2xl bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 md:text-lg"
            size="lg"
          >
            Share My Preferences
          </Button>
        </div>
      </div>
    </div>
  );
}
