import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:uri/uri.dart';

import 'aps_route_build_function.dart';

class ApsRouteMatcher {
  /// Map template URL -> builder
  final Map<String, ApsRouteBuilderFunction> mapToBuilders;

  ApsRouteMatcher(this.mapToBuilders);

  String? getTemplateForRoute(String route) {
    final uri = Uri.parse(route);
    final allTemplatesPatterns = _allPathsByPathLength();
    final pathShowsQuery = route.contains('?');

    for (final template in allTemplatesPatterns) {
      final patternDoNotShowsQueries = !template.contains('?');
      if (pathShowsQuery && patternDoNotShowsQueries) continue;

      final uriTemplate = UriTemplate(template);
      final parser = UriParser(uriTemplate, queryParamsAreOptional: true);
      final patternMatchesRoute = parser.matches(uri);

      if (patternMatchesRoute) {
        return template;
      }
    }

    return null;
  }

  Map<String, String> getValuesFromRoute(String route) {
    final uri = Uri.parse(route);
    final allPaths = _allPathsByPathLength();

    for (final pathPattern in allPaths) {
      final uriTemplate = UriTemplate(pathPattern);
      final parser = UriParser(uriTemplate);
      final templateMatchesRoute = parser.matches(uri);

      if (templateMatchesRoute) {
        final uriParams = parser.parse(uri);
        return uriParams;
      }
    }

    throw 'No route matches: $route';
  }

  ApsRouteBuilderFunction getBuildFunctionForRoute(String route) {
    final uri = Uri.parse(route);
    final allPathsPatterns = _allPathsByPathLength();
    final pathShowsQuery = route.contains('?');

    for (final pathPattern in allPathsPatterns) {
      final patternDoNotShowsQueries = !pathPattern.contains('?');
      if (pathShowsQuery && patternDoNotShowsQueries) continue;

      final uriTemplate = UriTemplate(pathPattern);
      final parser = UriParser(uriTemplate);
      final patternMatchesRoute = parser.matches(uri);

      if (patternMatchesRoute) {
        return mapToBuilders[pathPattern]!;
      }
    }

    throw 'No Builder Function matches: $route';
  }

  List<String> _allPathsByPathLength() {
    final templates = mapToBuilders.keys.toList();

    final groups = groupBy(templates, _quantityOfPathSegments)
      ..forEach((qntSeg, list) => list.sort(_sizeOfPath));

    final allPathsSorted = _mergeAndSortByPathSize(groups);

    return allPathsSorted;
  }

  int _quantityOfPathSegments(String template) => template.split('/').length;

  int _sizeOfPath(String a, String b) {
    final pathsOnA = a.length;
    final pathsOnB = b.length;
    return -1 * pathsOnA.compareTo(pathsOnB);
  }

  List<String> _mergeAndSortByPathSize(Map<int, List<String>> g) {
    final m = SplayTreeMap.from(g)
        .values
        .toList()
        .reversed
        .expand((e) => e as Iterable);

    return List<String>.from(m);
  }
}
