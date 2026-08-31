import 'package:commonplant_frontend/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiException.fromDio', () {
    test('표준 오류 응답에서 코드와 필드 사유를 파싱하고 거절값은 버린다', () {
      const rejectedValue = 'private-user-value';
      final error = ApiException.fromDio(
        _responseError(
          statusCode: 400,
          data: <String, Object?>{
            'status': 400,
            'code': 'C001',
            'message': '요청 값이 유효하지 않습니다.',
            'traceId': 'trace-123',
            'errors': <Object?>[
              <String, Object?>{
                'field': 'request.name',
                'value': rejectedValue,
                'reason': '이름을 확인해 주세요.',
              },
              <String, Object?>{
                'field': 'address',
                'value': rejectedValue,
                'reason': '주소를 입력해 주세요.',
              },
            ],
          },
        ),
      );

      expect(error.statusCode, 400);
      expect(error.code, 'C001');
      expect(error.traceId, 'trace-123');
      expect(error.kind, ApiFailureKind.validation);
      expect(error.fieldErrors, const <ApiFieldError>[
        ApiFieldError(field: 'request.name', reason: '이름을 확인해 주세요.'),
        ApiFieldError(field: 'address', reason: '주소를 입력해 주세요.'),
      ]);
      expect(error.fieldErrorMessages, <String, String>{
        'name': '이름을 확인해 주세요.',
        'address': '주소를 입력해 주세요.',
      });
      expect(error.toString(), isNot(contains(rejectedValue)));
      expect(error.toString(), contains('trace=trace-123'));
    });

    test('알려진 단일 필드 오류 코드를 폼 필드로 연결한다', () {
      final error = ApiException.fromDio(
        _responseError(
          statusCode: 400,
          data: const <String, Object?>{
            'code': 'P108',
            'message': '주소가 필요합니다.',
          },
        ),
      );

      expect(error.fieldErrorMessages['address'], '장소 주소를 입력해 주세요.');
    });

    test('인증 만료는 확인된 401 코드만 재로그인 대상으로 분류한다', () {
      for (final code in const ['A003', 'A004', 'A009']) {
        final error = ApiException.fromDio(
          _responseError(statusCode: 401, data: {'code': code}),
        );
        expect(error.requiresReauthentication, isTrue, reason: code);
        expect(
          error.userMessage(fallback: 'fallback'),
          sessionExpiredMessage,
          reason: code,
        );
      }

      for (final code in const ['A001', 'A002', 'A006', null]) {
        final error = ApiException.fromDio(
          _responseError(statusCode: 401, data: {'code': code}),
        );
        expect(error.requiresReauthentication, isFalse, reason: '$code');
      }
    });

    test('HTTP 상태와 전송 오류를 사용자용 범주로 변환한다', () {
      final cases = <(DioException, ApiFailureKind, String)>[
        (
          _responseError(statusCode: 403),
          ApiFailureKind.forbidden,
          '이 작업을 수행할 권한이 없어요.',
        ),
        (
          _responseError(statusCode: 404),
          ApiFailureKind.notFound,
          '요청한 정보를 찾을 수 없어요.',
        ),
        (
          _responseError(statusCode: 409),
          ApiFailureKind.conflict,
          '이미 처리되었거나 현재 상태와 맞지 않아요.',
        ),
        (
          _responseError(statusCode: 429),
          ApiFailureKind.rateLimited,
          '요청이 많아요. 잠시 후 다시 시도해 주세요.',
        ),
        (
          _responseError(statusCode: 500),
          ApiFailureKind.server,
          '서버에 문제가 발생했어요. 잠시 후 다시 시도해 주세요.',
        ),
        (
          _transportError(DioExceptionType.connectionTimeout),
          ApiFailureKind.timeout,
          '요청 시간이 초과됐어요. 다시 시도해 주세요.',
        ),
        (
          _transportError(DioExceptionType.connectionError),
          ApiFailureKind.network,
          '네트워크 연결을 확인한 뒤 다시 시도해 주세요.',
        ),
      ];

      for (final (dioError, expectedKind, expectedMessage) in cases) {
        final error = ApiException.fromDio(dioError);
        expect(error.kind, expectedKind);
        expect(error.userMessage(fallback: 'fallback'), expectedMessage);
      }
    });
  });
}

DioException _responseError({
  required int statusCode,
  Object? data = const <String, Object?>{},
}) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    ),
    type: DioExceptionType.badResponse,
  );
}

DioException _transportError(DioExceptionType type) {
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    type: type,
  );
}
