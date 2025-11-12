import React, { useState } from 'react';
import { Star } from 'lucide-react';

interface StarRatingProps {
  matchId: number;
  onRate: (matchId: number, rating: number) => void;
  userRating?: number;
  disabled?: boolean;
}

export function StarRating({ matchId, onRate, userRating = 0, disabled = false }: StarRatingProps) {
  const [hoveredStar, setHoveredStar] = useState(0);

  const handleClick = (rating: number) => {
    if (!disabled) {
      onRate(matchId, rating);
    }
  };

  return (
    <div className="flex items-center gap-2">
      <span className="text-sm text-gray-600">Rate your excitement:</span>
      <div className="flex gap-1">
        {[1, 2, 3, 4, 5].map((star) => {
          const isActive = star <= (hoveredStar || userRating);
          return (
            <button
              key={star}
              type="button"
              onClick={() => handleClick(star)}
              onMouseEnter={() => !disabled && setHoveredStar(star)}
              onMouseLeave={() => setHoveredStar(0)}
              disabled={disabled}
              className={`transition-all ${disabled ? 'cursor-default' : 'cursor-pointer'}`}
            >
              <Star
                className={`w-5 h-5 transition-all ${
                  isActive ? 'fill-yellow-400 text-yellow-400' : 'fill-none text-gray-300'
                } ${!disabled && 'hover:scale-110'}`}
              />
            </button>
          );
        })}
      </div>
    </div>
  );
}