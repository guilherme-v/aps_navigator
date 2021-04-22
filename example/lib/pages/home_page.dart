import 'package:aps_navigator/aps.dart';
import 'package:flutter/material.dart';

/// Page that contains different examples of navigation
class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();

  static Page route({Map<String, dynamic>? params}) {
    return MaterialPage(
      key: ValueKey('Home'), // Important to include a key
      child: HomePage(),
    );
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Navigation examples'),
      ),
      body: ListView(
        children: [
          _buildStaticURLExample(),
          _buildDynamicURLExample(),
          _buildReturnDataExample(),
          _buildPostListExample(),
          _buildInternalNavExample(),
          _buildMultiPushExample(),
          _buildMultiRemoveExample(),
        ],
      ),
    );
  }

  Widget _buildStaticURLExample() {
    return GestureDetector(
      child: ListTile(
        leading: Icon(Icons.web),
        title: Text('BottomNavPage - Static URL'),
      ),
      onTap: () {
        APSNavigator.of(context).pushNamed(
          path: '/static_url_example',
          params: {'tab': 'books'},
        );
      },
    );
  }

  Widget _buildDynamicURLExample() {
    return GestureDetector(
      child: ListTile(
        leading: Icon(Icons.web),
        title: Text('BottomNavPage - Dynamic URL'),
      ),
      onTap: () {
        APSNavigator.of(context).pushNamed(
          path: '/dynamic_url_example',
          params: {'tab': 'books'},
        );
      },
    );
  }

  Widget _buildReturnDataExample() {
    return GestureDetector(
      child: ListTile(
        leading: Icon(Icons.web),
        title: Text('Page that returns Data'),
      ),
      onTap: () async {
        final selectedOption = await APSNavigator.of(context).pushNamed(
          path: '/return_data_example',
        );

        if (selectedOption != null) {
          print('Selected: $selectedOption');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(selectedOption)),
          );
        }
      },
    );
  }

  Widget _buildPostListExample() {
    return GestureDetector(
      child: ListTile(
        leading: Icon(Icons.web),
        title: Text('Post List Page'),
      ),
      onTap: () {
        APSNavigator.of(context).pushNamed(
          path: '/posts',
        );
      },
    );
  }

  Widget _buildInternalNavExample() {
    return GestureDetector(
      child: ListTile(
        leading: Icon(Icons.navigation),
        title: Text('Internal Navs'),
      ),
      onTap: () {
        APSNavigator.of(context).pushNamed(
          path: '/internal_navs',
        );
      },
    );
  }

  Widget _buildMultiPushExample() {
    return GestureDetector(
      child: ListTile(
        leading: Icon(Icons.navigation),
        title: Text(
          'Multi Push Examples (tap to push 4 Pages on top of this at once)',
        ),
      ),
      onTap: () {
        APSNavigator.of(context).insertAll(
          list: [
            ApsPushListParam(path: '/multi_push', params: {'number': 1}),
            ApsPushListParam(path: '/multi_push', params: {'number': 2}),
            ApsPushListParam(path: '/multi_push', params: {'number': 3}),
            ApsPushListParam(path: '/multi_push', params: {'number': 4}),
          ],
        );
      },
    );
  }

  Widget _buildMultiRemoveExample() {
    return GestureDetector(
      child: ListTile(
        leading: Icon(Icons.navigation),
        title: Text(
          'Pushes 7 pages at once on top of this, and allow to remove pages between a range',
        ),
      ),
      onTap: () {
        APSNavigator.of(context).insertAll(
          list: [
            ApsPushListParam(path: '/multi_push', params: {'number': 1}),
            ApsPushListParam(path: '/multi_push', params: {'number': 2}),
            ApsPushListParam(path: '/multi_push', params: {'number': 3}),
            ApsPushListParam(path: '/multi_push', params: {'number': 4}),
            ApsPushListParam(path: '/multi_push', params: {'number': 5}),
            ApsPushListParam(path: '/multi_push', params: {'number': 6}),
            ApsPushListParam(path: '/multi_remove'),
          ],
        );
      },
    );
  }
}
