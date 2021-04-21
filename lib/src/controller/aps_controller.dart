import 'package:flutter/widgets.dart';

import '../aps_route/aps_route_descriptor.dart';
import '../aps_route/aps_route_matcher.dart';
import '../aps_snapshot.dart';
import '../helpers.dart';

class APSController extends ChangeNotifier {
  /// Global key used by the [Navigator] instance created internally by [APSNavigator].
  final navigatorKey = GlobalKey<NavigatorState>();

  /// Router matcher.
  final ApsRouteMatcher routerMatcher;

  /// Configuration currently used to recreate the [APSNavigator] page's list.
  ApsSnapshot currentSnapshot;

  /// List of pages used by [APSNavigator] to populate its [Navigator] instance.
  List<Page> get pages => List.unmodifiable(_buildPagesUsingCurrentConfig());

  ApsRouteDescriptor get currentConfig => currentSnapshot.topConfiguration;

  /// BuildContext was used to build this APSController instance.
  late BuildContext buildContext;

  APSController._(ApsSnapshot initSnapshot, ApsRouteMatcher matcher)
      : this.routerMatcher = matcher,
        this.currentSnapshot = initSnapshot;

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
  /// APSNavigator.of(context).pushNamed(
  ///   path: '/static_url_example',
  ///   params: {'tab': 'authors'},
  /// );
  /// ```
  ///
  ///
  /// The following results in only **"/dynamic_url_example?tab=authors"**.
  ///
  /// ```dart
  /// APSNavigator.of(context).pushNamed(
  ///   path: '/dynamic_url_example',
  ///   params: {'tab': 'authors'},
  /// );
  /// ```
  ///
  ///
  /// The following results in only **"/posts/10"**.
  ///
  /// ```dart
  /// APSNavigator.of(context).pushNamed(
  ///   path: '/posts/10',
  ///   params: {'post_id': 10},
  /// );
  /// ```
  ///
  Future<T> pushNamed<T>({
    required String path,
    Map<String, dynamic> params = const {},
  }) {
    final plainLocation = Helpers.locationWithoutQueries(path);

    // try to find a routeFunction to merged Path+Params
    var location = Helpers.mergeLocationAndParams(plainLocation, params);
    var template = routerMatcher.getTemplateForRoute(location);

    // if not found, fallback to find a template to Path only
    if (template == null) {
      location = path;
      template = routerMatcher.getTemplateForRoute(path);
    }

    // at least one template should be found at this point
    if (template == null) throw 'Invalid path';

    final descriptorToAdd = ApsRouteDescriptor(
      location: location,
      template: template,
      params: params,
    );

    currentSnapshot.routesDescriptors.add(descriptorToAdd);
    notifyListeners();

    return descriptorToAdd.popCompleter.future as Future<T>;
  }

  ///
  /// Returns until the root page.
  ///
  void backToRoot() {
    final end = currentSnapshot.routesDescriptors.length;
    if (end < 1) return;

    currentSnapshot.routesDescriptors.removeRange(1, end);
    notifyListeners();
  }

  ///
  /// Used internally by APSNavigator, when the user types a new URL in the Browser.
  ///
  void browserPushDescriptor(ApsRouteDescriptor descriptor) {
    currentSnapshot.routesDescriptors.add(descriptor);
    notifyListeners();
  }

  ///
  /// Used internally, when the user types a new URL in the Browser.
  ///
  void browserLoadDescriptors(List<ApsRouteDescriptor> descriptors) {
    currentSnapshot = ApsSnapshot(routesDescriptors: descriptors);
    notifyListeners();
  }

  ///
  /// Pop top
  ///
  bool pop<T extends Object>([T? result]) {
    final noPagesToPop = currentSnapshot.routesDescriptors.length <= 1;
    if (noPagesToPop) return false;

    final d = currentSnapshot.routesDescriptors.removeLast();
    d.popCompleter.complete(result);
    notifyListeners();

    return true;
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
      params: params,
      location: showsQueriesOnLocation
          ? Helpers.mergeLocationAndParams(plainLocation, params)
          : desc.location,
    );

    currentSnapshot.routesDescriptors.removeLast();
    currentSnapshot.routesDescriptors.add(descriptorToAdd);
    notifyListeners();
    _forceBrowserUpdateURL();
  }

  List<Page> _buildPagesUsingCurrentConfig() {
    final routeDescriptors = currentSnapshot.routesDescriptors;
    final pages = List<Page>.empty(growable: true);

    for (var d in routeDescriptors) {
      final builder = routerMatcher.getBuildFunctionForRoute(d.location);
      final page = builder(params: d.params);
      pages.add(page);
    }

    return List.unmodifiable(pages);
  }

  void _forceBrowserUpdateURL() {
    Router.navigate(buildContext, () {});
  }
}
