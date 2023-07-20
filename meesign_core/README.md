# MeeSign Core

## Regenerate Drift database code

After modifying the database code (`lib/src/database/{daos,database,tables}.dart`), make sure to also update the auto-generated files:

```bash
dart run build_runner build
```

For more information, see [Drift docs](https://drift.simonbinder.eu/docs/getting-started/).
