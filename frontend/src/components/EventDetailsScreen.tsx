import React, { useState, useEffect } from 'react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { StarRating } from './StarRating';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from './ui/dialog';
import {
  Sparkles,
  Calendar,
  Share2,
  Users,
  MapPin,
  DollarSign,
  Trophy,
  Star,
  Clock,
} from 'lucide-react';
import type { FriendPreference } from '../App';
import type { ApiEvent, ApiMatch } from '../api';

interface EventDetailsScreenProps {
  event: ApiEvent;
  matchResults: ApiMatch[];
  preferences: FriendPreference[];
  onBack: () => void;
}

interface MatchRating {
  matchId: number;
  userRating: number;
  ratedCount: number;
  averageRating: number;
  totalFriends: number;
}

const formatTimeSlot = (timeSlot: string) => timeSlot.replace(' AM', 'a').replace(' PM', 'p');

export function EventDetailsScreen({
  event,
  matchResults,
  preferences,
  onBack,
}: EventDetailsScreenProps) {
  const totalFriends = Math.max(preferences.length, 1);
  const [showPreferencesDialog, setShowPreferencesDialog] = useState(false);
  const [ratings, setRatings] = useState<Record<number, MatchRating>>({});

  useEffect(() => {
    const initial = matchResults.reduce((acc, match) => {
      acc[match.id] = {
        matchId: match.id,
        userRating: 0,
        ratedCount: match.votes || 0,
        averageRating: Number((match.compatibility / 20).toFixed(1)),
        totalFriends,
      };
      return acc;
    }, {} as Record<number, MatchRating>);
    setRatings(initial);
  }, [matchResults, totalFriends]);

  const handleRate = (matchId: number, rating: number) => {
    setRatings((prev) => {
      const current = prev[matchId];
      if (!current) return prev;

      const alreadyRated = current.userRating > 0;
      const adjustedRatedCount = alreadyRated ? current.ratedCount : current.ratedCount + 1;
      const totalScore =
        current.averageRating * current.ratedCount -
        (alreadyRated ? current.userRating : 0) +
        rating;
      const averageRating =
        adjustedRatedCount > 0 ? Number((totalScore / adjustedRatedCount).toFixed(1)) : rating;

      return {
        ...prev,
        [matchId]: {
          ...current,
          userRating: rating,
          ratedCount: adjustedRatedCount,
          averageRating,
        },
      };
    });
  };

  return (
    <div className="h-full min-h-[700px] md:min-h-[800px] bg-white flex flex-col">
      <div className="bg-gradient-to-r from-purple-500 via-pink-500 to-orange-400 p-6 md:p-8 pb-8 md:pb-12 rounded-b-3xl">
        <div className="max-w-6xl mx-auto">
          <Button onClick={onBack} variant="ghost" className="mb-4 text-white hover:bg-white/20">
            ← Back
          </Button>

          <div className="text-center">
            <div className="text-5xl md:text-6xl mb-3 md:mb-4">🎉</div>
            <h2 className="text-white mb-2 md:text-3xl">{event.title}</h2>
            <p className="text-white/90 md:text-lg">
              Results are in! Here's what the group matched on
            </p>
          </div>
        </div>
      </div>

      <div className="flex-1 p-6 md:p-8 overflow-y-auto">
        <div className="max-w-6xl mx-auto space-y-4 md:space-y-6">
          {matchResults.length === 0 ? (
            <Card className="p-6 text-center border-2">
              <p className="text-gray-600 md:text-lg">
                Matches will appear here once everyone shares their preferences and AI finishes
                processing.
              </p>
            </Card>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">
              {matchResults.map((match, index) => {
                const rating =
                  ratings[match.id] || {
                    matchId: match.id,
                    userRating: 0,
                    ratedCount: match.votes || 0,
                    averageRating: Number((match.compatibility / 20).toFixed(1)),
                    totalFriends,
                  };

                return (
                  <Card
                    key={match.id}
                    className={`overflow-hidden border-2 h-full ${
                      index === 0
                        ? 'border-yellow-400 bg-gradient-to-br from-yellow-50 to-orange-50 md:col-span-2'
                        : 'border-gray-200'
                    }`}
                  >
                    {index === 0 && (
                      <div className="bg-gradient-to-r from-yellow-400 to-orange-400 px-4 py-2 flex items-center justify-center gap-2">
                        <Trophy className="w-4 h-4 md:w-5 md:h-5 text-white" />
                        <span className="text-white text-sm md:text-base">Top Match</span>
                      </div>
                    )}

                    <div className="flex gap-4 p-4 md:p-6">
                      <div className="relative flex-shrink-0">
                        <ImageWithFallback
                          src={match.image}
                          alt={match.title}
                          className={`object-cover rounded-xl ${
                            index === 0 ? 'w-32 h-32' : 'w-24 h-24'
                          }`}
                        />
                        <div className="absolute -top-2 -right-2 bg-purple-500 rounded-full flex items-center justify-center text-white
shadow-lg w-10 h-10 md:w-12 md:h-12 md:text-lg">
                          {match.compatibility}%
                        </div>
                      </div>

                      <div className="flex-1 min-w-0">
                        <div className="flex items-start gap-2 mb-2">
                          <span className="text-2xl md:text-3xl">{match.emoji}</span>
                          <div className="flex-1 min-w-0">
                            <h3 className="mb-1 md:text-2xl">{match.title}</h3>
                            <p className="text-sm text-gray-600 line-clamp-2 md:text-base">
                              {match.description}
                            </p>
                          </div>
                        </div>

                        <div className="space-y-1 text-sm text-gray-600 mb-3 md:text-base">
                          <div className="flex items-center gap-2">
                            <MapPin className="w-4 h-4" />
                            <span className="truncate">{match.location}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <Calendar className="w-4 h-4" />
                            <span>{match.time}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <DollarSign className="w-4 h-4" />
                            <span>{match.price}</span>
                          </div>
                        </div>

                        <div className="flex items-center gap-2">
                          <Badge variant="secondary" className="bg-purple-100 text-purple-700">
                            <Users className="w-3 h-3 mr-1" />
                            {rating.ratedCount} voted
                          </Badge>
                        </div>

                        <div className="mt-4 space-y-3">
                          <StarRating
                            matchId={match.id}
                            userRating={rating.userRating}
                            onRate={handleRate}
                          />
                          <div className="flex items-center justify-between text-sm md:text-base">
                            <div className="flex items-center gap-1">
                              <Star className="fill-yellow-400 text-yellow-400 w-4 h-4" />
                              <span className="text-gray-900">{rating.averageRating} ★</span>
                              <span className="text-gray-500 ml-1">
                                from {rating.ratedCount} friends
                              </span>
                            </div>
                          </div>
                          <Progress
                            value={
                              rating.totalFriends
                                ? Math.min((rating.ratedCount / rating.totalFriends) * 100, 100)
                                : 0
                            }
                            className="h-1.5"
                          />
                        </div>
                      </div>
                    </div>
                  </Card>
                );
              })}
            </div>
          )}
        </div>
      </div>

      <div className="p-6 md:p-8 pt-2 border-t border-gray-100">
        <div className="max-w-6xl mx-auto space-y-3 md:space-y-4">
          <Button
            onClick={() => setShowPreferencesDialog(true)}
            className="w-full h-12 md:h-14 rounded-2xl bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-
600 md:text-lg"
          >
            <Users className="w-5 h-5 md:w-6 md:h-6 mr-2" />
            Everyone&apos;s Preferences
          </Button>

          <div className="grid grid-cols-2 gap-3 md:gap-4">
            <Button
              onClick={() => setShowPreferencesDialog(true)}
              variant="outline"
              className="rounded-2xl md:h-12 md:text-base"
            >
              <Sparkles className="w-4 h-4 md:w-5 md:h-5 mr-2" />
              Preference Summary
            </Button>
            <Button variant="outline" className="rounded-2xl md:h-12 md:text-base">
              <Share2 className="w-4 h-4 md:w-5 md:h-5 mr-2" />
              Share to Group Chat
            </Button>
          </div>
        </div>
      </div>

      <Dialog open={showPreferencesDialog} onOpenChange={setShowPreferencesDialog}>
        <DialogContent className="max-w-4xl max-h-[80vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="text-2xl md:text-3xl">Everyone&apos;s Preferences</DialogTitle>
            <DialogDescription>See what everyone is looking for in this hangout</DialogDescription>
          </DialogHeader>

          <div className="space-y-4 md:space-y-6 mt-4">
            {preferences.length === 0 ? (
              <Card className="p-4 md:p-6 border-2 text-center text-gray-600">
                Preferences will appear once friends respond to their invitations.
              </Card>
            ) : (
              preferences.map((friend, index) => (
                <Card key={`${friend.name}-${index}`} className="p-4 md:p-6 border-2">
                  <div className="space-y-4">
                    <div className="flex items-center gap-3 pb-3 border-b">
                      <div className="w-10 h-10 md:w-12 md:h-12 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full flex items-
center justify-center text-white">
                        {friend.name.charAt(0)}
                      </div>
                      <h3 className="md:text-xl">{friend.name}</h3>
                    </div>

                    <div>
                      <div className="flex items-center gap-2 mb-2">
                        <Clock className="w-4 h-4 text-purple-600" />
                        <span className="text-sm md:text-base">Available Times</span>
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {friend.availableTimes.map((time) => (
                          <Badge key={time} variant="secondary" className="bg-purple-50 text-purple-700">
                            {formatTimeSlot(time)}
                          </Badge>
                        ))}
                      </div>
                    </div>

                    <div>
                      <div className="flex items-center gap-2 mb-2">
                        <Sparkles className="w-4 h-4 text-pink-600" />
                        <span className="text-sm md:text-base">Interested Activities</span>
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {friend.activities.map((activity) => (
                          <Badge key={activity} variant="secondary" className="bg-pink-50 text-pink-700">
                            {activity}
                          </Badge>
                        ))}
                      </div>
                    </div>

                    <div>
                      <div className="flex items-center gap-2 mb-2">
                        <DollarSign className="w-4 h-4 text-green-600" />
                        <span className="text-sm md:text-base">Budget Range</span>
                      </div>
                      <Badge variant="secondary" className="bg-green-50 text-green-700">
                        ${friend.budgetRange[0]} - ${friend.budgetRange[1]} per person
                      </Badge>
                    </div>

                    {friend.ideas && (
                      <div>
                        <div className="flex items-center gap-2 mb-2">
                          <span className="text-2xl">💡</span>
                          <span className="text-sm md:text-base">Ideas</span>
                        </div>
                        <p className="text-sm md:text-base text-gray-600 bg-gray-50 p-3 rounded-lg">
                          “{friend.ideas}”
                        </p>
                      </div>
                    )}
                  </div>
                </Card>
              ))
            )}
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}