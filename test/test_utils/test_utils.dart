import 'package:aps_navigator/src/aps_route/aps_route_descriptor.dart';

abstract class TestUtils {
  static List<String> createDescriptorsJson({required String top}) {
    return [
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
        location: top,
        template: '/path/to/something{?tab,other}',
        values: const {'tab': '1', 'other': '2'},
      )
    ].map((d) => d.toJson()).toList();
  }
}
