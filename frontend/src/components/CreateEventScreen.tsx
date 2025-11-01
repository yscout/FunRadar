import React, { useState } from 'react';
import { Button } from './ui/button';
import { Label } from './ui/label';
import { Textarea } from './ui/textarea';
import { Slider } from './ui/slider';
import { X, ChevronLeft, ChevronRight, CalendarIcon, Utensils, Film, Coffee, Music, Palette, Gamepad2, TreePine, Dumbbell, ShoppingBag, Book, Plane, Waves, Mountain, Heart, Building2, Glasses } from 'lucide-react';
import type { EventData } from '../App';

interface CreateEventScreenProps {
  onComplete: (data: EventData) => void;
  onBack: () => void;
}

const activityTypes = [
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

export function CreateEventScreen({ onComplete, onBack }: CreateEventScreenProps) {
  const [step, setStep] = useState(1);
  const [selectedTimeSlots, setSelectedTimeSlots] = useState<TimeSlotSelection[]>([]);
  const [selectedActivities, setSelectedActivities] = useState<string[]>([]);
  const [budgetRange, setBudgetRange] = useState<[number, number]>([20, 80]);
  const [ideas, setIdeas] = useState('');
  const [invitedFriends, setInvitedFriends] = useState<string[]>([]);
  const [emailInput, setEmailInput] = useState('');

  const handleNext = () => {
    if (step < 5) {
      setStep(step + 1);
    } else {
      onComplete({
        availableTimes: selectedTimeSlots.map(slot => `${slot.day} ${slot.time}`),
        activityType: selectedActivities.join(', '),
        budgetRange,
        notes: ideas,
        invitedFriends,
      });
    }
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

  const toggleActivity = (activity: string) => {
    setSelectedActivities((prev) =>
      prev.includes(activity)
        ? prev.filter((a) => a !== activity)
        : [...prev, activity]
    );
  };

  const handleEmailAdd = () => {
    if (emailInput.trim() && !invitedFriends.includes(emailInput.trim())) {
      setInvitedFriends([...invitedFriends, emailInput.trim()]);
      setEmailInput('');
    }
  };

  const canProceed = () => {
    if (step === 1) return selectedTimeSlots.length > 0;
    if (step === 2) return selectedActivities.length > 0;
    if (step === 3) return true;
    if (step === 4) return true;
    if (step === 5) return invitedFriends.length > 0;
    return false;
  };

  return (
    <div className="h-full min-h-[700px] md:min-h-[800px] bg-white flex flex-col">
      <div className="bg-gradient-to-r from-purple-500 to-pink-500 p-6 md:p-8 pb-4 md:pb-6">
        <div className="max-w-3xl mx-auto">
          <div className="flex items-center gap-3 mb-4">
            <button
              onClick={onBack}
              className="w-10 h-10 md:w-12 md:h-12 bg-white/20 rounded-full flex items-center justify-center text-white hover:bg-white/30 transition-colors"
            >
              <ChevronLeft className="w-5 h-5 md:w-6 md:h-6" />
            </button>
            <h2 className="text-white flex-1 md:text-2xl">Create Event</h2>
            <span className="text-white/80 text-sm md:text-base">Step {step}/5</span>
          </div>

          {/* Progress bar */}
          <div className="flex gap-1.5 md:gap-2">
            {[1, 2, 3, 4, 5].map((s) => (
              <div
                key={s}
                className={`h-1 md:h-1.5 flex-1 rounded-full transition-all ${
                  s <= step ? 'bg-white' : 'bg-white/30'
                }`}
              />
            ))}
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 p-6 md:p-8 overflow-y-auto">
        <div className="max-w-3xl mx-auto">
          {step === 1 && (
              <div key="step1"
                className="space-y-6 md:space-y-8">
                <div className="text-center mb-6">
                  <div className="text-4xl md:text-5xl mb-3 md:mb-4">📅</div>
                  <h3 className="mb-2 md:text-3xl">When works for you?</h3>
                  <p className="text-gray-600 md:text-lg">Select multiple day and time combinations</p>
                </div>

                <div className="grid grid-cols-4 md:grid-cols-7 gap-2 md:gap-3 mb-4">
                  {days.map((day) => (
                    <div
                      key={day}
                      className="text-center p-2 md:p-3 rounded-xl bg-purple-50 border border-purple-200"
                    >
                      <div className="text-sm md:text-base">{day}</div>
                    </div>
                  ))}
                </div>

                <div className="grid grid-cols-7 gap-1 md:gap-2 max-h-96 overflow-y-auto p-1">
                  {days.map((day, dayIndex) => (
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
                                ? 'border-purple-500 bg-purple-500 text-white'
                                : 'border-gray-200 bg-white hover:border-purple-300'
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
            )}

            {step === 2 && (
              <div key="step2"
                className="space-y-6 md:space-y-8">
                <div className="text-center mb-6">
                  <div className="text-4xl md:text-5xl mb-3 md:mb-4">🎯</div>
                  <h3 className="mb-2 md:text-3xl">What's the vibe?</h3>
                  <p className="text-gray-600 md:text-lg">Choose one or more activity types</p>
                </div>

                <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
                  {activityTypes.map((activity) => {
                    const Icon = activity.icon;
                    const isSelected = selectedActivities.includes(activity.label);
                    return (
                      <button
                        key={activity.label}
                        onClick={() => toggleActivity(activity.label)}
                        className={`p-5 md:p-6 rounded-2xl border-2 transition-all ${
                          isSelected
                            ? 'border-purple-500 bg-purple-50 scale-95'
                            : 'border-gray-200 bg-white'
                        }`}
                      >
                        <div className={`w-12 h-12 md:w-14 md:h-14 bg-gradient-to-br ${activity.color} rounded-xl flex items-center justify-center mb-3 mx-auto`}>
                          <Icon className="w-6 h-6 md:w-7 md:h-7 text-white" />
                        </div>
                        <div className="md:text-lg">{activity.label}</div>
                      </button>
                    );
                  })}
                </div>

                {selectedActivities.length > 0 && (
                  <div className="bg-purple-50 rounded-xl p-4 md:p-6">
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
            )}

            {step === 3 && (
              <div key="step3"
                className="space-y-6 md:space-y-8">
                <div className="text-center mb-6">
                  <div className="text-4xl md:text-5xl mb-3 md:mb-4">💰</div>
                  <h3 className="mb-2 md:text-3xl">What's your budget?</h3>
                  <p className="text-gray-600 md:text-lg">Set a price range per person</p>
                </div>

                <div className="bg-gradient-to-br from-purple-50 to-pink-50 rounded-2xl p-6 md:p-8">
                  <div className="text-center mb-6 md:mb-8">
                    <div className="text-3xl md:text-4xl mb-2">
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

                <div className="grid grid-cols-3 gap-2 md:gap-4">
                  <button
                    onClick={() => setBudgetRange([0, 30])}
                    className="p-3 md:p-5 rounded-xl border-2 border-gray-200 hover:border-purple-300 transition-colors"
                  >
                    <div className="text-2xl md:text-3xl mb-1">💵</div>
                    <div className="text-xs md:text-sm">Budget</div>
                  </button>
                  <button
                    onClick={() => setBudgetRange([30, 80])}
                    className="p-3 md:p-5 rounded-xl border-2 border-gray-200 hover:border-purple-300 transition-colors"
                  >
                    <div className="text-2xl md:text-3xl mb-1">💰</div>
                    <div className="text-xs md:text-sm">Moderate</div>
                  </button>
                  <button
                    onClick={() => setBudgetRange([80, 200])}
                    className="p-3 md:p-5 rounded-xl border-2 border-gray-200 hover:border-purple-300 transition-colors"
                  >
                    <div className="text-2xl md:text-3xl mb-1">💎</div>
                    <div className="text-xs md:text-sm">Premium</div>
                  </button>
                </div>
              </div>
            )}

            {step === 4 && (
              <div key="step4"
                className="space-y-6 md:space-y-8">
                <div className="text-center mb-6">
                  <div className="text-4xl md:text-5xl mb-3 md:mb-4">📝</div>
                  <h3 className="mb-2 md:text-3xl">Any specific ideas?</h3>
                  <p className="text-gray-600 md:text-lg">Share your thoughts (Optional)</p>
                </div>

                <div>
                  <Label htmlFor="ideas" className="md:text-lg">Your ideas</Label>
                  <Textarea
                    id="ideas"
                    value={ideas}
                    onChange={(e) => setIdeas(e.target.value)}
                    placeholder="e.g., I'm thinking a rooftop dinner downtown, or maybe something outdoorsy..."
                    className="mt-1.5 min-h-40 md:min-h-48 md:text-lg"
                  />
                </div>
              </div>
            )}

            {step === 5 && (
              <div key="step5"
                className="space-y-6 md:space-y-8">
                <div className="text-center mb-6">
                  <div className="text-4xl md:text-5xl mb-3 md:mb-4">👥</div>
                  <h3 className="mb-2 md:text-3xl">Invite your crew</h3>
                  <p className="text-gray-600 md:text-lg">Who should join?</p>
                </div>

                <div className="space-y-3 md:space-y-4">
                  <div className="flex gap-2">
                    <input
                      type="text"
                      value={emailInput}
                      onChange={(e) => setEmailInput(e.target.value)}
                      placeholder="Enter friend's email"
                      className="flex-1 h-12 md:h-14 px-4 rounded-xl border-2 border-gray-200 focus:border-purple-500 focus:outline-none md:text-lg"
                        onKeyPress={(e) => {
                          if (e.key === 'Enter') {
                            handleEmailAdd();
                          }
                        }}
                      />
                    <Button
                      onClick={handleEmailAdd}
                      className="h-12 md:h-14 px-6 rounded-xl bg-purple-500 hover:bg-purple-600"
                    >
                      Add
                    </Button>
                  </div>

                  <div className="bg-purple-50 rounded-xl p-4 md:p-6">
                    <div className="text-sm md:text-base text-purple-700 mb-2 md:mb-3">Quick Add</div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-3">
                      {['Sarah Chen', 'Mike Johnson', 'Emma Davis', 'Alex Kim'].map((friend) => (
                        <button
                          key={friend}
                          onClick={() => {
                            if (!invitedFriends.includes(friend)) {
                              setInvitedFriends([...invitedFriends, friend]);
                            }
                          }}
                          className={`w-full p-3 md:p-4 rounded-lg text-left transition-colors md:text-lg ${
                            invitedFriends.includes(friend)
                              ? 'bg-purple-200 text-purple-900'
                              : 'bg-white hover:bg-purple-100'
                          }`}
                        >
                          {friend}
                        </button>
                      ))}
                    </div>
                  </div>

                  {invitedFriends.length > 0 && (
                    <div className="bg-green-50 rounded-xl p-4 md:p-6">
                      <div className="text-sm md:text-base text-green-700 mb-2 md:mb-3">
                        {invitedFriends.length} friends invited
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {invitedFriends.map((friend, index) => (
                          <div
                            key={index}
                            className="bg-white px-3 py-1 md:px-4 md:py-2 rounded-full text-sm md:text-base flex items-center gap-2"
                          >
                            {friend}
                            <button
                              onClick={() =>
                                setInvitedFriends(invitedFriends.filter((f) => f !== friend))
                              }
                              className="text-gray-400 hover:text-gray-600"
                            >
                              <X className="w-4 h-4" />
                            </button>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
      </div>

      {/* Footer */}
      <div className="p-6 md:p-8 pt-2 border-t border-gray-100">
        <div className="max-w-3xl mx-auto">
          <Button
            onClick={handleNext}
            disabled={!canProceed()}
            className="w-full h-14 md:h-16 rounded-2xl bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 md:text-lg"
            size="lg"
          >
            {step < 5 ? (
              <>
                Continue
                <ChevronRight className="ml-2 w-5 h-5 md:w-6 md:h-6" />
              </>
            ) : (
              'Send Invites 🎉'
            )}
          </Button>
        </div>
      </div>
    </div>
  );
}
