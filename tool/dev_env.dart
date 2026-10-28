import 'dart:convert';
import 'dart:io';

/// Reads one secret value from env/dev.json and stops the script if it is missing.
String readDevKey(String name) {
  // ── Open env/dev.json ──
  final file = File('env/dev.json');
  if (!file.existsSync()) {
    stderr.writeln(
      'env/dev.json not found. Copy env/dev.example.json to '
      'env/dev.json and paste your keys into it.',
    );
    exit(1);
  }

  // ── Find the value ──
  final values = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final value = values[name];
  if (value is! String || value.isEmpty || value.startsWith('PASTE_')) {
    stderr.writeln('$name is missing in env/dev.json.');
    exit(1);
  }
  return value;
}
