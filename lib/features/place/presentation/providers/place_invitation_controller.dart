import 'package:commonplant_frontend/features/place/presentation/models/place_invitation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placeInvitationControllerProvider =
    NotifierProvider.autoDispose<
      PlaceInvitationController,
      PlaceInvitationState
    >(PlaceInvitationController.new);

class PlaceInvitationState {
  const PlaceInvitationState({required this.results});

  const PlaceInvitationState.initial() : results = const {};

  final Map<String, PlaceInvitationResult> results;

  PlaceInvitationResult? resultFor(String invitationId) {
    return results[invitationId];
  }
}

class PlaceInvitationController extends Notifier<PlaceInvitationState> {
  @override
  PlaceInvitationState build() {
    return const PlaceInvitationState.initial();
  }

  void accept(String invitationId) {
    _setResult(invitationId, PlaceInvitationResult.accepted);
  }

  void delete(String invitationId) {
    _setResult(invitationId, PlaceInvitationResult.deleted);
  }

  void _setResult(String invitationId, PlaceInvitationResult result) {
    state = PlaceInvitationState(
      results: Map.unmodifiable({...state.results, invitationId: result}),
    );
  }
}
