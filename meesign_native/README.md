# MeeSign Native

## Regenerate Dart-C bindings

If you modify native libraries in [lib-native](lib-native), update Dart bindings by running:

```bash
dart run ffigen --config ffigen/changed-lib.yaml
```

This regenerates the files as specified by the provided ffigen configuration. (Note that [ffigen requires LLVM](https://pub.dev/packages/ffigen).)
