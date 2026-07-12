import 'package:injectable/injectable.dart';

import '../core/failure.dart';
import '../core/result.dart';
import '../entities/user_stats.dart';
import '../repositories/user_stats_repository.dart';
import 'get_user_stats_usecase.dart';

/// Loads lifetime [UserStats] from the repository, mapping any read error to a
/// [DataFailure] so the caller never has to catch across the layer boundary.
@LazySingleton(as: GetUserStatsUseCase)
class GetUserStatsUseCaseImpl implements GetUserStatsUseCase {
  final UserStatsRepository userStatsRepository;

  GetUserStatsUseCaseImpl(this.userStatsRepository);

  @override
  Future<Result<UserStats>> call() async {
    try {
      final stats = await userStatsRepository.getUserStats();
      return Result.success(stats);
    } catch (_) {
      return const Result.failure(DataFailure());
    }
  }
}
