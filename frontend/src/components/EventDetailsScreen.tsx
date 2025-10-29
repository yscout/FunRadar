import React, { useState, useEffect } from "react";
import { Button } from "./ui/button";
import { Card } from "./ui/card";
import { Badge } from "./ui/badge";
import { Progress } from "./ui/progress";
import { ImageWithFallback } from "./figma/ImageWithFallback";
import { StarRating } from "./StarRating";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "./ui/dialog";
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
} from "lucide-react";

import type { FriendPreference } from "../App";

interface EventDetailsScreenProps {
  eventId: number;
  eventTitle: string;
  onBack: () => void;
  allPreferences: FriendPreference[];
  matchResults: any[];
}

interface MatchRating {
  matchId: number;
  userRating: number;
  groupRatings: number[];
  ratedCount: number;
  totalFriends: number;
}

const hardcodedMatchResults = [
  {
    id: 1,
    title: "Free Jazz Picnic",
    compatibility: 95,
    image:
      "https://images.unsplash.com/photo-1603543900250-275a638755a9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxqYXp6JTIwbXVzaWMlMjBwaWNuaWMlMjBvdXRkb29yfGVufDF8fHx8MTc2MTIzNTQ1OHww&ixlib=rb-4.1.0&q=80&w=1080",
    location: "Central Park",
    price: "$15/person",
    time: "Saturday, 3:00 PM",
    emoji: "🎶",
    votes: 5,
    description:
      "Live jazz band with picnic setup and food trucks",
  },
  {
    id: 2,
    title: "Rooftop Dinner",
    compatibility: 88,
    image:
      "https://images.unsplash.com/photo-1742002661612-771125d0c050?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyb29mdG9wJTIwZGlubmVyJTIwY2l0eXxlbnwxfHx8fDE3NjEyMzU0NTh8MA&ixlib=rb-4.1.0&q=80&w=1080",
    location: "Downtown Skybar",
    price: "$45/person",
    time: "Friday, 7:00 PM",
    emoji: "🍽️",
    votes: 4,
    description: "Italian cuisine with city views",
  },
  {
    id: 3,
    title: "Coffee & Catch Up",
    compatibility: 85,
    image:
      "https://images.unsplash.com/photo-1721845706930-b3a05aa70baa?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2ZmZWUlMjBzaG9wJTIwZnJpZW5kc3xlbnwxfHx8fDE3NjExNzkzMTZ8MA&ixlib=rb-4.1.0&q=80&w=1080",
    location: "The Brew House",
    price: "$8/person",
    time: "Sunday, 10:00 AM",
    emoji: "☕",
    votes: 4,
    description: "Cozy cafe with board games",
  },
  {
    id: 4,
    title: "Movie Marathon",
    compatibility: 82,
    image:
      "https://images.unsplash.com/photo-1524712245354-2c4e5e7121c0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb3ZpZSUyMHRoZWF0ZXIlMjBjaW5lbWF8ZW58MXx8fHwxNzYxMjIyOTM3fDA&ixlib=rb-4.1.0&q=80&w=1080",
    location: "Cinema Plaza",
    price: "$12/person",
    time: "Saturday, 7:30 PM",
    emoji: "🎬",
    votes: 3,
    description: "Back-to-back screenings with premium seating",
  },
  {
    id: 5,
    title: "Art Gallery Tour",
    compatibility: 78,
    image:
      "https://images.unsplash.com/photo-1713779490284-a81ff6a8ffae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhcnQlMjBnYWxsZXJ5JTIwZXhoaWJpdGlvbnxlbnwxfHx8fDE3NjEyMzA0OTV8MA&ixlib=rb-4.1.0&q=80&w=1080",
    location: "Modern Arts Museum",
    price: "$20/person",
    time: "Saturday, 2:00 PM",
    emoji: "🎨",
    votes: 3,
    description: "New contemporary exhibit with guided tour",
  },
];



