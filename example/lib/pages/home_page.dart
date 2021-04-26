import 'package:aps_navigator/aps.dart';
import 'package:flutter/material.dart';

/// Page that contains different examples of navigation
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();

  static Page route(RouteData _) {
    return const MaterialPage(
      key: ValueKey('Home'), // Important to include a key
      child: HomePage(),
    );
  }
}

class _HomePageState extends State<HomePage> {
  String? result;

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final params = APSNavigator.of(context).currentConfig.values;
    result = params['result'] as String;
    if (result != null) _showSnackBar(result!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Navigation examples'),
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
      onTap: () {
        APSNavigator.of(context).push(
          path: '/static_url_example',
          params: {'tab': 'books'},
        );
      },
      child: const ListTile(
        leading: Icon(Icons.web),
        title: Text('BottomNavPage - Static URL'),
      ),
    );
  }

  Widget _buildDynamicURLExample() {
    return GestureDetector(
      onTap: () {
        APSNavigator.of(context).push(
          path: '/dynamic_url_example',
          params: {'tab': 'books'},
        );
      },
      child: const ListTile(
        leading: Icon(Icons.web),
        title: Text('BottomNavPage - Dynamic URL'),
      ),
    );
  }

  Widget _buildReturnDataExample() {
    return GestureDetector(
      onTap: () async {
        final selectedOption = await APSNavigator.of(context).push(
          path: '/return_data_example',
        );

        if (selectedOption != null) {
          _showSnackBar(selectedOption as String);
        }
      },
      child: const ListTile(
        leading: Icon(Icons.web),
        title: Text('Page that returns Data'),
      ),
    );
  }

  Widget _buildPostListExample() {
    return GestureDetector(
      onTap: () {
        APSNavigator.of(context).push(
          path: '/posts',
        );
      },
      child: const ListTile(
        leading: Icon(Icons.web),
        title: Text('Post List Page'),
      ),
    );
  }

  Widget _buildInternalNavExample() {
    return GestureDetector(
      onTap: () {
        APSNavigator.of(context).push(
          path: '/internal_navs',
        );
      },
      child: const ListTile(
        leading: Icon(Icons.navigation),
        title: Text('Internal Navs'),
      ),
    );
  }

  Widget _buildMultiPushExample() {
    return GestureDetector(
      onTap: () {
        APSNavigator.of(context).pushAll(
          list: [
            ApsPushParam(path: '/multi_push', params: {'number': 1}),
            ApsPushParam(path: '/multi_push', params: {'number': 2}),
            ApsPushParam(path: '/multi_push', params: {'number': 3}),
            ApsPushParam(path: '/multi_push', params: {'number': 4}),
          ],
        );
      },
      child: const ListTile(
        leading: Icon(Icons.navigation),
        title: Text(
          'Multi Push Examples (tap to push 4 Pages on top of this at once)',
        ),
      ),
    );
  }

  Widget _buildMultiRemoveExample() {
    return GestureDetector(
      onTap: () {
        APSNavigator.of(context).pushAll(
          list: [
            ApsPushParam(path: '/multi_push', params: {'number': 1}),
            ApsPushParam(path: '/multi_push', params: {'number': 2}),
            ApsPushParam(path: '/multi_push', params: {'number': 3}),
            ApsPushParam(path: '/multi_push', params: {'number': 4}),
            ApsPushParam(path: '/multi_push', params: {'number': 5}),
            ApsPushParam(path: '/multi_push', params: {'number': 6}),
            ApsPushParam(path: '/multi_remove'),
          ],
        );
      },
      child: const ListTile(
        leading: Icon(Icons.navigation),
        title: Text(
          'Pushes 7 pages at once on top of this, and allow to remove pages between a range',
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }
}
