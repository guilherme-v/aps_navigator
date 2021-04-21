import 'package:aps_navigator/aps.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import 'tab1_page.dart';
import 'tab2_page.dart';

class InternalNavigator extends StatefulWidget {
  final String initialRoute;

  const InternalNavigator({Key? key, required this.initialRoute})
      : super(key: key);

  @override
  _InternalNavigatorState createState() => _InternalNavigatorState();
}

class _InternalNavigatorState extends State<InternalNavigator> {
  late APSNavigator childNavigator = APSNavigator.from(
    parentNavigator: navigator,
    initialRoute: widget.initialRoute,
    initialParams: {'number': 1},
    routes: {
      '/tab1': Tab1Page.route,
      '/tab2': Tab2Page.route,
    },
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    childNavigator.interceptBackButton(context);
  }

  @override
  Widget build(BuildContext context) {
    return Router(
      // key: UniqueKey(),
      routerDelegate: childNavigator,
      backButtonDispatcher: childNavigator.backButtonDispatcher,
    );
  }
}
