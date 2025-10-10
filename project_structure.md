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






_# Practical Use-Cases:

## 1. Updating the local DB schema

**Example: Adding the `isLocal` column to the `Devices` table**

### a) Update the table definition
See the Devices table definition in meesign_core/lib/src/database/tables.dart:8-16

```dart
class Devices extends Table {
  BlobColumn get id => blob()();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<DeviceKind>()();
  BoolColumn get isLocal => boolean().withDefault(const Constant(false))();  // New column added

  @override
  Set<Column> get primaryKey => {id};
}
```

### b) Update the database schema version
In meesign_core/lib/src/database/database.dart:43

```dart
@override
int get schemaVersion => 2;  // Increment version from 1 to 2
```

### c) Add migration logic
In meesign_core/lib/src/database/database.dart:46-53

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: (Migrator m, int from, int to) async {
    if (from < 2) {
      // Add isLocal column to Devices table with default value false
      await m.addColumn(devices, devices.isLocal);
    }
  },
);
```

### d) Regenerate the database code
```bash
cd meesign_core && dart run build_runner build
```

---

## 2. Updating protobuffer schema to manage server endpoints

**Example: Adding a new RPC endpoint or message type**

### a) Update the proto definition

**Service definition** in meesign_network/proto/meesign.proto:4-19
```protobuf
service MeeSign {
  rpc GetServerInfo(ServerInfoRequest) returns (ServerInfo);
  rpc Register(RegistrationRequest) returns (RegistrationResponse);
  rpc Sign(SignRequest) returns (Task);
  rpc Group(GroupRequest) returns (Task);
  rpc Decrypt(DecryptRequest) returns (Task);
  // Add new endpoints here...
}
```

**Message definition** in meesign_network/proto/meesign.proto:52-56
```protobuf
message RegistrationRequest {
  string name = 1;
  DeviceKind kind = 2;
  bytes csr = 3; // CSR in DER format
}
```

**Enum definition** in meesign_network/proto/meesign.proto:27-32
```protobuf
enum ProtocolType {
  GG18 = 0;
  ELGAMAL = 1;
  FROST = 2;
  MUSIG2 = 3;
}
```

### b) Install dependencies (if not already installed)
```bash
# Install Protocol Buffers compiler
# macOS: brew install protobuf
# Ubuntu: apt-get install protobuf-compiler
```

### c) Install Dart plugin for protoc
```bash
dart pub global activate protoc_plugin
```

### d) Regenerate Dart gRPC code
```bash
cd meesign_network
protoc --experimental_allow_proto3_optional \
  --plugin=protoc-gen-dart \
  --dart_out=grpc:lib/src/generated/ \
  -I proto proto/meesign.proto
```

### e) Format the generated code
```bash
dart format ./lib/src/generated/
```

### f) Restart the client and the server to apply changes

---

## 3. Add or modify protocols

**Example: How the protocol enums are synchronized across three layers**

### a) Add to protobuf enum
In meesign_network/proto/meesign.proto:27-32
```protobuf
enum ProtocolType {
  GG18 = 0;
  ELGAMAL = 1;
  FROST = 2;
  MUSIG2 = 3;
  // Add new protocol here with next number
}
```

### b) Add to Rust enum
In meesign_native/native/meesign-crypto/src/c_api.rs:21-28
```rust
#[repr(C)]
#[derive(Clone, Copy)]
pub enum ProtocolId {
    Gg18,
    Elgamal,
    Frost,
    Musig2,
    // Add new protocol here
}
```

And implement the conversion in meesign_native/native/meesign-crypto/src/c_api.rs:31-40
```rust
#[cfg(feature = "protocol")]
impl From<ProtocolId> for ProtocolType {
    fn from(pid: ProtocolId) -> Self {
        match pid {
            ProtocolId::Gg18 => ProtocolType::Gg18,
            ProtocolId::Elgamal => ProtocolType::Elgamal,
            ProtocolId::Frost => ProtocolType::Frost,
            ProtocolId::Musig2 => ProtocolType::Musig2,
            // Add conversion for new protocol
        }
    }
}
```

### c) Add to Dart enum
In meesign_core/lib/src/model/protocol.dart:9-28
```dart
enum Protocol {
  gg18(10, 10, ThresholdType.tOfN),
  elgamal(6, 2, ThresholdType.tOfN),
  frost(4, 3, ThresholdType.tOfN, aid: '6a6366726f7374617070'),
  musig2(2, 3, ThresholdType.nOfN, aid: '01ffff04050607081101');
  // Add new protocol here with keygen rounds, sign rounds, and threshold type

