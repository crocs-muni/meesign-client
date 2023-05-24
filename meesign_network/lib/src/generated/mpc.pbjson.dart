///
//  Generated code. Do not modify.
//  source: mpc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use protocolTypeDescriptor instead')
const ProtocolType$json = const {
  '1': 'ProtocolType',
  '2': const [
    const {'1': 'GG18', '2': 0},
    const {'1': 'ELGAMAL', '2': 1},
  ],
};

/// Descriptor for `ProtocolType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List protocolTypeDescriptor = $convert
    .base64Decode('CgxQcm90b2NvbFR5cGUSCAoER0cxOBAAEgsKB0VMR0FNQUwQAQ==');
@$core.Deprecated('Use keyTypeDescriptor instead')
const KeyType$json = const {
  '1': 'KeyType',
  '2': const [
    const {'1': 'SignPDF', '2': 0},
    const {'1': 'SignChallenge', '2': 1},
    const {'1': 'Decrypt', '2': 2},
  ],
};

/// Descriptor for `KeyType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List keyTypeDescriptor = $convert.base64Decode(
    'CgdLZXlUeXBlEgsKB1NpZ25QREYQABIRCg1TaWduQ2hhbGxlbmdlEAESCwoHRGVjcnlwdBAC');
@$core.Deprecated('Use taskTypeDescriptor instead')
const TaskType$json = const {
  '1': 'TaskType',
  '2': const [
    const {'1': 'GROUP', '2': 0},
    const {'1': 'SIGN_PDF', '2': 1},
    const {'1': 'SIGN_CHALLENGE', '2': 2},
    const {'1': 'DECRYPT', '2': 3},
  ],
};

/// Descriptor for `TaskType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List taskTypeDescriptor = $convert.base64Decode(
    'CghUYXNrVHlwZRIJCgVHUk9VUBAAEgwKCFNJR05fUERGEAESEgoOU0lHTl9DSEFMTEVOR0UQAhILCgdERUNSWVBUEAM=');
@$core.Deprecated('Use serverInfoRequestDescriptor instead')
const ServerInfoRequest$json = const {
  '1': 'ServerInfoRequest',
};

/// Descriptor for `ServerInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverInfoRequestDescriptor =
    $convert.base64Decode('ChFTZXJ2ZXJJbmZvUmVxdWVzdA==');
@$core.Deprecated('Use serverInfoDescriptor instead')
const ServerInfo$json = const {
  '1': 'ServerInfo',
  '2': const [
    const {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
  ],
};

/// Descriptor for `ServerInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverInfoDescriptor = $convert
    .base64Decode('CgpTZXJ2ZXJJbmZvEhgKB3ZlcnNpb24YASABKAlSB3ZlcnNpb24=');
@$core.Deprecated('Use registrationRequestDescriptor instead')
const RegistrationRequest$json = const {
  '1': 'RegistrationRequest',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'csr', '3': 2, '4': 1, '5': 12, '10': 'csr'},
  ],
};

/// Descriptor for `RegistrationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registrationRequestDescriptor = $convert.base64Decode(
    'ChNSZWdpc3RyYXRpb25SZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWUSEAoDY3NyGAIgASgMUgNjc3I=');
@$core.Deprecated('Use registrationResponseDescriptor instead')
const RegistrationResponse$json = const {
  '1': 'RegistrationResponse',
  '2': const [
    const {'1': 'device_id', '3': 1, '4': 1, '5': 12, '10': 'deviceId'},
    const {'1': 'certificate', '3': 2, '4': 1, '5': 12, '10': 'certificate'},
  ],
};

/// Descriptor for `RegistrationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registrationResponseDescriptor = $convert.base64Decode(
    'ChRSZWdpc3RyYXRpb25SZXNwb25zZRIbCglkZXZpY2VfaWQYASABKAxSCGRldmljZUlkEiAKC2NlcnRpZmljYXRlGAIgASgMUgtjZXJ0aWZpY2F0ZQ==');
@$core.Deprecated('Use groupRequestDescriptor instead')
const GroupRequest$json = const {
  '1': 'GroupRequest',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'device_ids', '3': 2, '4': 3, '5': 12, '10': 'deviceIds'},
    const {'1': 'threshold', '3': 3, '4': 1, '5': 13, '10': 'threshold'},
    const {
      '1': 'protocol',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.meesign.ProtocolType',
      '10': 'protocol'
    },
    const {
      '1': 'key_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.meesign.KeyType',
      '10': 'keyType'
    },
  ],
};

