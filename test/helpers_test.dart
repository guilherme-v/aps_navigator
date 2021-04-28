import 'package:aps_navigator/aps_navigator.dart';
import 'package:aps_navigator/src/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('It should mergeLocationAndParams', () {
    // arrange
    const merge = Helpers.mergeLocationAndQueries;

    // asserts
    expect(merge('/path', {'q1': '1'}), '/path?q1=1');
    expect(merge('/path', {'q1': '1', 'q2': '2'}), '/path?q1=1&q2=2');
    expect(merge('/path/abc', {'q1': '1'}), '/path/abc?q1=1');
    expect(merge('/path/abc', {'q1': '1', 'q2': '2'}), '/path/abc?q1=1&q2=2');
  });

  test('It should return locationWithoutQueries', () {
    // arrange
    const remove = Helpers.locationWithoutQueries;

    // asserts
    expect(remove('/path?q1=1'), '/path');
    expect(remove('/path?q1=1&q2=2'), '/path');
    expect(remove('/path/abc?q1=1'), '/path/abc');
    expect(remove('/path/abc?q1=1&q2=2'), '/path/abc');
  });

  test('It should create Descriptors', () {
    // arrange
    const create = Helpers.createDescriptorFrom;
    // ignore: prefer_function_declarations_over_variables
    final builder = (RouteData _) => MaterialPage(child: Container());
    final mapToBuilders = {
      '/both/aps/{var1}/{var2}/other{?q1,q2,q3}': builder,
      '/simple_path': builder,
      '/path_with_var_1/{var1}': builder,
      '/path_with_query_1{?var1}': builder,
      '/path_with_query_2{?var1,var2}': builder,
      '/path_with_var_2/{var1}/{var2}': builder,
      '/path_with_query_3/aps{?var1,var2,var3}': builder,
      '/path_with_var_3/{var1}/{var2}/aps/{var3}': builder,
      '/': builder,
    };
    final routerMatcher = ApsRouteMatcher(mapToBuilders);

    // asserts
    final d1 = create(
      path: '/',
      queries: const {},
      routerMatcher: routerMatcher,
    );
    expect(d1.location, '/');
    expect(d1.values, const {});
    expect(d1.template, '/');

    final d2 = create(
      path: '/simple_path',
      queries: const {},
      routerMatcher: routerMatcher,
    );
    expect(d2.location, '/simple_path');
    expect(d2.values, const {});
    expect(d2.template, '/simple_path');

    final d3 = create(
      path: '/path_with_var_1/value_1',
      queries: const {},
      routerMatcher: routerMatcher,
    );
    expect(d3.location, '/path_with_var_1/value_1');
    expect(d3.values, {'var1': 'value_1'});
    expect(d3.template, '/path_with_var_1/{var1}');

    final d4 = create(
      path: '/path_with_query_1',
      queries: {'var1': 'abc'},
      routerMatcher: routerMatcher,
    );
    expect(d4.location, '/path_with_query_1?var1=abc');
    expect(d4.values, {'var1': 'abc'});
    expect(d4.template, '/path_with_query_1{?var1}');

    final d5 = create(
      path: '/path_with_query_2',
      queries: {'var1': 'abc', 'var2': '123'},
      routerMatcher: routerMatcher,
    );
    expect(d5.location, '/path_with_query_2?var1=abc&var2=123');
    expect(d5.values, {'var1': 'abc', 'var2': '123'});
    expect(d5.template, '/path_with_query_2{?var1,var2}');

    final d6 = create(
      path: '/path_with_var_2/var1/var2',
      queries: const {},
      routerMatcher: routerMatcher,
    );
    expect(d6.location, '/path_with_var_2/var1/var2');
    expect(d6.values, {'var1': 'var1', 'var2': 'var2'});
    expect(d6.template, '/path_with_var_2/{var1}/{var2}');

    final d7 = create(
      path: '/path_with_query_3/aps',
      queries: const {'var1': '1', 'var2': '2', 'var3': 3},
      routerMatcher: routerMatcher,
    );
    expect(d7.location, '/path_with_query_3/aps?var1=1&var2=2&var3=3');
    expect(d7.values, {'var1': '1', 'var2': '2', 'var3': '3'}); // TODO WTF?
    expect(d7.template, '/path_with_query_3/aps{?var1,var2,var3}');

    final d8 = create(
      path: '/path_with_var_3/val_1/val_2/aps/val_3',
      queries: const {},
      routerMatcher: routerMatcher,
    );
    expect(d8.location, '/path_with_var_3/val_1/val_2/aps/val_3');
    expect(d8.values, {'var1': 'val_1', 'var2': 'val_2', 'var3': 'val_3'});
    expect(d8.template, '/path_with_var_3/{var1}/{var2}/aps/{var3}');

    final d9 = create(
      path: '/both/aps/val_1/val_2/other',
      queries: const {'q1': '1', 'q2': '2', 'q3': '3'},
      routerMatcher: routerMatcher,
    );
    expect(d9.location, '/both/aps/val_1/val_2/other?q1=1&q2=2&q3=3');
    expect(d9.values,
        {'var1': 'val_1', 'var2': 'val_2', 'q1': '1', 'q2': '2', 'q3': '3'});
    expect(d9.template, '/both/aps/{var1}/{var2}/other{?q1,q2,q3}');
  });
}
