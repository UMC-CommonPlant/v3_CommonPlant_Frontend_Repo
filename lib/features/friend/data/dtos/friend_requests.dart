class SendFriendRequest {
  const SendFriendRequest({
    required this.receiverNames,
    required this.placeCode,
  });

  final List<String> receiverNames;
  final String placeCode;

  Map<String, Object?> toJson() {
    return {'receiverName': receiverNames, 'placeCode': placeCode};
  }
}

class FriendDecisionRequest {
  const FriendDecisionRequest({required this.friendId});

  final int friendId;

  Map<String, Object?> toJson() {
    return {'friendId': friendId};
  }
}
