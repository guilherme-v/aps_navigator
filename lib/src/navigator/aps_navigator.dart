import 'dart:async';

import 'package:flutter/material.dart';

import '../aps_route/aps_route_matcher.dart';
import '../aps_route/route_data.dart';
import '../aps_snapshot.dart';
import '../controller/aps_controller.dart';
import '../controller/aps_inherited_controller.dart';
import '../helpers.dart';
import '../parser/aps_parser.dart';
import '../parser/aps_parser_data.dart';

/// The APS lib implementation of a [RouterDelegate].
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
/// class HomePage extends StatefulWidget {
///  HomePage({Key? key}) : super(key: key);
///
///  @override
///  _HomePageState createState() => _HomePageState();
///
///  // You don't need to use a static method here, but it's a nice way of organizing things.
///  static Page route({Map<String, dynamic>? params}) {
///    // * Important: AVOID using 'const' keyword at "MaterialPage" or "HomePage" levels,
///    // * or Pop may not work properly with Web History
///    return MaterialPage(
///      key: const ValueKey('Home'), //* Important: Always include a key here!
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

  /// Returns the [APSController] instance closest [context].
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
  /// // route template with no path or query variable
  /// '/posts': PostListPage.route,
  ///
  /// // route template with path variable
  /// '/posts/{post_id}': PostListItemPage.route,
  ///
  /// // route template with queries variable
  /// '/bottom_nav{?var1,var2}': BottomNavPage.route,
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
    // Child navigators won't report back to browser's history
    final isAChildNavigator = parentNavigator != null;
    if (isAChildNavigator) return null;

    return controller.currentSnapshot.toApsParserData();
  }

  @override
  Future<bool> popRoute() {
    return controller.navigatorKey.currentState!.maybePop();
  }

  @override
  Future<void> setInitialRoutePath(ApsParserData configuration) async {
    // 'setInitialRoutePath' is tricky,
    // Initial Route is any kind of route the triggered app opening.
    // - user opens the app normally
    // - user opens the app using an browser's history entry
    // - ...
    //
    return setNewRoutePath(
      configuration.copyWith(isUserOpeningAppForTheFirstTime: true),
    );
  }

  @override
  Future<void> setNewRoutePath(ApsParserData configuration) async {
    controller.browserSetNewConfiguration(configuration);
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
  void addListener(Function() listener) => controller.addListener(listener);

  @override
  void removeListener(Function() listener) =>
      controller.removeListener(listener);
}
