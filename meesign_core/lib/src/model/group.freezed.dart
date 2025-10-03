// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Member {
  Device get device;
  int get shares;

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MemberCopyWith<Member> get copyWith =>
      _$MemberCopyWithImpl<Member>(this as Member, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Member &&
            (identical(other.device, device) || other.device == device) &&
            (identical(other.shares, shares) || other.shares == shares));
  }

  @override
  int get hashCode => Object.hash(runtimeType, device, shares);

  @override
  String toString() {
    return 'Member(device: $device, shares: $shares)';
  }
}

/// @nodoc
abstract mixin class $MemberCopyWith<$Res> {
  factory $MemberCopyWith(Member value, $Res Function(Member) _then) =
      _$MemberCopyWithImpl;
  @useResult
  $Res call({Device device, int shares});
}

/// @nodoc
class _$MemberCopyWithImpl<$Res> implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._self, this._then);

  final Member _self;
  final $Res Function(Member) _then;

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? device = null,
    Object? shares = null,
  }) {
    return _then(_self.copyWith(
      device: null == device
          ? _self.device
          : device // ignore: cast_nullable_to_non_nullable
              as Device,
      shares: null == shares
          ? _self.shares
          : shares // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [Member].
extension MemberPatterns on Member {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Member value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Member() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Member value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Member():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Member value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Member() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(Device device, int shares)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Member() when $default != null:
        return $default(_that.device, _that.shares);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(Device device, int shares) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Member():
        return $default(_that.device, _that.shares);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(Device device, int shares)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Member() when $default != null:
        return $default(_that.device, _that.shares);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Member implements Member {
  const _Member(this.device, this.shares);

  @override
  final Device device;
  @override
  final int shares;

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MemberCopyWith<_Member> get copyWith =>
      __$MemberCopyWithImpl<_Member>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Member &&
            (identical(other.device, device) || other.device == device) &&
            (identical(other.shares, shares) || other.shares == shares));
  }

  @override
  int get hashCode => Object.hash(runtimeType, device, shares);

  @override
  String toString() {
    return 'Member(device: $device, shares: $shares)';
  }
}

/// @nodoc
abstract mixin class _$MemberCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$MemberCopyWith(_Member value, $Res Function(_Member) _then) =
      __$MemberCopyWithImpl;
  @override
  @useResult
  $Res call({Device device, int shares});
}

/// @nodoc
class __$MemberCopyWithImpl<$Res> implements _$MemberCopyWith<$Res> {
  __$MemberCopyWithImpl(this._self, this._then);

  final _Member _self;
  final $Res Function(_Member) _then;

  /// Create a copy of Member
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? device = null,
    Object? shares = null,
  }) {
    return _then(_Member(
      null == device
          ? _self.device
          : device // ignore: cast_nullable_to_non_nullable
              as Device,
      null == shares
          ? _self.shares
          : shares // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$Group {
  List<int> get id;
  String get name;
  List<Member> get members;
  int get threshold;
  Protocol get protocol;
  KeyType get keyType;
  String? get note;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GroupCopyWith<Group> get copyWith =>
      _$GroupCopyWithImpl<Group>(this as Group, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Group &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other.members, members) &&
            (identical(other.threshold, threshold) ||
                other.threshold == threshold) &&
            (identical(other.protocol, protocol) ||
                other.protocol == protocol) &&
            (identical(other.keyType, keyType) || other.keyType == keyType) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      name,
      const DeepCollectionEquality().hash(members),
      threshold,
      protocol,
      keyType,
      note);

  @override
  String toString() {
    return 'Group(id: $id, name: $name, members: $members, threshold: $threshold, protocol: $protocol, keyType: $keyType, note: $note)';
  }
}

/// @nodoc
abstract mixin class $GroupCopyWith<$Res> {
  factory $GroupCopyWith(Group value, $Res Function(Group) _then) =
      _$GroupCopyWithImpl;
  @useResult
  $Res call(
      {List<int> id,
      String name,
      List<Member> members,
      int threshold,
      Protocol protocol,
      KeyType keyType,
      String? note});
}

/// @nodoc
class _$GroupCopyWithImpl<$Res> implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._self, this._then);

  final Group _self;
  final $Res Function(Group) _then;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? members = null,
    Object? threshold = null,
    Object? protocol = null,
    Object? keyType = null,
    Object? note = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as List<int>,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      members: null == members
          ? _self.members
          : members // ignore: cast_nullable_to_non_nullable
              as List<Member>,
      threshold: null == threshold
          ? _self.threshold
          : threshold // ignore: cast_nullable_to_non_nullable
              as int,
      protocol: null == protocol
          ? _self.protocol
          : protocol // ignore: cast_nullable_to_non_nullable
              as Protocol,
      keyType: null == keyType
          ? _self.keyType
          : keyType // ignore: cast_nullable_to_non_nullable
              as KeyType,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Group].
