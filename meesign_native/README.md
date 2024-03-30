# MeeSign Native

This is a Dart package providing bindings to the following native libraries (see [native](native/)):

* [meesign_crypto](native/meesign-crypto/)

## Compiling native libraries

When building [meesign_client](..), the compilation and bundling of the native libraries are integrated into the Flutter build proccess using [native/CMakeLists.txt](native/CMakeLists.txt).

If you wish to use [meesign_native](./) as a stand-alone Dart package, independently of [meesign_client](..) and Flutter, e.g., when testing [meesign_core](../meesign_core/):

1. Compile the native libraries manually.

   __Note:__ [meesign_crypto](native/meesign-crypto/) must be built with the `bindings` feature enabled.

2. Ensure that the Dart application depending on [meesign_native](./) can find the built libraries.

   On Linux, this can be achieved by setting the `LD_LIBRARY_PATH` environment variable, for example.

## Regenerating Dart-C bindings

If you modify any native library, update the Dart bindings by running:

```bash
dart run ffigen --config ffigen/changed-lib.yaml
```

This regenerates the files as specified by the provided ffigen configuration. (Note that [ffigen requires LLVM](https://pub.dev/packages/ffigen).)

Also make sure that the generated files are formatted properly:

```bash
dart format ./lib/src/generated/
```
