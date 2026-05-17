import 'user_stats.dart';

/// Domain entity representing a User/Player profile.
class User {
  /// Unique identifier (Supabase Auth ID or local UUID)
  final String id;

  /// Language preference (e.g., 'en', 'uk')
  final String languagePreference;

  /// High scores per mode/language (e.g., {'UA': 100, 'WORLD': 200})
  final Map<String, int> highScores;

  /// User statistics (historic used city IDs, etc.)
  final UserStats stats;

  const User({
    required this.id,
    required this.languagePreference,
    required this.highScores,
    required this.stats,
  });
}
