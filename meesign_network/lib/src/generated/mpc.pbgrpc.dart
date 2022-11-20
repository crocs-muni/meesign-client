///
//  Generated code. Do not modify.
//  source: mpc.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'mpc.pb.dart' as $0;
export 'mpc.pb.dart';

class MPCClient extends $grpc.Client {
  static final _$register =
      $grpc.ClientMethod<$0.RegistrationRequest, $0.RegistrationResponse>(
          '/meesign.MPC/Register',
          ($0.RegistrationRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.RegistrationResponse.fromBuffer(value));
  static final _$sign = $grpc.ClientMethod<$0.SignRequest, $0.Task>(
      '/meesign.MPC/Sign',
      ($0.SignRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Task.fromBuffer(value));
  static final _$group = $grpc.ClientMethod<$0.GroupRequest, $0.Task>(
      '/meesign.MPC/Group',
      ($0.GroupRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Task.fromBuffer(value));
  static final _$getTask = $grpc.ClientMethod<$0.TaskRequest, $0.Task>(
      '/meesign.MPC/GetTask',
      ($0.TaskRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Task.fromBuffer(value));
  static final _$updateTask = $grpc.ClientMethod<$0.TaskUpdate, $0.Resp>(
      '/meesign.MPC/UpdateTask',
      ($0.TaskUpdate value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Resp.fromBuffer(value));
  static final _$decideTask = $grpc.ClientMethod<$0.TaskDecision, $0.Resp>(
      '/meesign.MPC/DecideTask',
      ($0.TaskDecision value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Resp.fromBuffer(value));
  static final _$acknowledgeTask =
      $grpc.ClientMethod<$0.TaskAcknowledgement, $0.Resp>(
          '/meesign.MPC/AcknowledgeTask',
          ($0.TaskAcknowledgement value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Resp.fromBuffer(value));
  static final _$getTasks = $grpc.ClientMethod<$0.TasksRequest, $0.Tasks>(
      '/meesign.MPC/GetTasks',
      ($0.TasksRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Tasks.fromBuffer(value));
  static final _$getGroups = $grpc.ClientMethod<$0.GroupsRequest, $0.Groups>(
      '/meesign.MPC/GetGroups',
      ($0.GroupsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Groups.fromBuffer(value));
  static final _$getDevices = $grpc.ClientMethod<$0.DevicesRequest, $0.Devices>(
      '/meesign.MPC/GetDevices',
      ($0.DevicesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Devices.fromBuffer(value));
  static final _$log = $grpc.ClientMethod<$0.LogRequest, $0.Resp>(
      '/meesign.MPC/Log',
      ($0.LogRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Resp.fromBuffer(value));
  static final _$subscribeUpdates =
      $grpc.ClientMethod<$0.SubscribeRequest, $0.Task>(
          '/meesign.MPC/SubscribeUpdates',
          ($0.SubscribeRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Task.fromBuffer(value));

  MPCClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.RegistrationResponse> register(
      $0.RegistrationRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$register, request, options: options);
  }

  $grpc.ResponseFuture<$0.Task> sign($0.SignRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sign, request, options: options);
  }

  $grpc.ResponseFuture<$0.Task> group($0.GroupRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$group, request, options: options);
  }

  $grpc.ResponseFuture<$0.Task> getTask($0.TaskRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.Resp> updateTask($0.TaskUpdate request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.Resp> decideTask($0.TaskDecision request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$decideTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.Resp> acknowledgeTask($0.TaskAcknowledgement request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$acknowledgeTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.Tasks> getTasks($0.TasksRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getTasks, request, options: options);
  }

  $grpc.ResponseFuture<$0.Groups> getGroups($0.GroupsRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getGroups, request, options: options);
  }

  $grpc.ResponseFuture<$0.Devices> getDevices($0.DevicesRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getDevices, request, options: options);
  }

  $grpc.ResponseFuture<$0.Resp> log($0.LogRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$log, request, options: options);
  }

  $grpc.ResponseStream<$0.Task> subscribeUpdates($0.SubscribeRequest request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$subscribeUpdates, $async.Stream.fromIterable([request]),
        options: options);
  }
}

abstract class MPCServiceBase extends $grpc.Service {
  $core.String get $name => 'meesign.MPC';

  MPCServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.RegistrationRequest, $0.RegistrationResponse>(
            'Register',
            register_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RegistrationRequest.fromBuffer(value),
            ($0.RegistrationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SignRequest, $0.Task>(
        'Sign',
        sign_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SignRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GroupRequest, $0.Task>(
        'Group',
        group_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GroupRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskRequest, $0.Task>(
        'GetTask',
        getTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TaskRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskUpdate, $0.Resp>(
        'UpdateTask',
        updateTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TaskUpdate.fromBuffer(value),
        ($0.Resp value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskDecision, $0.Resp>(
        'DecideTask',
        decideTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TaskDecision.fromBuffer(value),
        ($0.Resp value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskAcknowledgement, $0.Resp>(
        'AcknowledgeTask',
        acknowledgeTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.TaskAcknowledgement.fromBuffer(value),
        ($0.Resp value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TasksRequest, $0.Tasks>(
        'GetTasks',
        getTasks_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TasksRequest.fromBuffer(value),
        ($0.Tasks value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GroupsRequest, $0.Groups>(
        'GetGroups',
        getGroups_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GroupsRequest.fromBuffer(value),
        ($0.Groups value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DevicesRequest, $0.Devices>(
        'GetDevices',
        getDevices_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DevicesRequest.fromBuffer(value),
        ($0.Devices value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LogRequest, $0.Resp>(
        'Log',
        log_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LogRequest.fromBuffer(value),
        ($0.Resp value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SubscribeRequest, $0.Task>(
        'SubscribeUpdates',
        subscribeUpdates_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.SubscribeRequest.fromBuffer(value),
        ($0.Task value) => value.writeToBuffer()));
  }

  $async.Future<$0.RegistrationResponse> register_Pre($grpc.ServiceCall call,
      $async.Future<$0.RegistrationRequest> request) async {
    return register(call, await request);
  }

  $async.Future<$0.Task> sign_Pre(
      $grpc.ServiceCall call, $async.Future<$0.SignRequest> request) async {
    return sign(call, await request);
  }

  $async.Future<$0.Task> group_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GroupRequest> request) async {
    return group(call, await request);
  }

  $async.Future<$0.Task> getTask_Pre(
      $grpc.ServiceCall call, $async.Future<$0.TaskRequest> request) async {
    return getTask(call, await request);
  }

  $async.Future<$0.Resp> updateTask_Pre(
      $grpc.ServiceCall call, $async.Future<$0.TaskUpdate> request) async {
    return updateTask(call, await request);
  }

  $async.Future<$0.Resp> decideTask_Pre(
      $grpc.ServiceCall call, $async.Future<$0.TaskDecision> request) async {
    return decideTask(call, await request);
  }

  $async.Future<$0.Resp> acknowledgeTask_Pre($grpc.ServiceCall call,
      $async.Future<$0.TaskAcknowledgement> request) async {
    return acknowledgeTask(call, await request);
  }

  $async.Future<$0.Tasks> getTasks_Pre(
      $grpc.ServiceCall call, $async.Future<$0.TasksRequest> request) async {
    return getTasks(call, await request);
  }

  $async.Future<$0.Groups> getGroups_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GroupsRequest> request) async {
    return getGroups(call, await request);
  }

  $async.Future<$0.Devices> getDevices_Pre(
      $grpc.ServiceCall call, $async.Future<$0.DevicesRequest> request) async {
    return getDevices(call, await request);
  }

  $async.Future<$0.Resp> log_Pre(
      $grpc.ServiceCall call, $async.Future<$0.LogRequest> request) async {
    return log(call, await request);
  }

  $async.Stream<$0.Task> subscribeUpdates_Pre($grpc.ServiceCall call,
      $async.Future<$0.SubscribeRequest> request) async* {
    yield* subscribeUpdates(call, await request);
  }

  $async.Future<$0.RegistrationResponse> register(
      $grpc.ServiceCall call, $0.RegistrationRequest request);
  $async.Future<$0.Task> sign($grpc.ServiceCall call, $0.SignRequest request);
  $async.Future<$0.Task> group($grpc.ServiceCall call, $0.GroupRequest request);
  $async.Future<$0.Task> getTask(
      $grpc.ServiceCall call, $0.TaskRequest request);
  $async.Future<$0.Resp> updateTask(
      $grpc.ServiceCall call, $0.TaskUpdate request);
  $async.Future<$0.Resp> decideTask(
      $grpc.ServiceCall call, $0.TaskDecision request);
  $async.Future<$0.Resp> acknowledgeTask(
      $grpc.ServiceCall call, $0.TaskAcknowledgement request);
  $async.Future<$0.Tasks> getTasks(
      $grpc.ServiceCall call, $0.TasksRequest request);
  $async.Future<$0.Groups> getGroups(
      $grpc.ServiceCall call, $0.GroupsRequest request);
  $async.Future<$0.Devices> getDevices(
      $grpc.ServiceCall call, $0.DevicesRequest request);
  $async.Future<$0.Resp> log($grpc.ServiceCall call, $0.LogRequest request);
  $async.Stream<$0.Task> subscribeUpdates(
      $grpc.ServiceCall call, $0.SubscribeRequest request);
}
