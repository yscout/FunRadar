import React from 'react';
import { motion } from 'motion/react';
import { Button } from './ui/button';
import { Sparkles } from 'lucide-react';

interface IntroScreenProps {
  onGetStarted: () => void;
}

export function IntroScreen({ onGetStarted }: IntroScreenProps) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="h-full min-h-[700px] md:min-h-[800px] bg-gradient-to-br from-purple-400 via-pink-300 to-orange-300 flex flex-col items-center justify-center p-8 md:p-16 relative overflow-hidden"
    >
      {/* Decorative circles */}
      <div className="absolute top-20 left-10 w-32 h-32 md:w-48 md:h-48 bg-white/20 rounded-full blur-2xl" />
      <div className="absolute bottom-40 right-10 w-40 h-40 md:w-56 md:h-56 bg-white/20 rounded-full blur-2xl" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 md:w-96 md:h-96 bg-white/10 rounded-full blur-3xl" />
      
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-center mb-12 md:mb-16 relative z-10"
      >
        <div className="mb-6 md:mb-8 flex justify-center">
          <div className="w-24 h-24 md:w-32 md:h-32 bg-white rounded-3xl flex items-center justify-center shadow-lg">
            <Sparkles className="w-12 h-12 md:w-16 md:h-16 text-purple-500" />
          </div>
        </div>
        
        <motion.h1
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.4 }}
          className="text-white mb-3 text-4xl md:text-6xl"
        >
          Gather&Go
        </motion.h1>
        
        <motion.p
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="text-white/90 text-xl md:text-2xl"
        >
          Plan faster. Go together.
        </motion.p>
      </motion.div>

      <motion.div
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.7 }}
        className="w-full max-w-sm md:max-w-md relative z-10"
      >
        <Button
          onClick={onGetStarted}
          className="w-full bg-white text-purple-600 hover:bg-white/90 h-14 md:h-16 rounded-2xl shadow-xl text-lg"
          size="lg"
        >
          Get Started
        </Button>
      </motion.div>

      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.9 }}
        className="mt-8 md:mt-12 text-center relative z-10"
      >
        <p className="text-white/70 text-sm md:text-base">
          Make plans with friends in seconds
        </p>
      </motion.div>
    </motion.div>
  );
}