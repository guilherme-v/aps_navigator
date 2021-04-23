import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../aps_route/aps_route_build_function.dart';
import '../aps_route/aps_route_descriptor.dart';
import '../aps_route/aps_route_matcher.dart';
import '../aps_snapshot.dart';
import '../controller/aps_controller.dart';
import '../controller/aps_inherited_controller.dart';
import '../helpers.dart';
import '../parser/aps_parser.dart';
import '../parser/aps_parser_data.dart';

///
/// APS implementation of [RouterDelegate].
///
/// It:
/// - Creates an internal [Navigator] Widget and handles it's [Pages] updates.
/// - Manages System Back Button events, popping [Pages] when needed.
/// - Receives URLs from browsers, parses any params, and pushes the proper route.
///
/// How to use it:
/// ```dart
/// // 1 - Creates a Navigator.
/// final navigator = APSNavigator.from(
///    routeBuilders: {
///      '/': HomePage.route,
///      '/posts/{post_id}': PostPage.route,
///      '/bottom_nav_2{?query_val1,query_val2,...}': BottomNavPage.route,
///      '...': ...
///    }
/// );
///
/// // 2 - Use it when creating a [Router]. Remember to include a [APSParser] too.
/// @override
/// Widget build(BuildContext context) {
///   return MaterialApp.router(
///     routeInformationParser: navigator.parser,
///     routerDelegate: navigator,
///   );
/// }
///
/// // 3 - Prepare your Widget to be used as a Route.
/// //
/// // It should return any Widget that extends a Page<T>.
/// // Recommendation is to use a Key to avoid problems.
/// class HomePage extends StatefulWidget {
///  HomePage({Key? key}) : super(key: key);
///
///  @override
///  _HomePageState createState() => _HomePageState();
///
///  // You don't need to use a static method here, but it's a nice way of organizing things.
///  static Page route({Map<String, dynamic>? params}) {
///    return MaterialPage(
///      key: ValueKey('Home'), // Always include a key
///      child: HomePage(),
///    );
///  }
/// }
/// ```
class APSNavigator extends RouterDelegate<ApsParserData> {
  final APSController controller;
  final APSNavigator? parentNavigator;
  final List<Page<dynamic>> _blankPage = [MaterialPage(child: Container())];

  APSNavigator._({
    required this.controller,
    this.parentNavigator,
  });

  /// Default APSParser used by all APSNavigator instances.
  APSParser get parser => const APSParser();

  /// Should be used when creating a child navigator.
  ///
  /// Use this to configure te [Router]'s [backButtonDispatcher] property.
  ///
  /// IMPORTANT: Before using it, you should call [interceptBackButton] on State's [didChangeDependencies] method:
  ///
  ///```dart
  /// final childNavigator = APSNavigator.from(
  ///   parentNavigator: navigator,
  ///   //...
  /// );
  ///
  ///  @override
  ///  void didChangeDependencies() {
  ///    super.didChangeDependencies();
  ///    childNavigator.interceptBackButton(context);
  ///  }
  ///
  ///  @override
  ///  Widget build(BuildContext context) {
  ///    return Router(
  ///      routerDelegate: childNavigator,
  ///      backButtonDispatcher: childNavigator.backButtonDispatcher,
  ///    );
  ///  }
  BackButtonDispatcher? backButtonDispatcher;

  /// Returns the [context] closest [APSController] instance
  static APSController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<APSInheritedController>()!
      .controller;

  /// Makes this navigator intercept Back Button Events.
  ///
  /// It's only necessary when you're using Child Navigators, and you should use it together with [backButtonDispatcher].
  ///
  ///```dart
  /// final childNavigator = APSNavigator.from(
  ///   parentNavigator: navigator,
  ///   //...
  /// );
  ///
  ///  @override
  ///  void didChangeDependencies() {
  ///    super.didChangeDependencies();
  ///    childNavigator.interceptBackButton(context);
  ///  }
  ///
  ///  @override
  ///  Widget build(BuildContext context) {
  ///    return Router(
  ///      routerDelegate: childNavigator,
  ///      backButtonDispatcher: childNavigator.backButtonDispatcher,
  ///    );
  ///  }
  ///```
  void interceptBackButton(BuildContext context) {
    backButtonDispatcher = Router.of(context)
        .backButtonDispatcher!
        .createChildBackButtonDispatcher();
  }

