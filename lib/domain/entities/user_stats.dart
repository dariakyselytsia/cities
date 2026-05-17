/// Domain entity representing user statistics and progress.
class UserStats {
  final int highScoreUA;
  final int highScoreWorld;
  final List<int> usedCityIds;

  const UserStats({
    required this.highScoreUA,
    required this.highScoreWorld,
    required this.usedCityIds,
  });
}
