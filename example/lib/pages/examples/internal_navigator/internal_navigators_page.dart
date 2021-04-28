import 'package:aps_navigator/aps_navigator.dart';
import 'package:flutter/material.dart';

import 'internal_navigator.dart';

class InternalNavigatorsPage extends StatefulWidget {
  const InternalNavigatorsPage({Key? key}) : super(key: key);

  @override
  _InternalNavigatorsPageState createState() => _InternalNavigatorsPageState();

  static Page route(RouteData _) {
    return const MaterialPage(
      key: ValueKey("InternalNavigators"), // Important! Always include a key
      child: InternalNavigatorsPage(),
    );
  }
}

class _InternalNavigatorsPageState extends State<InternalNavigatorsPage> {
  _InternalNavigatorsPageState();

  int tabIndex = 0;

  final List<Widget> _tabs = <Widget>[
    const InternalNavigator(
      key: ValueKey('NAV1'),
      initialRoute: '/tab1',
    ),
    const InternalNavigator(
      key: ValueKey('NAV2'),
      initialRoute: '/tab2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INTERNAL NAV'),
      ),
      body: IndexedStack(
        index: tabIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation),
            label: 'Navigator 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation),
            label: 'Navigator 2',
          ),
        ],
        currentIndex: tabIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (int index) {
          _onItemTapped(index);
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      tabIndex = index;
    });
  }
}
