//
//  Generated code. Do not modify.
//  source: mpc.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ProtocolType extends $pb.ProtobufEnum {
  static const ProtocolType GG18 =
      ProtocolType._(0, _omitEnumNames ? '' : 'GG18');
  static const ProtocolType ELGAMAL =
      ProtocolType._(1, _omitEnumNames ? '' : 'ELGAMAL');
  static const ProtocolType FROST =
      ProtocolType._(2, _omitEnumNames ? '' : 'FROST');

  static const $core.List<ProtocolType> values = <ProtocolType>[
    GG18,
    ELGAMAL,
    FROST,
  ];

  static final $core.Map<$core.int, ProtocolType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static ProtocolType? valueOf($core.int value) => _byValue[value];

  const ProtocolType._($core.int v, $core.String n) : super(v, n);
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

  static final $core.Map<$core.int, KeyType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static KeyType? valueOf($core.int value) => _byValue[value];

  const KeyType._($core.int v, $core.String n) : super(v, n);
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

  static final $core.Map<$core.int, TaskType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static TaskType? valueOf($core.int value) => _byValue[value];

  const TaskType._($core.int v, $core.String n) : super(v, n);
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

  static final $core.Map<$core.int, Task_TaskState> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Task_TaskState? valueOf($core.int value) => _byValue[value];

  const Task_TaskState._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
