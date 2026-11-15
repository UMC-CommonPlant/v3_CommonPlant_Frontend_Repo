import 'package:commonplant_frontend/core/config/app_environment.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_invitation_controller.dart';
import 'package:commonplant_frontend/features/place/presentation/providers/place_list_provider.dart';
import 'package:commonplant_frontend/features/plant/presentation/providers/plant_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final refreshHomeListsProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    if (!ref.read(useRemoteApiProvider)) return;

    try {
      await Future.wait<Object?>([
        _refreshQuery(ref, remotePlaceListProvider),
        _refreshQuery(ref, remotePlantListProvider),
        _refreshQuery(ref, remotePlaceInvitationsProvider),
      ]);
    } catch (_) {
      // 각 조회가 자신의 오류를 표시한다. 새로고침은 나머지 조회도 기다린다.
    }
  };
});

Future<T> _refreshQuery<T>(Ref ref, FutureProvider<T> query) {
  if (ref.read(query).isLoading) return ref.read(query.future);
  return ref.refresh(query.future);
}
