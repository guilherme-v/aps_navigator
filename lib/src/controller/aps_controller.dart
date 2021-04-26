import 'package:flutter/widgets.dart';

import '../aps_route/aps_route_build_function.dart';
import '../aps_route/aps_route_descriptor.dart';
import '../aps_route/aps_route_matcher.dart';
import '../aps_snapshot.dart';
import '../helpers.dart';
import '../parser/aps_parser_data.dart';
import 'aps_push_param.dart';

class APSController extends ChangeNotifier {
  /// Global key used by the [Navigator] instance created internally by [APSNavigator].
  final navigatorKey = GlobalKey<NavigatorState>();

  /// Router matcher.
  final ApsRouteMatcher routerMatcher;

  ApsSnapshot initialSnapshot;

  /// Configuration currently used to recreate the [APSNavigator] page's list.
  ApsSnapshot currentSnapshot;

  /// List of pages used by [APSNavigator] to populate its [Navigator] instance.
  List<Page> get pages => List.unmodifiable(_buildPagesUsingCurrentConfig());

  ApsRouteDescriptor get currentConfig => currentSnapshot.topConfiguration;

  /// BuildContext was used to build this APSController instance.
  late BuildContext buildContext;

  APSController._(this.initialSnapshot, this.routerMatcher)
      : currentSnapshot = initialSnapshot.clone();

  ///
  /// Creates a new [APSController] given an [initialConfiguration] configuration.
  ///
  factory APSController.from({
    required ApsRouteMatcher routerMatcher,
    required ApsSnapshot initialConfiguration,
  }) {
    return APSController._(initialConfiguration, routerMatcher);
  }

  ///
  /// Pushes a new page to the top.
  ///
  /// The [path] should match one of those configured when creating the [APSNavigator].
  ///
  /// Example:
  ///
  /// Given the following navigator:
  ///
  /// ```dart
  /// final navigator = APSNavigator.from(
  ///   initialRoute: "/",
  ///   routes: {
  ///     '/static_url_example': StaticURLPage.route,
  ///     '/dynamic_url_example{?tab}': DynamicURLPage.route,
  ///     '/posts/{post_id}': PostDetailsPage.route,
  ///   },
  /// );
  ///```
  ///
  /// The following results in **"/static_url_example"**.
  ///
  /// ```dart
  /// APSNavigator.of(context).push(
  ///   path: '/static_url_example',
  ///   params: {'tab': 'authors'},
  /// );
  /// ```
  ///
  ///
  /// The following results in only **"/dynamic_url_example?tab=authors"**.
  ///
  /// ```dart
  /// APSNavigator.of(context).push(
  ///   path: '/dynamic_url_example',
  ///   params: {'tab': 'authors'},
  /// );
  /// ```
  ///
  ///
  /// The following results in only **"/posts/10"**.
  ///
  /// ```dart
  /// APSNavigator.of(context).push(
  ///   path: '/posts/10',
  ///   params: {'post_id': 10},
  /// );
  /// ```
  ///
  Future<T> push<T>({
    required String path,
    Map<String, dynamic> params = const {},
  }) {
    final descriptorToAdd = _createDescriptorFrom(path, params);

    currentSnapshot.routesDescriptors.add(descriptorToAdd);
    notifyListeners();

    return descriptorToAdd.popCompleter.future as Future<T>;
  }

  void pushAll({int? position, required List<ApsPushParam> list}) {
    final desc = currentSnapshot.routesDescriptors;

    // Check for valid a position
    if (position != null) {
      final isPositionValid = position >= 0 || position <= desc.length - 1;
      final msg = 'Trying to push List at invalid position: $position';
      if (!isPositionValid) throw msg;
    }

    final pushAt = position ?? desc.length;
    final descriptionListToAdd = list.map(
      (lp) => _createDescriptorFrom(lp.path, lp.params),
    );

    desc.insertAll(pushAt, descriptionListToAdd);
    notifyListeners();
  }

  ///
  /// Returns until the root page.
  ///
  void backToRoot() {
    final curLocation = currentSnapshot.topConfiguration.location;
    final initialLocation = initialSnapshot.topConfiguration.location;
    final isAlreadyAtRoot = curLocation == initialLocation;
    if (isAlreadyAtRoot) return;

    currentSnapshot = initialSnapshot.clone();
    notifyListeners();
  }

