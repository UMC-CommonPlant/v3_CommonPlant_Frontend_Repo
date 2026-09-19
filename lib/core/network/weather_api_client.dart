import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CommonPlant 인증 헤더/쿠키를 외부 공공데이터 요청에 전달하지 않는다.
final weatherDioProvider = Provider.autoDispose<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      followRedirects: false,
      headers: {'Accept': 'application/json'},
    ),
  );
  ref.onDispose(() => dio.close(force: true));
  return dio;
});
