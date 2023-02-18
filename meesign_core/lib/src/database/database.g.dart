// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<Uint8List> id = GeneratedColumn<Uint8List>(
      'id', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? 'devices';
  @override
  String get actualTableName => 'devices';
  @override
  VerificationContext validateIntegrity(Insertable<Device> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final Uint8List id;
  final String name;
  const Device({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<Uint8List>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Device.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<Uint8List>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<Uint8List>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Device copyWith({Uint8List? id, String? name}) => Device(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash($driftBlobEquality.hash(id), name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          $driftBlobEquality.equals(other.id, this.id) &&
          other.name == this.name);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<Uint8List> id;
  final Value<String> name;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  DevicesCompanion.insert({
    required Uint8List id,
    required String name,
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Device> custom({
    Expression<Uint8List>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  DevicesCompanion copyWith({Value<Uint8List>? id, Value<String>? name}) {
    return DevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<Uint8List> id = GeneratedColumn<Uint8List>(
      'id', aliasedName, false,
      type: DriftSqlType.blob,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES devices (id)'));
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
      'host', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, host];
  @override
  String get aliasedName => _alias ?? 'users';
  @override
  String get actualTableName => 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
          _hostMeta, host.isAcceptableOrUnknown(data['host']!, _hostMeta));
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}id'])!,
      host: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}host'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final Uint8List id;
  final String host;
  const User({required this.id, required this.host});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<Uint8List>(id);
    map['host'] = Variable<String>(host);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      host: Value(host),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<Uint8List>(json['id']),
      host: serializer.fromJson<String>(json['host']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<Uint8List>(id),
      'host': serializer.toJson<String>(host),
    };
  }

  User copyWith({Uint8List? id, String? host}) => User(
        id: id ?? this.id,
        host: host ?? this.host,
      );
  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('host: $host')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash($driftBlobEquality.hash(id), host);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          $driftBlobEquality.equals(other.id, this.id) &&
          other.host == this.host);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<Uint8List> id;
  final Value<String> host;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.host = const Value.absent(),
  });
  UsersCompanion.insert({
    required Uint8List id,
    required String host,
  })  : id = Value(id),
        host = Value(host);
  static Insertable<User> custom({
    Expression<Uint8List>? id,
    Expression<String>? host,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (host != null) 'host': host,
    });
  }

  UsersCompanion copyWith({Value<Uint8List>? id, Value<String>? host}) {
    return UsersCompanion(
      id: id ?? this.id,
      host: host ?? this.host,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(id.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('host: $host')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<Uint8List> id = GeneratedColumn<Uint8List>(
      'id', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _didMeta = const VerificationMeta('did');
  @override
  late final GeneratedColumn<Uint8List> did = GeneratedColumn<Uint8List>(
      'did', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumnWithTypeConverter<TaskState, String> state =
      GeneratedColumn<String>('state', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TaskState>($TasksTable.$converterstate);
  static const VerificationMeta _approvedMeta =
      const VerificationMeta('approved');
  @override
  late final GeneratedColumn<bool> approved =
      GeneratedColumn<bool>('approved', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("approved" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  static const VerificationMeta _roundMeta = const VerificationMeta('round');
  @override
  late final GeneratedColumn<int> round = GeneratedColumn<int>(
      'round', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _attemptMeta =
      const VerificationMeta('attempt');
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
      'attempt', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _contextMeta =
      const VerificationMeta('context');
  @override
  late final GeneratedColumn<Uint8List> context = GeneratedColumn<Uint8List>(
      'context', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, did, state, approved, round, attempt, context];
  @override
  String get aliasedName => _alias ?? 'tasks';
  @override
  String get actualTableName => 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('did')) {
      context.handle(
          _didMeta, did.isAcceptableOrUnknown(data['did']!, _didMeta));
    } else if (isInserting) {
      context.missing(_didMeta);
    }
    context.handle(_stateMeta, const VerificationResult.success());
    if (data.containsKey('approved')) {
      context.handle(_approvedMeta,
          approved.isAcceptableOrUnknown(data['approved']!, _approvedMeta));
    }
    if (data.containsKey('round')) {
      context.handle(
          _roundMeta, round.isAcceptableOrUnknown(data['round']!, _roundMeta));
    }
    if (data.containsKey('attempt')) {
      context.handle(_attemptMeta,
          attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta));
    }
    if (data.containsKey('context')) {
      context.handle(_contextMeta,
          this.context.isAcceptableOrUnknown(data['context']!, _contextMeta));
    } else if (isInserting) {
      context.missing(_contextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, did};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}id'])!,
      did: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}did'])!,
      state: $TasksTable.$converterstate.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!),
      approved: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}approved'])!,
      round: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}round'])!,
      attempt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt'])!,
      context: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}context'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskState, String, String> $converterstate =
      const EnumNameConverter<TaskState>(TaskState.values);
}

class Task extends DataClass implements Insertable<Task> {
  final Uint8List id;
  final Uint8List did;
  final TaskState state;
  final bool approved;
  final int round;
  final int attempt;
  final Uint8List context;
  const Task(
      {required this.id,
      required this.did,
      required this.state,
      required this.approved,
      required this.round,
      required this.attempt,
      required this.context});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<Uint8List>(id);
    map['did'] = Variable<Uint8List>(did);
    {
      final converter = $TasksTable.$converterstate;
      map['state'] = Variable<String>(converter.toSql(state));
    }
    map['approved'] = Variable<bool>(approved);
    map['round'] = Variable<int>(round);
    map['attempt'] = Variable<int>(attempt);
    map['context'] = Variable<Uint8List>(context);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      did: Value(did),
      state: Value(state),
      approved: Value(approved),
      round: Value(round),
      attempt: Value(attempt),
      context: Value(context),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<Uint8List>(json['id']),
      did: serializer.fromJson<Uint8List>(json['did']),
      state: $TasksTable.$converterstate
          .fromJson(serializer.fromJson<String>(json['state'])),
      approved: serializer.fromJson<bool>(json['approved']),
      round: serializer.fromJson<int>(json['round']),
      attempt: serializer.fromJson<int>(json['attempt']),
      context: serializer.fromJson<Uint8List>(json['context']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<Uint8List>(id),
      'did': serializer.toJson<Uint8List>(did),
      'state':
          serializer.toJson<String>($TasksTable.$converterstate.toJson(state)),
      'approved': serializer.toJson<bool>(approved),
      'round': serializer.toJson<int>(round),
      'attempt': serializer.toJson<int>(attempt),
      'context': serializer.toJson<Uint8List>(context),
    };
  }

  Task copyWith(
          {Uint8List? id,
          Uint8List? did,
          TaskState? state,
          bool? approved,
          int? round,
          int? attempt,
          Uint8List? context}) =>
      Task(
        id: id ?? this.id,
        did: did ?? this.did,
        state: state ?? this.state,
        approved: approved ?? this.approved,
        round: round ?? this.round,
        attempt: attempt ?? this.attempt,
        context: context ?? this.context,
      );
  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('did: $did, ')
          ..write('state: $state, ')
          ..write('approved: $approved, ')
          ..write('round: $round, ')
          ..write('attempt: $attempt, ')
          ..write('context: $context')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      $driftBlobEquality.hash(id),
      $driftBlobEquality.hash(did),
      state,
      approved,
      round,
      attempt,
      $driftBlobEquality.hash(context));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          $driftBlobEquality.equals(other.id, this.id) &&
          $driftBlobEquality.equals(other.did, this.did) &&
          other.state == this.state &&
          other.approved == this.approved &&
          other.round == this.round &&
          other.attempt == this.attempt &&
          $driftBlobEquality.equals(other.context, this.context));
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<Uint8List> id;
  final Value<Uint8List> did;
  final Value<TaskState> state;
  final Value<bool> approved;
  final Value<int> round;
  final Value<int> attempt;
  final Value<Uint8List> context;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.did = const Value.absent(),
    this.state = const Value.absent(),
    this.approved = const Value.absent(),
    this.round = const Value.absent(),
    this.attempt = const Value.absent(),
    this.context = const Value.absent(),
  });
  TasksCompanion.insert({
    required Uint8List id,
    required Uint8List did,
    required TaskState state,
    this.approved = const Value.absent(),
    this.round = const Value.absent(),
    this.attempt = const Value.absent(),
    required Uint8List context,
  })  : id = Value(id),
        did = Value(did),
        state = Value(state),
        context = Value(context);
  static Insertable<Task> custom({
    Expression<Uint8List>? id,
    Expression<Uint8List>? did,
    Expression<String>? state,
    Expression<bool>? approved,
    Expression<int>? round,
    Expression<int>? attempt,
    Expression<Uint8List>? context,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (did != null) 'did': did,
      if (state != null) 'state': state,
      if (approved != null) 'approved': approved,
      if (round != null) 'round': round,
      if (attempt != null) 'attempt': attempt,
      if (context != null) 'context': context,
    });
  }

  TasksCompanion copyWith(
      {Value<Uint8List>? id,
      Value<Uint8List>? did,
      Value<TaskState>? state,
      Value<bool>? approved,
      Value<int>? round,
      Value<int>? attempt,
      Value<Uint8List>? context}) {
    return TasksCompanion(
      id: id ?? this.id,
      did: did ?? this.did,
      state: state ?? this.state,
      approved: approved ?? this.approved,
      round: round ?? this.round,
      attempt: attempt ?? this.attempt,
      context: context ?? this.context,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(id.value);
    }
    if (did.present) {
      map['did'] = Variable<Uint8List>(did.value);
    }
    if (state.present) {
      final converter = $TasksTable.$converterstate;
      map['state'] = Variable<String>(converter.toSql(state.value));
    }
    if (approved.present) {
      map['approved'] = Variable<bool>(approved.value);
    }
    if (round.present) {
      map['round'] = Variable<int>(round.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (context.present) {
      map['context'] = Variable<Uint8List>(context.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('did: $did, ')
          ..write('state: $state, ')
          ..write('approved: $approved, ')
          ..write('round: $round, ')
          ..write('attempt: $attempt, ')
          ..write('context: $context')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<Uint8List> id = GeneratedColumn<Uint8List>(
      'id', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _tidMeta = const VerificationMeta('tid');
  @override
  late final GeneratedColumn<Uint8List> tid = GeneratedColumn<Uint8List>(
      'tid', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _didMeta = const VerificationMeta('did');
  @override
  late final GeneratedColumn<Uint8List> did = GeneratedColumn<Uint8List>(
      'did', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _thresholdMeta =
      const VerificationMeta('threshold');
  @override
  late final GeneratedColumn<int> threshold = GeneratedColumn<int>(
      'threshold', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _protocolMeta =
      const VerificationMeta('protocol');
  @override
  late final GeneratedColumnWithTypeConverter<Protocol, String> protocol =
      GeneratedColumn<String>('protocol', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Protocol>($GroupsTable.$converterprotocol);
  static const VerificationMeta _keyTypeMeta =
      const VerificationMeta('keyType');
  @override
  late final GeneratedColumnWithTypeConverter<KeyType, String> keyType =
      GeneratedColumn<String>('key_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<KeyType>($GroupsTable.$converterkeyType);
  static const VerificationMeta _contextMeta =
      const VerificationMeta('context');
  @override
  late final GeneratedColumn<Uint8List> context = GeneratedColumn<Uint8List>(
      'context', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, tid, did, name, threshold, protocol, keyType, context];
  @override
  String get aliasedName => _alias ?? 'groups';
  @override
  String get actualTableName => 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<Group> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tid')) {
      context.handle(
          _tidMeta, tid.isAcceptableOrUnknown(data['tid']!, _tidMeta));
    } else if (isInserting) {
      context.missing(_tidMeta);
    }
    if (data.containsKey('did')) {
      context.handle(
          _didMeta, did.isAcceptableOrUnknown(data['did']!, _didMeta));
    } else if (isInserting) {
      context.missing(_didMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('threshold')) {
      context.handle(_thresholdMeta,
          threshold.isAcceptableOrUnknown(data['threshold']!, _thresholdMeta));
    } else if (isInserting) {
      context.missing(_thresholdMeta);
    }
    context.handle(_protocolMeta, const VerificationResult.success());
    context.handle(_keyTypeMeta, const VerificationResult.success());
    if (data.containsKey('context')) {
      context.handle(_contextMeta,
          this.context.isAcceptableOrUnknown(data['context']!, _contextMeta));
    } else if (isInserting) {
      context.missing(_contextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tid, did};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}id']),
      tid: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}tid'])!,
      did: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}did'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      threshold: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}threshold'])!,
      protocol: $GroupsTable.$converterprotocol.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}protocol'])!),
      keyType: $GroupsTable.$converterkeyType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key_type'])!),
      context: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}context'])!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Protocol, String, String> $converterprotocol =
      const EnumNameConverter<Protocol>(Protocol.values);
  static JsonTypeConverter2<KeyType, String, String> $converterkeyType =
      const EnumNameConverter<KeyType>(KeyType.values);
}

class Group extends DataClass implements Insertable<Group> {
  final Uint8List? id;
  final Uint8List tid;
  final Uint8List did;
  final String name;
  final int threshold;
  final Protocol protocol;
  final KeyType keyType;
  final Uint8List context;
  const Group(
      {this.id,
      required this.tid,
      required this.did,
      required this.name,
      required this.threshold,
      required this.protocol,
      required this.keyType,
      required this.context});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<Uint8List>(id);
    }
    map['tid'] = Variable<Uint8List>(tid);
    map['did'] = Variable<Uint8List>(did);
    map['name'] = Variable<String>(name);
    map['threshold'] = Variable<int>(threshold);
    {
      final converter = $GroupsTable.$converterprotocol;
      map['protocol'] = Variable<String>(converter.toSql(protocol));
    }
    {
      final converter = $GroupsTable.$converterkeyType;
      map['key_type'] = Variable<String>(converter.toSql(keyType));
    }
    map['context'] = Variable<Uint8List>(context);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      tid: Value(tid),
      did: Value(did),
      name: Value(name),
      threshold: Value(threshold),
      protocol: Value(protocol),
      keyType: Value(keyType),
      context: Value(context),
    );
  }

  factory Group.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<Uint8List?>(json['id']),
      tid: serializer.fromJson<Uint8List>(json['tid']),
      did: serializer.fromJson<Uint8List>(json['did']),
      name: serializer.fromJson<String>(json['name']),
      threshold: serializer.fromJson<int>(json['threshold']),
      protocol: $GroupsTable.$converterprotocol
          .fromJson(serializer.fromJson<String>(json['protocol'])),
      keyType: $GroupsTable.$converterkeyType
          .fromJson(serializer.fromJson<String>(json['keyType'])),
      context: serializer.fromJson<Uint8List>(json['context']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<Uint8List?>(id),
      'tid': serializer.toJson<Uint8List>(tid),
      'did': serializer.toJson<Uint8List>(did),
      'name': serializer.toJson<String>(name),
      'threshold': serializer.toJson<int>(threshold),
      'protocol': serializer
          .toJson<String>($GroupsTable.$converterprotocol.toJson(protocol)),
      'keyType': serializer
          .toJson<String>($GroupsTable.$converterkeyType.toJson(keyType)),
      'context': serializer.toJson<Uint8List>(context),
    };
  }

  Group copyWith(
          {Value<Uint8List?> id = const Value.absent(),
          Uint8List? tid,
          Uint8List? did,
          String? name,
          int? threshold,
          Protocol? protocol,
          KeyType? keyType,
          Uint8List? context}) =>
      Group(
        id: id.present ? id.value : this.id,
        tid: tid ?? this.tid,
        did: did ?? this.did,
        name: name ?? this.name,
        threshold: threshold ?? this.threshold,
        protocol: protocol ?? this.protocol,
        keyType: keyType ?? this.keyType,
        context: context ?? this.context,
      );
  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('name: $name, ')
          ..write('threshold: $threshold, ')
          ..write('protocol: $protocol, ')
          ..write('keyType: $keyType, ')
          ..write('context: $context')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      $driftBlobEquality.hash(id),
      $driftBlobEquality.hash(tid),
      $driftBlobEquality.hash(did),
      name,
      threshold,
      protocol,
      keyType,
      $driftBlobEquality.hash(context));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          $driftBlobEquality.equals(other.id, this.id) &&
          $driftBlobEquality.equals(other.tid, this.tid) &&
          $driftBlobEquality.equals(other.did, this.did) &&
          other.name == this.name &&
          other.threshold == this.threshold &&
          other.protocol == this.protocol &&
          other.keyType == this.keyType &&
          $driftBlobEquality.equals(other.context, this.context));
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<Uint8List?> id;
  final Value<Uint8List> tid;
  final Value<Uint8List> did;
  final Value<String> name;
  final Value<int> threshold;
  final Value<Protocol> protocol;
  final Value<KeyType> keyType;
  final Value<Uint8List> context;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.tid = const Value.absent(),
    this.did = const Value.absent(),
    this.name = const Value.absent(),
    this.threshold = const Value.absent(),
    this.protocol = const Value.absent(),
    this.keyType = const Value.absent(),
    this.context = const Value.absent(),
  });
  GroupsCompanion.insert({
    this.id = const Value.absent(),
    required Uint8List tid,
    required Uint8List did,
    required String name,
    required int threshold,
    required Protocol protocol,
    required KeyType keyType,
    required Uint8List context,
  })  : tid = Value(tid),
        did = Value(did),
        name = Value(name),
        threshold = Value(threshold),
        protocol = Value(protocol),
        keyType = Value(keyType),
        context = Value(context);
  static Insertable<Group> custom({
    Expression<Uint8List>? id,
    Expression<Uint8List>? tid,
    Expression<Uint8List>? did,
    Expression<String>? name,
    Expression<int>? threshold,
    Expression<String>? protocol,
    Expression<String>? keyType,
    Expression<Uint8List>? context,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tid != null) 'tid': tid,
      if (did != null) 'did': did,
      if (name != null) 'name': name,
      if (threshold != null) 'threshold': threshold,
      if (protocol != null) 'protocol': protocol,
      if (keyType != null) 'key_type': keyType,
      if (context != null) 'context': context,
    });
  }

  GroupsCompanion copyWith(
      {Value<Uint8List?>? id,
      Value<Uint8List>? tid,
      Value<Uint8List>? did,
      Value<String>? name,
      Value<int>? threshold,
      Value<Protocol>? protocol,
      Value<KeyType>? keyType,
      Value<Uint8List>? context}) {
    return GroupsCompanion(
      id: id ?? this.id,
      tid: tid ?? this.tid,
      did: did ?? this.did,
      name: name ?? this.name,
      threshold: threshold ?? this.threshold,
      protocol: protocol ?? this.protocol,
      keyType: keyType ?? this.keyType,
      context: context ?? this.context,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(id.value);
    }
    if (tid.present) {
      map['tid'] = Variable<Uint8List>(tid.value);
    }
    if (did.present) {
      map['did'] = Variable<Uint8List>(did.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (threshold.present) {
      map['threshold'] = Variable<int>(threshold.value);
    }
    if (protocol.present) {
      final converter = $GroupsTable.$converterprotocol;
      map['protocol'] = Variable<String>(converter.toSql(protocol.value));
    }
    if (keyType.present) {
      final converter = $GroupsTable.$converterkeyType;
      map['key_type'] = Variable<String>(converter.toSql(keyType.value));
    }
    if (context.present) {
      map['context'] = Variable<Uint8List>(context.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('name: $name, ')
          ..write('threshold: $threshold, ')
          ..write('protocol: $protocol, ')
          ..write('keyType: $keyType, ')
          ..write('context: $context')
          ..write(')'))
        .toString();
  }
}

class $GroupMembersTable extends GroupMembers
    with TableInfo<$GroupMembersTable, GroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tidMeta = const VerificationMeta('tid');
  @override
  late final GeneratedColumn<Uint8List> tid = GeneratedColumn<Uint8List>(
      'tid', aliasedName, false,
      type: DriftSqlType.blob,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES "groups" (id)'));
  static const VerificationMeta _didMeta = const VerificationMeta('did');
  @override
  late final GeneratedColumn<Uint8List> did = GeneratedColumn<Uint8List>(
      'did', aliasedName, false,
      type: DriftSqlType.blob,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES devices (id)'));
  @override
  List<GeneratedColumn> get $columns => [tid, did];
  @override
  String get aliasedName => _alias ?? 'group_members';
  @override
  String get actualTableName => 'group_members';
  @override
  VerificationContext validateIntegrity(Insertable<GroupMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tid')) {
      context.handle(
          _tidMeta, tid.isAcceptableOrUnknown(data['tid']!, _tidMeta));
    } else if (isInserting) {
      context.missing(_tidMeta);
    }
    if (data.containsKey('did')) {
      context.handle(
          _didMeta, did.isAcceptableOrUnknown(data['did']!, _didMeta));
    } else if (isInserting) {
      context.missing(_didMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tid, did};
  @override
  GroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMember(
      tid: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}tid'])!,
      did: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}did'])!,
    );
  }

  @override
  $GroupMembersTable createAlias(String alias) {
    return $GroupMembersTable(attachedDatabase, alias);
  }
}

class GroupMember extends DataClass implements Insertable<GroupMember> {
  final Uint8List tid;
  final Uint8List did;
  const GroupMember({required this.tid, required this.did});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tid'] = Variable<Uint8List>(tid);
    map['did'] = Variable<Uint8List>(did);
    return map;
  }

  GroupMembersCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCompanion(
      tid: Value(tid),
      did: Value(did),
    );
  }

  factory GroupMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMember(
      tid: serializer.fromJson<Uint8List>(json['tid']),
      did: serializer.fromJson<Uint8List>(json['did']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tid': serializer.toJson<Uint8List>(tid),
      'did': serializer.toJson<Uint8List>(did),
    };
  }

  GroupMember copyWith({Uint8List? tid, Uint8List? did}) => GroupMember(
        tid: tid ?? this.tid,
        did: did ?? this.did,
      );
  @override
  String toString() {
    return (StringBuffer('GroupMember(')
          ..write('tid: $tid, ')
          ..write('did: $did')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash($driftBlobEquality.hash(tid), $driftBlobEquality.hash(did));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMember &&
          $driftBlobEquality.equals(other.tid, this.tid) &&
          $driftBlobEquality.equals(other.did, this.did));
}

