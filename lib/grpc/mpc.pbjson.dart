///
//  Generated code. Do not modify.
//  source: mpc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use registrationRequestDescriptor instead')
const RegistrationRequest$json = const {
  '1': 'RegistrationRequest',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 12, '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `RegistrationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registrationRequestDescriptor = $convert.base64Decode(
    'ChNSZWdpc3RyYXRpb25SZXF1ZXN0Eg4KAmlkGAEgASgMUgJpZBISCgRuYW1lGAIgASgJUgRuYW1l');
@$core.Deprecated('Use groupRequestDescriptor instead')
const GroupRequest$json = const {
  '1': 'GroupRequest',
  '2': const [
    const {'1': 'device_ids', '3': 1, '4': 3, '5': 12, '10': 'deviceIds'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {
      '1': 'threshold',
      '3': 3,
      '4': 1,
      '5': 13,
      '9': 0,
      '10': 'threshold',
      '17': true
    },
  ],
  '8': const [
    const {'1': '_threshold'},
  ],
};

/// Descriptor for `GroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupRequestDescriptor = $convert.base64Decode(
    'CgxHcm91cFJlcXVlc3QSHQoKZGV2aWNlX2lkcxgBIAMoDFIJZGV2aWNlSWRzEhIKBG5hbWUYAiABKAlSBG5hbWUSIQoJdGhyZXNob2xkGAMgASgNSABSCXRocmVzaG9sZIgBAUIMCgpfdGhyZXNob2xk');
@$core.Deprecated('Use groupDescriptor instead')
const Group$json = const {
  '1': 'Group',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 12, '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'threshold', '3': 3, '4': 1, '5': 13, '10': 'threshold'},
    const {'1': 'device_ids', '3': 4, '4': 3, '5': 12, '10': 'deviceIds'},
  ],
};

/// Descriptor for `Group`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupDescriptor = $convert.base64Decode(
    'CgVHcm91cBIOCgJpZBgBIAEoDFICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIcCgl0aHJlc2hvbGQYAyABKA1SCXRocmVzaG9sZBIdCgpkZXZpY2VfaWRzGAQgAygMUglkZXZpY2VJZHM=');
@$core.Deprecated('Use devicesRequestDescriptor instead')
const DevicesRequest$json = const {
  '1': 'DevicesRequest',
};

/// Descriptor for `DevicesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List devicesRequestDescriptor =
    $convert.base64Decode('Cg5EZXZpY2VzUmVxdWVzdA==');
@$core.Deprecated('Use devicesDescriptor instead')
const Devices$json = const {
  '1': 'Devices',
  '2': const [
    const {
      '1': 'devices',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.mpcoord.Device',
      '10': 'devices'
    },
  ],
};

/// Descriptor for `Devices`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List devicesDescriptor = $convert.base64Decode(
    'CgdEZXZpY2VzEikKB2RldmljZXMYASADKAsyDy5tcGNvb3JkLkRldmljZVIHZGV2aWNlcw==');
@$core.Deprecated('Use deviceDescriptor instead')
const Device$json = const {
  '1': 'Device',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 12, '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Device`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceDescriptor = $convert.base64Decode(
    'CgZEZXZpY2USDgoCaWQYASABKAxSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWU=');
