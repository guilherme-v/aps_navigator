import 'package:aps_navigator/aps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final location = 'path/path2/abc?tab=0';

  test('it should be able to create a new instance with default values', () {
    // arrange
    final data = ApsParserData(
      location: location,
    );

    // asserts
    expect(data.location, location);
    expect(data.descriptorsJsons, const []);
  });

  test('it should be able to create a new instance with values != from default',
      () {
    // arrange
    final descriptorsJsons = ['a', 'b', 'c'];

    final data = ApsParserData(
      location: location,
      descriptorsJsons: descriptorsJsons,
    );

    // asserts
    expect(data.location, location);
    expect(listEquals(data.descriptorsJsons, descriptorsJsons), isTrue);
  });
}
