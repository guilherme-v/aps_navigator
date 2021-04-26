import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'aps_parser_data.dart';

/// [APSNavigator] instance of [RouteInformationParser<T>]
class APSParser extends RouteInformationParser<ApsParserData> {
  const APSParser();
  static const _descriptorsKey = 'descriptors';

  @override
  Future<ApsParserData> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    final ApsParserData data = ApsParserData(
      location: routeInformation.location ?? '/',
    );

    final isANewConfigCreatedByBrowser = routeInformation.state == null;
    if (!isANewConfigCreatedByBrowser) {
      final loadedState = routeInformation.state! as Map<String, dynamic>;
      data.descriptorsJsons = (loadedState[_descriptorsKey] as List)
          .map((e) => e as String)
          .toList();
    }

    return SynchronousFuture(data);
  }

  @override
  RouteInformation restoreRouteInformation(
    ApsParserData configuration,
  ) {
    final Map<String, dynamic> stateToSave = {
      _descriptorsKey: configuration.descriptorsJsons
    };

    final routeInfo = RouteInformation(
      location: configuration.location,
      state: stateToSave,
    );

    return routeInfo;
  }
}
