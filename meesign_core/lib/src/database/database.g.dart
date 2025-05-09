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
  late final GeneratedColumnWithTypeConverter<DeviceKind, String> kind =
      GeneratedColumn<String>('kind', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DeviceKind>($DevicesTable.$converterkind);
  @override
  List<GeneratedColumn> get $columns => [id, name, kind];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
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
      kind: $DevicesTable.$converterkind.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DeviceKind, String, String> $converterkind =
      const EnumNameConverter<DeviceKind>(DeviceKind.values);
}

class Device extends DataClass implements Insertable<Device> {
  final Uint8List id;
  final String name;
  final DeviceKind kind;
  const Device({required this.id, required this.name, required this.kind});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<Uint8List>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>($DevicesTable.$converterkind.toSql(kind));
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
    );
  }

  factory Device.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<Uint8List>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: $DevicesTable.$converterkind
          .fromJson(serializer.fromJson<String>(json['kind'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<Uint8List>(id),
      'name': serializer.toJson<String>(name),
      'kind':
          serializer.toJson<String>($DevicesTable.$converterkind.toJson(kind)),
    };
  }

  Device copyWith({Uint8List? id, String? name, DeviceKind? kind}) => Device(
        id: id ?? this.id,
        name: name ?? this.name,
        kind: kind ?? this.kind,
      );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash($driftBlobEquality.hash(id), name, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          $driftBlobEquality.equals(other.id, this.id) &&
          other.name == this.name &&
          other.kind == this.kind);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<Uint8List> id;
  final Value<String> name;
  final Value<DeviceKind> kind;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required Uint8List id,
    required String name,
    required DeviceKind kind,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        kind = Value(kind);
  static Insertable<Device> custom({
    Expression<Uint8List>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith(
      {Value<Uint8List>? id,
      Value<String>? name,
      Value<DeviceKind>? kind,
      Value<int>? rowid}) {
    return DevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      rowid: rowid ?? this.rowid,
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
    if (kind.present) {
      map['kind'] =
          Variable<String>($DevicesTable.$converterkind.toSql(kind.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
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
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
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
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      host: data.host.present ? data.host.value : this.host,
    );
  }

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
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.host = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required Uint8List id,
    required String host,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        host = Value(host);
  static Insertable<User> custom({
    Expression<Uint8List>? id,
    Expression<String>? host,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (host != null) 'host': host,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<Uint8List>? id, Value<String>? host, Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      host: host ?? this.host,
      rowid: rowid ?? this.rowid,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('rowid: $rowid')
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
  @override
  late final GeneratedColumnWithTypeConverter<Protocol, String> protocol =
      GeneratedColumn<String>('protocol', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Protocol>($GroupsTable.$converterprotocol);
  @override
  late final GeneratedColumnWithTypeConverter<KeyType, String> keyType =
      GeneratedColumn<String>('key_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<KeyType>($GroupsTable.$converterkeyType);
  static const VerificationMeta _withCardMeta =
      const VerificationMeta('withCard');
  @override
  late final GeneratedColumn<bool> withCard = GeneratedColumn<bool>(
      'with_card', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("with_card" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _contextMeta =
      const VerificationMeta('context');
  @override
  late final GeneratedColumn<Uint8List> context = GeneratedColumn<Uint8List>(
      'context', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _certificatesMeta =
      const VerificationMeta('certificates');
  @override
  late final GeneratedColumn<Uint8List> certificates =
      GeneratedColumn<Uint8List>('certificates', aliasedName, true,
          type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tid,
        did,
        name,
        threshold,
        protocol,
        keyType,
        withCard,
        context,
        certificates,
        note
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
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
    if (data.containsKey('with_card')) {
      context.handle(_withCardMeta,
          withCard.isAcceptableOrUnknown(data['with_card']!, _withCardMeta));
    }
    if (data.containsKey('context')) {
      context.handle(_contextMeta,
          this.context.isAcceptableOrUnknown(data['context']!, _contextMeta));
    } else if (isInserting) {
      context.missing(_contextMeta);
    }
    if (data.containsKey('certificates')) {
      context.handle(
          _certificatesMeta,
          certificates.isAcceptableOrUnknown(
              data['certificates']!, _certificatesMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
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
      withCard: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}with_card'])!,
      context: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}context'])!,
      certificates: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}certificates']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
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
  final bool withCard;
  final Uint8List context;
  final Uint8List? certificates;
  final String? note;
  const Group(
      {this.id,
      required this.tid,
      required this.did,
      required this.name,
      required this.threshold,
      required this.protocol,
      required this.keyType,
      required this.withCard,
      required this.context,
      this.certificates,
      this.note});
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
      map['protocol'] =
          Variable<String>($GroupsTable.$converterprotocol.toSql(protocol));
    }
    {
      map['key_type'] =
          Variable<String>($GroupsTable.$converterkeyType.toSql(keyType));
    }
    map['with_card'] = Variable<bool>(withCard);
    map['context'] = Variable<Uint8List>(context);
    if (!nullToAbsent || certificates != null) {
      map['certificates'] = Variable<Uint8List>(certificates);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
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
      withCard: Value(withCard),
      context: Value(context),
      certificates: certificates == null && nullToAbsent
          ? const Value.absent()
          : Value(certificates),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
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
      withCard: serializer.fromJson<bool>(json['withCard']),
      context: serializer.fromJson<Uint8List>(json['context']),
      certificates: serializer.fromJson<Uint8List?>(json['certificates']),
      note: serializer.fromJson<String?>(json['note']),
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
      'withCard': serializer.toJson<bool>(withCard),
      'context': serializer.toJson<Uint8List>(context),
      'certificates': serializer.toJson<Uint8List?>(certificates),
      'note': serializer.toJson<String?>(note),
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
          bool? withCard,
          Uint8List? context,
          Value<Uint8List?> certificates = const Value.absent(),
          Value<String?> note = const Value.absent()}) =>
      Group(
        id: id.present ? id.value : this.id,
        tid: tid ?? this.tid,
        did: did ?? this.did,
        name: name ?? this.name,
        threshold: threshold ?? this.threshold,
        protocol: protocol ?? this.protocol,
        keyType: keyType ?? this.keyType,
        withCard: withCard ?? this.withCard,
        context: context ?? this.context,
        certificates:
            certificates.present ? certificates.value : this.certificates,
        note: note.present ? note.value : this.note,
      );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      tid: data.tid.present ? data.tid.value : this.tid,
      did: data.did.present ? data.did.value : this.did,
      name: data.name.present ? data.name.value : this.name,
      threshold: data.threshold.present ? data.threshold.value : this.threshold,
      protocol: data.protocol.present ? data.protocol.value : this.protocol,
      keyType: data.keyType.present ? data.keyType.value : this.keyType,
      withCard: data.withCard.present ? data.withCard.value : this.withCard,
      context: data.context.present ? data.context.value : this.context,
      certificates: data.certificates.present
          ? data.certificates.value
          : this.certificates,
      note: data.note.present ? data.note.value : this.note,
    );
  }

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
          ..write('withCard: $withCard, ')
          ..write('context: $context, ')
          ..write('certificates: $certificates, ')
          ..write('note: $note')
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
      withCard,
      $driftBlobEquality.hash(context),
      $driftBlobEquality.hash(certificates),
      note);
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
          other.withCard == this.withCard &&
          $driftBlobEquality.equals(other.context, this.context) &&
          $driftBlobEquality.equals(other.certificates, this.certificates) &&
          other.note == this.note);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<Uint8List?> id;
  final Value<Uint8List> tid;
  final Value<Uint8List> did;
  final Value<String> name;
  final Value<int> threshold;
  final Value<Protocol> protocol;
  final Value<KeyType> keyType;
  final Value<bool> withCard;
  final Value<Uint8List> context;
  final Value<Uint8List?> certificates;
  final Value<String?> note;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.tid = const Value.absent(),
    this.did = const Value.absent(),
    this.name = const Value.absent(),
    this.threshold = const Value.absent(),
    this.protocol = const Value.absent(),
    this.keyType = const Value.absent(),
    this.withCard = const Value.absent(),
    this.context = const Value.absent(),
    this.certificates = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    this.id = const Value.absent(),
    required Uint8List tid,
    required Uint8List did,
    required String name,
    required int threshold,
    required Protocol protocol,
    required KeyType keyType,
    this.withCard = const Value.absent(),
    required Uint8List context,
    this.certificates = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
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
    Expression<bool>? withCard,
    Expression<Uint8List>? context,
    Expression<Uint8List>? certificates,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tid != null) 'tid': tid,
      if (did != null) 'did': did,
      if (name != null) 'name': name,
      if (threshold != null) 'threshold': threshold,
      if (protocol != null) 'protocol': protocol,
      if (keyType != null) 'key_type': keyType,
      if (withCard != null) 'with_card': withCard,
      if (context != null) 'context': context,
      if (certificates != null) 'certificates': certificates,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
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
      Value<bool>? withCard,
      Value<Uint8List>? context,
      Value<Uint8List?>? certificates,
      Value<String?>? note,
      Value<int>? rowid}) {
    return GroupsCompanion(
      id: id ?? this.id,
      tid: tid ?? this.tid,
      did: did ?? this.did,
      name: name ?? this.name,
      threshold: threshold ?? this.threshold,
      protocol: protocol ?? this.protocol,
      keyType: keyType ?? this.keyType,
      withCard: withCard ?? this.withCard,
      context: context ?? this.context,
      certificates: certificates ?? this.certificates,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
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
      map['protocol'] = Variable<String>(
          $GroupsTable.$converterprotocol.toSql(protocol.value));
    }
    if (keyType.present) {
      map['key_type'] =
          Variable<String>($GroupsTable.$converterkeyType.toSql(keyType.value));
    }
    if (withCard.present) {
      map['with_card'] = Variable<bool>(withCard.value);
    }
    if (context.present) {
      map['context'] = Variable<Uint8List>(context.value);
    }
    if (certificates.present) {
      map['certificates'] = Variable<Uint8List>(certificates.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
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
          ..write('withCard: $withCard, ')
          ..write('context: $context, ')
          ..write('certificates: $certificates, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _gidMeta = const VerificationMeta('gid');
  @override
  late final GeneratedColumn<Uint8List> gid = GeneratedColumn<Uint8List>(
      'gid', aliasedName, true,
      type: DriftSqlType.blob,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES "groups" (id)'));
  @override
  late final GeneratedColumnWithTypeConverter<TaskState, String> state =
      GeneratedColumn<String>('state', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TaskState>($TasksTable.$converterstate);
  @override
  late final GeneratedColumnWithTypeConverter<TaskError?, String> error =
      GeneratedColumn<String>('error', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<TaskError?>($TasksTable.$convertererrorn);
  static const VerificationMeta _approvedMeta =
      const VerificationMeta('approved');
  @override
  late final GeneratedColumn<bool> approved = GeneratedColumn<bool>(
      'approved', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("approved" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _archivedMeta =
      const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
      'archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
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
      'context', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
      'data', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        did,
        gid,
        state,
        error,
        approved,
        archived,
        round,
        attempt,
        context,
        data,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
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
    if (data.containsKey('gid')) {
      context.handle(
          _gidMeta, gid.isAcceptableOrUnknown(data['gid']!, _gidMeta));
    }
    if (data.containsKey('approved')) {
      context.handle(_approvedMeta,
          approved.isAcceptableOrUnknown(data['approved']!, _approvedMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta,
          archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
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
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
      gid: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}gid']),
      state: $TasksTable.$converterstate.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!),
      error: $TasksTable.$convertererrorn.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error'])),
      approved: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}approved'])!,
      archived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
      round: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}round'])!,
      attempt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt'])!,
      context: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}context']),
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}data']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskState, String, String> $converterstate =
      const EnumNameConverter<TaskState>(TaskState.values);
  static JsonTypeConverter2<TaskError, String, String> $convertererror =
      const EnumNameConverter<TaskError>(TaskError.values);
  static JsonTypeConverter2<TaskError?, String?, String?> $convertererrorn =
      JsonTypeConverter2.asNullable($convertererror);
}

class Task extends DataClass implements Insertable<Task> {
  final Uint8List id;
  final Uint8List did;
  final Uint8List? gid;
  final TaskState state;
  final TaskError? error;
  final bool approved;
  final bool archived;
  final int round;
  final int attempt;
  final Uint8List? context;
  final Uint8List? data;
  final DateTime createdAt;
  const Task(
      {required this.id,
      required this.did,
      this.gid,
      required this.state,
      this.error,
      required this.approved,
      required this.archived,
      required this.round,
      required this.attempt,
      this.context,
      this.data,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<Uint8List>(id);
    map['did'] = Variable<Uint8List>(did);
    if (!nullToAbsent || gid != null) {
      map['gid'] = Variable<Uint8List>(gid);
    }
    {
      map['state'] = Variable<String>($TasksTable.$converterstate.toSql(state));
    }
    if (!nullToAbsent || error != null) {
      map['error'] =
          Variable<String>($TasksTable.$convertererrorn.toSql(error));
    }
    map['approved'] = Variable<bool>(approved);
    map['archived'] = Variable<bool>(archived);
    map['round'] = Variable<int>(round);
    map['attempt'] = Variable<int>(attempt);
    if (!nullToAbsent || context != null) {
      map['context'] = Variable<Uint8List>(context);
    }
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<Uint8List>(data);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      did: Value(did),
      gid: gid == null && nullToAbsent ? const Value.absent() : Value(gid),
      state: Value(state),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      approved: Value(approved),
      archived: Value(archived),
      round: Value(round),
      attempt: Value(attempt),
      context: context == null && nullToAbsent
          ? const Value.absent()
          : Value(context),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<Uint8List>(json['id']),
      did: serializer.fromJson<Uint8List>(json['did']),
      gid: serializer.fromJson<Uint8List?>(json['gid']),
      state: $TasksTable.$converterstate
          .fromJson(serializer.fromJson<String>(json['state'])),
      error: $TasksTable.$convertererrorn
          .fromJson(serializer.fromJson<String?>(json['error'])),
      approved: serializer.fromJson<bool>(json['approved']),
      archived: serializer.fromJson<bool>(json['archived']),
      round: serializer.fromJson<int>(json['round']),
      attempt: serializer.fromJson<int>(json['attempt']),
      context: serializer.fromJson<Uint8List?>(json['context']),
      data: serializer.fromJson<Uint8List?>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<Uint8List>(id),
      'did': serializer.toJson<Uint8List>(did),
      'gid': serializer.toJson<Uint8List?>(gid),
      'state':
          serializer.toJson<String>($TasksTable.$converterstate.toJson(state)),
      'error': serializer
          .toJson<String?>($TasksTable.$convertererrorn.toJson(error)),
      'approved': serializer.toJson<bool>(approved),
      'archived': serializer.toJson<bool>(archived),
      'round': serializer.toJson<int>(round),
      'attempt': serializer.toJson<int>(attempt),
      'context': serializer.toJson<Uint8List?>(context),
      'data': serializer.toJson<Uint8List?>(data),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith(
          {Uint8List? id,
          Uint8List? did,
          Value<Uint8List?> gid = const Value.absent(),
          TaskState? state,
          Value<TaskError?> error = const Value.absent(),
          bool? approved,
          bool? archived,
          int? round,
          int? attempt,
          Value<Uint8List?> context = const Value.absent(),
          Value<Uint8List?> data = const Value.absent(),
          DateTime? createdAt}) =>
      Task(
        id: id ?? this.id,
        did: did ?? this.did,
        gid: gid.present ? gid.value : this.gid,
        state: state ?? this.state,
        error: error.present ? error.value : this.error,
        approved: approved ?? this.approved,
        archived: archived ?? this.archived,
        round: round ?? this.round,
        attempt: attempt ?? this.attempt,
        context: context.present ? context.value : this.context,
        data: data.present ? data.value : this.data,
        createdAt: createdAt ?? this.createdAt,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      did: data.did.present ? data.did.value : this.did,
      gid: data.gid.present ? data.gid.value : this.gid,
      state: data.state.present ? data.state.value : this.state,
      error: data.error.present ? data.error.value : this.error,
      approved: data.approved.present ? data.approved.value : this.approved,
      archived: data.archived.present ? data.archived.value : this.archived,
      round: data.round.present ? data.round.value : this.round,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      context: data.context.present ? data.context.value : this.context,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('did: $did, ')
          ..write('gid: $gid, ')
          ..write('state: $state, ')
          ..write('error: $error, ')
          ..write('approved: $approved, ')
          ..write('archived: $archived, ')
          ..write('round: $round, ')
          ..write('attempt: $attempt, ')
          ..write('context: $context, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      $driftBlobEquality.hash(id),
      $driftBlobEquality.hash(did),
      $driftBlobEquality.hash(gid),
      state,
      error,
      approved,
      archived,
      round,
      attempt,
      $driftBlobEquality.hash(context),
      $driftBlobEquality.hash(data),
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          $driftBlobEquality.equals(other.id, this.id) &&
          $driftBlobEquality.equals(other.did, this.did) &&
          $driftBlobEquality.equals(other.gid, this.gid) &&
          other.state == this.state &&
          other.error == this.error &&
          other.approved == this.approved &&
          other.archived == this.archived &&
          other.round == this.round &&
          other.attempt == this.attempt &&
          $driftBlobEquality.equals(other.context, this.context) &&
          $driftBlobEquality.equals(other.data, this.data) &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<Uint8List> id;
  final Value<Uint8List> did;
  final Value<Uint8List?> gid;
  final Value<TaskState> state;
  final Value<TaskError?> error;
  final Value<bool> approved;
  final Value<bool> archived;
  final Value<int> round;
  final Value<int> attempt;
  final Value<Uint8List?> context;
  final Value<Uint8List?> data;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.did = const Value.absent(),
    this.gid = const Value.absent(),
    this.state = const Value.absent(),
    this.error = const Value.absent(),
    this.approved = const Value.absent(),
    this.archived = const Value.absent(),
    this.round = const Value.absent(),
    this.attempt = const Value.absent(),
    this.context = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required Uint8List id,
    required Uint8List did,
    this.gid = const Value.absent(),
    required TaskState state,
    this.error = const Value.absent(),
    this.approved = const Value.absent(),
    this.archived = const Value.absent(),
    this.round = const Value.absent(),
    this.attempt = const Value.absent(),
    this.context = const Value.absent(),
    this.data = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        did = Value(did),
        state = Value(state),
        createdAt = Value(createdAt);
  static Insertable<Task> custom({
    Expression<Uint8List>? id,
    Expression<Uint8List>? did,
    Expression<Uint8List>? gid,
    Expression<String>? state,
    Expression<String>? error,
    Expression<bool>? approved,
    Expression<bool>? archived,
    Expression<int>? round,
    Expression<int>? attempt,
    Expression<Uint8List>? context,
    Expression<Uint8List>? data,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (did != null) 'did': did,
      if (gid != null) 'gid': gid,
      if (state != null) 'state': state,
      if (error != null) 'error': error,
      if (approved != null) 'approved': approved,
      if (archived != null) 'archived': archived,
      if (round != null) 'round': round,
      if (attempt != null) 'attempt': attempt,
      if (context != null) 'context': context,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<Uint8List>? id,
      Value<Uint8List>? did,
      Value<Uint8List?>? gid,
      Value<TaskState>? state,
      Value<TaskError?>? error,
      Value<bool>? approved,
      Value<bool>? archived,
      Value<int>? round,
      Value<int>? attempt,
      Value<Uint8List?>? context,
      Value<Uint8List?>? data,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      did: did ?? this.did,
      gid: gid ?? this.gid,
      state: state ?? this.state,
      error: error ?? this.error,
      approved: approved ?? this.approved,
      archived: archived ?? this.archived,
      round: round ?? this.round,
      attempt: attempt ?? this.attempt,
      context: context ?? this.context,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
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
    if (gid.present) {
      map['gid'] = Variable<Uint8List>(gid.value);
    }
    if (state.present) {
      map['state'] =
          Variable<String>($TasksTable.$converterstate.toSql(state.value));
    }
    if (error.present) {
      map['error'] =
          Variable<String>($TasksTable.$convertererrorn.toSql(error.value));
    }
    if (approved.present) {
      map['approved'] = Variable<bool>(approved.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
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
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('did: $did, ')
          ..write('gid: $gid, ')
          ..write('state: $state, ')
          ..write('error: $error, ')
          ..write('approved: $approved, ')
          ..write('archived: $archived, ')
          ..write('round: $round, ')
          ..write('attempt: $attempt, ')
          ..write('context: $context, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _sharesMeta = const VerificationMeta('shares');
  @override
  late final GeneratedColumn<int> shares = GeneratedColumn<int>(
      'shares', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [tid, did, shares];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_members';
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
    if (data.containsKey('shares')) {
      context.handle(_sharesMeta,
          shares.isAcceptableOrUnknown(data['shares']!, _sharesMeta));
    } else if (isInserting) {
      context.missing(_sharesMeta);
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
      shares: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shares'])!,
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
  final int shares;
  const GroupMember(
      {required this.tid, required this.did, required this.shares});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tid'] = Variable<Uint8List>(tid);
    map['did'] = Variable<Uint8List>(did);
    map['shares'] = Variable<int>(shares);
    return map;
  }

  GroupMembersCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCompanion(
      tid: Value(tid),
      did: Value(did),
      shares: Value(shares),
    );
  }

  factory GroupMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMember(
      tid: serializer.fromJson<Uint8List>(json['tid']),
      did: serializer.fromJson<Uint8List>(json['did']),
      shares: serializer.fromJson<int>(json['shares']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tid': serializer.toJson<Uint8List>(tid),
      'did': serializer.toJson<Uint8List>(did),
      'shares': serializer.toJson<int>(shares),
    };
  }

  GroupMember copyWith({Uint8List? tid, Uint8List? did, int? shares}) =>
      GroupMember(
        tid: tid ?? this.tid,
        did: did ?? this.did,
        shares: shares ?? this.shares,
      );
  GroupMember copyWithCompanion(GroupMembersCompanion data) {
    return GroupMember(
      tid: data.tid.present ? data.tid.value : this.tid,
      did: data.did.present ? data.did.value : this.did,
      shares: data.shares.present ? data.shares.value : this.shares,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMember(')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('shares: $shares')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      $driftBlobEquality.hash(tid), $driftBlobEquality.hash(did), shares);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMember &&
          $driftBlobEquality.equals(other.tid, this.tid) &&
          $driftBlobEquality.equals(other.did, this.did) &&
          other.shares == this.shares);
}

class GroupMembersCompanion extends UpdateCompanion<GroupMember> {
  final Value<Uint8List> tid;
  final Value<Uint8List> did;
  final Value<int> shares;
  final Value<int> rowid;
  const GroupMembersCompanion({
    this.tid = const Value.absent(),
    this.did = const Value.absent(),
    this.shares = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupMembersCompanion.insert({
    required Uint8List tid,
    required Uint8List did,
    required int shares,
    this.rowid = const Value.absent(),
  })  : tid = Value(tid),
        did = Value(did),
        shares = Value(shares);
  static Insertable<GroupMember> custom({
    Expression<Uint8List>? tid,
    Expression<Uint8List>? did,
    Expression<int>? shares,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tid != null) 'tid': tid,
      if (did != null) 'did': did,
      if (shares != null) 'shares': shares,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupMembersCompanion copyWith(
      {Value<Uint8List>? tid,
      Value<Uint8List>? did,
      Value<int>? shares,
      Value<int>? rowid}) {
    return GroupMembersCompanion(
      tid: tid ?? this.tid,
      did: did ?? this.did,
      shares: shares ?? this.shares,
      rowid: rowid ?? this.rowid,
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
    if (shares.present) {
      map['shares'] = Variable<int>(shares.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCompanion(')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('shares: $shares, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [tid, did, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'files';
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
  final String name;
  const File({required this.tid, required this.did, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tid'] = Variable<Uint8List>(tid);
    map['did'] = Variable<Uint8List>(did);
    map['name'] = Variable<String>(name);
    return map;
  }

  FilesCompanion toCompanion(bool nullToAbsent) {
    return FilesCompanion(
      tid: Value(tid),
      did: Value(did),
      name: Value(name),
    );
  }

  factory File.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return File(
      tid: serializer.fromJson<Uint8List>(json['tid']),
      did: serializer.fromJson<Uint8List>(json['did']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tid': serializer.toJson<Uint8List>(tid),
      'did': serializer.toJson<Uint8List>(did),
      'name': serializer.toJson<String>(name),
    };
  }

  File copyWith({Uint8List? tid, Uint8List? did, String? name}) => File(
        tid: tid ?? this.tid,
        did: did ?? this.did,
        name: name ?? this.name,
      );
  File copyWithCompanion(FilesCompanion data) {
    return File(
      tid: data.tid.present ? data.tid.value : this.tid,
      did: data.did.present ? data.did.value : this.did,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('File(')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      $driftBlobEquality.hash(tid), $driftBlobEquality.hash(did), name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is File &&
          $driftBlobEquality.equals(other.tid, this.tid) &&
          $driftBlobEquality.equals(other.did, this.did) &&
          other.name == this.name);
}

class FilesCompanion extends UpdateCompanion<File> {
  final Value<Uint8List> tid;
  final Value<Uint8List> did;
  final Value<String> name;
  final Value<int> rowid;
  const FilesCompanion({
    this.tid = const Value.absent(),
    this.did = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FilesCompanion.insert({
    required Uint8List tid,
    required Uint8List did,
    required String name,
    this.rowid = const Value.absent(),
  })  : tid = Value(tid),
        did = Value(did),
        name = Value(name);
  static Insertable<File> custom({
    Expression<Uint8List>? tid,
    Expression<Uint8List>? did,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tid != null) 'tid': tid,
      if (did != null) 'did': did,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FilesCompanion copyWith(
      {Value<Uint8List>? tid,
      Value<Uint8List>? did,
      Value<String>? name,
      Value<int>? rowid}) {
    return FilesCompanion(
      tid: tid ?? this.tid,
      did: did ?? this.did,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FilesCompanion(')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
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
  List<GeneratedColumn> get $columns => [tid, did, name, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'challenges';
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
  final String name;
  final Uint8List data;
  const Challenge(
      {required this.tid,
      required this.did,
      required this.name,
      required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tid'] = Variable<Uint8List>(tid);
    map['did'] = Variable<Uint8List>(did);
    map['name'] = Variable<String>(name);
    map['data'] = Variable<Uint8List>(data);
    return map;
  }

  ChallengesCompanion toCompanion(bool nullToAbsent) {
    return ChallengesCompanion(
      tid: Value(tid),
      did: Value(did),
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
      'name': serializer.toJson<String>(name),
      'data': serializer.toJson<Uint8List>(data),
    };
  }

  Challenge copyWith(
          {Uint8List? tid, Uint8List? did, String? name, Uint8List? data}) =>
      Challenge(
        tid: tid ?? this.tid,
        did: did ?? this.did,
        name: name ?? this.name,
        data: data ?? this.data,
      );
  Challenge copyWithCompanion(ChallengesCompanion data) {
    return Challenge(
      tid: data.tid.present ? data.tid.value : this.tid,
      did: data.did.present ? data.did.value : this.did,
      name: data.name.present ? data.name.value : this.name,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Challenge(')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('name: $name, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash($driftBlobEquality.hash(tid),
      $driftBlobEquality.hash(did), name, $driftBlobEquality.hash(data));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Challenge &&
          $driftBlobEquality.equals(other.tid, this.tid) &&
          $driftBlobEquality.equals(other.did, this.did) &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.data, this.data));
}

class ChallengesCompanion extends UpdateCompanion<Challenge> {
  final Value<Uint8List> tid;
  final Value<Uint8List> did;
  final Value<String> name;
  final Value<Uint8List> data;
  final Value<int> rowid;
  const ChallengesCompanion({
    this.tid = const Value.absent(),
    this.did = const Value.absent(),
    this.name = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChallengesCompanion.insert({
    required Uint8List tid,
    required Uint8List did,
    required String name,
    required Uint8List data,
    this.rowid = const Value.absent(),
  })  : tid = Value(tid),
        did = Value(did),
        name = Value(name),
        data = Value(data);
  static Insertable<Challenge> custom({
    Expression<Uint8List>? tid,
    Expression<Uint8List>? did,
    Expression<String>? name,
    Expression<Uint8List>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tid != null) 'tid': tid,
      if (did != null) 'did': did,
      if (name != null) 'name': name,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChallengesCompanion copyWith(
      {Value<Uint8List>? tid,
      Value<Uint8List>? did,
      Value<String>? name,
      Value<Uint8List>? data,
      Value<int>? rowid}) {
    return ChallengesCompanion(
      tid: tid ?? this.tid,
      did: did ?? this.did,
      name: name ?? this.name,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChallengesCompanion(')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('name: $name, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecryptsTable extends Decrypts with TableInfo<$DecryptsTable, Decrypt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecryptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dataTypeMeta =
      const VerificationMeta('dataType');
  @override
  late final GeneratedColumn<String> dataType = GeneratedColumn<String>(
      'data_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
      'data', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [tid, did, name, dataType, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decrypts';
  @override
  VerificationContext validateIntegrity(Insertable<Decrypt> instance,
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('data_type')) {
      context.handle(_dataTypeMeta,
          dataType.isAcceptableOrUnknown(data['data_type']!, _dataTypeMeta));
    } else if (isInserting) {
      context.missing(_dataTypeMeta);
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
  Decrypt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Decrypt(
      tid: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}tid'])!,
      did: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}did'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dataType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_type'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}data'])!,
    );
  }

  @override
  $DecryptsTable createAlias(String alias) {
    return $DecryptsTable(attachedDatabase, alias);
  }
}

class Decrypt extends DataClass implements Insertable<Decrypt> {
  final Uint8List tid;
  final Uint8List did;
  final String name;
  final String dataType;
  final Uint8List data;
  const Decrypt(
      {required this.tid,
      required this.did,
      required this.name,
      required this.dataType,
      required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tid'] = Variable<Uint8List>(tid);
    map['did'] = Variable<Uint8List>(did);
    map['name'] = Variable<String>(name);
    map['data_type'] = Variable<String>(dataType);
    map['data'] = Variable<Uint8List>(data);
    return map;
  }

  DecryptsCompanion toCompanion(bool nullToAbsent) {
    return DecryptsCompanion(
      tid: Value(tid),
      did: Value(did),
      name: Value(name),
      dataType: Value(dataType),
      data: Value(data),
    );
  }

  factory Decrypt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Decrypt(
      tid: serializer.fromJson<Uint8List>(json['tid']),
      did: serializer.fromJson<Uint8List>(json['did']),
      name: serializer.fromJson<String>(json['name']),
      dataType: serializer.fromJson<String>(json['dataType']),
      data: serializer.fromJson<Uint8List>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tid': serializer.toJson<Uint8List>(tid),
      'did': serializer.toJson<Uint8List>(did),
      'name': serializer.toJson<String>(name),
      'dataType': serializer.toJson<String>(dataType),
      'data': serializer.toJson<Uint8List>(data),
    };
  }

  Decrypt copyWith(
          {Uint8List? tid,
          Uint8List? did,
          String? name,
          String? dataType,
          Uint8List? data}) =>
      Decrypt(
        tid: tid ?? this.tid,
        did: did ?? this.did,
        name: name ?? this.name,
        dataType: dataType ?? this.dataType,
        data: data ?? this.data,
      );
  Decrypt copyWithCompanion(DecryptsCompanion data) {
    return Decrypt(
      tid: data.tid.present ? data.tid.value : this.tid,
      did: data.did.present ? data.did.value : this.did,
      name: data.name.present ? data.name.value : this.name,
      dataType: data.dataType.present ? data.dataType.value : this.dataType,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Decrypt(')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('name: $name, ')
          ..write('dataType: $dataType, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      $driftBlobEquality.hash(tid),
      $driftBlobEquality.hash(did),
      name,
      dataType,
      $driftBlobEquality.hash(data));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Decrypt &&
          $driftBlobEquality.equals(other.tid, this.tid) &&
          $driftBlobEquality.equals(other.did, this.did) &&
          other.name == this.name &&
          other.dataType == this.dataType &&
          $driftBlobEquality.equals(other.data, this.data));
}

class DecryptsCompanion extends UpdateCompanion<Decrypt> {
  final Value<Uint8List> tid;
  final Value<Uint8List> did;
  final Value<String> name;
  final Value<String> dataType;
  final Value<Uint8List> data;
  final Value<int> rowid;
  const DecryptsCompanion({
    this.tid = const Value.absent(),
    this.did = const Value.absent(),
    this.name = const Value.absent(),
    this.dataType = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecryptsCompanion.insert({
    required Uint8List tid,
    required Uint8List did,
    required String name,
    required String dataType,
    required Uint8List data,
    this.rowid = const Value.absent(),
  })  : tid = Value(tid),
        did = Value(did),
        name = Value(name),
        dataType = Value(dataType),
        data = Value(data);
  static Insertable<Decrypt> custom({
    Expression<Uint8List>? tid,
    Expression<Uint8List>? did,
    Expression<String>? name,
    Expression<String>? dataType,
    Expression<Uint8List>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tid != null) 'tid': tid,
      if (did != null) 'did': did,
      if (name != null) 'name': name,
      if (dataType != null) 'data_type': dataType,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecryptsCompanion copyWith(
      {Value<Uint8List>? tid,
      Value<Uint8List>? did,
      Value<String>? name,
      Value<String>? dataType,
      Value<Uint8List>? data,
      Value<int>? rowid}) {
    return DecryptsCompanion(
      tid: tid ?? this.tid,
      did: did ?? this.did,
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dataType.present) {
      map['data_type'] = Variable<String>(dataType.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecryptsCompanion(')
          ..write('tid: $tid, ')
          ..write('did: $did, ')
          ..write('name: $name, ')
          ..write('dataType: $dataType, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final $FilesTable files = $FilesTable(this);
  late final $ChallengesTable challenges = $ChallengesTable(this);
  late final $DecryptsTable decrypts = $DecryptsTable(this);
  late final DeviceDao deviceDao = DeviceDao(this as Database);
  late final UserDao userDao = UserDao(this as Database);
  late final TaskDao taskDao = TaskDao(this as Database);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        devices,
        users,
        groups,
        tasks,
        groupMembers,
        files,
        challenges,
        decrypts
      ];
}

typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required Uint8List id,
  required String name,
  required DeviceKind kind,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<Uint8List> id,
  Value<String> name,
  Value<DeviceKind> kind,
  Value<int> rowid,
});

final class $$DevicesTableReferences
    extends BaseReferences<_$Database, $DevicesTable, Device> {
  $$DevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UsersTable, List<User>> _usersRefsTable(
          _$Database db) =>
      MultiTypedResultKey.fromTable(db.users,
          aliasName: $_aliasNameGenerator(db.devices.id, db.users.id));

  $$UsersTableProcessedTableManager get usersRefs {
    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.id.sqlEquals($_itemColumn<Uint8List>('id')!));

    final cache = $_typedResult.readTableOrNull(_usersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
      _groupMembersRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
          db.groupMembers,
          aliasName: $_aliasNameGenerator(db.devices.id, db.groupMembers.did));

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager($_db, $_db.groupMembers)
        .filter((f) => f.did.id.sqlEquals($_itemColumn<Uint8List>('id')!));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DevicesTableFilterComposer extends Composer<_$Database, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<Uint8List> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DeviceKind, DeviceKind, String> get kind =>
      $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> usersRefs(
      Expression<bool> Function($$UsersTableFilterComposer f) f) {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> groupMembersRefs(
      Expression<bool> Function($$GroupMembersTableFilterComposer f) f) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.did,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableFilterComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DevicesTableOrderingComposer
    extends Composer<_$Database, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$Database, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DeviceKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  Expression<T> usersRefs<T extends Object>(
      Expression<T> Function($$UsersTableAnnotationComposer a) f) {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> groupMembersRefs<T extends Object>(
      Expression<T> Function($$GroupMembersTableAnnotationComposer a) f) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.did,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DevicesTableTableManager extends RootTableManager<
    _$Database,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, $$DevicesTableReferences),
    Device,
    PrefetchHooks Function({bool usersRefs, bool groupMembersRefs})> {
  $$DevicesTableTableManager(_$Database db, $DevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<Uint8List> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DeviceKind> kind = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion(
            id: id,
            name: name,
            kind: kind,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required Uint8List id,
            required String name,
            required DeviceKind kind,
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion.insert(
            id: id,
            name: name,
            kind: kind,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DevicesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {usersRefs = false, groupMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (usersRefs) db.users,
                if (groupMembersRefs) db.groupMembers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (usersRefs)
                    await $_getPrefetchedData<Device, $DevicesTable, User>(
                        currentTable: table,
                        referencedTable:
                            $$DevicesTableReferences._usersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DevicesTableReferences(db, table, p0).usersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.id == item.id),
                        typedResults: items),
                  if (groupMembersRefs)
                    await $_getPrefetchedData<Device, $DevicesTable,
                            GroupMember>(
                        currentTable: table,
                        referencedTable:
                            $$DevicesTableReferences._groupMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DevicesTableReferences(db, table, p0)
                                .groupMembersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.did == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DevicesTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, $$DevicesTableReferences),
    Device,
    PrefetchHooks Function({bool usersRefs, bool groupMembersRefs})>;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required Uint8List id,
  required String host,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<Uint8List> id,
  Value<String> host,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$Database, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DevicesTable _idTable(_$Database db) =>
      db.devices.createAlias($_aliasNameGenerator(db.users.id, db.devices.id));

  $$DevicesTableProcessedTableManager get id {
    final $_column = $_itemColumn<Uint8List>('id')!;

    final manager = $$DevicesTableTableManager($_db, $_db.devices)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UsersTableFilterComposer extends Composer<_$Database, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get host => $composableBuilder(
      column: $table.host, builder: (column) => ColumnFilters(column));

  $$DevicesTableFilterComposer get id {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableFilterComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UsersTableOrderingComposer extends Composer<_$Database, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get host => $composableBuilder(
      column: $table.host, builder: (column) => ColumnOrderings(column));

  $$DevicesTableOrderingComposer get id {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableOrderingComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UsersTableAnnotationComposer extends Composer<_$Database, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  $$DevicesTableAnnotationComposer get id {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableAnnotationComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$Database,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function({bool id})> {
  $$UsersTableTableManager(_$Database db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<Uint8List> id = const Value.absent(),
            Value<String> host = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            host: host,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required Uint8List id,
            required String host,
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            host: host,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({id = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (id) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.id,
                    referencedTable: $$UsersTableReferences._idTable(db),
                    referencedColumn: $$UsersTableReferences._idTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function({bool id})>;
typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  Value<Uint8List?> id,
  required Uint8List tid,
  required Uint8List did,
  required String name,
  required int threshold,
  required Protocol protocol,
  required KeyType keyType,
  Value<bool> withCard,
  required Uint8List context,
  Value<Uint8List?> certificates,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<Uint8List?> id,
  Value<Uint8List> tid,
  Value<Uint8List> did,
  Value<String> name,
  Value<int> threshold,
  Value<Protocol> protocol,
  Value<KeyType> keyType,
  Value<bool> withCard,
  Value<Uint8List> context,
  Value<Uint8List?> certificates,
  Value<String?> note,
  Value<int> rowid,
});

final class $$GroupsTableReferences
    extends BaseReferences<_$Database, $GroupsTable, Group> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
          _$Database db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName: $_aliasNameGenerator(db.groups.id, db.tasks.gid));

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks).filter((f) =>
        f.gid.id.sqlEquals($_itemColumn<Uint8List>('id') ?? Uint8List(0)));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
      _groupMembersRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
          db.groupMembers,
          aliasName: $_aliasNameGenerator(db.groups.id, db.groupMembers.tid));

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager($_db, $_db.groupMembers)
        .filter((f) =>
            f.tid.id.sqlEquals($_itemColumn<Uint8List>('id') ?? Uint8List(0)));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GroupsTableFilterComposer extends Composer<_$Database, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<Uint8List> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get tid => $composableBuilder(
      column: $table.tid, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get did => $composableBuilder(
      column: $table.did, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get threshold => $composableBuilder(
      column: $table.threshold, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Protocol, Protocol, String> get protocol =>
      $composableBuilder(
          column: $table.protocol,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<KeyType, KeyType, String> get keyType =>
      $composableBuilder(
          column: $table.keyType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get withCard => $composableBuilder(
      column: $table.withCard, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get certificates => $composableBuilder(
      column: $table.certificates, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  Expression<bool> tasksRefs(
      Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.gid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> groupMembersRefs(
      Expression<bool> Function($$GroupMembersTableFilterComposer f) f) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.tid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableFilterComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer extends Composer<_$Database, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get tid => $composableBuilder(
      column: $table.tid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get did => $composableBuilder(
      column: $table.did, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get threshold => $composableBuilder(
      column: $table.threshold, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get protocol => $composableBuilder(
      column: $table.protocol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keyType => $composableBuilder(
      column: $table.keyType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get withCard => $composableBuilder(
      column: $table.withCard, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get certificates => $composableBuilder(
      column: $table.certificates,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$Database, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get tid =>
      $composableBuilder(column: $table.tid, builder: (column) => column);

  GeneratedColumn<Uint8List> get did =>
      $composableBuilder(column: $table.did, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get threshold =>
      $composableBuilder(column: $table.threshold, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Protocol, String> get protocol =>
      $composableBuilder(column: $table.protocol, builder: (column) => column);

  GeneratedColumnWithTypeConverter<KeyType, String> get keyType =>
      $composableBuilder(column: $table.keyType, builder: (column) => column);

  GeneratedColumn<bool> get withCard =>
      $composableBuilder(column: $table.withCard, builder: (column) => column);

  GeneratedColumn<Uint8List> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<Uint8List> get certificates => $composableBuilder(
      column: $table.certificates, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  Expression<T> tasksRefs<T extends Object>(
      Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.gid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> groupMembersRefs<T extends Object>(
      Expression<T> Function($$GroupMembersTableAnnotationComposer a) f) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.tid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupsTableTableManager extends RootTableManager<
    _$Database,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, $$GroupsTableReferences),
    Group,
    PrefetchHooks Function({bool tasksRefs, bool groupMembersRefs})> {
  $$GroupsTableTableManager(_$Database db, $GroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<Uint8List?> id = const Value.absent(),
            Value<Uint8List> tid = const Value.absent(),
            Value<Uint8List> did = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> threshold = const Value.absent(),
            Value<Protocol> protocol = const Value.absent(),
            Value<KeyType> keyType = const Value.absent(),
            Value<bool> withCard = const Value.absent(),
            Value<Uint8List> context = const Value.absent(),
            Value<Uint8List?> certificates = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupsCompanion(
            id: id,
            tid: tid,
            did: did,
            name: name,
            threshold: threshold,
            protocol: protocol,
            keyType: keyType,
            withCard: withCard,
            context: context,
            certificates: certificates,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<Uint8List?> id = const Value.absent(),
            required Uint8List tid,
            required Uint8List did,
            required String name,
            required int threshold,
            required Protocol protocol,
            required KeyType keyType,
            Value<bool> withCard = const Value.absent(),
            required Uint8List context,
            Value<Uint8List?> certificates = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupsCompanion.insert(
            id: id,
            tid: tid,
            did: did,
            name: name,
            threshold: threshold,
            protocol: protocol,
            keyType: keyType,
            withCard: withCard,
            context: context,
            certificates: certificates,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GroupsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {tasksRefs = false, groupMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tasksRefs) db.tasks,
                if (groupMembersRefs) db.groupMembers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<Group, $GroupsTable, Task>(
                        currentTable: table,
                        referencedTable:
                            $$GroupsTableReferences._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupsTableReferences(db, table, p0).tasksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.gid == item.id),
                        typedResults: items),
                  if (groupMembersRefs)
                    await $_getPrefetchedData<Group, $GroupsTable, GroupMember>(
                        currentTable: table,
                        referencedTable:
                            $$GroupsTableReferences._groupMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupsTableReferences(db, table, p0)
                                .groupMembersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) =>
                                referencedItems.where((e) => e.tid == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GroupsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, $$GroupsTableReferences),
    Group,
    PrefetchHooks Function({bool tasksRefs, bool groupMembersRefs})>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required Uint8List id,
  required Uint8List did,
  Value<Uint8List?> gid,
  required TaskState state,
  Value<TaskError?> error,
  Value<bool> approved,
  Value<bool> archived,
  Value<int> round,
  Value<int> attempt,
  Value<Uint8List?> context,
  Value<Uint8List?> data,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<Uint8List> id,
  Value<Uint8List> did,
  Value<Uint8List?> gid,
  Value<TaskState> state,
  Value<TaskError?> error,
  Value<bool> approved,
  Value<bool> archived,
  Value<int> round,
  Value<int> attempt,
  Value<Uint8List?> context,
  Value<Uint8List?> data,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$Database, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _gidTable(_$Database db) =>
      db.groups.createAlias($_aliasNameGenerator(db.tasks.gid, db.groups.id));

  $$GroupsTableProcessedTableManager? get gid {
    final $_column = $_itemColumn<Uint8List>('gid');
    if ($_column == null) return null;
    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TasksTableFilterComposer extends Composer<_$Database, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<Uint8List> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get did => $composableBuilder(
      column: $table.did, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TaskState, TaskState, String> get state =>
      $composableBuilder(
          column: $table.state,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<TaskError?, TaskError, String> get error =>
      $composableBuilder(
          column: $table.error,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get approved => $composableBuilder(
      column: $table.approved, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get round => $composableBuilder(
      column: $table.round, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempt => $composableBuilder(
      column: $table.attempt, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$GroupsTableFilterComposer get gid {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gid,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableOrderingComposer extends Composer<_$Database, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get did => $composableBuilder(
      column: $table.did, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get approved => $composableBuilder(
      column: $table.approved, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get round => $composableBuilder(
      column: $table.round, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempt => $composableBuilder(
      column: $table.attempt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$GroupsTableOrderingComposer get gid {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gid,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableOrderingComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableAnnotationComposer extends Composer<_$Database, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get did =>
      $composableBuilder(column: $table.did, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskError?, String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<bool> get approved =>
      $composableBuilder(column: $table.approved, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<Uint8List> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get gid {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.gid,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$Database,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function({bool gid})> {
  $$TasksTableTableManager(_$Database db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<Uint8List> id = const Value.absent(),
            Value<Uint8List> did = const Value.absent(),
            Value<Uint8List?> gid = const Value.absent(),
            Value<TaskState> state = const Value.absent(),
            Value<TaskError?> error = const Value.absent(),
            Value<bool> approved = const Value.absent(),
            Value<bool> archived = const Value.absent(),
            Value<int> round = const Value.absent(),
            Value<int> attempt = const Value.absent(),
            Value<Uint8List?> context = const Value.absent(),
            Value<Uint8List?> data = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            did: did,
            gid: gid,
            state: state,
            error: error,
            approved: approved,
            archived: archived,
            round: round,
            attempt: attempt,
            context: context,
            data: data,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required Uint8List id,
            required Uint8List did,
            Value<Uint8List?> gid = const Value.absent(),
            required TaskState state,
            Value<TaskError?> error = const Value.absent(),
            Value<bool> approved = const Value.absent(),
            Value<bool> archived = const Value.absent(),
            Value<int> round = const Value.absent(),
            Value<int> attempt = const Value.absent(),
            Value<Uint8List?> context = const Value.absent(),
            Value<Uint8List?> data = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            did: did,
            gid: gid,
            state: state,
            error: error,
            approved: approved,
            archived: archived,
            round: round,
            attempt: attempt,
            context: context,
            data: data,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({gid = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (gid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.gid,
                    referencedTable: $$TasksTableReferences._gidTable(db),
                    referencedColumn: $$TasksTableReferences._gidTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function({bool gid})>;
typedef $$GroupMembersTableCreateCompanionBuilder = GroupMembersCompanion
    Function({
  required Uint8List tid,
  required Uint8List did,
  required int shares,
  Value<int> rowid,
});
typedef $$GroupMembersTableUpdateCompanionBuilder = GroupMembersCompanion
    Function({
  Value<Uint8List> tid,
  Value<Uint8List> did,
  Value<int> shares,
  Value<int> rowid,
});

final class $$GroupMembersTableReferences
    extends BaseReferences<_$Database, $GroupMembersTable, GroupMember> {
  $$GroupMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _tidTable(_$Database db) => db.groups
      .createAlias($_aliasNameGenerator(db.groupMembers.tid, db.groups.id));

  $$GroupsTableProcessedTableManager get tid {
    final $_column = $_itemColumn<Uint8List>('tid')!;

    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $DevicesTable _didTable(_$Database db) => db.devices
      .createAlias($_aliasNameGenerator(db.groupMembers.did, db.devices.id));

  $$DevicesTableProcessedTableManager get did {
    final $_column = $_itemColumn<Uint8List>('did')!;

    final manager = $$DevicesTableTableManager($_db, $_db.devices)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_didTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GroupMembersTableFilterComposer
    extends Composer<_$Database, $GroupMembersTable> {
  $$GroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get shares => $composableBuilder(
      column: $table.shares, builder: (column) => ColumnFilters(column));

  $$GroupsTableFilterComposer get tid {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tid,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DevicesTableFilterComposer get did {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.did,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableFilterComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupMembersTableOrderingComposer
    extends Composer<_$Database, $GroupMembersTable> {
  $$GroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get shares => $composableBuilder(
      column: $table.shares, builder: (column) => ColumnOrderings(column));

  $$GroupsTableOrderingComposer get tid {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tid,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableOrderingComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DevicesTableOrderingComposer get did {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.did,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableOrderingComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupMembersTableAnnotationComposer
    extends Composer<_$Database, $GroupMembersTable> {
  $$GroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get shares =>
      $composableBuilder(column: $table.shares, builder: (column) => column);

  $$GroupsTableAnnotationComposer get tid {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tid,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DevicesTableAnnotationComposer get did {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.did,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableAnnotationComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupMembersTableTableManager extends RootTableManager<
    _$Database,
    $GroupMembersTable,
    GroupMember,
    $$GroupMembersTableFilterComposer,
    $$GroupMembersTableOrderingComposer,
    $$GroupMembersTableAnnotationComposer,
    $$GroupMembersTableCreateCompanionBuilder,
    $$GroupMembersTableUpdateCompanionBuilder,
    (GroupMember, $$GroupMembersTableReferences),
    GroupMember,
    PrefetchHooks Function({bool tid, bool did})> {
  $$GroupMembersTableTableManager(_$Database db, $GroupMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<Uint8List> tid = const Value.absent(),
            Value<Uint8List> did = const Value.absent(),
            Value<int> shares = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupMembersCompanion(
            tid: tid,
            did: did,
            shares: shares,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required Uint8List tid,
            required Uint8List did,
            required int shares,
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupMembersCompanion.insert(
            tid: tid,
            did: did,
            shares: shares,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GroupMembersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({tid = false, did = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (tid) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tid,
                    referencedTable:
                        $$GroupMembersTableReferences._tidTable(db),
                    referencedColumn:
                        $$GroupMembersTableReferences._tidTable(db).id,
                  ) as T;
                }
                if (did) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.did,
                    referencedTable:
                        $$GroupMembersTableReferences._didTable(db),
                    referencedColumn:
                        $$GroupMembersTableReferences._didTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GroupMembersTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $GroupMembersTable,
    GroupMember,
    $$GroupMembersTableFilterComposer,
    $$GroupMembersTableOrderingComposer,
    $$GroupMembersTableAnnotationComposer,
    $$GroupMembersTableCreateCompanionBuilder,
    $$GroupMembersTableUpdateCompanionBuilder,
    (GroupMember, $$GroupMembersTableReferences),
    GroupMember,
    PrefetchHooks Function({bool tid, bool did})>;
typedef $$FilesTableCreateCompanionBuilder = FilesCompanion Function({
  required Uint8List tid,
  required Uint8List did,
  required String name,
  Value<int> rowid,
});
typedef $$FilesTableUpdateCompanionBuilder = FilesCompanion Function({
  Value<Uint8List> tid,
  Value<Uint8List> did,
  Value<String> name,
  Value<int> rowid,
});

class $$FilesTableFilterComposer extends Composer<_$Database, $FilesTable> {
  $$FilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<Uint8List> get tid => $composableBuilder(
      column: $table.tid, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get did => $composableBuilder(
      column: $table.did, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$FilesTableOrderingComposer extends Composer<_$Database, $FilesTable> {
  $$FilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get tid => $composableBuilder(
      column: $table.tid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get did => $composableBuilder(
      column: $table.did, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$FilesTableAnnotationComposer extends Composer<_$Database, $FilesTable> {
  $$FilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<Uint8List> get tid =>
      $composableBuilder(column: $table.tid, builder: (column) => column);

  GeneratedColumn<Uint8List> get did =>
      $composableBuilder(column: $table.did, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$FilesTableTableManager extends RootTableManager<
    _$Database,
    $FilesTable,
    File,
    $$FilesTableFilterComposer,
    $$FilesTableOrderingComposer,
    $$FilesTableAnnotationComposer,
    $$FilesTableCreateCompanionBuilder,
    $$FilesTableUpdateCompanionBuilder,
    (File, BaseReferences<_$Database, $FilesTable, File>),
    File,
    PrefetchHooks Function()> {
  $$FilesTableTableManager(_$Database db, $FilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<Uint8List> tid = const Value.absent(),
            Value<Uint8List> did = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FilesCompanion(
            tid: tid,
            did: did,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required Uint8List tid,
            required Uint8List did,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              FilesCompanion.insert(
            tid: tid,
            did: did,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FilesTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $FilesTable,
    File,
    $$FilesTableFilterComposer,
    $$FilesTableOrderingComposer,
    $$FilesTableAnnotationComposer,
    $$FilesTableCreateCompanionBuilder,
    $$FilesTableUpdateCompanionBuilder,
    (File, BaseReferences<_$Database, $FilesTable, File>),
    File,
    PrefetchHooks Function()>;
typedef $$ChallengesTableCreateCompanionBuilder = ChallengesCompanion Function({
  required Uint8List tid,
  required Uint8List did,
  required String name,
  required Uint8List data,
  Value<int> rowid,
});
typedef $$ChallengesTableUpdateCompanionBuilder = ChallengesCompanion Function({
  Value<Uint8List> tid,
  Value<Uint8List> did,
  Value<String> name,
  Value<Uint8List> data,
  Value<int> rowid,
});

class $$ChallengesTableFilterComposer
    extends Composer<_$Database, $ChallengesTable> {
  $$ChallengesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<Uint8List> get tid => $composableBuilder(
      column: $table.tid, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get did => $composableBuilder(
      column: $table.did, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));
}

class $$ChallengesTableOrderingComposer
    extends Composer<_$Database, $ChallengesTable> {
  $$ChallengesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get tid => $composableBuilder(
      column: $table.tid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get did => $composableBuilder(
      column: $table.did, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));
}

class $$ChallengesTableAnnotationComposer
    extends Composer<_$Database, $ChallengesTable> {
  $$ChallengesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<Uint8List> get tid =>
      $composableBuilder(column: $table.tid, builder: (column) => column);

  GeneratedColumn<Uint8List> get did =>
      $composableBuilder(column: $table.did, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$ChallengesTableTableManager extends RootTableManager<
    _$Database,
    $ChallengesTable,
    Challenge,
    $$ChallengesTableFilterComposer,
    $$ChallengesTableOrderingComposer,
    $$ChallengesTableAnnotationComposer,
    $$ChallengesTableCreateCompanionBuilder,
    $$ChallengesTableUpdateCompanionBuilder,
    (Challenge, BaseReferences<_$Database, $ChallengesTable, Challenge>),
    Challenge,
    PrefetchHooks Function()> {
  $$ChallengesTableTableManager(_$Database db, $ChallengesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChallengesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChallengesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChallengesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<Uint8List> tid = const Value.absent(),
            Value<Uint8List> did = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<Uint8List> data = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChallengesCompanion(
            tid: tid,
            did: did,
            name: name,
            data: data,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required Uint8List tid,
            required Uint8List did,
            required String name,
            required Uint8List data,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChallengesCompanion.insert(
            tid: tid,
            did: did,
            name: name,
            data: data,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChallengesTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $ChallengesTable,
    Challenge,
    $$ChallengesTableFilterComposer,
    $$ChallengesTableOrderingComposer,
    $$ChallengesTableAnnotationComposer,
    $$ChallengesTableCreateCompanionBuilder,
    $$ChallengesTableUpdateCompanionBuilder,
    (Challenge, BaseReferences<_$Database, $ChallengesTable, Challenge>),
    Challenge,
    PrefetchHooks Function()>;
typedef $$DecryptsTableCreateCompanionBuilder = DecryptsCompanion Function({
  required Uint8List tid,
  required Uint8List did,
  required String name,
  required String dataType,
  required Uint8List data,
  Value<int> rowid,
});
typedef $$DecryptsTableUpdateCompanionBuilder = DecryptsCompanion Function({
  Value<Uint8List> tid,
  Value<Uint8List> did,
  Value<String> name,
  Value<String> dataType,
  Value<Uint8List> data,
  Value<int> rowid,
});

class $$DecryptsTableFilterComposer
    extends Composer<_$Database, $DecryptsTable> {
  $$DecryptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<Uint8List> get tid => $composableBuilder(
      column: $table.tid, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get did => $composableBuilder(
      column: $table.did, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dataType => $composableBuilder(
      column: $table.dataType, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));
}

class $$DecryptsTableOrderingComposer
    extends Composer<_$Database, $DecryptsTable> {
  $$DecryptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get tid => $composableBuilder(
      column: $table.tid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get did => $composableBuilder(
      column: $table.did, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dataType => $composableBuilder(
      column: $table.dataType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));
}

class $$DecryptsTableAnnotationComposer
    extends Composer<_$Database, $DecryptsTable> {
  $$DecryptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<Uint8List> get tid =>
      $composableBuilder(column: $table.tid, builder: (column) => column);

  GeneratedColumn<Uint8List> get did =>
      $composableBuilder(column: $table.did, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dataType =>
      $composableBuilder(column: $table.dataType, builder: (column) => column);

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$DecryptsTableTableManager extends RootTableManager<
    _$Database,
    $DecryptsTable,
    Decrypt,
    $$DecryptsTableFilterComposer,
    $$DecryptsTableOrderingComposer,
    $$DecryptsTableAnnotationComposer,
    $$DecryptsTableCreateCompanionBuilder,
    $$DecryptsTableUpdateCompanionBuilder,
    (Decrypt, BaseReferences<_$Database, $DecryptsTable, Decrypt>),
    Decrypt,
    PrefetchHooks Function()> {
  $$DecryptsTableTableManager(_$Database db, $DecryptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecryptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecryptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecryptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<Uint8List> tid = const Value.absent(),
            Value<Uint8List> did = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> dataType = const Value.absent(),
            Value<Uint8List> data = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DecryptsCompanion(
            tid: tid,
            did: did,
            name: name,
            dataType: dataType,
            data: data,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required Uint8List tid,
            required Uint8List did,
            required String name,
            required String dataType,
            required Uint8List data,
            Value<int> rowid = const Value.absent(),
          }) =>
              DecryptsCompanion.insert(
            tid: tid,
            did: did,
            name: name,
            dataType: dataType,
            data: data,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DecryptsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $DecryptsTable,
    Decrypt,
    $$DecryptsTableFilterComposer,
    $$DecryptsTableOrderingComposer,
    $$DecryptsTableAnnotationComposer,
    $$DecryptsTableCreateCompanionBuilder,
    $$DecryptsTableUpdateCompanionBuilder,
    (Decrypt, BaseReferences<_$Database, $DecryptsTable, Decrypt>),
    Decrypt,
    PrefetchHooks Function()>;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db, _db.groupMembers);
  $$FilesTableTableManager get files =>
      $$FilesTableTableManager(_db, _db.files);
  $$ChallengesTableTableManager get challenges =>
      $$ChallengesTableTableManager(_db, _db.challenges);
  $$DecryptsTableTableManager get decrypts =>
      $$DecryptsTableTableManager(_db, _db.decrypts);
}
