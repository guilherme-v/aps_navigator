import 'package:aps_navigator/aps_navigator.dart';
import 'package:aps_navigator/src/aps_route/aps_route_descriptor.dart';
import 'package:aps_navigator/src/aps_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils/test_utils.dart';

void main() {
  MaterialPage createBuilder(RouteData data) =>
      MaterialPage(child: Container());

  final routes = {
    '/static_url_example': createBuilder,
    '/dynamic_url_example{?tab}': createBuilder,
    '/other_dynamic_url_example{?tab,other}': createBuilder,
    '/return_data_example': createBuilder,
    '/posts': createBuilder,
    '/posts/{post_id}': createBuilder,
    '/internal_navs': createBuilder,
    '/multi_push': createBuilder,
    '/multi_remove': createBuilder,
    '/': createBuilder,
  };

  test('it should be able to Push new Pages', () async {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);

    // act
    controller.push(path: '/posts');
    controller.push(path: '/posts/10');
    controller.push(path: '/static_url_example');
    controller.push(
      path: '/dynamic_url_example',
      params: {'tab': 'books'},
    );

    // asserts
    expect(controller.currentConfig.location, '/dynamic_url_example?tab=books');
    expect(controller.pages.length, 5);
    expect(notifyCounter, 4);
  });

  test('it should be able to Pop Pages', () async {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);
    controller.push(path: '/posts');
    controller.push(path: '/posts/10');
    controller.push(path: '/static_url_example');
    controller.push(
      path: '/dynamic_url_example',
      params: {'tab': 'books'},
    );

    // act + asserts
    expect(controller.currentConfig.location, '/dynamic_url_example?tab=books');
    expect(controller.pages.length, 5);
    expect(notifyCounter, 4);

    var res = controller.pop();
    expect(res, true);
    expect(controller.currentConfig.location, '/static_url_example');
    expect(controller.pages.length, 4);
    expect(notifyCounter, 5);

    res = controller.pop();
    expect(res, true);
    expect(controller.currentConfig.location, '/posts/10');
    expect(controller.pages.length, 3);
    expect(notifyCounter, 6);

    res = controller.pop();
    expect(res, true);
    expect(controller.currentConfig.location, '/posts');
    expect(controller.pages.length, 2);
    expect(notifyCounter, 7);

    res = controller.pop();
    expect(res, true);
    expect(controller.currentConfig.location, '/');
    expect(controller.pages.length, 1);
    expect(notifyCounter, 8);
    expect(
      controller.currentConfig,
      controller.initialSnapshot.topConfiguration,
    );

    res = controller.pop();
    expect(res, false);
  });

  test('it should return data to previous Pages when poping', () async {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);

    final f1 = controller.push(path: '/posts');
    final f2 = controller.push(path: '/posts/10');
    final f3 = controller.push(path: '/static_url_example');
    final f4 = controller.push(
      path: '/dynamic_url_example',
      params: {'tab': 'books'},
    );

    // act + asserts
    controller.pop('dummyRes');
    expect(await f4, 'dummyRes');

    controller.pop(123);
    expect(await f3, 123);

    controller.pop(123.00);
    expect(await f2, 123.00);

    controller.pop({'a': 1});
    expect(await f1, {'a': 1});
  });

  test(
      "it should return data in value['result'] restoring Pages from web history",
      () async {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    const loc = 'path/to/something?tab=1&other=2';
    final descriptors = TestUtils.createDescriptorsJson(top: loc);
    final browserConfig = ApsParserData(
      location: loc,
      descriptorsJsons: descriptors,
    );
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);

    // act + assert
    controller.browserSetNewConfiguration(browserConfig);

    controller.pop('dummyRes');
    expect(controller.currentConfig.values['result'], 'dummyRes');

    controller.pop(123);
    expect(controller.currentConfig.values['result'], 123);

    controller.pop(123.00);
    expect(controller.currentConfig.values['result'], 123.00);

    controller.pop({'a': 1});
    expect(controller.currentConfig.values['result'], {'a': 1});
  });

  test("it should be able to push a list of Pages at once on Top of Page Stack",
      () async {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);

    // act
    controller.pushAll(
      list: [
        ApsPushParam(path: '/static_url_example'),
        ApsPushParam(path: '/dynamic_url_example', params: {'tab': 'authors'}),
        ApsPushParam(path: '/posts/10'),
        ApsPushParam(path: '/multi_push', params: {'number': 4}),
      ],
    );

    // asserts
    expect(notifyCounter, 1);
    expect(controller.pages.length, 5);
    expect(
      controller.currentConfig,
      controller.currentSnapshot.topConfiguration,
    );

    expect(
      controller.currentSnapshot.routesDescriptors[4].location,
      '/multi_push',
    );
    expect(
      controller.currentSnapshot.routesDescriptors[3].location,
      '/posts/10',
    );
    expect(
      controller.currentSnapshot.routesDescriptors[2].location,
      '/dynamic_url_example?tab=authors',
    );
    expect(
      controller.currentSnapshot.routesDescriptors[1].location,
      '/static_url_example',
    );
  });

  test(
      "it should be able to push a list of Pages at specific Position of Page Stack",
      () async {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);
    controller.pushAll(
      list: [
        ApsPushParam(path: '/static_url_example'),
        ApsPushParam(path: '/static_url_example'),
        ApsPushParam(path: '/static_url_example'), // <- we'll push here
        ApsPushParam(path: '/static_url_example'),
      ],
    );

    // act
    controller.pushAll(
      position: 3,
      list: [
        ApsPushParam(path: '/static_url_example'),
        ApsPushParam(path: '/dynamic_url_example', params: {'tab': 'authors'}),
        ApsPushParam(path: '/posts/10'),
        ApsPushParam(path: '/multi_push', params: {'number': 4}),
      ],
    );

    // asserts
    expect(notifyCounter, 2);
    expect(controller.pages.length, 9);
    expect(
      controller.currentConfig,
      controller.currentSnapshot.topConfiguration,
    );

    expect(
      controller.currentSnapshot.routesDescriptors[6].location,
      '/multi_push',
    );
    expect(
      controller.currentSnapshot.routesDescriptors[5].location,
      '/posts/10',
    );
    expect(
      controller.currentSnapshot.routesDescriptors[4].location,
      '/dynamic_url_example?tab=authors',
    );
    expect(
      controller.currentSnapshot.routesDescriptors[3].location,
      '/static_url_example',
    );
    expect(
      controller.currentSnapshot.routesDescriptors[2].location,
      '/static_url_example',
    );
    expect(
      controller.currentSnapshot.routesDescriptors[1].location,
      '/static_url_example',
    );
  });

  test("it should not allow to push at Page Stack invalid position", () {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);

    // act
    expect(
      () => controller.pushAll(
        position: 50,
        list: [
          ApsPushParam(path: '/static_url_example'),
          ApsPushParam(path: '/posts/10'),
          ApsPushParam(path: '/multi_push', params: {'number': 4}),
        ],
      ),
      throwsA('Trying to push List of Pages at invalid position: 50'),
    );

    // asserts
    expect(notifyCounter, 0);
    expect(controller.pages.length, 1);
  });

  test('It should be able to navigate back to the Root', () {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);
    controller.push(path: '/posts');
    controller.push(path: '/posts/10');
    notifyCounter = 0; // reset again

    // act
    controller.backToRoot();

    // asserts
    expect(notifyCounter, 1);
    expect(
      controller.currentConfig,
      controller.initialSnapshot.topConfiguration,
    );
    expect(controller.pages.length, 1);
  });

  test('It should be able to remove a Range of Pages from Page Stack', () {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);
    controller.pushAll(
      list: [
        ApsPushParam(path: '/static_url_example'),
        ApsPushParam(path: '/static_url_example'), // will be removed
        ApsPushParam(path: '/static_url_example'), // will be removed
        ApsPushParam(path: '/static_url_example'),
      ],
    );
    notifyCounter = 0; // reset

    // act
    controller.removeRange(start: 2, end: 4);

    // asserts
    expect(notifyCounter, 1);
    expect(controller.pages.length, 3);
  });

  test('It should NOT be able to remove Pages from PageStack invalid ranges',
      () {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);
    controller.pushAll(
      list: [
        ApsPushParam(path: '/static_url_example'),
        ApsPushParam(path: '/static_url_example'),
        ApsPushParam(path: '/static_url_example'),
        ApsPushParam(path: '/static_url_example'),
      ],
    );
    notifyCounter = 0; // reset

    // act + asserts
    expect(
      () => controller.removeRange(start: -1, end: 4),
      throwsA('Trying to use an invalid range when removing Pages'),
    );
    expect(
      () => controller.removeRange(start: 1, end: 5),
      throwsA('Trying to use an invalid range when removing Pages'),
    );
    expect(notifyCounter, 0);
    expect(controller.pages.length, 5);
  });

  testWidgets('It should update Browsers Address properly when requested',
      (WidgetTester tester) async {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);
    final myApp = MaterialApp.router(
      routerDelegate: navigator,
      routeInformationParser: navigator.parser,
    );
    await tester.pumpWidget(myApp);

    // act + asserts

    // - If template contains Query params, updated it
    controller.push(
      path: '/other_dynamic_url_example',
      params: {'tab': 'authors', 'other': 123},
    );
    expect(notifyCounter, 1);
    controller.updateParams(
      params: {'tab': 'books', 'other': 321},
    );
    expect(notifyCounter, 1); // updateParams do not rebuild the UI
    expect(
      controller.currentConfig.location,
      '/other_dynamic_url_example?tab=books&other=321',
    );

    // - If template doesn't contains Query params, doen't update the URL
    controller.push(path: '/static_url_example');
    expect(notifyCounter, 2);
    controller.updateParams(params: {'tab': 'books', 'other': 321});
    expect(notifyCounter, 2); // updateParams do not rebuild the UI
    expect(controller.currentConfig.location, '/static_url_example');
  });

  test('It should redirect to Root when Browser goes back to /', () {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);

    // act
    controller.browserSetNewConfiguration(ApsParserData(location: '/'));

    // assert
    expect(
      controller.currentConfig,
      controller.initialSnapshot.topConfiguration,
    );
  });

  test(
      'It should create a Snapshot based on PageDescriptors if user uses we history',
      () {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);
    final descList = [
      ApsRouteDescriptor(location: '/a', template: '/a', values: const {}),
      ApsRouteDescriptor(location: '/a/b', template: '/a/b', values: const {}),
      ApsRouteDescriptor(
        location: '/a/b/c',
        template: '/a/b/{var2}',
        values: const {'var2': 'c'},
      ),
      ApsRouteDescriptor(
        location: '/a/b/c/d?x=1&z=2',
        template: '/a/b/{var2}/d{?x,y}',
        values: const {'var2': 'c'},
      ),
      ApsRouteDescriptor(
        location: '/dynamic_url_example?tab=books',
        template: '/dynamic_url_example{?tab}',
        values: const {'tab': 'books'},
      )
    ].map((d) => d.toJson()).toList();

    // act
    final browserConfig = ApsParserData(
      location: '/dynamic_url_example?tab=books',
      descriptorsJsons: descList,
    );
    controller.browserSetNewConfiguration(browserConfig);

    // assert
    expect(notifyCounter, 1);
    expect(controller.currentConfig.location, '/dynamic_url_example?tab=books');
    expect(
      controller.currentSnapshot,
      ApsSnapshot(
        popWasRestored: true,
        routesDescriptors: browserConfig.descriptorsJsons
            .map((j) => ApsRouteDescriptor.fromJson(j))
            .toList(),
      ),
    );
  });

  test(
      'It should be able to create a new PageDescriptor and add to current Snapshot',
      () {
    // arrange
    final navigator = APSNavigator.from(routes: routes);
    var notifyCounter = 0;
    final controller = navigator.controller..addListener(() => notifyCounter++);
    const loc = '/dynamic_url_example?tab=books';

    // act
    controller.browserSetNewConfiguration(ApsParserData(
      location: loc,
      isUserOpeningAppForTheFirstTime: true,
    ));

    // assert
    expect(notifyCounter, 1);
    expect(controller.currentConfig.location, '/dynamic_url_example?tab=books');
    expect(controller.currentConfig.template, '/dynamic_url_example{?tab}');
    expect(controller.currentConfig.values, const {'tab': 'books'});
    expect(controller.currentSnapshot.popWasRestored, true);
  });
}
