import 'dart:math';

/// A sum young children cannot easily solve, e.g. 14 + 9 (decision 003).
class GateQuestion {
  const GateQuestion(this.first, this.second);

  final int first;
  final int second;

  int get answer => first + second;

  String get text => '$first + $second = ?';

  /// A two-digit number from 12 to 29 plus a one-digit number from 6 to 9.
  factory GateQuestion.random(Random random) {
    final first = 12 + random.nextInt(18);
    final second = 6 + random.nextInt(4);
    return GateQuestion(first, second);
  }
}
