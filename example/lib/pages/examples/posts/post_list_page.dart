import 'package:aps_navigator/aps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({Key? key}) : super(key: key);

  @override
  _PostListPageState createState() => _PostListPageState();

  static Page route(RouteData _) {
    return const MaterialPage(
      key: ValueKey('PostListPage'), // Important! Always include a key
      child: PostListPage(),
    );
  }
}

class _PostListPageState extends State<PostListPage> {
  final List<String> items = List<String>.generate(100, (i) => "$i");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post List Sample'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              APSNavigator.of(context).pushNamed(
                // routeBuilder: PostListItemPage.route,
                path: '/posts/$index',
                // params: {'post_id': '$index'},
                // updatePath: false,
              );
            },
            child: ListTile(
              title: Text('Post Number: ${items[index]}'),
            ),
          );
        },
      ),
    );
  }
}
