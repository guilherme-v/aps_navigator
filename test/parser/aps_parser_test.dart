import 'package:aps_navigator/aps_navigator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils/test_utils.dart';

void main() {
  const loc = 'path/to/something?tab=1&other=2';
  final descriptors = TestUtils.createDescriptorsJson(top: loc);
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
    expect(routeInfo.state,
        {APSParser.descriptorsKey: configuration.descriptorsJsons});
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
