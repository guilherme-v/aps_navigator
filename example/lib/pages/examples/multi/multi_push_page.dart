import 'package:aps_navigator/aps_navigator.dart';
import 'package:flutter/material.dart';

class MultiPushPage extends StatefulWidget {
  final int number;

  const MultiPushPage({Key? key, required this.number}) : super(key: key);

  @override
  _MultiPushPageState createState() => _MultiPushPageState();

  static Page route(RouteData data) {
    final number = data.values['number'] as int;

    return MaterialPage(
      key: ValueKey('MultiPushPage$number'), // Important! Always include a key
      child: MultiPushPage(number: number),
    );
  }
}

class _MultiPushPageState extends State<MultiPushPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MultiPush Page number: ${widget.number}'),
      ),
      body: Column(),
    );
  }
}
