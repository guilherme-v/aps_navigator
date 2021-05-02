import 'package:flutter/foundation.dart';

import 'aps_route/aps_route_descriptor.dart';
import 'parser/aps_parser_data.dart';

/// An [ApsSnapshot] can be used to (re)create the entire route stack at any moment.
///
/// A route stack is any stack of [Page]s that can be set [ApsController] and passed to
/// [ApsNavigator] to create its internal [Navigator] page list.
///
class ApsSnapshot<T> {
  /// List of Descriptors that the [APSController] will use to recreate the [Navigator]'s [Page] stack.
  final List<ApsRouteDescriptor> routesDescriptors;

  /// Signals if the [APSNavigator] had to restore the [popCompleter].
  ///
  /// It will be `true` if the User uses the web history to go back to a page that pops a result.
  ///
  /// And if this happens, the result will be returned in `current.config.values['result']`. E.g.:
  ///
  /// ```dart
  /// final params = APSNavigator.of(context).currentConfig.values;
  /// result = params['result'] as String?;
  /// ```
  bool popWasRestored;

  /// Configuration is used to create the current top Page that the user sees.
  ApsRouteDescriptor get topConfiguration => routesDescriptors.last;

  /// Configuration is used to create the root Page.
  ApsRouteDescriptor get rootConfiguration => routesDescriptors.first;

  ApsSnapshot({
    required this.routesDescriptors,
    this.popWasRestored = false,
  });

  /// Transform this [ApsSnapshot] instance in an instance of [ApsParserData] that can be serialized in the browser's
  /// web history.
  ApsParserData toApsParserData() {
    return ApsParserData(
      location: topConfiguration.location,
      descriptorsJsons: routesDescriptors.map((d) => d.toJson()).toList(),
    );
  }

  ApsSnapshot clone() {
    return ApsSnapshot(
      routesDescriptors: routesDescriptors.map((d) => d.copyWith()).toList(),
      popWasRestored: popWasRestored,
    );
  }

  @override
  String toString() =>
      'ApsSnapshot(routesDescriptors: $routesDescriptors, popWasRestored: $popWasRestored)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApsSnapshot<T> &&
        listEquals(other.routesDescriptors, routesDescriptors) &&
        other.popWasRestored == popWasRestored;
  }

  @override
  int get hashCode => routesDescriptors.hashCode ^ popWasRestored.hashCode;
}
