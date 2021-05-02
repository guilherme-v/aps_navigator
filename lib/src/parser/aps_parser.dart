import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'aps_parser_data.dart';

/// [APSNavigator] instance of [RouteInformationParser<T>]
class APSParser extends RouteInformationParser<ApsParserData> {
  const APSParser();
  static const descriptorsKey = '_aps_pages_descriptors';

  @override
  Future<ApsParserData> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    var data = ApsParserData(
      location: routeInformation.location ?? '/',
    );

    final loadedState = routeInformation.state as Map<String, dynamic>? ?? {};
    final hasApsData = loadedState.containsKey(descriptorsKey);
    if (hasApsData) {
      data = data.copyWith(
        descriptorsJsons: (loadedState[descriptorsKey] as List)
            .map((e) => e as String)
            .toList(),
      );
    }

    return SynchronousFuture(data);
  }

  @override
  RouteInformation restoreRouteInformation(
    ApsParserData configuration,
  ) {
    final Map<String, dynamic> stateToSave = {
      descriptorsKey: configuration.descriptorsJsons
    };

    final routeInfo = RouteInformation(
      location: configuration.location,
      state: stateToSave,
    );

    return routeInfo;
  }
}
