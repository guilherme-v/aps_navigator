import 'dart:async';

import 'package:aps_navigator/src/aps_route/aps_route_descriptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final template = '/path/{var1}/abc/?{?tab}';
  final location = 'path/path2/abc?tab=0';

  test('it should be able to create a new instance with default values', () {
    // arrange
    final data = ApsRouteDescriptor(
      template: template,
      location: location,
    );

    // asserts
    expect(data.template, template);
    expect(data.location, location);
    expect(data.values, const {});
  });

  test('it should be able to create a new instance with values != from default',
      () {
    // arrange
    final Map<String, dynamic> values = {'a': 1, 'b': 'abc', 'd': 1.2};
    final completer = Completer();

    final data = ApsRouteDescriptor(
      template: template,
      location: location,
      values: values,
      completer: completer,
    );

    // asserts
    expect(data.template, template);
    expect(data.location, location);
    expect(mapEquals(data.values, values), isTrue);
    expect(data.popCompleter, completer);
  });
}
