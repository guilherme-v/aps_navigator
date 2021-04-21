import 'aps_route/aps_route_descriptor.dart';
import 'parser/aps_parser_data.dart';

class ApsSnapshot<T> {
  List<ApsRouteDescriptor> routesDescriptors;

  ApsRouteDescriptor get topConfiguration => routesDescriptors.last;

  ApsRouteDescriptor get rootConfiguration => routesDescriptors.first;

  ApsSnapshot({
    required this.routesDescriptors,
  }); // TODO: passar em cada descriptor definindo que o anteriror é PopCompliter pq isso nao foi serializado

  ApsParserData toApsParserData() {
    return ApsParserData(
      location: topConfiguration.location,
      descriptorsJsons: routesDescriptors.map((d) => d.toJson()).toList(),
    );
  }
}
