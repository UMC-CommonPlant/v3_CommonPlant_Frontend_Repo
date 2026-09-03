abstract final class AppRouteNames {
  const AppRouteNames._();

  static const String home = 'home';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String profileSetup = 'profileSetup';
  static const String terms = 'terms';
  static const String placeInvitations = 'placeInvitations';
  static const String placeCreate = 'placeCreate';
  static const String addressSearch = 'addressSearch';
  static const String placeFriendAdd = 'placeFriendAdd';
  static const String placeEdit = 'placeEdit';
  static const String placeDetail = 'placeDetail';
  static const String friendManagement = 'friendManagement';
  static const String plantSearch = 'plantSearch';
  static const String plantCreateDetails = 'plantCreateDetails';
  static const String plantEdit = 'plantEdit';
  static const String plantDetail = 'plantDetail';
  static const String memoWrite = 'memoWrite';
  static const String memoList = 'memoList';
  static const String userProfile = 'userProfile';
  static const String userSettings = 'userSettings';
  static const String userProfileEdit = 'userProfileEdit';
}

abstract final class AppRoutePaths {
  const AppRoutePaths._();

  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String profileSetup = '/profile/setup';
  static const String terms = '/terms/privacy';
  static const String placeInvitations = '/places/invitations';
  static const String placeCreate = '/places/new';
  static const String addressSearch = '/places/new/address-search';
  static const String placeFriendAdd = '/places/new/friends';
  static const String placeEdit = '/places/:placeId/edit';
  static const String placeDetail = '/places/:placeId';
  static const String friendManagement = '/places/:placeId/friends';
  static const String plantSearch = '/plants/new/search';
  static const String plantCreateDetails = '/plants/new/details';
  static const String plantEdit = '/plants/:plantId/edit';
  static const String plantDetail = '/plants/:plantId';
  static const String memoWrite = '/plants/:plantId/memos/new';
  static const String memoList = '/plants/:plantId/memos';
  static const String userProfile = '/me';
  static const String userSettings = '/me/settings';
  static const String userProfileEdit = '/me/edit';

  static String loginLocation({String? redirect}) {
    if (redirect == null || redirect.isEmpty) {
      return login;
    }

    return Uri(path: login, queryParameters: {'redirect': redirect}).toString();
  }

  static String onboardingLocation({String? redirect}) {
    if (redirect == null || redirect.isEmpty) {
      return onboarding;
    }

    return Uri(
      path: onboarding,
      queryParameters: {'redirect': redirect},
    ).toString();
  }

  static String termsLocation({String? next}) {
    if (next == null) {
      return terms;
    }

    return Uri(path: terms, queryParameters: {'next': next}).toString();
  }

  static String placeEditLocation(String placeId) {
    return '/places/${Uri.encodeComponent(placeId)}/edit';
  }

  static String placeFriendAddLocation(String placeCode) {
    return Uri(
      path: placeFriendAdd,
      queryParameters: {'placeCode': placeCode},
    ).toString();
  }

  static String placeDetailLocation(String placeId) {
    return '/places/${Uri.encodeComponent(placeId)}';
  }

  static String friendManagementLocation(String placeId) {
    return '/places/${Uri.encodeComponent(placeId)}/friends';
  }

  static String plantEditLocation(String plantId, {String? placeId}) {
    final path = '/plants/${Uri.encodeComponent(plantId)}/edit';

    if (placeId == null) {
      return path;
    }

    return Uri(path: path, queryParameters: {'placeId': placeId}).toString();
  }

  static String plantDetailLocation(String plantId, {String? placeId}) {
    final path = '/plants/${Uri.encodeComponent(plantId)}';

    if (placeId == null) {
      return path;
    }

    return Uri(path: path, queryParameters: {'placeId': placeId}).toString();
  }

  static String memoWriteLocation(String plantId) {
    return '/plants/${Uri.encodeComponent(plantId)}/memos/new';
  }

  static String memoListLocation(String plantId) {
    return '/plants/${Uri.encodeComponent(plantId)}/memos';
  }
}
