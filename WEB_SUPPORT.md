# MeeSign Web Platform Support

This document describes the implementation of web browser support for the MeeSign client, covering architecture decisions, platform abstraction patterns, WASM cryptography, authentication changes, and known limitations.

## Table of Contents

1. [Overview](#overview)
2. [Architecture: Conditional Imports](#architecture-conditional-imports)
3. [Cryptography: Rust to WASM](#cryptography-rust-to-wasm)
4. [Authentication: mTLS to JWT](#authentication-mtls-to-jwt)
5. [Networking: gRPC to gRPC-Web](#networking-grpc-to-grpc-web)
6. [Database: SQLite via WASM](#database-sqlite-via-wasm)
7. [Storage: IndexedDB Persistence](#storage-indexeddb-persistence)
8. [Platform Guards](#platform-guards)
9. [Server Changes](#server-changes)
10. [Web Assets](#web-assets)
11. [Build Instructions](#build-instructions)
12. [Known Limitations](#known-limitations)

---

## Overview

The native client uses `dart:ffi` for Rust crypto, `dart:io` for file/network operations, and mTLS for server authentication. None of these APIs exist in web browsers, so every platform-dependent layer needed a web-specific alternative:

| Concern | Native | Web |
|---------|--------|-----|
| Cryptography | FFI to Rust `.so`/`.dylib` | WASM (`wasm-bindgen`) |
| Authentication | mTLS client certificates | JWT Bearer tokens |
| gRPC transport | HTTP/2 with `ClientChannel` | gRPC-Web over HTTP/1.1 with XHR |
| Database | SQLite via `drift/native` | SQLite via `drift/wasm` (OPFS) |
| Key storage | PKCS12 files on disk | IndexedDB (`meesign_storage`) + in-memory cache |
| File storage | Filesystem directories | IndexedDB (`meesign_storage`) + in-memory cache |
| File open/share | `open_filex` / `share_plus` | Browser download via Blob URL |
| Biometrics | `local_auth` plugin | Skipped (`kIsWeb` guard) |
| Smart cards | NFC / PC/SC plugins | Not available |

---

## Architecture: Conditional Imports

Dart's conditional import/export mechanism is the foundation of all platform abstraction. The pattern uses `dart.library.*` checks resolved at compile time:

```dart
// Example: key_store.dart
export 'key_store_stub.dart'
    if (dart.library.io) 'key_store_native.dart'
    if (dart.library.js_interop) 'key_store_web.dart';
```

Every platform-dependent module follows the **three-file pattern**:

1. **`_stub.dart`** -- Default fallback that throws `UnsupportedError`. Selected when neither `dart:io` nor `dart:js_interop` is available.
2. **`_native.dart`** (or `_io.dart`) -- Native implementation using `dart:io`, `dart:ffi`, etc. Selected when `dart.library.io` is present.
3. **`_web.dart`** -- Web implementation using `dart:js_interop`, `dart:html`, etc. Selected when `dart.library.js_interop` is present.

### Files using this pattern

| Module | Router file | Native | Web | Stub |
|--------|-------------|--------|-----|------|
| Key store | `key_store.dart` | `key_store_native.dart` | `key_store_web.dart` | `key_store_stub.dart` |
| File store | `file_store.dart` | `file_store_native.dart` | `file_store_web.dart` | `file_store_stub.dart` |
| Database | `database.dart` | `database_connection_native.dart` | `database_connection_web.dart` | `database_connection_stub.dart` |
| Crypto | `meesign_native.dart` | `crypto_ffi.dart` | `crypto_wasm.dart` | `crypto_stub.dart` |
| gRPC client | `client_factory.dart` | `client_factory_io.dart` | `client_factory_web.dart` | `client_factory_stub.dart` |
| App directory | `app_dir_getter.dart` | `app_dir_getter_native.dart` | `app_dir_getter_web.dart` | `app_dir_getter_stub.dart` |
| Platform info | `platform.dart` | `platform_io.dart` | *(uses `kIsWeb`)* | `platform_io_stub.dart` |
| Smart cards | `card.dart` | `card_factory_native.dart` | *(not available)* | `card_factory_stub.dart` |
| File download | `web_file_opener.dart` | *(uses `open_filex`/`share_plus`)* | `web_file_opener_web.dart` | `web_file_opener_stub.dart` |

### Why this pattern?

Importing `dart:io` or `dart:ffi` in code compiled for web causes a compilation failure. The conditional import mechanism ensures platform-specific code is never loaded on the wrong target. The stub provides a safe default when neither platform is detected.

---

## Cryptography: Rust to WASM

### Native path (FFI)

On native platforms, the Rust crypto library (`meesign-crypto`) is compiled to a shared library (`.so`/`.dylib`/`.dll`) and accessed via `dart:ffi` through C bindings defined in `c_api.rs`. The FFI implementation uses `Isolate.run()` for the computationally expensive `protocolAdvance` operation to avoid blocking the UI thread.

### Web path (WASM)

On web, the same Rust code is compiled to WebAssembly using `wasm-pack` with the `--target no-modules` flag. The WASM module exposes functions through `wasm-bindgen` JS glue code.

#### Build command

```bash
cd meesign_native/native/meesign-crypto
wasm-pack build --target no-modules --no-default-features --features "wasm,elgamal,frost,gg18,musig2"
```

The `--target no-modules` flag is critical: it produces a script that declares `wasm_bindgen` as a `let` variable (not an ES module), making it accessible after manual assignment to `window`.

#### WASM initialization

The WASM module is loaded in two stages:

**Stage 1 -- HTML (`web/index.html`):**
```html
<script src="meesign_crypto.js"></script>
<script>window.wasm_bindgen = wasm_bindgen;</script>
```

The second `<script>` line is necessary because `let wasm_bindgen;` at the top level of `meesign_crypto.js` does **not** become a property of `globalThis`/`window` (only `var` does). Without this explicit assignment, Dart's `globalContext['wasm_bindgen']` returns `null`.

**Stage 2 -- Dart (`crypto_wasm.dart`):**
```dart
Future<CryptoInterface> createCryptoInstance() async {
  final wbInit = globalContext['wasm_bindgen']! as JSFunction;
  final promise = wbInit.callAsFunction(null, 'meesign_crypto_bg.wasm'.toJS)! as JSPromise;
  await promise.toDart;
  // Module is now initialized, functions available on wasm_bindgen object
}
```

The `createCryptoInstance()` function is `async` on all platforms for API consistency, even though the FFI version completes synchronously.

#### The `typetag`/`inventory` incompatibility

The native Rust build uses `typetag` for serializing trait objects (`Box<dyn Protocol>`). `typetag` depends on `inventory`, which uses `#[ctor]` for static initialization. The `#[ctor]` attribute generates `__ctor` functions that `wasm-bindgen` cannot handle, causing a panic at runtime.

**Solution: `ProtocolBox` enum** (`security/protocol_box.rs`)

For WASM builds, trait object serialization is replaced with an explicit enum that wraps all protocol types:

```rust
#[derive(Serialize, Deserialize)]
pub(crate) enum ProtocolBox {
    #[cfg(feature = "gg18")]    Gg18Keygen(gg18::KeygenContext),
    #[cfg(feature = "elgamal")]  ElgamalKeygen(elgamal::KeygenContext),
    #[cfg(feature = "frost")]    FrostKeygen(frost::KeygenContext),
    // ... all protocol variants
}
```

The `SecureLayer` struct uses `Box<dyn Protocol>` when `typetag` is enabled (native) and `ProtocolBox` when it is not (WASM). This is controlled by `#[cfg(feature = "typetag")]` guards in `security/mod.rs`.

#### Cargo feature configuration

```toml
[features]
default = ["gg18", "frost", "elgamal", "bindings", "musig2", "typetag"]
typetag = ["dep:typetag"]    # Explicit feature declaration required
wasm = ["dep:wasm-bindgen"]
bindings = []                 # Gates c_api.rs (uses Box<dyn Protocol>)
protocol = []
gg18 = ["protocol", "dep:mpecdsa"]
frost = ["protocol", "dep:frost-secp256k1"]
elgamal = ["protocol", "elgamal-encrypt", "dep:elastic-elgamal"]
musig2 = ["protocol", "dep:musig2"]
```

Key detail: `dep:typetag` in the dependency syntax does **not** automatically create a `typetag` feature. The line `typetag = ["dep:typetag"]` is required for `#[cfg(feature = "typetag")]` to work.

The `c_api.rs` module (FFI bindings) is gated behind the `bindings` feature because it uses `Box<dyn Protocol>`, which requires `typetag`:

```rust
#[cfg(feature = "bindings")]
pub mod c_api;
```

---

## Authentication: mTLS to JWT

### Problem

Native clients authenticate via mTLS: each device has a client certificate issued by the server's CA, presented during the TLS handshake. Browsers cannot programmatically present TLS client certificates, so an alternative authentication mechanism was needed.

### Solution: JWT tokens

During registration, the server generates a JWT token containing the device ID and returns it alongside the certificate in the `RegistrationResponse`:

```protobuf
message RegistrationResponse {
  bytes device_id = 1;
  bytes certificate = 2;
  optional string auth_token = 3;  // JWT for web clients
}
```

The server's `extract_device_id()` function implements dual-path authentication:

```rust
fn extract_device_id<T>(request: &Request<T>) -> Option<Vec<u8>> {
    // Path 1: mTLS peer certificate (native clients)
    if let Some(certs) = request.peer_certs() { ... }
    // Path 2: JWT token in metadata (web clients)
    if let Some(auth_header) = request.metadata().get("authorization") { ... }
    None
}
```

This is transparent to the rest of the server code -- `extract_device_id()` is called uniformly regardless of client type.

### Client-side token handling

The `KeyStore` interface was extended with `storeToken()`/`loadToken()` methods:
- **Native** (`key_store_native.dart`): Token methods are no-ops (mTLS is used instead).
- **Web** (`key_store_web.dart`): Tokens are stored in an in-memory `Map<String, String>`.

The `NetworkDispatcher` passes the token to `ClientFactory.create()`, which on web sets it as gRPC metadata:

```dart
// client_factory_web.dart
final options = authToken != null
    ? CallOptions(metadata: {'authorization': 'Bearer $authToken'})
    : null;
return MeeSignClient(channel, options: options);
```

### JWT secret management

The server auto-generates a 32-byte secret at `keys/jwt-secret.key` on first run. For production deployments, this file should be pre-provisioned and persisted.

---

## Networking: gRPC to gRPC-Web

### Why gRPC-Web?

Browsers cannot make raw HTTP/2 gRPC calls. gRPC-Web is a protocol that encodes gRPC messages over HTTP/1.1, making them compatible with browser `XMLHttpRequest` and `fetch` APIs.

### Client implementation

```dart
// client_factory_web.dart
final channel = GrpcWebClientChannel.xhr(
  Uri.parse('https://$host:$port'),
);
```

The web client uses `GrpcWebClientChannel.xhr()` from the `grpc` Dart package. All mTLS parameters (key, clientCerts, serverCerts) are ignored since browsers handle TLS at the platform level.

### Server implementation

The server wraps the gRPC service with `tonic_web::enable()` to auto-detect and translate gRPC-Web requests:

```rust
let grpc_web_service = tonic_web::enable(MeeSignServer::new(node));
Server::builder()
    .accept_http1(true)
    .layer(cors)
    .add_service(grpc_web_service)
```

### CORS configuration

The `authorization` header used for JWT auth triggers CORS preflight requests. The default CORS headers from `tonic_web::enable()` do not include `authorization` in the allowed headers list, causing browser preflight failures.

**Fix:** An explicit `CorsLayer::permissive()` from `tower-http` is added as an outer layer on the server. This handles OPTIONS preflight with all necessary headers (including `authorization`). For POST responses, both layers add CORS headers, but `CorsLayer`'s `insert()` replaces `tonic-web`'s values (avoiding duplicates since `HeaderMap::insert()` replaces existing entries).

```rust
let cors = CorsLayer::permissive();
Server::builder()
    .accept_http1(true)
    .tls_config(...)
    .layer(cors)           // outer: handles preflight + replaces CORS headers
    .add_service(grpc_web_service)  // inner: protocol translation + basic CORS
```

### Server streaming

The `SubscribeUpdates` RPC uses server-side streaming. gRPC-Web supports this via chunked transfer encoding with `application/grpc-web-text` (base64-encoded frames). The browser reads partial responses via XHR `readyState == 3` (LOADING).

---

## Database: SQLite via WASM

Drift (the ORM) supports web through a WASM-compiled SQLite running in a Web Worker.

### Native connection

```dart
// database_connection_native.dart
QueryExecutor openDatabaseConnection(String dbFolder) {
  return LazyDatabase(() async {
    final file = File(p.join(dbFolder, 'meesign.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

### Web connection

```dart
// database_connection_web.dart
QueryExecutor openDatabaseConnection(String dbFolder) {
  return DatabaseConnection.delayed(Future(() async {
    final db = await WasmDatabase.open(
      databaseName: 'meesign_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return db.resolvedExecutor;
  }));
}
```

The `dbFolder` parameter is ignored on web since Drift uses browser-managed storage (OPFS/IndexedDB).

### Required web assets

Two files must be served alongside the Flutter web build:
- **`sqlite3.wasm`** -- From the `sqlite3` Dart package releases. Must match the version in `pubspec.lock` (e.g., v2.9.4 for `sqlite3: ^2.4.7`). **Critical:** Drift uses `sqlite3` 2.x; files from 3.x are incompatible.
- **`drift_worker.js`** -- From the `drift` package releases. Must match the version in `pubspec.lock` (e.g., v2.30.1).

---

## Storage: IndexedDB Persistence

### Architecture

On web, `KeyStore` and `FileStore` persist data in a dedicated IndexedDB database (`meesign_storage`) separate from Drift's SQLite database (`meesign_db`). This separation exists because Drift's WASM database is a serialized SQLite blob inside IndexedDB — mixing large binary blobs (files up to 8 MB) into it would bloat the WAL and complicate migrations.

The `IndexedDbStore` helper class (`indexed_db_store.dart`) wraps the IndexedDB API using `package:web` typed bindings. It manages two object stores:

| Object Store | Key Path | Contents |
|---|---|---|
| `keys` | `id` (device UUID) | PKCS#12 certificate (`Uint8Array`) + JWT token (`string?`) |
| `files` | `path` (virtual path) | File data (`Uint8Array`) |

### Cache-on-init pattern

Both web stores use an in-memory `Map` as a read-through cache. This is necessary because `KeyStore.load()` is synchronous (matching the native API which uses `readAsBytesSync`). The lifecycle is:

1. **`init()`** — Called at startup; loads all entries from IndexedDB into the in-memory cache.
2. **`store()`/`storeFile()`** — Writes to both the cache and IndexedDB (write-through).
3. **`load()`/`getFileBytes()`** — Reads from the cache only (synchronous).
4. **`deleteDirectory()`** — Removes matching entries from both cache and IndexedDB.

### KeyStore

- **Native:** Stores PKCS12 files at `<appDir>/<deviceId>/key.p12`. Token methods are no-ops (mTLS is used).
- **Web:** Persists keys and JWT tokens in IndexedDB (`meesign_storage/keys`), cached in memory at startup.

### FileStore

- **Native:** Stores files in a directory hierarchy under the app directory.
- **Web:** Persists files in IndexedDB (`meesign_storage/files`), cached in memory at startup. Files can be retrieved via `getFileBytes()` and downloaded through the browser using `downloadFileOnWeb()` (creates a Blob URL and triggers a download via a hidden `<a>` element).

---

## Platform Guards

### PlatformGroup

The `PlatformGroup` class (`lib/util/platform.dart`) provides static boolean flags for platform detection:

```dart
class PlatformGroup {
  static const bool isWeb = kIsWeb;
  static final bool isMobile = !kIsWeb && platformIsMobile();
  static final bool isDesktop = !kIsWeb && platformIsDesktop();
  // ...
}
```

The `platformIsMobile()` etc. functions are themselves conditionally imported to avoid referencing `dart:io.Platform` on web.

### Web detection without Flutter

In `meesign_core` (a pure Dart package without Flutter dependency), web detection uses the `identical(0, 0.0)` trick:

```dart
const bool _kIsWeb = identical(0, 0.0);
```

On web platforms, `int` and `double` are the same JavaScript `number` type, so `identical(0, 0.0)` returns `true`. On native platforms, they are distinct types, so it returns `false`.

### Feature filtering

The `Protocol` enum has a `webSupported` flag indicating which protocols are available in the WASM build. All four protocols are currently supported on web:

```dart
enum Protocol {
  gg18(10, 10, ThresholdType.tOfN, webSupported: true),
  elgamal(6, 2, ThresholdType.tOfN, webSupported: true),
  frost(4, 3, ThresholdType.tOfN, ..., webSupported: true),
  musig2(2, 3, ThresholdType.nOfN, ..., webSupported: true);
}
```

The group creation UI filters available key types and protocols based on this flag, preventing users from selecting unavailable protocols on web.

### Biometric authentication

The `local_auth` Flutter plugin does not support web. `LocalAuthService.authUser()` returns `true` immediately on web:

```dart
static Future<bool> authUser(SettingsController settingsController) async {
  if (kIsWeb) return true;
  // ... native biometric auth
}
```

---

## Server Changes

Changes to `meesign-server` (in the sibling `../meesign-server` directory):

### New dependencies

```toml
jsonwebtoken = "9"
tower-http = { version = "0.4", features = ["cors"] }
```

### Modified files

- **`proto/meesign.proto`** -- Added `optional string auth_token = 3` to `RegistrationResponse`.
- **`src/interfaces/grpc.rs`** -- JWT generation/validation, dual-path auth extraction, CORS layer, `accept_http1(true)`.

### Authentication flow

1. Client sends `RegistrationRequest` (no auth required).
2. Server issues certificate and generates JWT with `device_id` as subject.
3. Server returns both certificate and JWT in `RegistrationResponse`.
4. Web client stores JWT in memory and sends it as `Authorization: Bearer <token>` on all subsequent calls.
5. Native client ignores the JWT and continues using mTLS.

---

## Web Assets

The `web/` directory contains the following runtime assets:

| File | Source | Size | Purpose |
|------|--------|------|---------|
| `meesign_crypto.js` | `wasm-pack build` output | ~20 KB | wasm-bindgen JS glue code |
| `meesign_crypto_bg.wasm` | `wasm-pack build` output | ~4.9 MB | WASM crypto binary (all protocols) |
| `sqlite3.wasm` | `sqlite3` Dart package release | ~714 KB | SQLite compiled to WASM |
| `drift_worker.js` | `drift` package release | ~347 KB | Drift database web worker |
| `index.html` | Flutter template (modified) | ~1 KB | Entry point with WASM init scripts |

---

## Build Instructions

### Prerequisites

- Flutter SDK (with web support)
- Rust toolchain with `wasm32-unknown-unknown` target
- `wasm-pack` (`cargo install wasm-pack`)
- `protoc` with Dart plugin (v20.0.1 for `protobuf: ^3.0.0`)

### Build WASM crypto

```bash
cd meesign_native/native/meesign-crypto
wasm-pack build --target no-modules --no-default-features --features "wasm,elgamal,frost,gg18,musig2"
cp pkg/meesign_crypto_bg.wasm ../../web/
cp pkg/meesign_crypto.js ../../web/
```

### Build Flutter web

```bash
flutter build web
```

### Build server

```bash
cd ../meesign-server
cargo build --release
```

### Run locally

```bash
# Terminal 1: Start server
cd ../meesign-server && cargo run

# Terminal 2: Run web client
cd meesign-client && flutter run -d chrome
```

Note: The server uses a self-signed TLS certificate by default. You'll need to accept it in the browser by navigating to `https://localhost:1337` first.

---

## Known Limitations

### Storage limitations

- **Private keys and JWT tokens** are persisted in IndexedDB (`meesign_storage`, `keys` store). This survives page refreshes and browser restarts. **Private/incognito browsing** may restrict IndexedDB availability or quota — if unavailable, `init()` will fail and the app cannot start.
- **Keys are stored unencrypted** in IndexedDB, accessible to any JS running on the same origin (same security model as the native implementation, which stores unencrypted files on disk).
- **PDF files** from sign tasks are persisted in IndexedDB (`meesign_storage`, `files` store) and loaded into an in-memory cache at startup. Users with many large stored files may experience increased memory usage.
- **Decrypt task data** (encrypted and decrypted payloads) is stored in the Drift/SQLite database (OPFS), not in IndexedDB.

### No smart card support

NFC and PC/SC smart card plugins (`flutter_nfc_kit`, `dart_pcsc`) are unavailable on web. JavaCard-based FROST signing is not supported.

### TLS certificate handling

Browsers manage TLS trust independently. Self-signed server certificates must be manually accepted by navigating to the server URL before using the web client. There is no programmatic `allowBadCerts` equivalent on web.

### No isolate support

Web does not support Dart isolates. The `protocolAdvance` crypto operation runs on the main thread instead of a background isolate. For large threshold groups, this may cause brief UI freezes.