  ///
  /// Pop top
  ///
  bool pop<T extends Object>([T? result]) {
    final noPagesToPop = currentSnapshot.routesDescriptors.length <= 1;
    if (noPagesToPop) return false;

    final d = currentSnapshot.routesDescriptors.removeLast();

    if (currentSnapshot.descriptorsWereLoadedFromBrowserHistory) {
      final nextTop = currentSnapshot.topConfiguration;
      nextTop.values['result'] = result;
    } else {
      d.popCompleter.complete(result);
    }

    notifyListeners();

    return true;
  }

  /// Removes a range of Pages from stack history.
  ///
  /// Removes the elements with positions greater than or equal to [start]
  /// and less than [end], from the list.
  /// This reduces the list's length by `end - start`.
  ///
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if 0 ≤ `start` ≤ `end` ≤ [length].
  /// An empty range (with `end == start`) is valid.
  ///
  void removeRange({required int start, required int end}) {
    final desc = currentSnapshot.routesDescriptors;

    if (start < 0 || end >= desc.length - 1) throw 'Invalid range';

    desc.removeRange(start, end);
    notifyListeners();
  }

  ///
  /// Updates the current route params.
  ///
  /// Example, the follows generates: **"baseURL?tab=books"** or **"baseURL?tab=authors"**.
  ///
  /// ```dart
  ///  final aps = APSNavigator.of(context);
  ///  aps.updateParams(
  ///    params: {'tab': index == 0 ? 'books' : 'authors'},
  ///  );
  /// ```
  ///
  void updateParams({required Map<String, dynamic> params}) {
    final desc = currentSnapshot.topConfiguration;
    final showsQueriesOnLocation = desc.location.contains('?');
    final plainLocation = Helpers.locationWithoutQueries(desc.location);

    final descriptorToAdd = desc.copyWith(
      values: params,
      location: showsQueriesOnLocation
          ? Helpers.mergeLocationAndQueries(plainLocation, params)
          : desc.location,
    );

    currentSnapshot.routesDescriptors.removeLast();
    currentSnapshot.routesDescriptors.add(descriptorToAdd);
    // notifyListeners();
    _forceBrowserUpdateURL();
  }

  void browserSetNewConfiguration(ApsParserData configuration) {
    if (configuration.location == '/') {
      backToRoot();
      return;
    }

    if (configuration.isANewConfigCreatedByBrowser) {
      // build and push a new descriptor
      final location = configuration.location;
      final template = routerMatcher.getTemplateForRoute(location)!;
      final params = routerMatcher.getValuesFromRoute(location);

      final descriptorToAdd = ApsRouteDescriptor(
        location: location,
        template: template,
        values: params,
      );

      _browserPushDescriptor(descriptorToAdd);
    } else {
      // load all the previous descriptors available
      final descriptors = configuration.descriptorsJsons
          .map((j) => ApsRouteDescriptor.fromJson(j))
          .toList();

      _browserLoadDescriptors(descriptors);
    }
  }

  // *
  // * Private helpers
  // *

  List<Page> _buildPagesUsingCurrentConfig() {
    final routeDescriptors = currentSnapshot.routesDescriptors;
    final pages = List<Page>.empty(growable: true);

    for (final d in routeDescriptors) {
      final builder = routerMatcher.getBuildFunctionForRoute(d.location);
      final data = RouteData(
        location: d.location,
        values: d.values,
      );
      final page = builder(data);
      pages.add(page);
    }

    return List.unmodifiable(pages);
  }

  void _forceBrowserUpdateURL() {
    Router.navigate(buildContext, () {});
  }

  void _browserPushDescriptor(ApsRouteDescriptor descriptor) {
    currentSnapshot.routesDescriptors.add(descriptor);
    notifyListeners();
  }

  void _browserLoadDescriptors(List<ApsRouteDescriptor> descriptors) {
    currentSnapshot = ApsSnapshot(
      routesDescriptors: descriptors,
      descriptorsWereLoadedFromBrowserHistory: true,
    );
    notifyListeners();
  }

  ApsRouteDescriptor _createDescriptorFrom(
    String path,
    Map<String, dynamic> params,
  ) {
    return Helpers.createDescriptorFrom(
      path: path,
      queries: params,
      routerMatcher: routerMatcher,
    );
  }
}
