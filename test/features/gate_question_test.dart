import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/features/auth/controllers/gate_question.dart';

void main() {
  // ── Answer and text ──
  test('answer is the sum and text shows the question', () {
    const question = GateQuestion(14, 9);

    expect(question.answer, 23);
    expect(question.text, '14 + 9 = ?');
  });

  // ── Random questions stay in the agreed ranges (decision 003) ──
  test('random questions are 12–29 plus 6–9', () {
    final random = Random(7);
    for (var i = 0; i < 500; i++) {
      final question = GateQuestion.random(random);
      expect(question.first, inInclusiveRange(12, 29));
      expect(question.second, inInclusiveRange(6, 9));
    }
  });
}
