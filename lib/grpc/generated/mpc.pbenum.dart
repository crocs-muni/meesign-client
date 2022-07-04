///
//  Generated code. Do not modify.
//  source: mpc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class Protocol extends $pb.ProtobufEnum {
  static const Protocol GG18 = Protocol._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'GG18');

  static const $core.List<Protocol> values = <Protocol>[
    GG18,
  ];

  static final $core.Map<$core.int, Protocol> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Protocol? valueOf($core.int value) => _byValue[value];

  const Protocol._($core.int v, $core.String n) : super(v, n);
}

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
  static const Task_TaskState CREATED = Task_TaskState._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'CREATED');
  static const Task_TaskState RUNNING = Task_TaskState._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'RUNNING');
  static const Task_TaskState FINISHED = Task_TaskState._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'FINISHED');
  static const Task_TaskState FAILED = Task_TaskState._(
      3,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'FAILED');

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
