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

## Example Policy bot

The `bin/policy.dart` implements a commmand-line MeeSign client that automaticaly approves any task, be it group or signature creation, or decryption, if _a policy_ is satisfied. The default policy is that it approves everything whenever. However, the bot can verify the current time and only sign within working hours, for example. For demo purposes, it can be useful to use the `odd-minute` or `even-minute` policy, where the bot checks the parity of the current minute and decides based on that.

To build the bot do:

```bash
cd meesign_core/
dart compile exe bin/policy.dart
```

To run the bot called `PolicyBot` against the MeeSign server `localhost` with the policy `policy.json` do:
```bash
./bin/policy.exe --name PolicyBot --host localhost --policy policy.json
```

The name of the bot identifies it fully. Thus, starting the bot with the same name yields the same MeeSign client. Therefore, if more clients are required, use different names.

### Policy definition

The `policy.json` can specify `from` and `to` times
```json
{
    "from": "8:00",
    "to": "17:00"
}
```

For the odd
```json
{ "odd-minute": true }
```
and for the even ones
```json
{ "even-minute": true }
```