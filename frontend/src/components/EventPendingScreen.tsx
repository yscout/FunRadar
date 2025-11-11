import React from 'react';
import { Card } from './ui/card';
import { Progress } from './ui/progress';
import { Badge } from './ui/badge';
import { Button } from './ui/button';
import { CheckCircle, Clock, Users, ChevronLeft } from 'lucide-react';
import type { ApiProgressEntry } from '../api';

interface EventPendingScreenProps {
  eventTitle: string;
  organizerName: string;
  progress: ApiProgressEntry[];
  onBack: () => void;
}

export function EventPendingScreen({ eventTitle, organizerName, progress, onBack }: EventPendingScreenProps) {
  const participants = progress.map((entry) => ({
    name: entry.name,
    submitted: entry.status === 'submitted',
  }));
  const submittedCount = participants.filter((p) => p.submitted).length;
  const totalCount = participants.length || 1;
  const progressPercent = Math.min((submittedCount / totalCount) * 100, 100);

  return (
    <div className="h-full min-h-[700px] md:min-h-[800px] bg-white flex flex-col">
      <div className="bg-gradient-to-r from-purple-500 via-pink-500 to-orange-400 p-6 md:p-8 pb-8 md:pb-12 rounded-b-3xl">
        <div className="max-w-6xl mx-auto">
          <Button onClick={onBack} variant="ghost" className="mb-4 text-white hover:bg-white/20">
            <ChevronLeft className="w-5 h-5 mr-2" />
            Back
          </Button>

          <div className="text-center">
            <div className="text-5xl md:text-6xl mb-3 md:mb-4">⏳</div>
            <h2 className="text-white mb-2 md:text-3xl">{eventTitle}</h2>
            <p className="text-white/90 md:text-lg">
              Waiting for everyone to share their preferences, {organizerName}
            </p>
          </div>
        </div>
      </div>

      <div className="p-6 md:p-8 bg-gradient-to-br from-purple-50 to-pink-50">
        <Card className="p-6 md:p-8 border-2 border-purple-200">
          <div className="max-w-4xl mx-auto">
            <div className="mb-4">
              <h3 className="md:text-2xl mb-2">Progress</h3>
              <p className="text-gray-600 md:text-lg">
                {submittedCount} of {totalCount} participants shared their preferences
              </p>
            </div>

            <Progress value={progressPercent} className="h-3 md:h-4 mb-4" />

            <div className="flex items-center justify-center gap-4 text-sm md:text-base text-gray-600">
              <div className="flex items-center gap-2">
                <CheckCircle className="w-5 h-5 text-green-500" />
                <span>{submittedCount} submitted</span>
              </div>
              <div className="flex items-center gap-2">
                <Clock className="w-5 h-5 text-orange-500" />
                <span>{totalCount - submittedCount} pending</span>
              </div>
            </div>
          </div>
        </Card>
      </div>

      <div className="flex-1 p-6 md:p-8 overflow-y-auto">
        <div className="max-w-4xl mx-auto">
          <h3 className="mb-4 md:text-2xl">Participants</h3>

          {participants.length === 0 ? (
            <Card className="p-6 text-center border-2">
              <p className="text-gray-600 md:text-lg">
                Invite friends so they can start sharing their preferences.
              </p>
            </Card>
          ) : (
            <div className="space-y-3">
              {participants.map((participant) => (
                <Card key={participant.name} className="p-4 md:p-6 border-2">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3 md:gap-4">
                      <div className="w-10 h-10 md:w-12 md:h-12 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full flex items-
center justify-center text-white font-semibold">
                        {participant.name.charAt(0)}
                      </div>
                      <div>
                        <div className="md:text-lg">{participant.name}</div>
                        {participant.submitted && (
                          <div className="text-sm text-gray-500">Shared preferences</div>
                        )}
                      </div>
                    </div>

                    {participant.submitted ? (
                      <Badge className="bg-green-100 text-green-700">
                        <CheckCircle className="w-4 h-4 mr-1" />
                        Submitted
                      </Badge>
                    ) : (
                      <Badge variant="secondary" className="bg-orange-100 text-orange-700">
                        <Clock className="w-4 h-4 mr-1" />
                        Pending
                      </Badge>
                    )}
                  </div>
                </Card>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}