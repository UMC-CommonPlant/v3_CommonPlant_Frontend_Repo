import 'package:commonplant_frontend/app/router/app_route_spec.dart';
import 'package:commonplant_frontend/app/router/route_paths.dart';
import 'package:commonplant_frontend/app/router/route_placeholder_page.dart';
import 'package:commonplant_frontend/features/home/presentation/home_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

const List<AppRouteSpec> appRouteSpecs = [
  AppRouteSpec(
    name: AppRouteNames.home,
    path: AppRoutePaths.home,
    title: '홈',
    figmaFrames: ['#2 Main', '#2 Main/D'],
    implementation: AppRouteImplementation.implemented,
  ),
  AppRouteSpec(
    name: AppRouteNames.onboarding,
    path: AppRoutePaths.onboarding,
    title: '온보딩',
    figmaFrames: ['#1-1'],
  ),
  AppRouteSpec(
    name: AppRouteNames.profileSetup,
    path: AppRoutePaths.profileSetup,
    title: '프로필 설정',
    figmaFrames: [
      '#1-2-2 Log in',
      '#1-2-2 Log in / Clear',
      '#1-2-2 Log in / Picture',
    ],
  ),
  AppRouteSpec(
    name: AppRouteNames.terms,
    path: AppRoutePaths.terms,
    title: '개인정보 이용약관',
    figmaFrames: ['#1-2-3 Sign up / 2D'],
  ),
  AppRouteSpec(
    name: AppRouteNames.placeInvitations,
    path: AppRoutePaths.placeInvitations,
    title: '장소 친구 요청',
    figmaFrames: ['#2-2 Main / 장소 친구 요청', '#2-2 Main / 장소 친구 요청 (BTN 결과값)'],
  ),
  AppRouteSpec(
    name: AppRouteNames.placeCreate,
    path: AppRoutePaths.placeCreate,
    title: '장소 등록',
    figmaFrames: ['#2-2-2 장소 등록'],
  ),
  AppRouteSpec(
    name: AppRouteNames.addressSearch,
    path: AppRoutePaths.addressSearch,
    title: '주소 검색',
    figmaFrames: ['#2-2-2-2 장소 등록 / 주소 검색'],
  ),
  AppRouteSpec(
    name: AppRouteNames.placeFriendAdd,
    path: AppRoutePaths.placeFriendAdd,
    title: '친구 추가',
    figmaFrames: ['#2-2-2-2 장소 등록-친구 추가', '#2-2-2-2 장소 등록-친구 추가 과정'],
  ),
  AppRouteSpec(
    name: AppRouteNames.placeEdit,
    path: AppRoutePaths.placeEdit,
    title: '장소 수정',
    figmaFrames: ['#2-2-2 장소 수정'],
  ),
  AppRouteSpec(
    name: AppRouteNames.friendManagement,
    path: AppRoutePaths.friendManagement,
    title: '친구 관리',
    figmaFrames: ['#2-3-2 친구 관리', '#2-3-2 친구 관리 - 삭제 알럿'],
  ),
  AppRouteSpec(
    name: AppRouteNames.placeDetail,
    path: AppRoutePaths.placeDetail,
    title: '장소 상세',
    figmaFrames: ['#2-3 My place 리더화면', '#2-3 My place 팀원화면'],
  ),
  AppRouteSpec(
    name: AppRouteNames.plantSearch,
    path: AppRoutePaths.plantSearch,
    title: '식물 등록 검색',
    figmaFrames: ['#2-2-3 식물 등록', '#2-2-3 식물 등록(검색 후)'],
  ),
  AppRouteSpec(
    name: AppRouteNames.plantCreateDetails,
    path: AppRoutePaths.plantCreateDetails,
    title: '식물 등록 정보 입력',
    figmaFrames: ['#2-2-3-2 식물 등록'],
  ),
  AppRouteSpec(
    name: AppRouteNames.plantEdit,
    path: AppRoutePaths.plantEdit,
    title: '식물 수정',
    figmaFrames: ['#2-2-3-3 식물 수정'],
  ),
  AppRouteSpec(
    name: AppRouteNames.memoWrite,
    path: AppRoutePaths.memoWrite,
    title: '메모 작성',
    figmaFrames: ['#2-4-2 메모 작성'],
  ),
  AppRouteSpec(
    name: AppRouteNames.memoList,
    path: AppRoutePaths.memoList,
    title: '메모',
    figmaFrames: ['#2-4-3 메모', '#2-4-3 메모 수정/삭제', '#2-4-3 메모 삭제 alert'],
  ),
  AppRouteSpec(
    name: AppRouteNames.plantDetail,
    path: AppRoutePaths.plantDetail,
    title: '식물 상세',
    figmaFrames: ['#2-4 My plants'],
  ),
];

List<RouteBase> buildAppRoutes() {
  return [
    for (final route in appRouteSpecs)
      GoRoute(
        name: route.name,
        path: route.path,
        builder: (context, state) => _buildRoutePage(route, state),
      ),
  ];
}

Widget _buildRoutePage(AppRouteSpec route, GoRouterState state) {
  return switch (route.implementation) {
    AppRouteImplementation.implemented => const HomeScreen(),
    AppRouteImplementation.placeholder => RoutePlaceholderPage(
      route: route,
      pathParameters: state.pathParameters,
    ),
  };
}
