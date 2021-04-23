import 'aps_route/aps_route_descriptor.dart';
import 'parser/aps_parser_data.dart';

class ApsSnapshot<T> {
  final List<ApsRouteDescriptor> routesDescriptors;
  final bool descriptorsWereLoadedFromBrowserHistory;

  ApsRouteDescriptor get topConfiguration => routesDescriptors.last;

  ApsRouteDescriptor get rootConfiguration => routesDescriptors.first;

  ApsSnapshot({
    required this.routesDescriptors,
    this.descriptorsWereLoadedFromBrowserHistory = false,
  });

  ApsParserData toApsParserData() {
    return ApsParserData(
      location: topConfiguration.location,
      descriptorsJsons: routesDescriptors.map((d) => d.toJson()).toList(),
    );
  }

  ApsSnapshot clone() {
    return ApsSnapshot(
      routesDescriptors: routesDescriptors.map((d) => d.copyWith()).toList(),
      descriptorsWereLoadedFromBrowserHistory:
          this.descriptorsWereLoadedFromBrowserHistory,
    );
  }
}
