import 'package:aps_navigator/aps.dart';
import 'package:flutter/material.dart';

class Tab1Page extends StatefulWidget {
  final int number;
  const Tab1Page({Key? key, required this.number}) : super(key: key);

  @override
  _Tab1PageState createState() => _Tab1PageState();

  static Page route({Map<String, dynamic>? params}) {
    final number = params!['number'];
    return MaterialPage(
      key: ValueKey('$number'), // Important to include a key
      child: Tab1Page(number: number),
    );
  }
}

class _Tab1PageState extends State<Tab1Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TAB1 - Details ${widget.number}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  APSNavigator.of(context).pushNamed(
                    path: '/tab1',
                    params: {'number': widget.number + 1},
                  );
                },
                child: Text('PUSH NEW DETAIL PAGE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
