import '../core/result.dart';
import '../entities/user_stats.dart';

/// Use case for loading the player's persisted lifetime statistics — high
/// scores, the set of every city ever named (drives the absolute-new-city
/// bonus), longest streak, and cities-played count. Returns default/empty stats
/// when nothing has been saved yet.
abstract class GetUserStatsUseCase {
  Future<Result<UserStats>> call();
}
