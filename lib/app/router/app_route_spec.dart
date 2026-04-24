enum AppRouteImplementation { implemented, placeholder }

class AppRouteSpec {
  const AppRouteSpec({
    required this.name,
    required this.path,
    required this.title,
    required this.figmaFrames,
    this.implementation = AppRouteImplementation.placeholder,
  });

  final String name;
  final String path;
  final String title;
  final List<String> figmaFrames;
  final AppRouteImplementation implementation;
}
