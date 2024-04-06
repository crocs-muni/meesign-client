//
//  Generated code. Do not modify.
//  source: meesign.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'meesign.pbenum.dart';

export 'meesign.pbenum.dart';

class ServerInfoRequest extends $pb.GeneratedMessage {
  factory ServerInfoRequest() => create();
  ServerInfoRequest._() : super();
  factory ServerInfoRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ServerInfoRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ServerInfoRequest clone() => ServerInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ServerInfoRequest copyWith(void Function(ServerInfoRequest) updates) =>
      super.copyWith((message) => updates(message as ServerInfoRequest))
          as ServerInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerInfoRequest create() => ServerInfoRequest._();
  ServerInfoRequest createEmptyInstance() => create();
  static $pb.PbList<ServerInfoRequest> createRepeated() =>
      $pb.PbList<ServerInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static ServerInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServerInfoRequest>(create);
  static ServerInfoRequest? _defaultInstance;
}

class ServerInfo extends $pb.GeneratedMessage {
  factory ServerInfo({
    $core.String? version,
  }) {
    final $result = create();
    if (version != null) {
      $result.version = version;
    }
    return $result;
  }
  ServerInfo._() : super();
  factory ServerInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ServerInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ServerInfo clone() => ServerInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ServerInfo copyWith(void Function(ServerInfo) updates) =>
      super.copyWith((message) => updates(message as ServerInfo)) as ServerInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerInfo create() => ServerInfo._();
  ServerInfo createEmptyInstance() => create();
  static $pb.PbList<ServerInfo> createRepeated() => $pb.PbList<ServerInfo>();
  @$core.pragma('dart2js:noInline')
  static ServerInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServerInfo>(create);
  static ServerInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => clearField(1);
}

