# Internal Project Packages
MeeSign Client consist out of the main application (frontend) and several internal packages used by the client.
1. /meesign_core
    - Implements the core functionality of the app, that can be reused for both GUI and CLI version of this app.
    - Fully manages the local database (drift_db), tables definitions etc
    - Defines and implements TaskRepositories. These repos use Drifts auto-generated DAO classes to manipulate the local database
    - It has direct dependency on meesign_network package, which is used in repositories to sync local db with remote db with NetworkDispatcher class 
    - Defines base logic for smart cards and policy controller
    - Contains model classes for tasks (domain objects)

2. /meessign_network
    - Package that is responsible for communication with the server
    - Uses gRPC as a communication protocol
    - Contains protobuffer to define endpoints on the server
   
3. /meesing_native
    - This package is responsible for managing all cryptographic operations in the app
    - Has another internal sub-package called meesign-crypto, which is written in Rust
    - Uses FFI to communicate with the meesign-crypto (bridge between Dart and Rust)

   


# Important folders in the Flutter project:
1. lib/app/
    - Entrypoint of the client
    - Defines tabbed scaffold logic (authenticated section)
2. lib/pages/
    - Contains all individual pages of the app (register, settings etc)
3. lib/widgets/
    - Contains all reusable widgets
4. lib/view_model/
    - Contains all view models used in the app
    - View models use the Change Notifier architecture
5. assets/
   - Contains all images, icons, and fonts
   - This is where we store lottie files (code-controllable animated images)


# State management architecture
## Provider
App mostly uses traditional Provider architecture together with Change Notifier in view models to separate advanced business logic from the UI.
You can find the provider-relevant code in main.dart and in app_container.dart

## rxDart
Some parts of the application also use rxDart to combine different streams  from db tables (drift provides reactive stream for all its tables),
in order to achieve better UI reactivity. It would be nice to unify  these state management approaches with BLOC in the future.




# Object immutability
Project uses the freezed package to generate immutable object classes along side with copyWith methods etc. Some parts of the application however 
still  do not use freezed annotation. This is task to be done in the future.






# Practical Use-Cases:

1. Updating the local DB schema
   a) Update the table definition in lib/src/database/tables.dart
   b) Update the database schema version in lib/src/database/database.dart
   c) Add migration logic in lib/src/database/database.dart
   d) Regenerate the database code: cd meesign_core && dart run build_runner build



2. Updating protobuffer schema to manage server endpoints
   a) Update the proto definition in proto/meesign.proto
   b) Install dependencies (if not already installed):
      # Install Protocol Buffers compiler
      # macOS: brew install protobuf
      # Ubuntu: apt-get install protobuf-compiler
   c) Install Dart plugin for protoc: dart pub global activate protoc_plugin
   d) Regenerate Dart gRPC code:
      cd meesign_network
      protoc --experimental_allow_proto3_optional \
      --plugin=protoc-gen-dart \
      --dart_out=grpc:lib/src/generated/ \
      -I proto proto/meesign.proto
   e) Format the generated code: dart format ./lib/src/generated/
   f) Restart the client and the server to apply changes



3. Add or modify protocols
   a) Add to protobuf enum in meesign_network/proto/meesign.proto
   b) Add to Rust enum in meesign_native/native/meesign-crypto/src/c_api.rs
   c) Add to Dart enum in meesign_core/lib/src/model/protocol.dart
   d) Rebuild Native Code:
      cd meesign_native
      flutter packages pub run ffigen
      dart run build_runner build




