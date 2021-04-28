import 'package:aps_navigator/aps_navigator.dart';

import 'aps_route/aps_route_descriptor.dart';

abstract class Helpers {
  static String mergeLocationAndQueries(
    String plainPath,
    Map<String, dynamic> queries,
  ) {
    final pathWithParams = StringBuffer();
    pathWithParams.write(plainPath);

    // Add '?' if needed
    if (queries.isNotEmpty) {
      pathWithParams.write('?');
    }

    // Add all 'param=value&' queries
    for (final entry in queries.entries) {
      pathWithParams.write('${entry.key}=${entry.value}&');
    }

    // remove any trailing '&'
    var locAndQueries = pathWithParams.toString();
    if (locAndQueries.endsWith("&")) {
      locAndQueries = locAndQueries.substring(0, locAndQueries.length - 1);
    }

    return locAndQueries;
  }

  static String locationWithoutQueries(String path) {
    var queryStartAt = path.indexOf('?');
    if (queryStartAt == -1) queryStartAt = path.length;
    return path.substring(0, queryStartAt);
  }

  static ApsRouteDescriptor createDescriptorFrom({
    required String path,
    required Map<String, dynamic> queries,
    required ApsRouteMatcher routerMatcher,
  }) {
    final plainLocation = Helpers.locationWithoutQueries(path);

    // try to find a routeFunction to merged Path+Params
    var location = Helpers.mergeLocationAndQueries(plainLocation, queries);
    var template = routerMatcher.getTemplateForRoute(location);

    // if not found, fallback to find a template to Path only
    if (template == null) {
      location = path;
      template = routerMatcher.getTemplateForRoute(path);
    }

    // at least one template should be found at this point
    if (template == null) throw 'Invalid path';

    // add queries with dynamic values first
    // then add location values (all as string), allowing it to override any query with same key
    final values = <String, dynamic>{}
      ..addAll(queries)
      ..addAll(routerMatcher.getValuesFromRoute(location));

    return ApsRouteDescriptor(
      location: location,
      template: template,
      values: values,
    );
  }
}
