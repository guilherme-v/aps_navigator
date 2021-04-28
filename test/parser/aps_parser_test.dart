import 'package:aps_navigator/aps_navigator.dart';
import 'package:aps_navigator/src/aps_route/aps_route_descriptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const loc = 'path/to/something?tab=1&other=2';
  final descriptors = [
    ApsRouteDescriptor(location: '/a', template: '/a', values: const {}),
    ApsRouteDescriptor(location: '/a/b', template: '/a/b', values: const {}),
    ApsRouteDescriptor(
      location: '/a/b/c',
      template: '/a/b/{var2}',
      values: const {'var2': 'c'},
    ),
    ApsRouteDescriptor(
      location: '/a/b/c/d?x=1&z=2',
      template: '/a/b/{var2}/d{?x,y}',
      values: const {'var2': 'c'},
    ),
    ApsRouteDescriptor(
      location: loc,
      template: '/path/to/something{?tab,other}',
      values: const {'tab': '1', 'other': '2'},
    )
  ].map((d) => d.toJson()).toList();

  final configuration = ApsParserData(
    location: loc,
    descriptorsJsons: descriptors,
  );

  test('it should be able to restore RouteInformation properly', () async {
    // arrange
    const parser = APSParser();

    // asserts
    final routeInfo = parser.restoreRouteInformation(configuration);
    expect(routeInfo.location, configuration.location);
    expect(routeInfo.state, {'descriptors': configuration.descriptorsJsons});
  });

  test('it should be able to parse RouteInformation properly', () async {
    // arrange
    const parser = APSParser();
    final routeInfo = parser.restoreRouteInformation(configuration);

    // asserts
    final apsData = await parser.parseRouteInformation(routeInfo);
    expect(apsData.location, loc);
    expect(apsData.descriptorsJsons, descriptors);
  });
}
