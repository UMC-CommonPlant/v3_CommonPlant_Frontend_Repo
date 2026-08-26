class FriendInvitation {
  const FriendInvitation({
    required this.id,
    required this.senderName,
    required this.placeCode,
    required this.placeName,
    required this.placeAddress,
    required this.status,
    this.senderImageUrl,
  });

  final int id;
  final String senderName;
  final String? senderImageUrl;
  final String placeCode;
  final String placeName;
  final String placeAddress;
  final String status;
}
