import 'package:aps_navigator/aps_navigator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const location = 'path/path2/abc?tab=0';

  test('it should be able to create a new instance with default values', () {
    // arrange
    final data = ApsPushParam(
      path: location,
    );

    // asserts
    expect(data.path, location);
    expect(data.params, const {});
  });

  test('it should be able to create a new instance with values != from default',
      () {
    // arrange
    final Map<String, dynamic> values = {'a': 1, 'b': 'abc', 'd': 1.2};

    final data = ApsPushParam(
      path: location,
      params: values,
    );

    // asserts
    expect(data.path, location);
    expect(mapEquals(data.params, values), isTrue);
  });
}