class RegistrationRequest extends $pb.GeneratedMessage {
  factory RegistrationRequest({
    $core.String? name,
    DeviceKind? kind,
    $core.List<$core.int>? csr,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (kind != null) {
      $result.kind = kind;
    }
    if (csr != null) {
      $result.csr = csr;
    }
    return $result;
  }
  RegistrationRequest._() : super();
  factory RegistrationRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RegistrationRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegistrationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..e<DeviceKind>(2, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE,
        defaultOrMaker: DeviceKind.USER,
        valueOf: DeviceKind.valueOf,
        enumValues: DeviceKind.values)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'csr', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  RegistrationRequest clone() => RegistrationRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  RegistrationRequest copyWith(void Function(RegistrationRequest) updates) =>
      super.copyWith((message) => updates(message as RegistrationRequest))
          as RegistrationRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegistrationRequest create() => RegistrationRequest._();
  RegistrationRequest createEmptyInstance() => create();
  static $pb.PbList<RegistrationRequest> createRepeated() =>
      $pb.PbList<RegistrationRequest>();
  @$core.pragma('dart2js:noInline')
  static RegistrationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegistrationRequest>(create);
  static RegistrationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  DeviceKind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(DeviceKind v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get csr => $_getN(2);
  @$pb.TagNumber(3)
  set csr($core.List<$core.int> v) {
    $_setBytes(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasCsr() => $_has(2);
  @$pb.TagNumber(3)
  void clearCsr() => clearField(3);
}

class RegistrationResponse extends $pb.GeneratedMessage {
  factory RegistrationResponse({
    $core.List<$core.int>? deviceId,
    $core.List<$core.int>? certificate,
  }) {
    final $result = create();
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    if (certificate != null) {
      $result.certificate = certificate;
    }
    return $result;
  }
  RegistrationResponse._() : super();
  factory RegistrationResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory RegistrationResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegistrationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'deviceId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'certificate', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  RegistrationResponse clone() =>
      RegistrationResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  RegistrationResponse copyWith(void Function(RegistrationResponse) updates) =>
      super.copyWith((message) => updates(message as RegistrationResponse))
          as RegistrationResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegistrationResponse create() => RegistrationResponse._();
  RegistrationResponse createEmptyInstance() => create();
  static $pb.PbList<RegistrationResponse> createRepeated() =>
      $pb.PbList<RegistrationResponse>();
  @$core.pragma('dart2js:noInline')
  static RegistrationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegistrationResponse>(create);
  static RegistrationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get deviceId => $_getN(0);
  @$pb.TagNumber(1)
  set deviceId($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get certificate => $_getN(1);
  @$pb.TagNumber(2)
  set certificate($core.List<$core.int> v) {
    $_setBytes(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCertificate() => $_has(1);
  @$pb.TagNumber(2)
  void clearCertificate() => clearField(2);
}

class GroupRequest extends $pb.GeneratedMessage {
  factory GroupRequest({
    $core.String? name,
    $core.Iterable<$core.List<$core.int>>? deviceIds,
    $core.int? threshold,
    ProtocolType? protocol,
    KeyType? keyType,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (deviceIds != null) {
      $result.deviceIds.addAll(deviceIds);
    }
    if (threshold != null) {
      $result.threshold = threshold;
    }
    if (protocol != null) {
      $result.protocol = protocol;
    }
    if (keyType != null) {
      $result.keyType = keyType;
    }
    return $result;
  }
  GroupRequest._() : super();
  factory GroupRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GroupRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..p<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'deviceIds', $pb.PbFieldType.PY)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'threshold', $pb.PbFieldType.OU3)
    ..e<ProtocolType>(4, _omitFieldNames ? '' : 'protocol', $pb.PbFieldType.OE,
        defaultOrMaker: ProtocolType.GG18,
        valueOf: ProtocolType.valueOf,
        enumValues: ProtocolType.values)
    ..e<KeyType>(5, _omitFieldNames ? '' : 'keyType', $pb.PbFieldType.OE,
        defaultOrMaker: KeyType.SignPDF,
        valueOf: KeyType.valueOf,
        enumValues: KeyType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GroupRequest clone() => GroupRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GroupRequest copyWith(void Function(GroupRequest) updates) =>
      super.copyWith((message) => updates(message as GroupRequest))
          as GroupRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupRequest create() => GroupRequest._();
  GroupRequest createEmptyInstance() => create();
  static $pb.PbList<GroupRequest> createRepeated() =>
      $pb.PbList<GroupRequest>();
  @$core.pragma('dart2js:noInline')
  static GroupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupRequest>(create);
  static GroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get deviceIds => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get threshold => $_getIZ(2);
  @$pb.TagNumber(3)
  set threshold($core.int v) {
    $_setUnsignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasThreshold() => $_has(2);
  @$pb.TagNumber(3)
  void clearThreshold() => clearField(3);

  @$pb.TagNumber(4)
  ProtocolType get protocol => $_getN(3);
  @$pb.TagNumber(4)
  set protocol(ProtocolType v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasProtocol() => $_has(3);
  @$pb.TagNumber(4)
  void clearProtocol() => clearField(4);

  @$pb.TagNumber(5)
  KeyType get keyType => $_getN(4);
  @$pb.TagNumber(5)
  set keyType(KeyType v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasKeyType() => $_has(4);
  @$pb.TagNumber(5)
  void clearKeyType() => clearField(5);
}

class Group extends $pb.GeneratedMessage {
  factory Group({
    $core.List<$core.int>? identifier,
    $core.String? name,
    $core.int? threshold,
    ProtocolType? protocol,
    KeyType? keyType,
    $core.Iterable<$core.List<$core.int>>? deviceIds,
  }) {
    final $result = create();
    if (identifier != null) {
      $result.identifier = identifier;
    }
    if (name != null) {
      $result.name = name;
    }
    if (threshold != null) {
      $result.threshold = threshold;
    }
    if (protocol != null) {
      $result.protocol = protocol;
    }
    if (keyType != null) {
      $result.keyType = keyType;
    }
    if (deviceIds != null) {
      $result.deviceIds.addAll(deviceIds);
    }
    return $result;
  }
  Group._() : super();
  factory Group.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Group.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Group',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'identifier', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'threshold', $pb.PbFieldType.OU3)
    ..e<ProtocolType>(4, _omitFieldNames ? '' : 'protocol', $pb.PbFieldType.OE,
        defaultOrMaker: ProtocolType.GG18,
        valueOf: ProtocolType.valueOf,
        enumValues: ProtocolType.values)
    ..e<KeyType>(5, _omitFieldNames ? '' : 'keyType', $pb.PbFieldType.OE,
        defaultOrMaker: KeyType.SignPDF,
        valueOf: KeyType.valueOf,
        enumValues: KeyType.values)
    ..p<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'deviceIds', $pb.PbFieldType.PY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Group clone() => Group()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Group copyWith(void Function(Group) updates) =>
      super.copyWith((message) => updates(message as Group)) as Group;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Group create() => Group._();
  Group createEmptyInstance() => create();
  static $pb.PbList<Group> createRepeated() => $pb.PbList<Group>();
  @$core.pragma('dart2js:noInline')
  static Group getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Group>(create);
  static Group? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get identifier => $_getN(0);
  @$pb.TagNumber(1)
  set identifier($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasIdentifier() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentifier() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get threshold => $_getIZ(2);
  @$pb.TagNumber(3)
  set threshold($core.int v) {
    $_setUnsignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasThreshold() => $_has(2);
  @$pb.TagNumber(3)
  void clearThreshold() => clearField(3);

  @$pb.TagNumber(4)
  ProtocolType get protocol => $_getN(3);
  @$pb.TagNumber(4)
  set protocol(ProtocolType v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasProtocol() => $_has(3);
  @$pb.TagNumber(4)
  void clearProtocol() => clearField(4);

  @$pb.TagNumber(5)
  KeyType get keyType => $_getN(4);
  @$pb.TagNumber(5)
  set keyType(KeyType v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasKeyType() => $_has(4);
  @$pb.TagNumber(5)
  void clearKeyType() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.List<$core.int>> get deviceIds => $_getList(5);
}

class DevicesRequest extends $pb.GeneratedMessage {
  factory DevicesRequest() => create();
  DevicesRequest._() : super();
  factory DevicesRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DevicesRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DevicesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DevicesRequest clone() => DevicesRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DevicesRequest copyWith(void Function(DevicesRequest) updates) =>
      super.copyWith((message) => updates(message as DevicesRequest))
          as DevicesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DevicesRequest create() => DevicesRequest._();
  DevicesRequest createEmptyInstance() => create();
  static $pb.PbList<DevicesRequest> createRepeated() =>
      $pb.PbList<DevicesRequest>();
  @$core.pragma('dart2js:noInline')
  static DevicesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DevicesRequest>(create);
  static DevicesRequest? _defaultInstance;
}

class Devices extends $pb.GeneratedMessage {
  factory Devices({
    $core.Iterable<Device>? devices,
  }) {
    final $result = create();
    if (devices != null) {
      $result.devices.addAll(devices);
    }
    return $result;
  }
  Devices._() : super();
  factory Devices.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Devices.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Devices',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..pc<Device>(1, _omitFieldNames ? '' : 'devices', $pb.PbFieldType.PM,
        subBuilder: Device.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Devices clone() => Devices()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Devices copyWith(void Function(Devices) updates) =>
      super.copyWith((message) => updates(message as Devices)) as Devices;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Devices create() => Devices._();
  Devices createEmptyInstance() => create();
  static $pb.PbList<Devices> createRepeated() => $pb.PbList<Devices>();
  @$core.pragma('dart2js:noInline')
  static Devices getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Devices>(create);
  static Devices? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Device> get devices => $_getList(0);
}

class Device extends $pb.GeneratedMessage {
  factory Device({
    $core.List<$core.int>? identifier,
    $core.String? name,
    DeviceKind? kind,
    $core.List<$core.int>? certificate,
    $fixnum.Int64? lastActive,
  }) {
    final $result = create();
    if (identifier != null) {
      $result.identifier = identifier;
    }
    if (name != null) {
      $result.name = name;
    }
    if (kind != null) {
      $result.kind = kind;
    }
    if (certificate != null) {
      $result.certificate = certificate;
    }
    if (lastActive != null) {
      $result.lastActive = lastActive;
    }
    return $result;
  }
  Device._() : super();
  factory Device.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Device.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Device',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'identifier', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..e<DeviceKind>(3, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE,
        defaultOrMaker: DeviceKind.USER,
        valueOf: DeviceKind.valueOf,
        enumValues: DeviceKind.values)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'certificate', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'lastActive', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Device clone() => Device()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Device copyWith(void Function(Device) updates) =>
      super.copyWith((message) => updates(message as Device)) as Device;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Device create() => Device._();
  Device createEmptyInstance() => create();
  static $pb.PbList<Device> createRepeated() => $pb.PbList<Device>();
  @$core.pragma('dart2js:noInline')
  static Device getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Device>(create);
  static Device? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get identifier => $_getN(0);
  @$pb.TagNumber(1)
  set identifier($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasIdentifier() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentifier() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  DeviceKind get kind => $_getN(2);
  @$pb.TagNumber(3)
  set kind(DeviceKind v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get certificate => $_getN(3);
  @$pb.TagNumber(4)
  set certificate($core.List<$core.int> v) {
    $_setBytes(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasCertificate() => $_has(3);
  @$pb.TagNumber(4)
  void clearCertificate() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get lastActive => $_getI64(4);
  @$pb.TagNumber(5)
  set lastActive($fixnum.Int64 v) {
    $_setInt64(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasLastActive() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastActive() => clearField(5);
}

class SignRequest extends $pb.GeneratedMessage {
  factory SignRequest({
    $core.String? name,
    $core.List<$core.int>? groupId,
    $core.List<$core.int>? data,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  SignRequest._() : super();
  factory SignRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SignRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SignRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'groupId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SignRequest clone() => SignRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SignRequest copyWith(void Function(SignRequest) updates) =>
      super.copyWith((message) => updates(message as SignRequest))
          as SignRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignRequest create() => SignRequest._();
  SignRequest createEmptyInstance() => create();
  static $pb.PbList<SignRequest> createRepeated() => $pb.PbList<SignRequest>();
  @$core.pragma('dart2js:noInline')
  static SignRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignRequest>(create);
  static SignRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get groupId => $_getN(1);
  @$pb.TagNumber(2)
  set groupId($core.List<$core.int> v) {
    $_setBytes(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> v) {
    $_setBytes(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);
}

class DecryptRequest extends $pb.GeneratedMessage {
  factory DecryptRequest({
    $core.String? name,
    $core.List<$core.int>? groupId,
    $core.List<$core.int>? data,
    $core.String? dataType,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (groupId != null) {
      $result.groupId = groupId;
    }
    if (data != null) {
      $result.data = data;
    }
    if (dataType != null) {
      $result.dataType = dataType;
    }
    return $result;
  }
  DecryptRequest._() : super();
  factory DecryptRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DecryptRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DecryptRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'groupId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOS(4, _omitFieldNames ? '' : 'dataType')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DecryptRequest clone() => DecryptRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DecryptRequest copyWith(void Function(DecryptRequest) updates) =>
      super.copyWith((message) => updates(message as DecryptRequest))
          as DecryptRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecryptRequest create() => DecryptRequest._();
  DecryptRequest createEmptyInstance() => create();
  static $pb.PbList<DecryptRequest> createRepeated() =>
      $pb.PbList<DecryptRequest>();
  @$core.pragma('dart2js:noInline')
  static DecryptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecryptRequest>(create);
  static DecryptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get groupId => $_getN(1);
  @$pb.TagNumber(2)
  set groupId($core.List<$core.int> v) {
    $_setBytes(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> v) {
    $_setBytes(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get dataType => $_getSZ(3);
  @$pb.TagNumber(4)
  set dataType($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasDataType() => $_has(3);
  @$pb.TagNumber(4)
  void clearDataType() => clearField(4);
}

class TaskRequest extends $pb.GeneratedMessage {
  factory TaskRequest({
    $core.List<$core.int>? taskId,
    $core.List<$core.int>? deviceId,
  }) {
    final $result = create();
    if (taskId != null) {
      $result.taskId = taskId;
    }
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    return $result;
  }
  TaskRequest._() : super();
  factory TaskRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TaskRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'taskId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'deviceId', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TaskRequest clone() => TaskRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TaskRequest copyWith(void Function(TaskRequest) updates) =>
      super.copyWith((message) => updates(message as TaskRequest))
          as TaskRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TaskRequest create() => TaskRequest._();
  TaskRequest createEmptyInstance() => create();
  static $pb.PbList<TaskRequest> createRepeated() => $pb.PbList<TaskRequest>();
  @$core.pragma('dart2js:noInline')
  static TaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskRequest>(create);
  static TaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get taskId => $_getN(0);
  @$pb.TagNumber(1)
  set taskId($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get deviceId => $_getN(1);
  @$pb.TagNumber(2)
  set deviceId($core.List<$core.int> v) {
    $_setBytes(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => clearField(2);
}

class Task extends $pb.GeneratedMessage {
  factory Task({
    $core.List<$core.int>? id,
    TaskType? type,
    Task_TaskState? state,
    $core.int? round,
    $core.int? attempt,
    $core.int? accept,
    $core.int? reject,
    $core.Iterable<$core.List<$core.int>>? data,
    $core.List<$core.int>? request,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (type != null) {
      $result.type = type;
    }
    if (state != null) {
      $result.state = state;
    }
    if (round != null) {
      $result.round = round;
    }
    if (attempt != null) {
      $result.attempt = attempt;
    }
    if (accept != null) {
      $result.accept = accept;
    }
    if (reject != null) {
      $result.reject = reject;
    }
    if (data != null) {
      $result.data.addAll(data);
    }
    if (request != null) {
      $result.request = request;
    }
    return $result;
  }
  Task._() : super();
  factory Task.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Task.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Task',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OY)
    ..e<TaskType>(2, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: TaskType.GROUP,
        valueOf: TaskType.valueOf,
        enumValues: TaskType.values)
    ..e<Task_TaskState>(3, _omitFieldNames ? '' : 'state', $pb.PbFieldType.OE,
        defaultOrMaker: Task_TaskState.CREATED,
        valueOf: Task_TaskState.valueOf,
        enumValues: Task_TaskState.values)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'round', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'attempt', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'accept', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'reject', $pb.PbFieldType.OU3)
    ..p<$core.List<$core.int>>(
        8, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PY)
    ..a<$core.List<$core.int>>(
        9, _omitFieldNames ? '' : 'request', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Task clone() => Task()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Task copyWith(void Function(Task) updates) =>
      super.copyWith((message) => updates(message as Task)) as Task;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Task create() => Task._();
  Task createEmptyInstance() => create();
  static $pb.PbList<Task> createRepeated() => $pb.PbList<Task>();
  @$core.pragma('dart2js:noInline')
  static Task getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Task>(create);
  static Task? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get id => $_getN(0);
  @$pb.TagNumber(1)
  set id($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  TaskType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(TaskType v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  Task_TaskState get state => $_getN(2);
  @$pb.TagNumber(3)
  set state(Task_TaskState v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasState() => $_has(2);
  @$pb.TagNumber(3)
  void clearState() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get round => $_getIZ(3);
  @$pb.TagNumber(4)
  set round($core.int v) {
    $_setUnsignedInt32(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasRound() => $_has(3);
  @$pb.TagNumber(4)
  void clearRound() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get attempt => $_getIZ(4);
  @$pb.TagNumber(5)
  set attempt($core.int v) {
    $_setUnsignedInt32(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasAttempt() => $_has(4);
  @$pb.TagNumber(5)
  void clearAttempt() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get accept => $_getIZ(5);
  @$pb.TagNumber(6)
  set accept($core.int v) {
    $_setUnsignedInt32(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasAccept() => $_has(5);
  @$pb.TagNumber(6)
  void clearAccept() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get reject => $_getIZ(6);
  @$pb.TagNumber(7)
  set reject($core.int v) {
    $_setUnsignedInt32(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasReject() => $_has(6);
  @$pb.TagNumber(7)
  void clearReject() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.List<$core.int>> get data => $_getList(7);

  @$pb.TagNumber(9)
  $core.List<$core.int> get request => $_getN(8);
  @$pb.TagNumber(9)
  set request($core.List<$core.int> v) {
    $_setBytes(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasRequest() => $_has(8);
  @$pb.TagNumber(9)
  void clearRequest() => clearField(9);
}

class TaskUpdate extends $pb.GeneratedMessage {
  factory TaskUpdate({
    $core.List<$core.int>? task,
    $core.Iterable<$core.List<$core.int>>? data,
    $core.int? attempt,
  }) {
    final $result = create();
    if (task != null) {
      $result.task = task;
    }
    if (data != null) {
      $result.data.addAll(data);
    }
    if (attempt != null) {
      $result.attempt = attempt;
    }
    return $result;
  }
  TaskUpdate._() : super();
  factory TaskUpdate.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TaskUpdate.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'task', $pb.PbFieldType.OY)
    ..p<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.PY)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'attempt', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TaskUpdate clone() => TaskUpdate()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TaskUpdate copyWith(void Function(TaskUpdate) updates) =>
      super.copyWith((message) => updates(message as TaskUpdate)) as TaskUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TaskUpdate create() => TaskUpdate._();
  TaskUpdate createEmptyInstance() => create();
  static $pb.PbList<TaskUpdate> createRepeated() => $pb.PbList<TaskUpdate>();
  @$core.pragma('dart2js:noInline')
  static TaskUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskUpdate>(create);
  static TaskUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get task => $_getN(0);
  @$pb.TagNumber(1)
  set task($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get data => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get attempt => $_getIZ(2);
  @$pb.TagNumber(3)
  set attempt($core.int v) {
    $_setUnsignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasAttempt() => $_has(2);
  @$pb.TagNumber(3)
  void clearAttempt() => clearField(3);
}

class TasksRequest extends $pb.GeneratedMessage {
  factory TasksRequest({
    $core.List<$core.int>? deviceId,
  }) {
    final $result = create();
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    return $result;
  }
  TasksRequest._() : super();
  factory TasksRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TasksRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TasksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'deviceId', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TasksRequest clone() => TasksRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TasksRequest copyWith(void Function(TasksRequest) updates) =>
      super.copyWith((message) => updates(message as TasksRequest))
          as TasksRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TasksRequest create() => TasksRequest._();
  TasksRequest createEmptyInstance() => create();
  static $pb.PbList<TasksRequest> createRepeated() =>
      $pb.PbList<TasksRequest>();
  @$core.pragma('dart2js:noInline')
  static TasksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TasksRequest>(create);
  static TasksRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get deviceId => $_getN(0);
  @$pb.TagNumber(1)
  set deviceId($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);
}

class Tasks extends $pb.GeneratedMessage {
  factory Tasks({
    $core.Iterable<Task>? tasks,
  }) {
    final $result = create();
    if (tasks != null) {
      $result.tasks.addAll(tasks);
    }
    return $result;
  }
  Tasks._() : super();
  factory Tasks.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Tasks.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tasks',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..pc<Task>(1, _omitFieldNames ? '' : 'tasks', $pb.PbFieldType.PM,
        subBuilder: Task.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Tasks clone() => Tasks()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Tasks copyWith(void Function(Tasks) updates) =>
      super.copyWith((message) => updates(message as Tasks)) as Tasks;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tasks create() => Tasks._();
  Tasks createEmptyInstance() => create();
  static $pb.PbList<Tasks> createRepeated() => $pb.PbList<Tasks>();
  @$core.pragma('dart2js:noInline')
  static Tasks getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tasks>(create);
  static Tasks? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Task> get tasks => $_getList(0);
}

class GroupsRequest extends $pb.GeneratedMessage {
  factory GroupsRequest({
    $core.List<$core.int>? deviceId,
  }) {
    final $result = create();
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    return $result;
  }
  GroupsRequest._() : super();
  factory GroupsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GroupsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'deviceId', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GroupsRequest clone() => GroupsRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GroupsRequest copyWith(void Function(GroupsRequest) updates) =>
      super.copyWith((message) => updates(message as GroupsRequest))
          as GroupsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupsRequest create() => GroupsRequest._();
  GroupsRequest createEmptyInstance() => create();
  static $pb.PbList<GroupsRequest> createRepeated() =>
      $pb.PbList<GroupsRequest>();
  @$core.pragma('dart2js:noInline')
  static GroupsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupsRequest>(create);
  static GroupsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get deviceId => $_getN(0);
  @$pb.TagNumber(1)
  set deviceId($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);
}

class Groups extends $pb.GeneratedMessage {
  factory Groups({
    $core.Iterable<Group>? groups,
  }) {
    final $result = create();
    if (groups != null) {
      $result.groups.addAll(groups);
    }
    return $result;
  }
  Groups._() : super();
  factory Groups.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Groups.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Groups',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..pc<Group>(1, _omitFieldNames ? '' : 'groups', $pb.PbFieldType.PM,
        subBuilder: Group.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Groups clone() => Groups()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Groups copyWith(void Function(Groups) updates) =>
      super.copyWith((message) => updates(message as Groups)) as Groups;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Groups create() => Groups._();
  Groups createEmptyInstance() => create();
  static $pb.PbList<Groups> createRepeated() => $pb.PbList<Groups>();
  @$core.pragma('dart2js:noInline')
  static Groups getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Groups>(create);
  static Groups? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Group> get groups => $_getList(0);
}

class Resp extends $pb.GeneratedMessage {
  factory Resp({
    $core.String? message,
  }) {
    final $result = create();
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  Resp._() : super();
  factory Resp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Resp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Resp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Resp clone() => Resp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Resp copyWith(void Function(Resp) updates) =>
      super.copyWith((message) => updates(message as Resp)) as Resp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Resp create() => Resp._();
  Resp createEmptyInstance() => create();
  static $pb.PbList<Resp> createRepeated() => $pb.PbList<Resp>();
  @$core.pragma('dart2js:noInline')
  static Resp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Resp>(create);
  static Resp? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);
}

class TaskDecision extends $pb.GeneratedMessage {
  factory TaskDecision({
    $core.List<$core.int>? task,
    $core.bool? accept,
  }) {
    final $result = create();
    if (task != null) {
      $result.task = task;
    }
    if (accept != null) {
      $result.accept = accept;
    }
    return $result;
  }
  TaskDecision._() : super();
  factory TaskDecision.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TaskDecision.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskDecision',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'task', $pb.PbFieldType.OY)
    ..aOB(2, _omitFieldNames ? '' : 'accept')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TaskDecision clone() => TaskDecision()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TaskDecision copyWith(void Function(TaskDecision) updates) =>
      super.copyWith((message) => updates(message as TaskDecision))
          as TaskDecision;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TaskDecision create() => TaskDecision._();
  TaskDecision createEmptyInstance() => create();
  static $pb.PbList<TaskDecision> createRepeated() =>
      $pb.PbList<TaskDecision>();
  @$core.pragma('dart2js:noInline')
  static TaskDecision getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskDecision>(create);
  static TaskDecision? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get task => $_getN(0);
  @$pb.TagNumber(1)
  set task($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get accept => $_getBF(1);
  @$pb.TagNumber(2)
  set accept($core.bool v) {
    $_setBool(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasAccept() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccept() => clearField(2);
}

class TaskAcknowledgement extends $pb.GeneratedMessage {
  factory TaskAcknowledgement({
    $core.List<$core.int>? taskId,
  }) {
    final $result = create();
    if (taskId != null) {
      $result.taskId = taskId;
    }
    return $result;
  }
  TaskAcknowledgement._() : super();
  factory TaskAcknowledgement.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TaskAcknowledgement.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskAcknowledgement',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'taskId', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TaskAcknowledgement clone() => TaskAcknowledgement()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TaskAcknowledgement copyWith(void Function(TaskAcknowledgement) updates) =>
      super.copyWith((message) => updates(message as TaskAcknowledgement))
          as TaskAcknowledgement;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TaskAcknowledgement create() => TaskAcknowledgement._();
  TaskAcknowledgement createEmptyInstance() => create();
  static $pb.PbList<TaskAcknowledgement> createRepeated() =>
      $pb.PbList<TaskAcknowledgement>();
  @$core.pragma('dart2js:noInline')
  static TaskAcknowledgement getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskAcknowledgement>(create);
  static TaskAcknowledgement? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get taskId => $_getN(0);
  @$pb.TagNumber(1)
  set taskId($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => clearField(1);
}

class LogRequest extends $pb.GeneratedMessage {
  factory LogRequest({
    $core.String? message,
  }) {
    final $result = create();
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  LogRequest._() : super();
  factory LogRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory LogRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  LogRequest clone() => LogRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  LogRequest copyWith(void Function(LogRequest) updates) =>
      super.copyWith((message) => updates(message as LogRequest)) as LogRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogRequest create() => LogRequest._();
  LogRequest createEmptyInstance() => create();
  static $pb.PbList<LogRequest> createRepeated() => $pb.PbList<LogRequest>();
  @$core.pragma('dart2js:noInline')
  static LogRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogRequest>(create);
  static LogRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);
}

class SubscribeRequest extends $pb.GeneratedMessage {
  factory SubscribeRequest() => create();
  SubscribeRequest._() : super();
  factory SubscribeRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SubscribeRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'meesign'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SubscribeRequest clone() => SubscribeRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SubscribeRequest copyWith(void Function(SubscribeRequest) updates) =>
      super.copyWith((message) => updates(message as SubscribeRequest))
          as SubscribeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeRequest create() => SubscribeRequest._();
  SubscribeRequest createEmptyInstance() => create();
  static $pb.PbList<SubscribeRequest> createRepeated() =>
      $pb.PbList<SubscribeRequest>();
  @$core.pragma('dart2js:noInline')
  static SubscribeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeRequest>(create);
  static SubscribeRequest? _defaultInstance;
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
