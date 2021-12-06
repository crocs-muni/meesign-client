///
//  Generated code. Do not modify.
//  source: mpc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'mpc.pbenum.dart';

export 'mpc.pbenum.dart';

class RegistrationRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'RegistrationRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id', $pb.PbFieldType.OY)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..hasRequiredFields = false
  ;

  RegistrationRequest._() : super();
  factory RegistrationRequest({
    $core.List<$core.int>? id,
    $core.String? name,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    return _result;
  }
  factory RegistrationRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RegistrationRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RegistrationRequest clone() => RegistrationRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RegistrationRequest copyWith(void Function(RegistrationRequest) updates) => super.copyWith((message) => updates(message as RegistrationRequest)) as RegistrationRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static RegistrationRequest create() => RegistrationRequest._();
  RegistrationRequest createEmptyInstance() => create();
  static $pb.PbList<RegistrationRequest> createRepeated() => $pb.PbList<RegistrationRequest>();
  @$core.pragma('dart2js:noInline')
  static RegistrationRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RegistrationRequest>(create);
  static RegistrationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get id => $_getN(0);
  @$pb.TagNumber(1)
  set id($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);
}

class GroupRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GroupRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..p<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'deviceIds', $pb.PbFieldType.PY)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'threshold', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  GroupRequest._() : super();
  factory GroupRequest({
    $core.Iterable<$core.List<$core.int>>? deviceIds,
    $core.String? name,
    $core.int? threshold,
  }) {
    final _result = create();
    if (deviceIds != null) {
      _result.deviceIds.addAll(deviceIds);
    }
    if (name != null) {
      _result.name = name;
    }
    if (threshold != null) {
      _result.threshold = threshold;
    }
    return _result;
  }
  factory GroupRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GroupRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GroupRequest clone() => GroupRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GroupRequest copyWith(void Function(GroupRequest) updates) => super.copyWith((message) => updates(message as GroupRequest)) as GroupRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GroupRequest create() => GroupRequest._();
  GroupRequest createEmptyInstance() => create();
  static $pb.PbList<GroupRequest> createRepeated() => $pb.PbList<GroupRequest>();
  @$core.pragma('dart2js:noInline')
  static GroupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupRequest>(create);
  static GroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.List<$core.int>> get deviceIds => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get threshold => $_getIZ(2);
  @$pb.TagNumber(3)
  set threshold($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasThreshold() => $_has(2);
  @$pb.TagNumber(3)
  void clearThreshold() => clearField(3);
}

class Group extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Group', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id', $pb.PbFieldType.OY)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'threshold', $pb.PbFieldType.OU3)
    ..p<$core.List<$core.int>>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'deviceIds', $pb.PbFieldType.PY)
    ..hasRequiredFields = false
  ;

  Group._() : super();
  factory Group({
    $core.List<$core.int>? id,
    $core.String? name,
    $core.int? threshold,
    $core.Iterable<$core.List<$core.int>>? deviceIds,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    if (threshold != null) {
      _result.threshold = threshold;
    }
    if (deviceIds != null) {
      _result.deviceIds.addAll(deviceIds);
    }
    return _result;
  }
  factory Group.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Group.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Group clone() => Group()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Group copyWith(void Function(Group) updates) => super.copyWith((message) => updates(message as Group)) as Group; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Group create() => Group._();
  Group createEmptyInstance() => create();
  static $pb.PbList<Group> createRepeated() => $pb.PbList<Group>();
  @$core.pragma('dart2js:noInline')
  static Group getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Group>(create);
  static Group? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get id => $_getN(0);
  @$pb.TagNumber(1)
  set id($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get threshold => $_getIZ(2);
  @$pb.TagNumber(3)
  set threshold($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasThreshold() => $_has(2);
  @$pb.TagNumber(3)
  void clearThreshold() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.List<$core.int>> get deviceIds => $_getList(3);
}

class DevicesRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'DevicesRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  DevicesRequest._() : super();
  factory DevicesRequest() => create();
  factory DevicesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DevicesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DevicesRequest clone() => DevicesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DevicesRequest copyWith(void Function(DevicesRequest) updates) => super.copyWith((message) => updates(message as DevicesRequest)) as DevicesRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DevicesRequest create() => DevicesRequest._();
  DevicesRequest createEmptyInstance() => create();
  static $pb.PbList<DevicesRequest> createRepeated() => $pb.PbList<DevicesRequest>();
  @$core.pragma('dart2js:noInline')
  static DevicesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DevicesRequest>(create);
  static DevicesRequest? _defaultInstance;
}

class Devices extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Devices', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..pc<Device>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'devices', $pb.PbFieldType.PM, subBuilder: Device.create)
    ..hasRequiredFields = false
  ;

  Devices._() : super();
  factory Devices({
    $core.Iterable<Device>? devices,
  }) {
    final _result = create();
    if (devices != null) {
      _result.devices.addAll(devices);
    }
    return _result;
  }
  factory Devices.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Devices.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Devices clone() => Devices()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Devices copyWith(void Function(Devices) updates) => super.copyWith((message) => updates(message as Devices)) as Devices; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Devices create() => Devices._();
  Devices createEmptyInstance() => create();
  static $pb.PbList<Devices> createRepeated() => $pb.PbList<Devices>();
  @$core.pragma('dart2js:noInline')
  static Devices getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Devices>(create);
  static Devices? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Device> get devices => $_getList(0);
}

