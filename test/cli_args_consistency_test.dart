import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meesign_client/util/app_arg_parser.dart';

// The canonical set of CLI flag names. When you add or remove a flag in
// AppArgParser, update this list AND update the usage strings in:
//   - linux/my_application.cc       (USAGE_TEXT)
//   - windows/runner/utils.cpp      (kUsageText)
//   - macos/Runner/main.swift       (usageText)
const _canonicalFlags = {
  'help',
  'host',
  'name',
  'app-dir',
  'temp-dir',
  'downloads-dir',
  'documents-dir',
  'cache-dir',
};

void main() {
  group('CLI args consistency', () {
    test('AppArgParser registers exactly the canonical flag set', () {
      final parser = AppArgParser.buildParser();
      expect(
        parser.options.keys.toSet(),
        _canonicalFlags,
        reason: 'Flag set in AppArgParser drifted from canonical list. '
            'Update _canonicalFlags in this test, AND the native usage '
            'strings in linux/my_application.cc, windows/runner/utils.cpp, '
            'and macos/Runner/main.swift.',
      );
    });

    // Each native runner has its own copy of usage text (no shared source —
    // see the JSON-config discussion in the issue). These checks ensure
    // that every flag is at least mentioned in each native usage string.
    // They don't validate formatting or descriptions.
    final nativeUsageFiles = {
      'linux/my_application.cc': 'USAGE_TEXT',
      'windows/runner/utils.cpp': 'kUsageText',
      'macos/Runner/main.swift': 'usageText',
    };

    for (final entry in nativeUsageFiles.entries) {
      test('${entry.key} mentions every canonical flag', () {
        final file = File(entry.key);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Expected ${entry.key} to exist (run from project root).',
        );
        final contents = file.readAsStringSync();
        for (final flag in _canonicalFlags) {
          expect(
            contents.contains('--$flag'),
            isTrue,
            reason: '${entry.key} (${entry.value}) is missing --$flag. '
                'Add it to the usage string.',
          );
        }
      });
    }
  });
}
