import 'package:flutter/material.dart';

/// Defines a Route Builder function.
///
/// [RouteData] contains data about the current location that can be used the create the [Page].
///
/// This type is used usually to configure [ApsNavigator.from.route]. E.g.:
///
/// ```dart
/// // 1 - Create the navigation and the route
/// final navigator = APSNavigator.from(
///   routes: {
///     '/static_url_example': // [ApsRouteBuilderFunction]...
///   }
/// )
/// ```
///
typedef ApsRouteBuilderFunction = Page<dynamic> Function(
  RouteData data,
);

/// It contains information about the current route being created.
///
/// [location] represents the current location being build (path + queries). E.g.: `/path/abc?tab=0`
///
/// [values] is a map containing all values extracted from [location] variables. E.g.:
/// * Given the route template: `/path/{var1}/abc/?{?tab}`
/// * And the following location: `/path/post_a/abc/?tab=0`
/// * [values] will contains: `{'var1': 'post_a', 'tab': 0}`
///
class RouteData {
  final Map<String, dynamic> values;
  final String location;

  const RouteData({
    required this.location,
    this.values = const {},
  });
}