/// Descriptor for `GroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupRequestDescriptor = $convert.base64Decode(
    'CgxHcm91cFJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIdCgpkZXZpY2VfaWRzGAIgAygMUglkZXZpY2VJZHMSHAoJdGhyZXNob2xkGAMgASgNUgl0aHJlc2hvbGQSMQoIcHJvdG9jb2wYBCABKA4yFS5tZWVzaWduLlByb3RvY29sVHlwZVIIcHJvdG9jb2wSKwoIa2V5X3R5cGUYBSABKA4yEC5tZWVzaWduLktleVR5cGVSB2tleVR5cGU=');
@$core.Deprecated('Use groupDescriptor instead')
const Group$json = const {
  '1': 'Group',
  '2': const [
    const {'1': 'identifier', '3': 1, '4': 1, '5': 12, '10': 'identifier'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'threshold', '3': 3, '4': 1, '5': 13, '10': 'threshold'},
    const {
      '1': 'protocol',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.meesign.ProtocolType',
      '10': 'protocol'
    },
    const {
      '1': 'key_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.meesign.KeyType',
      '10': 'keyType'
    },
    const {'1': 'device_ids', '3': 6, '4': 3, '5': 12, '10': 'deviceIds'},
  ],
};

/// Descriptor for `Group`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupDescriptor = $convert.base64Decode(
    'CgVHcm91cBIeCgppZGVudGlmaWVyGAEgASgMUgppZGVudGlmaWVyEhIKBG5hbWUYAiABKAlSBG5hbWUSHAoJdGhyZXNob2xkGAMgASgNUgl0aHJlc2hvbGQSMQoIcHJvdG9jb2wYBCABKA4yFS5tZWVzaWduLlByb3RvY29sVHlwZVIIcHJvdG9jb2wSKwoIa2V5X3R5cGUYBSABKA4yEC5tZWVzaWduLktleVR5cGVSB2tleVR5cGUSHQoKZGV2aWNlX2lkcxgGIAMoDFIJZGV2aWNlSWRz');
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
      '6': '.meesign.Device',
      '10': 'devices'
    },
  ],
};

/// Descriptor for `Devices`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List devicesDescriptor = $convert.base64Decode(
    'CgdEZXZpY2VzEikKB2RldmljZXMYASADKAsyDy5tZWVzaWduLkRldmljZVIHZGV2aWNlcw==');
@$core.Deprecated('Use deviceDescriptor instead')
const Device$json = const {
  '1': 'Device',
  '2': const [
    const {'1': 'identifier', '3': 1, '4': 1, '5': 12, '10': 'identifier'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'certificate', '3': 3, '4': 1, '5': 12, '10': 'certificate'},
    const {'1': 'last_active', '3': 4, '4': 1, '5': 4, '10': 'lastActive'},
  ],
};

/// Descriptor for `Device`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceDescriptor = $convert.base64Decode(
    'CgZEZXZpY2USHgoKaWRlbnRpZmllchgBIAEoDFIKaWRlbnRpZmllchISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2NlcnRpZmljYXRlGAMgASgMUgtjZXJ0aWZpY2F0ZRIfCgtsYXN0X2FjdGl2ZRgEIAEoBFIKbGFzdEFjdGl2ZQ==');
