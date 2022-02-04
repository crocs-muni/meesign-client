# meesign client

A new Flutter project.

## Build

1. [Install Flutter](https://flutter.dev/docs/get-started/install), be sure to also follow the instructions for the platform you want to build for, i.e. **enable desktop support or set up Android SDK** (all described on the same page). At the moment, the following targets are supported: **Linux, Windows, Android**

2. [Install Rust](https://www.rust-lang.org/tools/install)
   1. Android only:
      1. Add Android targets for cross-compilation

         ```bash
         rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android
         ```

      2. Point cargo to the linker provided by Android NDK, a helper script for generating the necessary configuration is provided in [tool/cargo-config-gen-android.sh](tool/cargo-config-gen-android.sh), append the output to your [cargo configuration file](https://doc.rust-lang.org/cargo/reference/config.html#hierarchical-structure), e.g. by:

         ```bash
         ANDROID_NDK_HOME="path/to/ndk/version" ANDROID_API="30" bash ./tool/cargo-config-gen-android.sh >> ~/.cargo/config.toml
         ```

3. Clone the repository **with submodules**:

   ```bash
   git clone --recurse-submodules https://github.com/crocs-muni/meesign-client
   ```

4. Build the app:

   ```bash
   flutter build
   ```

   or run it directly:

   ```bash
   flutter run
   ```

## Contributing

### Regenerate Dart-C bindings

If you modify native libraries in [lib-native](lib-native), update Dart bindings by running:

```bash
flutter pub run ffigen --config ffigen/changed-lib.yaml
```

This regenerates the files as specified by the provided ffigen configuration. (Note that [ffigen requires LLVM](https://pub.dev/packages/ffigen).)

### Regenerate gRPC code

If you modify a file in [proto](proto), regenerate the Dart gRPC code:

1. Install [Protocol buffers compiler](https://github.com/protocolbuffers/protobuf#protocol-compiler-installation)

2. Install [Dart plugin for protoc](https://pub.dev/packages/protoc_plugin):

   ```bash
   flutter pub global activate protoc_plugin
   ```

   Note the path to the plugin executable or make sure it is available through `PATH`.

3. Generate Dart code:

   ```bash
   protoc --experimental_allow_proto3_optional --plugin=/path/to/bin/protoc-gen-dart --dart_out=grpc:lib/grpc/generated/ -I proto proto/mpc.proto
   ```
