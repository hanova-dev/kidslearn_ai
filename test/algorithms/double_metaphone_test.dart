import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/algorithms/double_metaphone.dart';

String code(String word) => DoubleMetaphone.encode(word);

void main() {
  // ── Clean-up before the rules ──
  test('no letters gives an empty code', () {
    expect(code(''), '');
    expect(code('!?'), '');
    expect(code('123'), '');
  });

  test('case and punctuation do not matter', () {
    expect(code('Elephant!'), code('elephant'));
    expect(code("Mango's"), code('mangos'));
  });

  // ── Vowels: only a first vowel is kept, as A ──
  test('a vowel at the start becomes A; other vowels are dropped', () {
    expect(code('apple'), 'APL');
    expect(code('egg'), 'AK');
    expect(code('Mango'), 'MNK');
  });

  // ── Silent first letters ──
  test('KN, GN, PN and WR lose their first letter; WH is W', () {
    expect(code('knee'), 'N');
    expect(code('gnome'), 'NM');
    expect(code('write'), 'RT');
    expect(code('whale'), 'WL');
  });

  // ── Letter pairs ──
  test('PH sounds like F', () {
    expect(code('phone'), 'FN');
    expect(code('elephant'), 'ALFNT');
  });

  test('GH is silent, except at the start', () {
    expect(code('night'), 'NT');
    expect(code('knight'), 'NT');
    expect(code('ghost'), 'KST');
  });

  test('C is S before E, I or Y, otherwise K; CK is one K', () {
    expect(code('city'), 'ST');
    expect(code('cat'), 'KT');
    expect(code('duck'), 'TK');
  });

  test('CH and SH are X, TH is 0 (the "th" sound)', () {
    expect(code('chair'), 'XR');
    expect(code('ship'), 'XP');
    expect(code('the'), '0');
    expect(code('bath'), 'P0');
  });

  test('G is J before E, I or Y, otherwise K; DGE is J', () {
    expect(code('giraffe'), 'JRF');
    expect(code('dog'), 'TK');
    expect(code('edge'), 'AJ');
  });

  test('TIO and SIA sound like X', () {
    expect(code('nation'), 'NXN');
    expect(code('Asia'), 'AX');
  });

  // ── Single letters that change ──
  test('B is P, V is F, Q is K, X is KS, Z is S', () {
    expect(code('ball'), 'PL');
    expect(code('very'), 'FR');
    expect(code('queen'), 'KN');
    expect(code('fox'), 'FKS');
    expect(code('zoo'), 'S');
  });

  test('MB at the end loses the B', () {
    expect(code('lamb'), 'LM');
  });

  test('H, W and Y count only before a vowel', () {
    expect(code('hat'), 'HT');
    expect(code('oh'), 'A');
    expect(code('yes'), 'YS');
    expect(code('cow'), 'K');
    expect(code('play'), 'PL');
  });

  // ── Double letters count once ──
  test('double letters count once', () {
    expect(code('rabbit'), 'RPT');
    expect(code('ball'), code('bal'));
  });

  // ── Words that sound the same get the same code ──
  test('sound-alike spellings get the same code', () {
    expect(code('sun'), code('son'));
    expect(code('elefant'), code('elephant'));
    expect(code('fone'), code('phone'));
    expect(code('kat'), code('cat'));
  });
}