@$core.Deprecated('Use signRequestDescriptor instead')
const SignRequest$json = const {
  '1': 'SignRequest',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'group_id', '3': 2, '4': 1, '5': 12, '10': 'groupId'},
    const {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `SignRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signRequestDescriptor = $convert.base64Decode(
    'CgtTaWduUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEhkKCGdyb3VwX2lkGAIgASgMUgdncm91cElkEhIKBGRhdGEYAyABKAxSBGRhdGE=');
@$core.Deprecated('Use decryptRequestDescriptor instead')
const DecryptRequest$json = const {
  '1': 'DecryptRequest',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'group_id', '3': 2, '4': 1, '5': 12, '10': 'groupId'},
    const {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `DecryptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decryptRequestDescriptor = $convert.base64Decode(
    'Cg5EZWNyeXB0UmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEhkKCGdyb3VwX2lkGAIgASgMUgdncm91cElkEhIKBGRhdGEYAyABKAxSBGRhdGE=');
@$core.Deprecated('Use taskRequestDescriptor instead')
const TaskRequest$json = const {
  '1': 'TaskRequest',
  '2': const [
    const {'1': 'task_id', '3': 1, '4': 1, '5': 12, '10': 'taskId'},
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
    'CgtUYXNrUmVxdWVzdBIXCgd0YXNrX2lkGAEgASgMUgZ0YXNrSWQSIAoJZGV2aWNlX2lkGAIgASgMSABSCGRldmljZUlkiAEBQgwKCl9kZXZpY2VfaWQ=');
@$core.Deprecated('Use taskDescriptor instead')
const Task$json = const {
  '1': 'Task',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 12, '10': 'id'},
    const {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.meesign.TaskType',
      '10': 'type'
    },
    const {
      '1': 'state',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.meesign.Task.TaskState',
      '10': 'state'
    },
    const {'1': 'round', '3': 4, '4': 1, '5': 13, '10': 'round'},
    const {'1': 'attempt', '3': 5, '4': 1, '5': 13, '10': 'attempt'},
    const {'1': 'accept', '3': 6, '4': 1, '5': 13, '10': 'accept'},
    const {'1': 'reject', '3': 7, '4': 1, '5': 13, '10': 'reject'},
    const {
      '1': 'data',
      '3': 8,
      '4': 1,
      '5': 12,
      '9': 0,
      '10': 'data',
      '17': true
    },
    const {
      '1': 'request',
      '3': 9,
      '4': 1,
      '5': 12,
      '9': 1,
      '10': 'request',
      '17': true
    },
  ],
  '4': const [Task_TaskState$json],
  '8': const [
    const {'1': '_data'},
    const {'1': '_request'},
  ],
};

@$core.Deprecated('Use taskDescriptor instead')
const Task_TaskState$json = const {
  '1': 'TaskState',
  '2': const [
    const {'1': 'CREATED', '2': 0},
    const {'1': 'RUNNING', '2': 1},
    const {'1': 'FINISHED', '2': 2},
    const {'1': 'FAILED', '2': 3},
  ],
};

/// Descriptor for `Task`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskDescriptor = $convert.base64Decode(
    'CgRUYXNrEg4KAmlkGAEgASgMUgJpZBIlCgR0eXBlGAIgASgOMhEubWVlc2lnbi5UYXNrVHlwZVIEdHlwZRItCgVzdGF0ZRgDIAEoDjIXLm1lZXNpZ24uVGFzay5UYXNrU3RhdGVSBXN0YXRlEhQKBXJvdW5kGAQgASgNUgVyb3VuZBIYCgdhdHRlbXB0GAUgASgNUgdhdHRlbXB0EhYKBmFjY2VwdBgGIAEoDVIGYWNjZXB0EhYKBnJlamVjdBgHIAEoDVIGcmVqZWN0EhcKBGRhdGEYCCABKAxIAFIEZGF0YYgBARIdCgdyZXF1ZXN0GAkgASgMSAFSB3JlcXVlc3SIAQEiPwoJVGFza1N0YXRlEgsKB0NSRUFURUQQABILCgdSVU5OSU5HEAESDAoIRklOSVNIRUQQAhIKCgZGQUlMRUQQA0IHCgVfZGF0YUIKCghfcmVxdWVzdA==');
@$core.Deprecated('Use taskUpdateDescriptor instead')
const TaskUpdate$json = const {
  '1': 'TaskUpdate',
  '2': const [
    const {'1': 'task', '3': 1, '4': 1, '5': 12, '10': 'task'},
    const {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
    const {'1': 'attempt', '3': 3, '4': 1, '5': 13, '10': 'attempt'},
  ],
};

/// Descriptor for `TaskUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskUpdateDescriptor = $convert.base64Decode(
    'CgpUYXNrVXBkYXRlEhIKBHRhc2sYASABKAxSBHRhc2sSEgoEZGF0YRgCIAEoDFIEZGF0YRIYCgdhdHRlbXB0GAMgASgNUgdhdHRlbXB0');
