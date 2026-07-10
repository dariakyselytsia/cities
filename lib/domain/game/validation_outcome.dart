import '../entities/city.dart';

/// Base points awarded for a valid city.
const int kBasePoints = 10;

/// Extra points for an "absolute new" city — one the player has never named in
/// any previous session (requires persisted historic city ids; see the P1
/// User/UserStats persistence work).
const int kNewCityBonus = 25;

/// Why an answer was accepted or rejected.
enum AnswerStatus {
  /// Valid city, correct letter, not already used this session.
  accepted,

  /// No city with that name exists for the active mode.
  notFound,

  /// The city exists but starts with the wrong letter.
  wrongLetter,

  /// The city was already named earlier this session.
  alreadyUsed,
}

/// Result of validating a submitted city answer: the verdict, the matched
/// [City] (when one was found), and the points earned.
class ValidationOutcome {
  final AnswerStatus status;
  final City? city;
  final int points;

  /// True when the awarded points include the absolute-new-city bonus.
  final bool isNewToPlayer;

  const ValidationOutcome({
    required this.status,
    this.city,
    this.points = 0,
    this.isNewToPlayer = false,
  });

  const ValidationOutcome.accepted({
    required City city,
    required int points,
    bool isNewToPlayer = false,
  }) : this(
         status: AnswerStatus.accepted,
         city: city,
         points: points,
         isNewToPlayer: isNewToPlayer,
       );

  const ValidationOutcome.rejected(AnswerStatus status, {City? city})
    : this(status: status, city: city);

  bool get isAccepted => status == AnswerStatus.accepted;
}
