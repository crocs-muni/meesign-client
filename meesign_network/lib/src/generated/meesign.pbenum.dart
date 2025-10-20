// This is a generated file - do not edit.
//
// Generated from meesign.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ProtocolType extends $pb.ProtobufEnum {
  static const ProtocolType GG18 =
      ProtocolType._(0, _omitEnumNames ? '' : 'GG18');
  static const ProtocolType ELGAMAL =
      ProtocolType._(1, _omitEnumNames ? '' : 'ELGAMAL');
  static const ProtocolType FROST =
      ProtocolType._(2, _omitEnumNames ? '' : 'FROST');
  static const ProtocolType MUSIG2 =
      ProtocolType._(3, _omitEnumNames ? '' : 'MUSIG2');

  static const $core.List<ProtocolType> values = <ProtocolType>[
    GG18,
    ELGAMAL,
    FROST,
    MUSIG2,
  ];

  static final $core.List<ProtocolType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ProtocolType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ProtocolType._(super.value, super.name);
}

class KeyType extends $pb.ProtobufEnum {
  static const KeyType SignPDF = KeyType._(0, _omitEnumNames ? '' : 'SignPDF');
  static const KeyType SignChallenge =
      KeyType._(1, _omitEnumNames ? '' : 'SignChallenge');
  static const KeyType Decrypt = KeyType._(2, _omitEnumNames ? '' : 'Decrypt');

  static const $core.List<KeyType> values = <KeyType>[
    SignPDF,
    SignChallenge,
    Decrypt,
  ];

  static final $core.List<KeyType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static KeyType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const KeyType._(super.value, super.name);
}

class TaskType extends $pb.ProtobufEnum {
  static const TaskType GROUP = TaskType._(0, _omitEnumNames ? '' : 'GROUP');
  static const TaskType SIGN_PDF =
      TaskType._(1, _omitEnumNames ? '' : 'SIGN_PDF');
  static const TaskType SIGN_CHALLENGE =
      TaskType._(2, _omitEnumNames ? '' : 'SIGN_CHALLENGE');
  static const TaskType DECRYPT =
      TaskType._(3, _omitEnumNames ? '' : 'DECRYPT');

  static const $core.List<TaskType> values = <TaskType>[
    GROUP,
    SIGN_PDF,
    SIGN_CHALLENGE,
    DECRYPT,
  ];

  static final $core.List<TaskType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static TaskType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TaskType._(super.value, super.name);
}

class DeviceKind extends $pb.ProtobufEnum {
  static const DeviceKind USER = DeviceKind._(0, _omitEnumNames ? '' : 'USER');
  static const DeviceKind BOT = DeviceKind._(1, _omitEnumNames ? '' : 'BOT');

  static const $core.List<DeviceKind> values = <DeviceKind>[
    USER,
    BOT,
  ];

  static final $core.List<DeviceKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static DeviceKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DeviceKind._(super.value, super.name);
}

class Task_TaskState extends $pb.ProtobufEnum {
  static const Task_TaskState CREATED =
      Task_TaskState._(0, _omitEnumNames ? '' : 'CREATED');
  static const Task_TaskState RUNNING =
      Task_TaskState._(1, _omitEnumNames ? '' : 'RUNNING');
  static const Task_TaskState FINISHED =
      Task_TaskState._(2, _omitEnumNames ? '' : 'FINISHED');
  static const Task_TaskState FAILED =
      Task_TaskState._(3, _omitEnumNames ? '' : 'FAILED');

  static const $core.List<Task_TaskState> values = <Task_TaskState>[
    CREATED,
    RUNNING,
    FINISHED,
    FAILED,
  ];

  static final $core.List<Task_TaskState?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Task_TaskState? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Task_TaskState._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
