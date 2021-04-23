import 'package:flutter/material.dart';

import 'package:aps_navigator/aps.dart';

import 'pages/examples/dynamic_url_page.dart';
import 'pages/examples/internal_navigator/internal_navigators_page.dart';
import 'pages/examples/multi/multi_push_page.dart';
import 'pages/examples/multi/multi_remove_page.dart';
import 'pages/examples/posts/post_details_page.dart';
import 'pages/examples/posts/post_list_page.dart';
import 'pages/examples/return_data_page.dart';
import 'pages/examples/static_url_page.dart';
import 'pages/home_page.dart';

void main() => runApp(MyApp());

// Creates a Main ApsNavigator
final navigator = APSNavigator.from(
  initialRoute: "/",
  routes: {
    // Persists state on Browser's history without including it in URL Address (Query params)
    '/static_url_example': StaticURLPage.route,
    // Persists state on Browser's history including/updating URL Address (Query params)
    '/dynamic_url_example{?tab}': DynamicURLPage.route,
    // Creates a page that returns data
    '/return_data_example': ReturnDataPage.route,
    // Shows how to include values on URL address path
    '/posts': PostListPage.route,
    '/posts/{post_id}': PostDetailsPage.route,
    // Shows how to use Internal Navigation
    '/internal_navs': InternalNavigatorsPage.route,
    // Shows how to Push multiples Pages at a specific location
    '/multi_push': MultiPushPage.route,
    // Shows how to Remove multiples Page at a specific location
    '/multi_remove': MultiRemovePage.route,
    // Initial page
    '/': HomePage.route,
  },
);

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Configures the Main ApsNavigator instance to be used
    return MaterialApp.router(
      routerDelegate: navigator,
      routeInformationParser: navigator.parser,
    );
  }
}