class GroupMembersCompanion extends UpdateCompanion<GroupMember> {
  final Value<Uint8List> tid;
  final Value<Uint8List> did;
  const GroupMembersCompanion({
    this.tid = const Value.absent(),
    this.did = const Value.absent(),
  });
  GroupMembersCompanion.insert({
    required Uint8List tid,
    required Uint8List did,
  })  : tid = Value(tid),
        did = Value(did);
  static Insertable<GroupMember> custom({
    Expression<Uint8List>? tid,
    Expression<Uint8List>? did,
  }) {
    return RawValuesInsertable({
      if (tid != null) 'tid': tid,
      if (did != null) 'did': did,
    });
  }

  GroupMembersCompanion copyWith(
      {Value<Uint8List>? tid, Value<Uint8List>? did}) {
    return GroupMembersCompanion(
      tid: tid ?? this.tid,
      did: did ?? this.did,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tid.present) {
      map['tid'] = Variable<Uint8List>(tid.value);
    }
    if (did.present) {
      map['did'] = Variable<Uint8List>(did.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCompanion(')
          ..write('tid: $tid, ')
          ..write('did: $did')
          ..write(')'))
        .toString();
  }
}

class $FilesTable extends Files with TableInfo<$FilesTable, File> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tidMeta = const VerificationMeta('tid');
  @override
  late final GeneratedColumn<Uint8List> tid = GeneratedColumn<Uint8List>(
      'tid', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _didMeta = const VerificationMeta('did');
  @override
  late final GeneratedColumn<Uint8List> did = GeneratedColumn<Uint8List>(
      'did', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _gidMeta = const VerificationMeta('gid');
  @override
  late final GeneratedColumn<Uint8List> gid = GeneratedColumn<Uint8List>(
      'gid', aliasedName, false,
      type: DriftSqlType.blob,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES "groups" (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [tid, did, gid, name];
  @override
  String get aliasedName => _alias ?? 'files';
  @override
  String get actualTableName => 'files';
  @override
  VerificationContext validateIntegrity(Insertable<File> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tid')) {
      context.handle(
          _tidMeta, tid.isAcceptableOrUnknown(data['tid']!, _tidMeta));
    } else if (isInserting) {
      context.missing(_tidMeta);
    }
    if (data.containsKey('did')) {
      context.handle(
          _didMeta, did.isAcceptableOrUnknown(data['did']!, _didMeta));
    } else if (isInserting) {
      context.missing(_didMeta);
    }
    if (data.containsKey('gid')) {
      context.handle(
          _gidMeta, gid.isAcceptableOrUnknown(data['gid']!, _gidMeta));
    } else if (isInserting) {
      context.missing(_gidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tid, did};
  @override
  File map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return File(
      tid: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}tid'])!,
      did: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}did'])!,
      gid: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}gid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $FilesTable createAlias(String alias) {
    return $FilesTable(attachedDatabase, alias);
  }
}

class File extends DataClass implements Insertable<File> {
  final Uint8List tid;
  final Uint8List did;
  final Uint8List gid;
  final String name;
  const File(
      {required this.tid,
      required this.did,
      required this.gid,
      required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tid'] = Variable<Uint8List>(tid);
    map['did'] = Variable<Uint8List>(did);
    map['gid'] = Variable<Uint8List>(gid);
    map['name'] = Variable<String>(name);
    return map;
  }

  FilesCompanion toCompanion(bool nullToAbsent) {
    return FilesCompanion(
      tid: Value(tid),
      did: Value(did),
      gid: Value(gid),
      name: Value(name),
    );
  }

  factory File.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return File(
      tid: serializer.fromJson<Uint8List>(json['tid']),
      did: serializer.fromJson<Uint8List>(json['did']),
      gid: serializer.fromJson<Uint8List>(json['gid']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tid': serializer.toJson<Uint8List>(tid),
      'did': serializer.toJson<Uint8List>(did),
      'gid': serializer.toJson<Uint8List>(gid),
      'name': serializer.toJson<String>(name),
    };
  }

  File copyWith(
          {Uint8List? tid, Uint8List? did, Uint8List? gid, String? name}) =>
      File(
        tid: tid ?? this.tid,
        did: did ?? this.did,
        gid: gid ?? this.gid,
        name: name ?? this.name,
      );
  @override
  String toString() {
    return (StringBuffer('File(')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('gid: $gid, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash($driftBlobEquality.hash(tid),
      $driftBlobEquality.hash(did), $driftBlobEquality.hash(gid), name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is File &&
          $driftBlobEquality.equals(other.tid, this.tid) &&
          $driftBlobEquality.equals(other.did, this.did) &&
          $driftBlobEquality.equals(other.gid, this.gid) &&
          other.name == this.name);
}

class FilesCompanion extends UpdateCompanion<File> {
  final Value<Uint8List> tid;
  final Value<Uint8List> did;
  final Value<Uint8List> gid;
  final Value<String> name;
  const FilesCompanion({
    this.tid = const Value.absent(),
    this.did = const Value.absent(),
    this.gid = const Value.absent(),
    this.name = const Value.absent(),
  });
  FilesCompanion.insert({
    required Uint8List tid,
    required Uint8List did,
    required Uint8List gid,
    required String name,
  })  : tid = Value(tid),
        did = Value(did),
        gid = Value(gid),
        name = Value(name);
  static Insertable<File> custom({
    Expression<Uint8List>? tid,
    Expression<Uint8List>? did,
    Expression<Uint8List>? gid,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (tid != null) 'tid': tid,
      if (did != null) 'did': did,
      if (gid != null) 'gid': gid,
      if (name != null) 'name': name,
    });
  }

  FilesCompanion copyWith(
      {Value<Uint8List>? tid,
      Value<Uint8List>? did,
      Value<Uint8List>? gid,
      Value<String>? name}) {
    return FilesCompanion(
      tid: tid ?? this.tid,
      did: did ?? this.did,
      gid: gid ?? this.gid,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tid.present) {
      map['tid'] = Variable<Uint8List>(tid.value);
    }
    if (did.present) {
      map['did'] = Variable<Uint8List>(did.value);
    }
    if (gid.present) {
      map['gid'] = Variable<Uint8List>(gid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FilesCompanion(')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('gid: $gid, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ChallengesTable extends Challenges
    with TableInfo<$ChallengesTable, Challenge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChallengesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tidMeta = const VerificationMeta('tid');
  @override
  late final GeneratedColumn<Uint8List> tid = GeneratedColumn<Uint8List>(
      'tid', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _didMeta = const VerificationMeta('did');
  @override
  late final GeneratedColumn<Uint8List> did = GeneratedColumn<Uint8List>(
      'did', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _gidMeta = const VerificationMeta('gid');
  @override
  late final GeneratedColumn<Uint8List> gid = GeneratedColumn<Uint8List>(
      'gid', aliasedName, false,
      type: DriftSqlType.blob,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES "groups" (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
      'data', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [tid, did, gid, name, data];
  @override
  String get aliasedName => _alias ?? 'challenges';
  @override
  String get actualTableName => 'challenges';
  @override
  VerificationContext validateIntegrity(Insertable<Challenge> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tid')) {
      context.handle(
          _tidMeta, tid.isAcceptableOrUnknown(data['tid']!, _tidMeta));
    } else if (isInserting) {
      context.missing(_tidMeta);
    }
    if (data.containsKey('did')) {
      context.handle(
          _didMeta, did.isAcceptableOrUnknown(data['did']!, _didMeta));
    } else if (isInserting) {
      context.missing(_didMeta);
    }
    if (data.containsKey('gid')) {
      context.handle(
          _gidMeta, gid.isAcceptableOrUnknown(data['gid']!, _gidMeta));
    } else if (isInserting) {
      context.missing(_gidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tid, did};
  @override
  Challenge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Challenge(
      tid: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}tid'])!,
      did: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}did'])!,
      gid: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}gid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}data'])!,
    );
  }

  @override
  $ChallengesTable createAlias(String alias) {
    return $ChallengesTable(attachedDatabase, alias);
  }
}

class Challenge extends DataClass implements Insertable<Challenge> {
  final Uint8List tid;
  final Uint8List did;
  final Uint8List gid;
  final String name;
  final Uint8List data;
  const Challenge(
      {required this.tid,
      required this.did,
      required this.gid,
      required this.name,
      required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tid'] = Variable<Uint8List>(tid);
    map['did'] = Variable<Uint8List>(did);
    map['gid'] = Variable<Uint8List>(gid);
    map['name'] = Variable<String>(name);
    map['data'] = Variable<Uint8List>(data);
    return map;
  }

  ChallengesCompanion toCompanion(bool nullToAbsent) {
    return ChallengesCompanion(
      tid: Value(tid),
      did: Value(did),
      gid: Value(gid),
      name: Value(name),
      data: Value(data),
    );
  }

  factory Challenge.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Challenge(
      tid: serializer.fromJson<Uint8List>(json['tid']),
      did: serializer.fromJson<Uint8List>(json['did']),
      gid: serializer.fromJson<Uint8List>(json['gid']),
      name: serializer.fromJson<String>(json['name']),
      data: serializer.fromJson<Uint8List>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tid': serializer.toJson<Uint8List>(tid),
      'did': serializer.toJson<Uint8List>(did),
      'gid': serializer.toJson<Uint8List>(gid),
      'name': serializer.toJson<String>(name),
      'data': serializer.toJson<Uint8List>(data),
    };
  }

  Challenge copyWith(
          {Uint8List? tid,
          Uint8List? did,
          Uint8List? gid,
          String? name,
          Uint8List? data}) =>
      Challenge(
        tid: tid ?? this.tid,
        did: did ?? this.did,
        gid: gid ?? this.gid,
        name: name ?? this.name,
        data: data ?? this.data,
      );
  @override
  String toString() {
    return (StringBuffer('Challenge(')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('gid: $gid, ')
          ..write('name: $name, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      $driftBlobEquality.hash(tid),
      $driftBlobEquality.hash(did),
      $driftBlobEquality.hash(gid),
      name,
      $driftBlobEquality.hash(data));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Challenge &&
          $driftBlobEquality.equals(other.tid, this.tid) &&
          $driftBlobEquality.equals(other.did, this.did) &&
          $driftBlobEquality.equals(other.gid, this.gid) &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.data, this.data));
}

class ChallengesCompanion extends UpdateCompanion<Challenge> {
  final Value<Uint8List> tid;
  final Value<Uint8List> did;
  final Value<Uint8List> gid;
  final Value<String> name;
  final Value<Uint8List> data;
  const ChallengesCompanion({
    this.tid = const Value.absent(),
    this.did = const Value.absent(),
    this.gid = const Value.absent(),
    this.name = const Value.absent(),
    this.data = const Value.absent(),
  });
  ChallengesCompanion.insert({
    required Uint8List tid,
    required Uint8List did,
    required Uint8List gid,
    required String name,
    required Uint8List data,
  })  : tid = Value(tid),
        did = Value(did),
        gid = Value(gid),
        name = Value(name),
        data = Value(data);
  static Insertable<Challenge> custom({
    Expression<Uint8List>? tid,
    Expression<Uint8List>? did,
    Expression<Uint8List>? gid,
    Expression<String>? name,
    Expression<Uint8List>? data,
  }) {
    return RawValuesInsertable({
      if (tid != null) 'tid': tid,
      if (did != null) 'did': did,
      if (gid != null) 'gid': gid,
      if (name != null) 'name': name,
      if (data != null) 'data': data,
    });
  }

  ChallengesCompanion copyWith(
      {Value<Uint8List>? tid,
      Value<Uint8List>? did,
      Value<Uint8List>? gid,
      Value<String>? name,
      Value<Uint8List>? data}) {
    return ChallengesCompanion(
      tid: tid ?? this.tid,
      did: did ?? this.did,
      gid: gid ?? this.gid,
      name: name ?? this.name,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tid.present) {
      map['tid'] = Variable<Uint8List>(tid.value);
    }
    if (did.present) {
      map['did'] = Variable<Uint8List>(did.value);
    }
    if (gid.present) {
      map['gid'] = Variable<Uint8List>(gid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChallengesCompanion(')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('gid: $gid, ')
          ..write('name: $name, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final $FilesTable files = $FilesTable(this);
  late final $ChallengesTable challenges = $ChallengesTable(this);
  late final DeviceDao deviceDao = DeviceDao(this as Database);
  late final UserDao userDao = UserDao(this as Database);
  late final TaskDao taskDao = TaskDao(this as Database);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [devices, users, tasks, groups, groupMembers, files, challenges];
}