class Device extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Device', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id', $pb.PbFieldType.OY)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..hasRequiredFields = false
  ;

  Device._() : super();
  factory Device({
    $core.List<$core.int>? id,
    $core.String? name,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    return _result;
  }
  factory Device.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Device.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Device clone() => Device()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Device copyWith(void Function(Device) updates) => super.copyWith((message) => updates(message as Device)) as Device; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Device create() => Device._();
  Device createEmptyInstance() => create();
  static $pb.PbList<Device> createRepeated() => $pb.PbList<Device>();
  @$core.pragma('dart2js:noInline')
  static Device getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Device>(create);
  static Device? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get id => $_getN(0);
  @$pb.TagNumber(1)
  set id($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);
}

class SignRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SignRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'groupId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  SignRequest._() : super();
  factory SignRequest({
    $core.List<$core.int>? groupId,
    $core.List<$core.int>? data,
  }) {
    final _result = create();
    if (groupId != null) {
      _result.groupId = groupId;
    }
    if (data != null) {
      _result.data = data;
    }
    return _result;
  }
  factory SignRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignRequest clone() => SignRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignRequest copyWith(void Function(SignRequest) updates) => super.copyWith((message) => updates(message as SignRequest)) as SignRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SignRequest create() => SignRequest._();
  SignRequest createEmptyInstance() => create();
  static $pb.PbList<SignRequest> createRepeated() => $pb.PbList<SignRequest>();
  @$core.pragma('dart2js:noInline')
  static SignRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignRequest>(create);
  static SignRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get groupId => $_getN(0);
  @$pb.TagNumber(1)
  set groupId($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
}

class TaskRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TaskRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'taskId', $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'deviceId', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  TaskRequest._() : super();
  factory TaskRequest({
    $core.int? taskId,
    $core.List<$core.int>? deviceId,
  }) {
    final _result = create();
    if (taskId != null) {
      _result.taskId = taskId;
    }
    if (deviceId != null) {
      _result.deviceId = deviceId;
    }
    return _result;
  }
  factory TaskRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TaskRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TaskRequest clone() => TaskRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TaskRequest copyWith(void Function(TaskRequest) updates) => super.copyWith((message) => updates(message as TaskRequest)) as TaskRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TaskRequest create() => TaskRequest._();
  TaskRequest createEmptyInstance() => create();
  static $pb.PbList<TaskRequest> createRepeated() => $pb.PbList<TaskRequest>();
  @$core.pragma('dart2js:noInline')
  static TaskRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskRequest>(create);
  static TaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get taskId => $_getIZ(0);
  @$pb.TagNumber(1)
  set taskId($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get deviceId => $_getN(1);
  @$pb.TagNumber(2)
  set deviceId($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => clearField(2);
}

class Task extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Task', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id', $pb.PbFieldType.OU3)
    ..e<Task_TaskType>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: Task_TaskType.GROUP, valueOf: Task_TaskType.valueOf, enumValues: Task_TaskType.values)
    ..e<Task_TaskState>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'state', $pb.PbFieldType.OE, defaultOrMaker: Task_TaskState.WAITING, valueOf: Task_TaskState.valueOf, enumValues: Task_TaskState.values)
    ..a<$core.int>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'progress', $pb.PbFieldType.O3)
    ..p<$core.List<$core.int>>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.PY)
    ..a<$core.List<$core.int>>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'work', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  Task._() : super();
  factory Task({
    $core.int? id,
    Task_TaskType? type,
    Task_TaskState? state,
    $core.int? progress,
    $core.Iterable<$core.List<$core.int>>? data,
    $core.List<$core.int>? work,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (type != null) {
      _result.type = type;
    }
    if (state != null) {
      _result.state = state;
    }
    if (progress != null) {
      _result.progress = progress;
    }
    if (data != null) {
      _result.data.addAll(data);
    }
    if (work != null) {
      _result.work = work;
    }
    return _result;
  }
  factory Task.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Task.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Task clone() => Task()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Task copyWith(void Function(Task) updates) => super.copyWith((message) => updates(message as Task)) as Task; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Task create() => Task._();
  Task createEmptyInstance() => create();
  static $pb.PbList<Task> createRepeated() => $pb.PbList<Task>();
  @$core.pragma('dart2js:noInline')
  static Task getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Task>(create);
  static Task? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  Task_TaskType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(Task_TaskType v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  Task_TaskState get state => $_getN(2);
  @$pb.TagNumber(3)
  set state(Task_TaskState v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasState() => $_has(2);
  @$pb.TagNumber(3)
  void clearState() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get progress => $_getIZ(3);
  @$pb.TagNumber(4)
  set progress($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasProgress() => $_has(3);
  @$pb.TagNumber(4)
  void clearProgress() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.List<$core.int>> get data => $_getList(4);

  @$pb.TagNumber(6)
  $core.List<$core.int> get work => $_getN(5);
  @$pb.TagNumber(6)
  set work($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasWork() => $_has(5);
  @$pb.TagNumber(6)
  void clearWork() => clearField(6);
}

class TaskUpdate extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TaskUpdate', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'device', $pb.PbFieldType.OY)
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'task', $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  TaskUpdate._() : super();
  factory TaskUpdate({
    $core.List<$core.int>? device,
    $core.int? task,
    $core.List<$core.int>? data,
  }) {
    final _result = create();
    if (device != null) {
      _result.device = device;
    }
    if (task != null) {
      _result.task = task;
    }
    if (data != null) {
      _result.data = data;
    }
    return _result;
  }
  factory TaskUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TaskUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TaskUpdate clone() => TaskUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TaskUpdate copyWith(void Function(TaskUpdate) updates) => super.copyWith((message) => updates(message as TaskUpdate)) as TaskUpdate; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TaskUpdate create() => TaskUpdate._();
  TaskUpdate createEmptyInstance() => create();
  static $pb.PbList<TaskUpdate> createRepeated() => $pb.PbList<TaskUpdate>();
  @$core.pragma('dart2js:noInline')
  static TaskUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskUpdate>(create);
  static TaskUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get device => $_getN(0);
  @$pb.TagNumber(1)
  set device($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get task => $_getIZ(1);
  @$pb.TagNumber(2)
  set task($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTask() => $_has(1);
  @$pb.TagNumber(2)
  void clearTask() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);
}

class InfoRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'InfoRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'deviceId', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  InfoRequest._() : super();
  factory InfoRequest({
    $core.List<$core.int>? deviceId,
  }) {
    final _result = create();
    if (deviceId != null) {
      _result.deviceId = deviceId;
    }
    return _result;
  }
  factory InfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InfoRequest clone() => InfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InfoRequest copyWith(void Function(InfoRequest) updates) => super.copyWith((message) => updates(message as InfoRequest)) as InfoRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static InfoRequest create() => InfoRequest._();
  InfoRequest createEmptyInstance() => create();
  static $pb.PbList<InfoRequest> createRepeated() => $pb.PbList<InfoRequest>();
  @$core.pragma('dart2js:noInline')
  static InfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InfoRequest>(create);
  static InfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get deviceId => $_getN(0);
  @$pb.TagNumber(1)
  set deviceId($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);
}

class Info extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Info', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..pc<Group>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'groups', $pb.PbFieldType.PM, subBuilder: Group.create)
    ..pc<Task>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'tasks', $pb.PbFieldType.PM, subBuilder: Task.create)
    ..hasRequiredFields = false
  ;

  Info._() : super();
  factory Info({
    $core.Iterable<Group>? groups,
    $core.Iterable<Task>? tasks,
  }) {
    final _result = create();
    if (groups != null) {
      _result.groups.addAll(groups);
    }
    if (tasks != null) {
      _result.tasks.addAll(tasks);
    }
    return _result;
  }
  factory Info.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Info.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Info clone() => Info()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Info copyWith(void Function(Info) updates) => super.copyWith((message) => updates(message as Info)) as Info; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Info create() => Info._();
  Info createEmptyInstance() => create();
  static $pb.PbList<Info> createRepeated() => $pb.PbList<Info>();
  @$core.pragma('dart2js:noInline')
  static Info getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Info>(create);
  static Info? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Group> get groups => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<Task> get tasks => $_getList(1);
}

enum Resp_Variant {
  success, 
  failure, 
  notSet
}

class Resp extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, Resp_Variant> _Resp_VariantByTag = {
    1 : Resp_Variant.success,
    2 : Resp_Variant.failure,
    0 : Resp_Variant.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Resp', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'mpcoord'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'failure')
    ..hasRequiredFields = false
  ;

  Resp._() : super();
  factory Resp({
    $core.String? success,
    $core.String? failure,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (failure != null) {
      _result.failure = failure;
    }
    return _result;
  }
  factory Resp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Resp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Resp clone() => Resp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Resp copyWith(void Function(Resp) updates) => super.copyWith((message) => updates(message as Resp)) as Resp; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Resp create() => Resp._();
  Resp createEmptyInstance() => create();
  static $pb.PbList<Resp> createRepeated() => $pb.PbList<Resp>();
  @$core.pragma('dart2js:noInline')
  static Resp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Resp>(create);
  static Resp? _defaultInstance;

  Resp_Variant whichVariant() => _Resp_VariantByTag[$_whichOneof(0)]!;
  void clearVariant() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get success => $_getSZ(0);
  @$pb.TagNumber(1)
  set success($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get failure => $_getSZ(1);
  @$pb.TagNumber(2)
  set failure($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFailure() => $_has(1);
  @$pb.TagNumber(2)
  void clearFailure() => clearField(2);
}