  final int keygenRounds;
  final int signRounds;
  final ThresholdType thresholdType;
  final String? aid;

  const Protocol(
    this.keygenRounds,
    this.signRounds,
    this.thresholdType, {
    this.aid,
  });
}
```

And implement the conversion methods in meesign_core/lib/src/model/protocol.dart:31-43
```dart
extension ProtocolConversion on Protocol {
  int toNative() => switch (this) {
        Protocol.gg18 => ProtocolId.Gg18,
        Protocol.elgamal => ProtocolId.Elgamal,
        Protocol.frost => ProtocolId.Frost,
        Protocol.musig2 => ProtocolId.Musig2,
        // Add conversion for new protocol
      };

  ProtocolType toNetwork() => switch (this) {
        Protocol.gg18 => ProtocolType.GG18,
        Protocol.elgamal => ProtocolType.ELGAMAL,
        Protocol.frost => ProtocolType.FROST,
        Protocol.musig2 => ProtocolType.MUSIG2,
        // Add conversion for new protocol
      };
}
```

### d) Rebuild Native Code
```bash
cd meesign_native
flutter packages pub run ffigen
dart run build_runner build
```

---

## 4. Adding translations (internationalization)

**Example: Adding a new translation key**

The app supports multiple languages (currently English and Czech). Translation files are located in lib/l10n/arb/

### a) Add the translation key to both language files

In lib/l10n/arb/app_en.arb:1-50
```json
{
  "languageSettingsTitle": "Language settings",
  "languageSettingsDescription": "Choose your preferred language...",
  "showArchivedItems": "Show archived items",
  // Add your new key here
  "myNewKey": "My new translation",
  "@myNewKey": {
    "description": "Description of what this translation is for"
  }
}
```

In lib/l10n/arb/app_cs.arb (Czech translation):
```json
{
  "languageSettingsTitle": "Nastavení jazyka",
  "myNewKey": "Můj nový překlad"
}
```

### b) Use the translation in your Dart code

```dart
import '../l10n/arb/app_localizations.dart';

// Inside your widget's build method:
Text(AppLocalizations.of(context)!.myNewKey)
```

### c) Regenerate localization files

Translations are automatically regenerated when you run the app. If needed, manually run:
```bash
flutter gen-l10n
```

**Note:** The l10n configuration is defined in pubspec.yaml with `flutter_localizations` SDK dependency.

---

## 5. Adding a new page/route

**Example: Creating a new settings page**

### a) Create the page file

Create a new file in `lib/pages/` directory:

lib/pages/my_new_page.dart
```dart
import 'package:flutter/material.dart';
import '../templates/default_page_template.dart';

class MyNewPage extends StatefulWidget {
  const MyNewPage({super.key});

  @override
  State<MyNewPage> createState() => _MyNewPageState();
}

class _MyNewPageState extends State<MyNewPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultPageTemplate(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('My New Page'),
            pinned: true,
          ),
          SliverList.list(
            children: [
              // Your page content here
            ],
          ),
        ],
      ),
    );
  }
}
```

See lib/pages/device_page.dart:1-80 for a complete page example.

### b) Add route to Routes class

In lib/routes.dart:1-9
```dart
class Routes {
  static const String home = '/home';
  static const String newGroup = '/new_group';
  static const String myNewPage = '/my_new_page';  // Add your route
  // ... other routes
}
```

### c) Register route in main.dart

In lib/main.dart:104-113
```dart
routes: {
  Routes.home: (_) => const TabbedScaffold(),
  Routes.newGroup: (_) => const NewGroupPage(),
  Routes.myNewPage: (_) => const MyNewPage(),  // Add your page
  // ... other routes
}
```

### d) Navigate to the page

```dart
Navigator.pushNamed(context, Routes.myNewPage);
```

---

## 6. Creating a new repository and DAO

**Example: Adding a repository to manage app data**

### a) Add table definition (if needed)

If you need a new table, add it to meesign_core/lib/src/database/tables.dart:8-103

### b) Create the DAO

Add your DAO to meesign_core/lib/src/database/daos.dart:1-260

```dart
@DriftAccessor(tables: [YourTable])
class YourDao extends DatabaseAccessor<Database> with _$YourDaoMixin {
  YourDao(super.db);

