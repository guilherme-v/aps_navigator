import 'package:uri/uri.dart';

import 'aps_route_build_function.dart';

class ApsRouteMatcher {
  // template URL -> builder
  final Map<String, ApsRouteBuilderFunction> mapToBuilders;

  ApsRouteMatcher(this.mapToBuilders);

  String? getTemplateForRoute(String route) {
    final uri = Uri.parse(route);
    final allTemplatesPatterns = _allPathsByPathLength();
    final pathShowsQuery = route.contains('?');

    for (var template in allTemplatesPatterns) {
      final patternDoNotShowsQueries = !template.contains('?');
      if (pathShowsQuery && patternDoNotShowsQueries) continue;

      final uriTemplate = UriTemplate(template);
      final parser = UriParser(uriTemplate, queryParamsAreOptional: false);
      final patternMatchesRoute = parser.matches(uri);

      if (patternMatchesRoute) {
        return template;
      }
    }

    return null;
  }

  Map<String, dynamic> getParamsFromRoute(String route) {
    final uri = Uri.parse(route);
    final allPaths = _allPathsByPathLength();

    for (var pathPattern in allPaths) {
      final uriTemplate = UriTemplate(pathPattern);
      final parser = UriParser(uriTemplate, queryParamsAreOptional: false);
      final templateMatchesRoute = parser.matches(uri);

      if (templateMatchesRoute) {
        final uriParams = parser.match(uri)!.parameters;
        final params = Map<String, dynamic>.from(uriParams);
        return params;
      }
    }

    throw 'No route matches: $route';
  }

  ApsRouteBuilderFunction getBuildFunctionForRoute(String route) {
    final uri = Uri.parse(route);
    final allPathsPatterns = _allPathsByPathLength();
    final pathShowsQuery = route.contains('?');

    for (var pathPattern in allPathsPatterns) {
      final patternDoNotShowsQueries = !pathPattern.contains('?');
      if (pathShowsQuery && patternDoNotShowsQueries) continue;

      final uriTemplate = UriTemplate(pathPattern);
      final parser = UriParser(uriTemplate, queryParamsAreOptional: false);
      final patternMatchesRoute = parser.matches(uri);

      if (patternMatchesRoute) {
        return mapToBuilders[pathPattern]!;
      }
    }

    throw 'No Builder Function matches: $route';
  }

  List<String> _allPathsByPathLength() {
    final builders = mapToBuilders.keys.toList()
      ..sort((a, b) {
        final pathsOnA = a.split('/').length;
        final pathsOnB = b.split('/').length;
        return -1 * pathsOnA.compareTo(pathsOnB);
      });

    return builders;
  }
}