@$core.Deprecated('Use tasksRequestDescriptor instead')
const TasksRequest$json = const {
  '1': 'TasksRequest',
  '2': const [
    const {
      '1': 'device_id',
      '3': 1,
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

/// Descriptor for `TasksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tasksRequestDescriptor = $convert.base64Decode(
    'CgxUYXNrc1JlcXVlc3QSIAoJZGV2aWNlX2lkGAEgASgMSABSCGRldmljZUlkiAEBQgwKCl9kZXZpY2VfaWQ=');
@$core.Deprecated('Use tasksDescriptor instead')
const Tasks$json = const {
  '1': 'Tasks',
  '2': const [
    const {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meesign.Task',
      '10': 'tasks'
    },
  ],
};

/// Descriptor for `Tasks`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tasksDescriptor = $convert.base64Decode(
    'CgVUYXNrcxIjCgV0YXNrcxgBIAMoCzINLm1lZXNpZ24uVGFza1IFdGFza3M=');
@$core.Deprecated('Use groupsRequestDescriptor instead')
const GroupsRequest$json = const {
  '1': 'GroupsRequest',
  '2': const [
    const {
      '1': 'device_id',
      '3': 1,
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

/// Descriptor for `GroupsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupsRequestDescriptor = $convert.base64Decode(
    'Cg1Hcm91cHNSZXF1ZXN0EiAKCWRldmljZV9pZBgBIAEoDEgAUghkZXZpY2VJZIgBAUIMCgpfZGV2aWNlX2lk');
@$core.Deprecated('Use groupsDescriptor instead')
const Groups$json = const {
  '1': 'Groups',
  '2': const [
    const {
      '1': 'groups',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.meesign.Group',
      '10': 'groups'
    },
  ],
};

/// Descriptor for `Groups`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupsDescriptor = $convert.base64Decode(
    'CgZHcm91cHMSJgoGZ3JvdXBzGAEgAygLMg4ubWVlc2lnbi5Hcm91cFIGZ3JvdXBz');
@$core.Deprecated('Use respDescriptor instead')
const Resp$json = const {
  '1': 'Resp',
  '2': const [
    const {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `Resp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List respDescriptor =
    $convert.base64Decode('CgRSZXNwEhgKB21lc3NhZ2UYASABKAlSB21lc3NhZ2U=');
@$core.Deprecated('Use taskDecisionDescriptor instead')
const TaskDecision$json = const {
  '1': 'TaskDecision',
  '2': const [
    const {'1': 'task', '3': 1, '4': 1, '5': 12, '10': 'task'},
    const {'1': 'accept', '3': 2, '4': 1, '5': 8, '10': 'accept'},
  ],
};

/// Descriptor for `TaskDecision`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskDecisionDescriptor = $convert.base64Decode(
    'CgxUYXNrRGVjaXNpb24SEgoEdGFzaxgBIAEoDFIEdGFzaxIWCgZhY2NlcHQYAiABKAhSBmFjY2VwdA==');
@$core.Deprecated('Use taskAcknowledgementDescriptor instead')
const TaskAcknowledgement$json = const {
  '1': 'TaskAcknowledgement',
  '2': const [
    const {'1': 'task_id', '3': 1, '4': 1, '5': 12, '10': 'taskId'},
  ],
};

/// Descriptor for `TaskAcknowledgement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskAcknowledgementDescriptor =
    $convert.base64Decode(
        'ChNUYXNrQWNrbm93bGVkZ2VtZW50EhcKB3Rhc2tfaWQYASABKAxSBnRhc2tJZA==');
@$core.Deprecated('Use logRequestDescriptor instead')
const LogRequest$json = const {
  '1': 'LogRequest',
  '2': const [
    const {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `LogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logRequestDescriptor = $convert
    .base64Decode('CgpMb2dSZXF1ZXN0EhgKB21lc3NhZ2UYASABKAlSB21lc3NhZ2U=');
@$core.Deprecated('Use subscribeRequestDescriptor instead')
const SubscribeRequest$json = const {
  '1': 'SubscribeRequest',
};

/// Descriptor for `SubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeRequestDescriptor =
    $convert.base64Decode('ChBTdWJzY3JpYmVSZXF1ZXN0');
