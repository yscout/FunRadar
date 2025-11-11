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
import type { ApiEvent, ApiMatch, ApiVotesSummary } from '../api';

interface EventDetailsScreenProps {
  event: ApiEvent;
  matchResults: ApiMatch[];
  preferences: FriendPreference[];
  votesSummary?: ApiVotesSummary;
  userVotes?: Record<string, number>;
  onRate: (matchId: string | number, rating: number) => void;
  onBack: () => void;
}

const formatTimeSlot = (timeSlot: string) => timeSlot.replace(' AM', 'a').replace(' PM', 'p');

export function EventDetailsScreen({
  event,
  matchResults,
  preferences,
  votesSummary,
  userVotes,
  onRate,
  onBack,
}: EventDetailsScreenProps) {
  const totalFriends = Math.max(preferences.length, 1);
  const [showPreferencesDialog, setShowPreferencesDialog] = useState(false);
  const [ratings, setRatings] = useState<Record<string, number>>({});

  useEffect(() => {
    setRatings(
      Object.entries(userVotes || {}).reduce<Record<string, number>>((acc, [matchId, score]) => {
        acc[matchId] = score;
        return acc;
      }, {}),
    );
  }, [userVotes]);

  const handleRate = (matchId: string | number, rating: number) => {
    setRatings((prev) => ({ ...prev, [String(matchId)]: rating }));
    onRate(matchId, rating);
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
              {event.status === 'completed'
                ? 'Everyone voted! Here is your final pick.'
                : 'Results are in! Rate the ideas with your friends.'}
            </p>
          </div>
        </div>
      </div>

      <div className="flex-1 p-6 md:p-8 overflow-y-auto">
        <div className="max-w-6xl mx-auto space-y-4 md:space-y-6">
          {event.status === 'completed' && event.final_match && (
            <Card className="p-4 md:p-6 border-2 border-green-200">
              <div className="flex items-center gap-3 md:gap-4">
                <div className="text-4xl md:text-5xl">{event.final_match.emoji || '✅'}</div>
                <div>
                  <div className="text-xs text-green-600 uppercase tracking-wide">Final pick</div>
                  <div className="md:text-xl font-semibold">{event.final_match.title}</div>
                  <div className="text-gray-500">
                    {event.final_match.time || event.final_match.location || 'Ready to go'}
                  </div>
                </div>
              </div>
            </Card>
          )}

          {matchResults.length === 0 ? (
            <Card className="p-6 text-center border-2">
              <p className="text-gray-600 md:text-lg">
                Matches will appear here once everyone shares their preferences and AI finishes
                processing.
              </p>
            </Card>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">
              {matchResults.map((match) => {
                const summary = votesSummary?.[String(match.id)];
                const ratingsCount = summary?.ratings_count ?? match.votes ?? 0;
                const totalScore = summary?.total_score ?? 0;
                const userScore = ratings[String(match.id)] ?? 0;

                return (
                  <Card key={match.id} className="p-4 md:p-6 border-2">
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center gap-2">
                        <div className="text-3xl">{match.emoji}</div>
                        <div>
                          <div className="md:text-xl font-semibold">{match.title}</div>
                          <div className="text-sm text-gray-500">{match.location}</div>
                        </div>
                      </div>
                      <Badge className="bg-purple-100 text-purple-700 flex items-center gap-1">
                        <Sparkles className="w-4 h-4" />
                        {match.compatibility}% match
                      </Badge>
                    </div>

                    <ImageWithFallback
                      src={match.image}
                      alt={match.title}
                      className="w-full h-40 md:h-52 rounded-2xl object-cover mb-4"
                    />

                    <div className="space-y-2 text-sm md:text-base text-gray-600 mb-4">
                      <div className="flex items-center gap-2">
                        <Calendar className="w-4 h-4" />
                        {match.time}
                      </div>
                      <div className="flex items-center gap-2">
                        <DollarSign className="w-4 h-4" />
                        {match.price}
                      </div>
                      <p className="text-gray-700">{match.description}</p>
                    </div>

                    <StarRating
                      matchId={match.id}
                      userRating={userScore}
                      onRate={handleRate}
                      disabled={event.status === 'completed'}
                    />

                    <div className="mt-4 bg-gray-50 rounded-xl p-4">
                      <div className="flex items-center justify-between">
                        <div>
                          <div className="text-sm text-gray-500">Group voting progress</div>
                          <div className="text-xs text-gray-400">
                            {ratingsCount} of {totalFriends} friends rated
                          </div>
                        </div>
                        <div className="text-right">
                          <div className="font-semibold text-lg">{totalScore}</div>
                          <Progress
                            value={totalFriends ? Math.min((ratingsCount / totalFriends) * 100, 100) : 0}
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