  ///
  /// Creates and configures a new APSNavigator instance properly.
  ///
  /// Use [initialRoute] to set the first path to be opened. You can configure
  /// its initial parameters using [initialParams].
  ///
  /// [routes] defines the relation between routes addresses and widgets that
  /// should be created. [APSNavigator] will match variables both in addresses
  /// paths and query params:
  ///
  /// Example of addresses that can be used in [routeBuilders]:
  ///
  /// ```dart
  /// // no path or query variable
  /// '/posts': PostListPage.route,
  ///
  /// // path variable
  /// '/posts/{post_id}': PostListItemPage.route,
  ///
  /// // queries variable
  /// '/bottom_nav{?var1,var2}': BottomNavPage.route,
  ///
  /// ```
  ///
  factory APSNavigator.from({
    String initialRoute = '/',
    Map<String, dynamic> initialParams = const {},
    required Map<String, ApsRouteBuilderFunction> routes,
    APSNavigator? parentNavigator,
  }) {
    final routerMatcher = ApsRouteMatcher(routes);

    final initialRouteDescriptor = Helpers.createDescriptorFrom(
      path: initialRoute,
      queries: initialParams,
      routerMatcher: routerMatcher,
    );

    final initialConfiguration = ApsSnapshot(
      routesDescriptors: [initialRouteDescriptor],
    );

    final controller = APSController.from(
      initialConfiguration: initialConfiguration,
      routerMatcher: routerMatcher,
    );

    return APSNavigator._(
      controller: controller,
      parentNavigator: parentNavigator,
    );
  }

  @override
  ApsParserData? get currentConfiguration {
    // Child navigators won't report back to browser history
    final isAChildNavigator = parentNavigator != null;
    if (isAChildNavigator) return null;

    return controller.currentSnapshot.toApsParserData();
  }

  @override
  Future<bool> popRoute() {
    return controller.navigatorKey.currentState!.maybePop();
  }

  @override
  Future<void> setInitialRoutePath(ApsParserData _) {
    return setNewRoutePath(controller.initialSnapshot.toApsParserData());
  }

  @override
  Future<void> setNewRoutePath(ApsParserData configuration) {
    if (configuration.location == '/') {
      controller.backToRoot();
      return SynchronousFuture(true);
    }

    if (configuration.isANewConfigCreatedByBrowser) {
      // build and push a new descriptor
      final matcher = controller.routerMatcher;

      final location = configuration.location;
      final template = matcher.getTemplateForRoute(location)!;
      final params = matcher.getValuesFromRoute(location);

      final descriptorToAdd = ApsRouteDescriptor(
        location: location,
        template: template,
        values: params,
      );

      controller.browserPushDescriptor(descriptorToAdd);
    } else {
      // load all the previous descriptors available
      final descriptors = configuration.descriptorsJsons
          .map((j) => ApsRouteDescriptor.fromJson(j))
          .toList();

      controller.browserLoadDescriptors(descriptors);
    }

    return SynchronousFuture(true);
  }

  @override
  Widget build(BuildContext context) {
    if (backButtonDispatcher != null) backButtonDispatcher!.takePriority();

    return APSInheritedController(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext buildContext, Widget? _) {
          controller.buildContext = buildContext;
          final pages = controller.pages;
          return Navigator(
            key: controller.navigatorKey,
            pages: pages.isNotEmpty ? pages : _blankPage,
            onPopPage: (route, result) {
              if (!route.didPop(result)) {
                return false;
              }
              controller.pop();
              return true;
            },
          );
        },
      ),
    );
  }

  @override
  void addListener(listener) => controller.addListener(listener);

  @override
  void removeListener(listener) => controller.removeListener(listener);
}