  Future<YourEntity?> getEntity(Uint8List id) {
    final query = select(yourTable)
      ..where((entity) => entity.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsertEntity(YourTableCompanion entity) {
    return into(yourTable).insertOnConflictUpdate(entity);
  }
}
```

### c) Create the repository

Create a new file meesign_core/lib/src/data/your_repository.dart

```dart
import 'package:drift/drift.dart';
import '../database/daos.dart';
import 'network_dispatcher.dart';

class YourRepository {
  final NetworkDispatcher _dispatcher;
  final YourDao _dao;

  YourRepository(this._dispatcher, this._dao);

  Future<YourEntity> getEntity(Uint8List id) async {
    return await _dao.getEntity(id);
  }

  Future<void> sync(Uuid did) async {
    // Sync with server using _dispatcher
    final response = await _dispatcher.auth.yourEndpoint();
    // Update local DB using _dao
  }
}
```

See meesign_core/lib/src/data/device_repository.dart:1-80 for a complete repository example.

### d) Register in AppContainer

Add your repository to lib/app_container.dart:1-102 if it needs to be globally accessible.

---

## 7. Working with ViewModels and Provider

**Example: Using AppViewModel to access application state**

The app uses Provider for state management. See lib/view_model/app_view_model.dart:1-279

### a) Access ViewModel in a widget

```dart
import 'package:provider/provider.dart';
import '../view_model/app_view_model.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appViewModel = context.watch<AppViewModel>();

    // Access data
    final tasks = appViewModel.signTasks;

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Text(tasks[index].info.name);
      },
    );
  }
}
```

### b) Listen to streams

The AppViewModel uses rxDart to combine multiple streams. See lib/view_model/app_view_model.dart:93-112

```dart
StreamBuilder<TaskStream>(
  stream: appViewModel.combinedTaskStream,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();

    final taskStream = snapshot.data!;
    return Text('Tasks: ${taskStream.signTasks.length}');
  },
)
```

### c) Trigger actions

```dart
// Approve a task
await appViewModel.joinSign(task, agree: true);

// Archive a task
await appViewModel.archiveTask(task, archive: true);

// Refresh tasks
await appViewModel.refetchTasks(TaskType.sign);
```

---

## 8. Running and building the application

### a) Run in development mode

```bash
# Run on connected device/emulator
flutter run

# Run with specific arguments
flutter run --dart-define=ALLOW_BAD_CERTS=true

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

### b) Build for production

**Android:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**iOS:**
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode and archive
```

**Desktop (Linux):**
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

**Desktop (macOS):**
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

**Desktop (Windows):**
```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

### c) Clean and regenerate

```bash
# Clean build files
flutter clean

# Get dependencies
flutter pub get

# Regenerate generated files (database, freezed models, etc.)
cd meesign_core && dart run build_runner build --delete-conflicting-outputs
```

### d) Run tests

```bash
flutter test
```

---

## 9. Working with generated code (freezed models)

The project uses freezed for immutable data classes. See pubspec.yaml:83 for freezed dependencies.

### a) Create a freezed model

Create a new file with freezed annotations:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_model.freezed.dart';

@freezed
class MyModel with _$MyModel {
  const factory MyModel({
    required String id,
    required String name,
    int? optionalValue,
  }) = _MyModel;
}
```

### b) Generate the freezed code

```bash
dart run build_runner build
```

### c) Use the model

```dart
// Create instance
final model = MyModel(id: '123', name: 'Test');

// Copy with modifications
final updated = model.copyWith(name: 'Updated');

// Pattern matching
model.when(/* ... */);
```

**Note:** The project has started using freezed but not all models have been migrated yet. See project_structure.md:52-54




