import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../aps_route/aps_route_descriptor.dart';
import '../aps_route/aps_route_matcher.dart';
import '../aps_route/route_data.dart';
import '../aps_snapshot.dart';
import '../helpers.dart';
import '../parser/aps_parser_data.dart';
import 'aps_push_param.dart';

/// Class that allows navigation control.
///
class APSController extends ChangeNotifier {
  /// Global key set to the [Navigator] instance created internally by [APSNavigator].
  final navigatorKey = GlobalKey<NavigatorState>();

  /// Router matcher.
  final ApsRouteMatcher routerMatcher;

  /// First snapshot created by this controller.
  ApsSnapshot initialSnapshot;

  /// Snapshot used to create the current route/page stack.
  ApsSnapshot currentSnapshot;

  /// Shortcut to `currentConfig.topConfiguration`.
  ApsRouteDescriptor get currentConfig => currentSnapshot.topConfiguration;

  /// List of pages used by [APSNavigator] to populate its internal [Navigator]'s page list.
  List<Page> get pages => List.unmodifiable(_buildPagesUsingCurrentConfig());

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

  /// Pushes a new page to the top.
  ///
  /// [path] should match one of those templates configured when creating the [APSNavigator] instance.
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
  /// The following navigates to: **"/static_url_example"**.
  ///
  /// ```dart
  /// APSNavigator.of(context).push(
  ///   path: '/static_url_example',
  ///   params: {'tab': 'authors'},
  /// );
  /// ```
  ///
  ///
  /// The following navigates to: **"/dynamic_url_example?tab=authors"**.
  ///
  /// ```dart
  /// APSNavigator.of(context).push(
  ///   path: '/dynamic_url_example',
  ///   params: {'tab': 'authors'},
  /// );
  /// ```
  ///
  ///
  /// The following navigates to: **"/posts/10"**.
  ///
  /// ```dart
  /// APSNavigator.of(context).push(
  ///   path: '/posts/10',
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

  /// Pop top [Page]
  ///
  /// The result returned by the page is returned as expected:
  /// ```dart
  /// final result = await APSNavigator.of(context).push(
  ///     path: '...',
  /// );
  /// ```
  ///
  /// But if the User uses the web history to go back to a page that pops a result,
  /// the result is returned at `didUpdateWidget`. E.g.:
  /// ```dart
  /// @override
  /// void didUpdateWidget(HomePage oldWidget) {
  ///   super.didUpdateWidget(oldWidget);
  ///   final params = APSNavigator.of(context).currentConfig.values;
  ///   result = params['result'] as String?;
  ///   if (result != null) _showSnackBar(result!);
  /// }
  /// ```
  ///
  bool pop<T extends Object>([T? result]) {
    final noPagesToPop = currentSnapshot.routesDescriptors.length <= 1;
    if (noPagesToPop) return false;

    final d = currentSnapshot.routesDescriptors.removeLast();

    if (currentSnapshot.popWasRestored) {
      final newTop = currentSnapshot.topConfiguration;
      newTop.values['result'] = result;
    } else {
      d.popCompleter.complete(result);
    }

    notifyListeners();

    return true;
  }

  /// Pushes a list of Pages at the specified position.
  ///
  /// [position] should be in the range: [0 <= position <= [apsController.pages.length]].
  /// if no [position] is given, the list will be added at the top of the current Page Stack.
  ///
  /// ```dart
  /// APSNavigator.of(context).pushAll(
  ///   position: ..,
  ///   list: [
  ///     ApsPushParam(path: '/a', params: {'p1': 1}),
  ///     ApsPushParam(path: '/b'),
  ///     ApsPushParam(path: '/c', params: {'number': 3}),
  ///     ApsPushParam(path: '/d', params: {'any_other': 'asdf'}),
  ///   ],
  /// );
  /// ```
  ///
  void pushAll({int? position, required List<ApsPushParam> list}) {
    final desc = currentSnapshot.routesDescriptors;

    // Check for valid a position
    if (position != null) {
      final isPositionValid = position >= 0 && position <= desc.length - 1;
      final msg = 'Trying to push List of Pages at invalid position: $position';
      if (!isPositionValid) throw msg;
    }

    final pushAt = position ?? desc.length;
    final descriptionListToAdd = list.map(
      (lp) => _createDescriptorFrom(lp.path, lp.params),
    );

    desc.insertAll(pushAt, descriptionListToAdd);
    notifyListeners();
  }

  /// It navigates back to the Root (the route provided to [APSNavigator.from.initialRoute]).
  ///
  /// It won't call the [PopCompleter] of the pages above it.
  ///
  void backToRoot() {
    final curLocation = currentSnapshot.topConfiguration.location;
    final initialLocation = initialSnapshot.topConfiguration.location;
    final isAlreadyAtRoot = curLocation == initialLocation;
    if (isAlreadyAtRoot) return;

    currentSnapshot = initialSnapshot.clone();
    notifyListeners();
  }

  /// Removes a range of Pages from the Page Stack.
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

    if (start < 0 || end >= desc.length) {
      throw 'Trying to use an invalid range when removing Pages';
    }

    desc.removeRange(start, end);
    notifyListeners();
  }

  /// It requests the Browser to update its address bar based on the given params.
  ///
  /// Example, given a route templated configured as `'/dynamic_url_example{?tab}'`,
  /// the following generates: **"baseURL?tab=books"** or **"baseURL?tab=authors"**.
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

    _forceBrowserUpdateURL();
  }

  /// Configures this [ApsController] instance to use an [ApsSnapshot] created based on the given [configuration].
  ///
  /// [configuration] is usually an [ApsParserData] that was created by the browser or recovered from its history.
  void browserSetNewConfiguration(ApsParserData configuration) {
    if (configuration.location == '/') {
      backToRoot();
      return;
    }

    if (configuration.hasPageDescriptorsAvailableFromWebHistory) {
      // load all descriptors and create a new Snapshot from them
      final descriptors = configuration.descriptorsJsons
          .map((j) => ApsRouteDescriptor.fromJson(j))
          .toList();

      currentSnapshot = ApsSnapshot(
        routesDescriptors: descriptors,
        popWasRestored: true,
      );
      notifyListeners();
    } else {
      // build a new descriptor and upate the current Snapshot
      final location = configuration.location;
      final template = routerMatcher.getTemplateForRoute(location)!;
      final params = routerMatcher.getValuesFromRoute(location);

      final descriptorToAdd = ApsRouteDescriptor(
        location: location,
        template: template,
        values: params,
      );

      currentSnapshot.routesDescriptors.add(descriptorToAdd);
      currentSnapshot.popWasRestored =
          configuration.isUserOpeningAppForTheFirstTime;

      notifyListeners();
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

  void _forceBrowserUpdateURL({VoidCallback? callback}) {
    Router.navigate(buildContext, callback ?? () {});
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
