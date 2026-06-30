import 'package:flutter/material.dart';

enum PlaceInvitationResult { accepted, deleted }

class PlaceInvitation {
  const PlaceInvitation({
    required this.id,
    required this.inviterName,
    required this.placeName,
    required this.address,
    required this.avatarAsset,
    this.avatarAlignment = Alignment.center,
  });

  final String id;
  final String inviterName;
  final String placeName;
  final String address;
  final String avatarAsset;
  final Alignment avatarAlignment;
}