extension GroupPatterns on Group {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Group value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Group() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Group value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Group():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Group value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Group() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<int> id, String name, List<Member> members,
            int threshold, Protocol protocol, KeyType keyType, String? note)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Group() when $default != null:
        return $default(_that.id, _that.name, _that.members, _that.threshold,
            _that.protocol, _that.keyType, _that.note);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<int> id, String name, List<Member> members,
            int threshold, Protocol protocol, KeyType keyType, String? note)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Group():
        return $default(_that.id, _that.name, _that.members, _that.threshold,
            _that.protocol, _that.keyType, _that.note);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<int> id, String name, List<Member> members,
            int threshold, Protocol protocol, KeyType keyType, String? note)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Group() when $default != null:
        return $default(_that.id, _that.name, _that.members, _that.threshold,
            _that.protocol, _that.keyType, _that.note);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Group extends Group {
  const _Group(
      {required final List<int> id,
      required this.name,
      required final List<Member> members,
      required this.threshold,
      required this.protocol,
      required this.keyType,
      this.note})
      : _id = id,
        _members = members,
        super._();

  final List<int> _id;
  @override
  List<int> get id {
    if (_id is EqualUnmodifiableListView) return _id;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_id);
  }

  @override
  final String name;
  final List<Member> _members;
  @override
  List<Member> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  @override
  final int threshold;
  @override
  final Protocol protocol;
  @override
  final KeyType keyType;
  @override
  final String? note;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GroupCopyWith<_Group> get copyWith =>
      __$GroupCopyWithImpl<_Group>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Group &&
            const DeepCollectionEquality().equals(other._id, _id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            (identical(other.threshold, threshold) ||
                other.threshold == threshold) &&
            (identical(other.protocol, protocol) ||
                other.protocol == protocol) &&
            (identical(other.keyType, keyType) || other.keyType == keyType) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_id),
      name,
      const DeepCollectionEquality().hash(_members),
      threshold,
      protocol,
      keyType,
      note);

  @override
  String toString() {
    return 'Group(id: $id, name: $name, members: $members, threshold: $threshold, protocol: $protocol, keyType: $keyType, note: $note)';
  }
}

/// @nodoc
abstract mixin class _$GroupCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$GroupCopyWith(_Group value, $Res Function(_Group) _then) =
      __$GroupCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<int> id,
      String name,
      List<Member> members,
      int threshold,
      Protocol protocol,
      KeyType keyType,
      String? note});
}

/// @nodoc
class __$GroupCopyWithImpl<$Res> implements _$GroupCopyWith<$Res> {
  __$GroupCopyWithImpl(this._self, this._then);

  final _Group _self;
  final $Res Function(_Group) _then;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? members = null,
    Object? threshold = null,
    Object? protocol = null,
    Object? keyType = null,
    Object? note = freezed,
  }) {
    return _then(_Group(
      id: null == id
          ? _self._id
          : id // ignore: cast_nullable_to_non_nullable
              as List<int>,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      members: null == members
          ? _self._members
          : members // ignore: cast_nullable_to_non_nullable
              as List<Member>,
      threshold: null == threshold
          ? _self.threshold
          : threshold // ignore: cast_nullable_to_non_nullable
              as int,
      protocol: null == protocol
          ? _self.protocol
          : protocol // ignore: cast_nullable_to_non_nullable
              as Protocol,
      keyType: null == keyType
          ? _self.keyType
          : keyType // ignore: cast_nullable_to_non_nullable
              as KeyType,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
