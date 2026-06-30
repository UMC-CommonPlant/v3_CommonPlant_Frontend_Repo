import 'package:commonplant_frontend/core/assets/app_image_assets.dart';
import 'package:commonplant_frontend/features/place/presentation/models/place_invitation.dart';
import 'package:flutter/material.dart';

const List<PlaceInvitation> placeInvitationFixture = <PlaceInvitation>[
  PlaceInvitation(
    id: 'invite-1',
    inviterName: '커먼맘',
    placeName: '스윗홈_욕실',
    address: '서울시 노원구 광운로 20',
    avatarAsset: AppImageAssets.placeInvitationAvatarCommonMom,
  ),
  PlaceInvitation(
    id: 'invite-2',
    inviterName: '커먼맘',
    placeName: '스윗홈_베란다',
    address: '서울시 노원구 광운로 20',
    avatarAsset: AppImageAssets.placeInvitationAvatarCommonMom,
  ),
  PlaceInvitation(
    id: 'invite-3',
    inviterName: '도라에몽',
    placeName: '낫 스윗 회사_중앙',
    address: '서울시 강남구 커먼로 55',
    avatarAsset: AppImageAssets.placeInvitationAvatarDoraemon,
    avatarAlignment: Alignment.topCenter,
  ),
];
