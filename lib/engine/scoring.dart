/// Scoring (game_design §2.8). Tuning values (T20).
library;

import 'difficulty.dart';

/// Points for a city the player names.
const int pointsForCity = 10;

/// Points instead of [pointsForCity] for a city the player has **never
/// named before** in any game: the reward for discovering cities.
const int pointsForNewCity = 25;

/// Points for a city played by a hint: it only keeps the game alive.
const int pointsForHint = 0;

/// The win bonus, multiplied by [Difficulty.winMultiplier].
const int winBonus = 50;

/// The points for winning on [difficulty]: 50 / 100 / 150.
int winPoints(Difficulty difficulty) => winBonus * difficulty.winMultiplier;
