import 'dart:math';

import 'package:cities/engine/bot.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/difficulty.dart';

/// A bot that plays a fixed list of cities, then gives up.
class ScriptedBot extends CityBot {
  ScriptedBot(CityIndex index, List<City> script)
      : _script = [...script],
        super(index: index, difficulty: Difficulty.hard, random: Random(0));

  final List<City> _script;

  @override
  BotMove move({required String? requiredLetter, required Set<int> usedIds}) =>
      _script.isEmpty ? const BotGivesUp() : BotPlays(_script.removeAt(0));
}