@$core.Deprecated('Use signRequestDescriptor instead')
const SignRequest$json = const {
  '1': 'SignRequest',
  '2': const [
    const {'1': 'group_id', '3': 1, '4': 1, '5': 12, '10': 'groupId'},
    const {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `SignRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signRequestDescriptor = $convert.base64Decode(
    'CgtTaWduUmVxdWVzdBIZCghncm91cF9pZBgBIAEoDFIHZ3JvdXBJZBISCgRkYXRhGAIgASgMUgRkYXRh');
@$core.Deprecated('Use taskRequestDescriptor instead')
const TaskRequest$json = const {
  '1': 'TaskRequest',
  '2': const [
    const {'1': 'task_id', '3': 1, '4': 1, '5': 13, '10': 'taskId'},
    const {
      '1': 'device_id',
      '3': 2,
      '4': 1,
      '5': 12,
      '9': 0,
      '10': 'deviceId',
      '17': true
    },
  ],
  '8': const [
    const {'1': '_device_id'},
  ],
};

/// Descriptor for `TaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskRequestDescriptor = $convert.base64Decode(
    'CgtUYXNrUmVxdWVzdBIXCgd0YXNrX2lkGAEgASgNUgZ0YXNrSWQSIAoJZGV2aWNlX2lkGAIgASgMSABSCGRldmljZUlkiAEBQgwKCl9kZXZpY2VfaWQ=');
@$core.Deprecated('Use taskDescriptor instead')
const Task$json = const {
  '1': 'Task',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    const {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.mpcoord.Task.TaskType',
      '10': 'type'
    },
    const {
      '1': 'state',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.mpcoord.Task.TaskState',
      '10': 'state'
    },
    const {'1': 'progress', '3': 4, '4': 1, '5': 5, '10': 'progress'},
    const {'1': 'data', '3': 5, '4': 3, '5': 12, '10': 'data'},
    const {
      '1': 'work',
      '3': 6,
      '4': 1,
      '5': 12,
      '9': 0,
      '10': 'work',
      '17': true
    },
  ],
  '4': const [Task_TaskType$json, Task_TaskState$json],
  '8': const [
    const {'1': '_work'},
  ],
};

@$core.Deprecated('Use taskDescriptor instead')
const Task_TaskType$json = const {
  '1': 'TaskType',
  '2': const [
    const {'1': 'GROUP', '2': 0},
    const {'1': 'SIGN', '2': 1},
  ],
};

@$core.Deprecated('Use taskDescriptor instead')
const Task_TaskState$json = const {
  '1': 'TaskState',
  '2': const [
    const {'1': 'WAITING', '2': 0},
    const {'1': 'FINISHED', '2': 1},
    const {'1': 'FAILED', '2': 2},
  ],
};

/// Descriptor for `Task`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskDescriptor = $convert.base64Decode(
    'CgRUYXNrEg4KAmlkGAEgASgNUgJpZBIqCgR0eXBlGAIgASgOMhYubXBjb29yZC5UYXNrLlRhc2tUeXBlUgR0eXBlEi0KBXN0YXRlGAMgASgOMhcubXBjb29yZC5UYXNrLlRhc2tTdGF0ZVIFc3RhdGUSGgoIcHJvZ3Jlc3MYBCABKAVSCHByb2dyZXNzEhIKBGRhdGEYBSADKAxSBGRhdGESFwoEd29yaxgGIAEoDEgAUgR3b3JriAEBIh8KCFRhc2tUeXBlEgkKBUdST1VQEAASCAoEU0lHThABIjIKCVRhc2tTdGF0ZRILCgdXQUlUSU5HEAASDAoIRklOSVNIRUQQARIKCgZGQUlMRUQQAkIHCgVfd29yaw==');
@$core.Deprecated('Use taskUpdateDescriptor instead')
const TaskUpdate$json = const {
  '1': 'TaskUpdate',
  '2': const [
    const {'1': 'device', '3': 1, '4': 1, '5': 12, '10': 'device'},
    const {'1': 'task', '3': 2, '4': 1, '5': 13, '10': 'task'},
    const {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `TaskUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskUpdateDescriptor = $convert.base64Decode(
    'CgpUYXNrVXBkYXRlEhYKBmRldmljZRgBIAEoDFIGZGV2aWNlEhIKBHRhc2sYAiABKA1SBHRhc2sSEgoEZGF0YRgDIAEoDFIEZGF0YQ==');
@$core.Deprecated('Use infoRequestDescriptor instead')
const InfoRequest$json = const {
  '1': 'InfoRequest',
  '2': const [
    const {'1': 'device_id', '3': 1, '4': 1, '5': 12, '10': 'deviceId'},
  ],
};

/// Descriptor for `InfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List infoRequestDescriptor = $convert
    .base64Decode('CgtJbmZvUmVxdWVzdBIbCglkZXZpY2VfaWQYASABKAxSCGRldmljZUlk');
@$core.Deprecated('Use infoDescriptor instead')
const Info$json = const {
  '1': 'Info',
  '2': const [
    const {
      '1': 'groups',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.mpcoord.Group',
      '10': 'groups'
    },
    const {
      '1': 'tasks',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.mpcoord.Task',
      '10': 'tasks'
    },
  ],
};

/// Descriptor for `Info`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List infoDescriptor = $convert.base64Decode(
    'CgRJbmZvEiYKBmdyb3VwcxgBIAMoCzIOLm1wY29vcmQuR3JvdXBSBmdyb3VwcxIjCgV0YXNrcxgCIAMoCzINLm1wY29vcmQuVGFza1IFdGFza3M=');
@$core.Deprecated('Use respDescriptor instead')
const Resp$json = const {
  '1': 'Resp',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'success'},
    const {'1': 'failure', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'failure'},
  ],
  '8': const [
    const {'1': 'variant'},
  ],
};

/// Descriptor for `Resp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List respDescriptor = $convert.base64Decode(
    'CgRSZXNwEhoKB3N1Y2Nlc3MYASABKAlIAFIHc3VjY2VzcxIaCgdmYWlsdXJlGAIgASgJSABSB2ZhaWx1cmVCCQoHdmFyaWFudA==');
