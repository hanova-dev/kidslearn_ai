import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/services/placeholder_illustrator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── Placeholder picture (FR-ILLUS-06, decision 010) ──
  test('draws a PNG picture with no network', () async {
    final image = await PlaceholderIllustrator().renderScene('x', 'y', 0);

    expect(image.source, 'PLACEHOLDER');
    expect(image.fileExtension, 'png');
    expect(image.bytes.sublist(1, 4), 'PNG'.codeUnits);
    expect(image.bytes.length, greaterThan(1000));
  });
}
