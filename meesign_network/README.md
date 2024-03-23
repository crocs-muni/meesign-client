# MeeSign Network

## Regenerate gRPC code

If you modify a file in [proto](proto), regenerate the Dart gRPC code:

1. Install [Protocol buffers compiler](https://github.com/protocolbuffers/protobuf#protocol-compiler-installation)

2. Install [Dart plugin for protoc](https://pub.dev/packages/protoc_plugin):

   ```bash
   dart pub global activate protoc_plugin
   ```

   Note the path to the plugin executable or make sure it is available through `PATH`.

3. Generate Dart code:

   ```bash
   protoc --experimental_allow_proto3_optional --plugin=/path/to/bin/protoc-gen-dart --dart_out=grpc:lib/src/generated/ -I proto proto/meesign.proto
   ```

4. Format the generated code:

   ```bash
   dart format ./lib/src/generated/
   ```
