import 'package:aps_navigator/aps.dart';
import 'package:flutter/material.dart';

class StaticURLPage extends StatefulWidget {
  final int tabIndex;
  StaticURLPage({Key? key, required this.tabIndex}) : super(key: key);

  @override
  _StaticURLPageState createState() => _StaticURLPageState(tabIndex);

  static Page route(RouteData data) {
    final tab = data.values['tab'] == 'books' ? 0 : 1;

    return MaterialPage(
      key: ValueKey('StaticURLPage'), // Important! Always include a key
      child: StaticURLPage(
        tabIndex: tab,
      ),
    );
  }
}

class _StaticURLPageState extends State<StaticURLPage> {
  _StaticURLPageState(this.tabIndex);

  int tabIndex;

  static const List<Widget> _tabs = <Widget>[
    Text('Index 0: Books'),
    Text('Index 1: Authors')
  ];

  @override
  void didUpdateWidget(StaticURLPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = APSNavigator.of(context).currentConfig.values;
    tabIndex = (previous['tab'] == 'books') ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('BottomNavPage - Static URL Sample'),
      ),
      body: Center(
        child: _tabs.elementAt(tabIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Authors',
          ),
        ],
        currentIndex: tabIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (int index) {
          _onItemTapped(index);

          final aps = APSNavigator.of(context);
          aps.updateParams(
            params: {'tab': index == 0 ? 'books' : 'authors'},
          );
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
