import 'package:aps_navigator/aps_navigator.dart';
import 'package:flutter/material.dart';

class DynamicURLPage extends StatefulWidget {
  final int tabIndex;
  const DynamicURLPage({Key? key, required this.tabIndex}) : super(key: key);

  @override
  _DynamicURLPageState createState() => _DynamicURLPageState();

  static Page route(RouteData data) {
    final tab = data.values['tab'] == 'books' ? 0 : 1;

    return MaterialPage(
      key: const ValueKey('DynamicURLPage'), // Important! Always include a key
      child: DynamicURLPage(
        tabIndex: tab,
      ),
    );
  }
}

class _DynamicURLPageState extends State<DynamicURLPage> {
  _DynamicURLPageState();

  late int tabIndex;

  static const List<Widget> _tabs = <Widget>[
    Text('Index 0: Books'),
    Text('Index 1: Authors')
  ];

  @override
  void initState() {
    super.initState();
    tabIndex = widget.tabIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final previous = APSNavigator.of(context).currentConfig.values;
    tabIndex = (previous['tab'] == 'books') ? 0 : 1;
  }

  @override
  void didUpdateWidget(DynamicURLPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // final previous = APSNavigator.of(context).currentConfig.values;
    // tabIndex = (previous['tab'] == 'books') ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('BottomNavPage - Dynamic URL Sample'),
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
