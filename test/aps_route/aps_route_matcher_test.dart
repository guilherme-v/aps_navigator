import 'package:aps_navigator/src/aps_route/route_data.dart';
import 'package:aps_navigator/src/aps_route/aps_route_matcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MaterialPage createBuilder(RouteData data) =>
      MaterialPage(child: Container());

  final builder1 = createBuilder;
  final builder2 = createBuilder;
  final builder3 = createBuilder;
  final builder4 = createBuilder;
  final builder5 = createBuilder;
  final builder6 = createBuilder;
  final builder7 = createBuilder;
  final builder8 = createBuilder;
  final builder9 = createBuilder;

  final mapToBuilders = {
    '/both/aps/{var1}/{var2}/other{?q1,q2,q3}': builder9,
    '/simple_path': builder2,
    '/path_with_var_1/{var1}': builder3,
    '/path_with_query_1{?var1}': builder6,
    '/path_with_query_2{?var1,var2}': builder7,
    '/path_with_var_2/{var1}/{var2}': builder4,
    '/path_with_query_3/aps{?var1,var2,var3}': builder8,
    '/path_with_var_3/{var1}/{var2}/aps/{var3}': builder5,
    '/': builder1,
  };

  test('it should get the right Template given a route', () {
    // arrange
    final routeMatcher = ApsRouteMatcher(mapToBuilders);

    // asserts
    //
    // simple
    expect(routeMatcher.getTemplateForRoute('/'), '/');
    expect(routeMatcher.getTemplateForRoute('/simple_path'), '/simple_path');

    // path_with_var
    expect(
      routeMatcher.getTemplateForRoute('/path_with_var_1/value_1'),
      '/path_with_var_1/{var1}',
    );
    expect(
      routeMatcher.getTemplateForRoute('/path_with_var_2/value_1/value_2'),
      '/path_with_var_2/{var1}/{var2}',
    );
    expect(
      routeMatcher.getTemplateForRoute('/path_with_var_3/val1/val2/aps/val3'),
      '/path_with_var_3/{var1}/{var2}/aps/{var3}',
    );

    // path_with_query
    expect(
      routeMatcher.getTemplateForRoute('/path_with_query_1?var1=any'),
      '/path_with_query_1{?var1}',
    );
    expect(
      routeMatcher.getTemplateForRoute('/path_with_query_2?var1=aa&var2=bb'),
      '/path_with_query_2{?var1,var2}',
    );
    expect(
      routeMatcher.getTemplateForRoute(
        '/path_with_query_3/aps?var1=a&var2=b&var3=c',
      ),
      '/path_with_query_3/aps{?var1,var2,var3}',
    );

    // both
    expect(
      routeMatcher.getTemplateForRoute(
        '/both/aps/var1/var2/other?q1=1&q2=2&q3=3',
      ),
      '/both/aps/{var1}/{var2}/other{?q1,q2,q3}',
    );
  });

  test('It should get the right Values given a route', () {
    // arrange
    final routeMatcher = ApsRouteMatcher(mapToBuilders);

    // asserts

    // simple
    expect(routeMatcher.getValuesFromRoute('/'), const {});
    expect(routeMatcher.getValuesFromRoute('/simple_path'), const {});

    // path_with_var

    // '/path_with_var_1/{var1}',
    expect(
      routeMatcher.getValuesFromRoute('/path_with_var_1/value_1'),
      {'var1': 'value_1'},
    );
    // '/path_with_var_2/{var1}/{var2}',
    expect(
      routeMatcher.getValuesFromRoute('/path_with_var_2/value_1/value_2'),
      {'var1': 'value_1', 'var2': 'value_2'},
    );
    // '/path_with_var_3/{var1}/{var2}/aps/{var3}',
    expect(
      routeMatcher.getValuesFromRoute('/path_with_var_3/val1/val2/aps/val3'),
      {'var1': 'val1', 'var2': 'val2', 'var3': 'val3'},
    );

    // path_with_query

    // '/path_with_query_1{?var1}',
    expect(
      routeMatcher.getValuesFromRoute('/path_with_query_1?var1=any'),
      {'var1': 'any'},
    );
    // '/path_with_query_2{?var1,var2}',
    expect(
      routeMatcher.getValuesFromRoute('/path_with_query_2?var1=aa&var2=bb'),
      {'var1': 'aa', 'var2': 'bb'},
    );
    // '/path_with_query_3/aps{?var1,var2,var3}',
    expect(
      routeMatcher.getValuesFromRoute(
        '/path_with_query_3/aps?var1=a&var2=1.0&var3=10',
      ),
      {'var1': 'a', 'var2': '1.0', 'var3': '10'},
    );

    // both
    // '/both/aps/{var1}/{var2}/other{?q1,q2,q3}',
    expect(
      routeMatcher.getValuesFromRoute(
        '/both/aps/var1/var2/other?q1=1&q2=2&q3=3',
      ),
      {'var1': 'var1', 'var2': 'var2', 'q1': '1', 'q2': '2', 'q3': '3'},
    );
  });

  test('It should return the right Builder Function given a Route', () {
    // arrange
    final routeMatcher = ApsRouteMatcher(mapToBuilders);

    // asserts
    // simple
    expect(routeMatcher.getBuildFunctionForRoute('/'), builder1);
    expect(routeMatcher.getBuildFunctionForRoute('/simple_path'), builder2);

    // path_with_var
    expect(
      routeMatcher.getBuildFunctionForRoute('/path_with_var_1/value_1'),
      builder3,
    );
    expect(
      routeMatcher.getBuildFunctionForRoute('/path_with_var_2/value_1/value_2'),
      builder4,
    );
    expect(
      routeMatcher.getBuildFunctionForRoute(
        '/path_with_var_3/val1/val2/aps/val3',
      ),
      builder5,
    );

    // path_with_query
    expect(
      routeMatcher.getBuildFunctionForRoute(
        '/path_with_query_1?var1=any',
      ),
      builder6,
    );
    expect(
      routeMatcher.getBuildFunctionForRoute(
        '/path_with_query_2?var1=aa&var2=bb',
      ),
      builder7,
    );
    expect(
      routeMatcher.getBuildFunctionForRoute(
        '/path_with_query_3/aps?var1=a&var2=1.0&var3=10',
      ),
      builder8,
    );

    // both
    expect(
      routeMatcher.getBuildFunctionForRoute(
        '/both/aps/var1/var2/other?q1=1&q2=2&q3=3',
      ),
      builder9,
    );
  });
}
