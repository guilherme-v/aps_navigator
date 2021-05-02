import 'package:aps_navigator/src/aps_route/route_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('it should be able to create a new instance containing default values',
      () {
    // arrange
    const data = RouteData(location: '/path/abc?tab=0');

    // asserts
    expect(data.location, '/path/abc?tab=0');
    expect(data.values, const {});
  });

  test('it should be able to create a new instance with values != from default',
      () {
    // arrange
    final Map<String, dynamic> values = {'a': 1, 'b': 'abc', 'd': 1.2};
    final data = RouteData(location: '/path/abc?tab=0', values: values);

    // asserts
    expect(data.location, '/path/abc?tab=0');
    expect(mapEquals(data.values, values), isTrue);
  });
}
