import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';

// should eventually be replaced by a Rust-focused package:
// https://github.com/dart-lang/native/issues/883

String selectTarget(BuildConfig config) {
  return switch ((config.targetOS, config.targetArchitecture)) {
    (OS.linux, Architecture.x64) => 'x86_64-unknown-linux-gnu',
    (OS.windows, Architecture.x64) => 'x86_64-pc-windows-msvc',
    (OS.macOS, Architecture.x64) => 'x86_64-apple-darwin',
    (OS.macOS, Architecture.arm64) => 'aarch64-apple-darwin',
    (OS.android, Architecture.x64) => 'x86_64-linux-android',
    (OS.android, Architecture.arm64) => 'aarch64-linux-android',
    (OS.android, Architecture.arm) => 'armv7-linux-androideabi',
    (OS.iOS, Architecture.arm64) => config.targetIOSSdk == IOSSdk.iPhoneOS
        ? 'aarch64-apple-ios'
        : 'aarch64-apple-ios-sim',
    _ => throw UnsupportedError(
        '(${config.targetOS}, ${config.targetArchitecture}) not supported'),
  };
}

String libPrefix(OS os) => switch (os) {
      OS.linux || OS.macOS || OS.android || OS.iOS => 'lib',
      _ => '',
    };

String libSuffix(OS os) => switch (os) {
      OS.linux || OS.android => '.so',
      OS.macOS || OS.iOS => '.dylib',
      OS.windows => '.dll',
      _ => throw UnsupportedError(''),
    };

void main(List<String> args) async {
  await build(args, (config, output) async {
    if (config.linkModePreference == LinkModePreference.static) {
      // Simulate that this hook only supports dynamic libraries.
      throw UnsupportedError(
        'LinkModePreference.static is not supported.',
      );
    }

    String libName =
        '${libPrefix(config.targetOS)}meesign_crypto${libSuffix(config.targetOS)}';
    final assetPath = config.outputDirectory.resolve(libName);
    final cryptoDir = config.packageRoot.resolve('native/meesign-crypto/');

    if (!config.dryRun) {
      final target = selectTarget(config);

      final result = await Process.run(
        'cargo',
        ['build', '--release', '--target', target],
        workingDirectory: cryptoDir.toFilePath(),
        includeParentEnvironment: true,
        runInShell: true,
        environment: {
          'CC': config.cCompiler.compiler?.toFilePath() ?? '',
          'AR': config.cCompiler.archiver?.toFilePath() ?? '',
        },
      );
      stdout.write(result.stdout);
      stderr.write(result.stderr);

      final libUri = cryptoDir.resolve('target/$target/release/$libName');
      await File.fromUri(libUri).copy(assetPath.toFilePath());

      output.addDependencies([
        cryptoDir,
        config.packageRoot.resolve('hook/build.dart'),
      ]);
    }

    output.addAsset(
      // TODO: Change to DataAsset once the Dart/Flutter SDK can consume it.
      NativeCodeAsset(
        package: config.packageName,
        name: 'libmeesign_crypto',
        file: assetPath,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: config.targetArchitecture,
      ),
    );
  });
}
