import 'dart:async';
import 'dart:typed_data';

import 'package:commonplant_frontend/core/network/api_client.dart';
import 'package:commonplant_frontend/core/network/auth_token_store.dart';
import 'package:commonplant_frontend/core/network/user_data_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('인증 전 요청에는 저장된 이전 access token을 첨부하지 않는다', () async {
    final store = _TokenStore();
    final container = _container(store);
    final adapter = _RecordingAdapter();
    final dio = container.read(dioProvider)..httpClientAdapter = adapter;

    await dio.post<Object?>('/auth/login');

    expect(store.readCalls, 0);
    expect(adapter.requests.single.headers['Authorization'], isNull);
  });

  test('토큰 읽기 중 세션이 바뀌면 이전 요청에 B의 토큰을 보내지 않는다', () async {
    final store = _TokenStore()..delayRead = true;
    final container = _container(store);
    container.read(userDataSessionProvider.notifier).start();
    final oldAdapter = _RecordingAdapter();
    final oldDio = container.read(dioProvider)..httpClientAdapter = oldAdapter;
    final pending = oldDio.get<Object?>('/users');
    final cancelled = expectLater(pending, throwsA(_cancelled));
    await store.readStarted.future;

    store
      ..accessToken = 'token-B'
      ..delayRead = false;
    container.read(userDataSessionProvider.notifier).start();
    final newAdapter = _RecordingAdapter();
    final newDio = container.read(dioProvider)..httpClientAdapter = newAdapter;
    store.delayedToken.complete('token-B');
    await cancelled;
    await newDio.get<Object?>('/users');

    expect(oldAdapter.requests, isEmpty);
    expect(oldAdapter.closed, isTrue);
    expect(
      newAdapter.requests.single.headers['Authorization'],
      'Bearer token-B',
    );
  });

  test('이미 전송된 A 요청의 늦은 응답은 취소로 처리하고 B 요청은 정상 완료한다', () async {
    final store = _TokenStore();
    final container = _container(store);
    container.read(userDataSessionProvider.notifier).start();
    final response = Completer<ResponseBody>();
    final oldAdapter = _RecordingAdapter(response: response);
    final oldDio = container.read(dioProvider)..httpClientAdapter = oldAdapter;
    final pending = oldDio.get<Object?>('/users');
    final cancelled = expectLater(pending, throwsA(_cancelled));
    await oldAdapter.started.future;
    expect(
      oldAdapter.requests.single.headers['Authorization'],
      'Bearer token-A',
    );

    store.accessToken = 'token-B';
    container.read(userDataSessionProvider.notifier).start();
    final newAdapter = _RecordingAdapter();
    final newDio = container.read(dioProvider)..httpClientAdapter = newAdapter;
    response.complete(_response());
    await cancelled;
    await newDio.get<Object?>('/users');

    expect(oldAdapter.closed, isTrue);
    expect(
      newAdapter.requests.single.headers['Authorization'],
      'Bearer token-B',
    );
  });

  test('토큰 저장소 읽기 오류도 요청을 남겨두지 않고 Dio 오류로 반환한다', () async {
    final store = _TokenStore()..readError = StateError('storage unavailable');
    final container = _container(store);
    container.read(userDataSessionProvider.notifier).start();
    final adapter = _RecordingAdapter();
    final dio = container.read(dioProvider)..httpClientAdapter = adapter;

    await expectLater(dio.get<Object?>('/users'), throwsA(isA<DioException>()));
    expect(adapter.requests, isEmpty);
  });
}

final _cancelled = isA<DioException>().having(
  (error) => error.type,
  'type',
  DioExceptionType.cancel,
);

ProviderContainer _container(AuthTokenStore store) {
  final container = ProviderContainer(
    overrides: [authTokenStoreProvider.overrideWithValue(store)],
  );
  addTearDown(container.dispose);
  return container;
}

ResponseBody _response() => ResponseBody.fromString(
  '{}',
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({this.response});

  final Completer<ResponseBody>? response;
  final started = Completer<void>();
  final requests = <RequestOptions>[];
  bool closed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (!started.isCompleted) started.complete();
    return response?.future ?? _response();
  }

  @override
  void close({bool force = false}) => closed = true;
}

class _TokenStore implements AuthTokenStore {
  String? accessToken = 'token-A';
  bool delayRead = false;
  Object? readError;
  int readCalls = 0;
  final readStarted = Completer<void>();
  final delayedToken = Completer<String?>();

  @override
  Future<String?> readAccessToken() async {
    readCalls++;
    if (readError != null) throw readError!;
    if (delayRead) {
      if (!readStarted.isCompleted) readStarted.complete();
      return delayedToken.future;
    }
    return accessToken;
  }

  @override
  Future<String?> readRefreshToken() async => 'refresh';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
  }

  @override
  Future<void> clear() async => accessToken = null;
}
