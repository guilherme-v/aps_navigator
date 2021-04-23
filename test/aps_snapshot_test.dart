import 'package:aps_navigator/src/aps_route/aps_route_descriptor.dart';
import 'package:aps_navigator/src/aps_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final routesDescriptors = [
    ApsRouteDescriptor(template: '/', location: '/'),
    ApsRouteDescriptor(template: '/abc', location: '/abc'),
    ApsRouteDescriptor(template: '/{var1}', location: '/value_1'),
  ];

  test('it should be able to create a new instance properly', () {
    // arrange
    final data = ApsSnapshot(routesDescriptors: routesDescriptors);

    // asserts
    expect(data.routesDescriptors, routesDescriptors);
    expect(data.descriptorsWereLoadedFromBrowserHistory, isFalse);
    expect(data.topConfiguration, routesDescriptors.last);
    expect(data.rootConfiguration, routesDescriptors.first);

    final parseData = data.toApsParserData();
    expect(parseData.location, data.topConfiguration.location);
    expect(
      parseData.descriptorsJsons,
      data.routesDescriptors.map((d) => d.toJson()).toList(),
    );

    final clone = data.clone();
    expect(clone.routesDescriptors, data.routesDescriptors);
    expect(
      clone.descriptorsWereLoadedFromBrowserHistory,
      data.descriptorsWereLoadedFromBrowserHistory,
    );
  });
}
