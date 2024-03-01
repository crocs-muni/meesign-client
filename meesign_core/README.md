# MeeSign Core

This package implements the functionality shared by both GUI and CLI MeeSign clients.

## Usage without Flutter

The package has no Flutter dependencies and can thus be used in Dart-only applications, see [example](example/). However, extra steps are needed so that the application can access the native libraries provided by [meesign_native](../meesign_native/); follow the instructions in [meesign_native's README](../meesign_native/README.md).

__Note:__ The additional setup is also needed when running tests.

## Regenerating Drift database code

After modifying the database code (`lib/src/database/{daos,database,tables}.dart`), make sure to also update the auto-generated files:

```bash
dart run build_runner build
```

For more information, see [Drift docs](https://drift.simonbinder.eu/docs/getting-started/).
