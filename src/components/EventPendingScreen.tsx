import React from 'react';
import { motion } from 'motion/react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { CheckCircle, Clock, Users, ChevronLeft } from 'lucide-react';
import type { FriendPreference } from '../App';

interface Participant {
  name: string;
  submitted: boolean;
}

interface EventPendingScreenProps {
  eventId: number;
  eventTitle: string;
  organizerName: string;
  participants: Participant[];
  submittedPreferences: FriendPreference[];
  onBack: () => void;
}

export function EventPendingScreen({
  eventId,
  eventTitle,
  organizerName,
  participants,
  submittedPreferences,
  onBack,
}: EventPendingScreenProps) {
  const submittedCount = participants.filter(p => p.submitted).length;
  const totalCount = participants.length;
  const progressPercent = (submittedCount / totalCount) * 100;

  return (
    <div className="h-full min-h-[700px] md:min-h-[800px] bg-white flex flex-col">
      {/* Header */}
      <motion.div
        initial={{ y: -20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        className="bg-gradient-to-r from-purple-500 via-pink-500 to-orange-400 p-6 md:p-8 pb-8 md:pb-12 rounded-b-3xl"
      >
        <div className="max-w-6xl mx-auto">
          <Button
            onClick={onBack}
            variant="ghost"
            className="mb-4 text-white hover:bg-white/20"
          >
            <ChevronLeft className="w-5 h-5 mr-2" />
            Back
          </Button>
          
          <div className="text-center">
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ type: 'spring', delay: 0.2 }}
              className="text-5xl md:text-6xl mb-3 md:mb-4"
            >
              ⏳
            </motion.div>
            <h2 className="text-white mb-2 md:text-3xl">{eventTitle}</h2>
            <p className="text-white/90 md:text-lg">
              Waiting for everyone to share their preferences
            </p>
          </div>
        </div>
      </motion.div>

      {/* Progress Section */}
      <div className="p-6 md:p-8 bg-gradient-to-br from-purple-50 to-pink-50">
        <div>
          <Card className="p-6 md:p-8 border-2 border-purple-200">
            <div className="max-w-4xl mx-auto">
              <div className="mb-4">
                <h3 className="md:text-2xl mb-2">Progress</h3>
                <p className="text-gray-600 md:text-lg">
                  {submittedCount} of {totalCount} participants shared their preferences
                </p>
              </div>
              
              <Progress value={progressPercent} className="h-3 md:h-4 mb-4" />
              
              <div className="flex items-center justify-center gap-2 md:gap-4 text-sm md:text-base text-gray-600">
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
      </div>

      {/* Participants List */}
      <div className="flex-1 p-6 md:p-8 overflow-y-auto">
        <div className="max-w-4xl mx-auto">
          <h3 className="mb-4 md:text-2xl">Participants</h3>
          
          <div className="space-y-3">
            {participants.map((participant, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.1 }}
              >
                <Card className="p-4 md:p-6 border-2">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3 md:gap-4">
                      <div className="w-10 h-10 md:w-12 md:h-12 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full flex items-center justify-center text-white font-semibold">
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
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

