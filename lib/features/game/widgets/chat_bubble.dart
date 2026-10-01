import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../engine/city.dart';
import '../../../engine/letter_rule.dart';
import '../../../engine/match.dart';

/// One city in the chat: CityBot's on the left in a white card, the
/// player's on the right in coral. The first letter is accented so the chain
/// is easy to follow. The newest city also shows its [marks]: the letter the
/// next city may start with in teal, like the "your turn" banner: the
/// required one and the rarer ones skipped after it (light teal on the coral
/// and purple bubbles, where plain teal is hard to read). A hinted city is
/// purple with a bulb; a named one shows the points it earned.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.turn,
    required this.language,
    this.marks,
  });

  final Turn turn;
  final NameLanguage language;

  /// The next and skipped letters to mark; `null` for older cities.
  final LetterMarks? marks;

  @override
  Widget build(BuildContext context) {
    final isBot = turn.side == Side.bot;
    final background = isBot
        ? AppColors.card
        : (turn.isHint ? AppColors.purple : AppColors.coral);
    final ink = isBot ? AppColors.ink : Colors.white;
    final accent = isBot ? AppColors.coral : AppColors.yellow;
    final nextColor = isBot ? AppColors.teal : AppColors.tealLight;
    final name = turn.city.name(language) ?? turn.city.nameEn;

    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isBot ? 4 : 18),
            bottomRight: Radius.circular(isBot ? 18 : 4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (turn.isHint) ...[
              Icon(Icons.lightbulb_rounded, size: 16, color: accent),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: _AccentedName(
                name,
                marks: marks,
                ink: ink,
                accent: accent,
                nextColor: nextColor,
              ),
            ),
            if (!isBot && !turn.isHint) ...[
              const SizedBox(width: 10),
              Text(
                '+${turn.points}',
                style: heading(
                  size: 13,
                  weight: FontWeight.w800,
                  color: ink.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// [name] with its first letter in [accent], and the next and skipped
/// letters in [nextColor].
class _AccentedName extends StatelessWidget {
  const _AccentedName(
    this.name, {
    required this.marks,
    required this.ink,
    required this.accent,
    required this.nextColor,
  });

  final String name;
  final LetterMarks? marks;
  final Color ink;
  final Color accent;
  final Color nextColor;

  @override
  Widget build(BuildContext context) {
    final firstEnd = name.characters.isEmpty ? 0 : name.characters.first.length;
    final marked = <(int, int, Color)>[
      (0, firstEnd, accent),
      if (marks case final marks?) ...[
        if (marks.next case final next?) (next.start, next.end, nextColor),
        for (final skipped in marks.skipped)
          (skipped.start, skipped.end, nextColor),
      ],
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    final parts = <TextSpan>[];
    var at = 0;
    for (final (start, end, color) in marked) {
      // The first letter wins over a mark on the same character.
      if (start < at || end > name.length) continue;
      if (start > at) parts.add(TextSpan(text: name.substring(at, start)));
      parts.add(
        TextSpan(
          text: name.substring(start, end),
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      );
      at = end;
    }
    if (at < name.length) parts.add(TextSpan(text: name.substring(at)));
    return Text.rich(
      TextSpan(
        style: heading(size: 17, color: ink),
        children: parts,
      ),
    );
  }
}
