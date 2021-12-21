///
//  Generated code. Do not modify.
//  source: mpc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class Task_TaskType extends $pb.ProtobufEnum {
  static const Task_TaskType GROUP = Task_TaskType._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'GROUP');
  static const Task_TaskType SIGN = Task_TaskType._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'SIGN');

  static const $core.List<Task_TaskType> values = <Task_TaskType>[
    GROUP,
    SIGN,
  ];

  static final $core.Map<$core.int, Task_TaskType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Task_TaskType? valueOf($core.int value) => _byValue[value];

  const Task_TaskType._($core.int v, $core.String n) : super(v, n);
}

class Task_TaskState extends $pb.ProtobufEnum {
  static const Task_TaskState WAITING = Task_TaskState._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'WAITING');
  static const Task_TaskState FINISHED = Task_TaskState._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'FINISHED');
  static const Task_TaskState FAILED = Task_TaskState._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'FAILED');

  static const $core.List<Task_TaskState> values = <Task_TaskState>[
    WAITING,
    FINISHED,
    FAILED,
  ];

  static final $core.Map<$core.int, Task_TaskState> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Task_TaskState? valueOf($core.int value) => _byValue[value];

  const Task_TaskState._($core.int v, $core.String n) : super(v, n);
}