const formatTimeSlot = (timeSlot: string) => {
  // Convert "Mon 9:00 AM" to "Mon 9a"
  return timeSlot.replace(' AM', 'a').replace(' PM', 'p');
};

export function EventDetailsScreen({
  eventId,
  eventTitle,
  onBack,
  allPreferences,
  matchResults,
}: EventDetailsScreenProps) {
  const [showPreferencesDialog, setShowPreferencesDialog] = useState(false);
  const totalFriends = allPreferences.length;

  // Initialize ratings state
  const [ratings, setRatings] = useState<
    Record<number, MatchRating>
  >({
    1: {
      matchId: 1,
      userRating: 0,
      groupRatings: [5, 4, 5, 4],
      ratedCount: 4,
      totalFriends,
    },
    2: {
      matchId: 2,
      userRating: 0,
      groupRatings: [4, 3, 5, 4],
      ratedCount: 4,
      totalFriends,
    },
    3: {
      matchId: 3,
      userRating: 0,
      groupRatings: [4, 5, 3],
      ratedCount: 3,
      totalFriends,
    },
    4: {
      matchId: 4,
      userRating: 0,
      groupRatings: [3, 4, 4],
      ratedCount: 3,
      totalFriends,
    },
    5: {
      matchId: 5,
      userRating: 0,
      groupRatings: [3, 4, 3],
      ratedCount: 3,
      totalFriends,
    },
  });

  const handleRate = (matchId: number, rating: number) => {
    setRatings((prev) => {
      const current = prev[matchId];
      const newGroupRatings =
        current.userRating === 0
          ? [...current.groupRatings, rating]
          : current.groupRatings.map((r, i) =>
              i === current.groupRatings.length - 1
                ? rating
                : r,
            );

      return {
        ...prev,
        [matchId]: {
          ...current,
          userRating: rating,
          groupRatings: newGroupRatings,
          ratedCount:
            current.userRating === 0
              ? current.ratedCount + 1
              : current.ratedCount,
        },
      };
    });
  };

  const calculateAverage = (matchId: number) => {
    const rating = ratings[matchId];
    if (rating.groupRatings.length === 0) return 0;
    const sum = rating.groupRatings.reduce(
      (acc, r) => acc + r,
      0,
    );
    return (sum / rating.groupRatings.length).toFixed(1);
  };


  return (
    <div className="h-full min-h-[700px] md:min-h-[800px] bg-white flex flex-col">
      {/* Header */}
      <div
        className="bg-gradient-to-r from-purple-500 via-pink-500 to-orange-400 p-6 md:p-8 pb-8 md:pb-12 rounded-b-3xl">
        <div className="max-w-6xl mx-auto">
          <Button
            onClick={onBack}
            variant="ghost"
            className="mb-4 text-white hover:bg-white/20"
          >
            ← Back
          </Button>
          
          <div className="text-center">
            <div
              className="text-5xl md:text-6xl mb-3 md:mb-4">
              🎉
            </div>
            <h2 className="text-white mb-2 md:text-3xl">
              {eventTitle}
            </h2>
            <p className="text-white/90 md:text-lg">
              Results are in! Here's what the group matched on
            </p>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 p-6 md:p-8 overflow-y-auto">
        <div className="max-w-6xl mx-auto">
          <div
                className="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">
                {matchResults.map((match, index) => (
                  <div key={match.id}
                    className={
                      index === 0 ? "md:col-span-2" : ""
                    }>
                    <Card
                      className={`overflow-hidden border-2 h-full ${
                        index === 0
                          ? "border-yellow-400 bg-gradient-to-br from-yellow-50 to-orange-50"
                          : "border-gray-200"
                      }`}
                    >
                      {index === 0 && (
                        <div className="bg-gradient-to-r from-yellow-400 to-orange-400 px-4 py-2 flex items-center justify-center gap-2">
                          <Trophy className="w-4 h-4 md:w-5 md:h-5 text-white" />
                          <span className="text-white text-sm md:text-base">
                            Top Match
                          </span>
                        </div>
                      )}

                      <div
                        className={`flex gap-4 p-4 md:p-6 ${index === 0 ? "md:gap-6" : ""}`}
                      >
                        <div className="relative flex-shrink-0">
                          <ImageWithFallback
                            src={match.image}
                            alt={match.title}
                            className={`object-cover rounded-xl ${
                              index === 0
                                ? "w-24 h-24 md:w-32 md:h-32"
                                : "w-24 h-24 md:w-28 md:h-28"
                            }`}
                          />
                          <div
                            className={`absolute -top-2 -right-2 bg-purple-500 rounded-full flex items-center justify-center text-white shadow-lg ${
                              index === 0
                                ? "w-10 h-10 md:w-12 md:h-12 md:text-lg"
                                : "w-10 h-10"
                            }`}
                          >
                            {match.compatibility}%
                          </div>
                        </div>

                        <div className="flex-1 min-w-0">
                          <div className="flex items-start gap-2 mb-2">
                            <span
                              className={`flex-shrink-0 ${index === 0 ? "text-2xl md:text-3xl" : "text-2xl"}`}
                            >
                              {match.emoji}
                            </span>
                            <div className="flex-1">
                              <h3
                                className={`mb-1 ${index === 0 ? "md:text-2xl" : "md:text-xl"}`}
                              >
                                {match.title}
                              </h3>
                              <p
                                className={`text-sm text-gray-600 line-clamp-2 ${index === 0 ? "md:text-base" : ""}`}
                              >
                                {match.description}
                              </p>
                            </div>
                          </div>

                          <div
                            className={`space-y-1 text-sm text-gray-600 mb-3 ${index === 0 ? "md:text-base md:space-y-2" : ""}`}
                          >
                            <div className="flex items-center gap-2">
                              <MapPin
                                className={`flex-shrink-0 ${index === 0 ? "w-4 h-4 md:w-5 md:h-5" : "w-4 h-4"}`}
                              />
                              <span className="truncate">
                                {match.location}
                              </span>
                            </div>
                            <div className="flex items-center gap-2">
                              <Calendar
                                className={`flex-shrink-0 ${index === 0 ? "w-4 h-4 md:w-5 md:h-5" : "w-4 h-4"}`}
                              />
                              <span>{match.time}</span>
                            </div>
                            <div className="flex items-center gap-2">
                              <DollarSign
                                className={`flex-shrink-0 ${index === 0 ? "w-4 h-4 md:w-5 md:h-5" : "w-4 h-4"}`}
                              />
                              <span>{match.price}</span>
                            </div>
                          </div>

                          <div className="flex items-center gap-2">
                            <Badge
                              variant="secondary"
                              className={`bg-purple-100 text-purple-700 ${index === 0 ? "md:text-base md:px-3 md:py-1" : ""}`}
                            >
                              <Users
                                className={`mr-1 ${index === 0 ? "w-3 h-3 md:w-4 md:h-4" : "w-3 h-3"}`}
                              />
                              {match.votes}/5 voted
                            </Badge>
                          </div>

                          <div className="mt-4">
                            <StarRating
                              matchId={match.id}
                              userRating={
                                ratings[match.id].userRating
                              }
                              groupRatings={
                                ratings[match.id].groupRatings
                              }
                              ratedCount={
                                ratings[match.id].ratedCount
                              }
                              totalFriends={
                                ratings[match.id].totalFriends
                              }
                              onRate={handleRate}
                            />
                            <div className="mt-3 space-y-2">
                              <div
                                className={`flex items-center justify-between text-sm ${index === 0 ? "md:text-base" : ""}`}
                              >
                                <div className="flex items-center gap-1">
                                  <Star
                                    className={`fill-yellow-400 text-yellow-400 ${index === 0 ? "w-4 h-4 md:w-5 md:h-5" : "w-4 h-4"}`}
                                  />
                                  <span className="text-gray-900">
                                    {calculateAverage(match.id)}{" "}
                                    ★
                                  </span>
                                  <span className="text-gray-500 ml-1">
                                    from{" "}
                                    {
                                      ratings[match.id]
                                        .ratedCount
                                    }{" "}
                                    friends
                                  </span>
                                </div>
                              </div>
                              <Progress
                                value={
                                  (ratings[match.id]
                                    .ratedCount /
                                    ratings[match.id]
                                      .totalFriends) *
                                  100
                                }
                                className={
                                  index === 0
                                    ? "h-1.5 md:h-2"
                                    : "h-1.5"
                                }
                              />
                            </div>
                          </div>
                        </div>
                      </div>
                    </Card>
                  </div>
                ))}
          </div>
        </div>
      </div>

      {/* Footer */}
      <div
        className="p-6 md:p-8 pt-2 border-t border-gray-100">
        <div className="max-w-6xl mx-auto space-y-3 md:space-y-4">
          <Button 
            onClick={() => setShowPreferencesDialog(true)}
            className="w-full h-12 md:h-14 rounded-2xl bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 md:text-lg"
          >
            <Users className="w-5 h-5 md:w-6 md:h-6 mr-2" />
            Everyone's Preferences
          </Button>

          <div className="grid grid-cols-2 gap-3 md:gap-4">
            <Button
              onClick={() => setShowPreferencesDialog(true)}
              variant="outline"
              className="rounded-2xl md:h-12 md:text-base"
            >
              <Users className="w-4 h-4 md:w-5 md:h-5 mr-2" />
              Everyone's Preferences
            </Button>
            <Button
              variant="outline"
              className="rounded-2xl md:h-12 md:text-base"
            >
              <Share2 className="w-4 h-4 md:w-5 md:h-5 mr-2" />
              Share to Group Chat
            </Button>
          </div>

        </div>
      </div>

      {/* Preferences Dialog */}
      <Dialog open={showPreferencesDialog} onOpenChange={setShowPreferencesDialog}>
        <DialogContent className="max-w-4xl max-h-[80vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="text-2xl md:text-3xl">Everyone's Preferences</DialogTitle>
            <DialogDescription>
              See what everyone is looking for in this hangout
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4 md:space-y-6 mt-4">
            {allPreferences.map((user, index) => (
              <Card key={index} className="p-4 md:p-6 border-2">
                <div className="space-y-4">
                  <div className="flex items-center gap-3 pb-3 border-b">
                    <div className="w-10 h-10 md:w-12 md:h-12 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full flex items-center justify-center text-white">
                      {user.name.charAt(0)}
                    </div>
                    <h3 className="md:text-xl">{user.name}</h3>
                  </div>
                  
                  <div>
                    <div className="flex items-center gap-2 mb-2">
                      <Clock className="w-4 h-4 text-purple-600" />
                      <span className="text-sm md:text-base">Available Times</span>
                    </div>
                    <div className="flex flex-wrap gap-2">
                      {user.availableTimes.map((time, idx) => (
                        <Badge key={idx} variant="secondary" className="bg-purple-50 text-purple-700">
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
                      {user.activities.map((activity, idx) => (
                        <Badge key={idx} variant="secondary" className="bg-pink-50 text-pink-700">
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
                      ${user.budgetRange[0]} - ${user.budgetRange[1]} per person
                    </Badge>
                  </div>

                  {user.ideas && (
                    <div>
                      <div className="flex items-center gap-2 mb-2">
                        <span className="text-2xl">💡</span>
                        <span className="text-sm md:text-base">Ideas</span>
                      </div>
                      <p className="text-sm md:text-base text-gray-600 bg-gray-50 p-3 rounded-lg">
                        "{user.ideas}"
                      </p>
                    </div>
                  )}
                </div>
              </Card>
            ))}
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
