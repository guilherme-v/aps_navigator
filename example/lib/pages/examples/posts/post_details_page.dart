import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostDetailsPage extends StatefulWidget {
  final String postId;

  PostDetailsPage({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDetailsPageState createState() => _PostDetailsPageState();

  static Page route({Map<String, dynamic>? params}) {
    return MaterialPage(
      key: ValueKey('PostDetailsPage'), // Important! Always include a key
      child: PostDetailsPage(postId: params!['post_id']),
    );
  }
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final List<String> items = List<String>.generate(10000, (i) => "$i");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post (${widget.postId}) details'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: ListTile(
              title: Text('Comment Number: ${items[index]}'),
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}
