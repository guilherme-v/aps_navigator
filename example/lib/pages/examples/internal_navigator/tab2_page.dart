import 'package:aps_navigator/aps.dart';
import 'package:flutter/material.dart';

class Tab2Page extends StatefulWidget {
  final int number;
  const Tab2Page({Key? key, required this.number}) : super(key: key);

  @override
  _Tab2PageState createState() => _Tab2PageState();

  static Page route(RouteData data) {
    final number = data.values['number'];
    return MaterialPage(
      key: ValueKey('$number'), // Important to include a key
      child: Tab2Page(number: number),
    );
  }
}

class _Tab2PageState extends State<Tab2Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TAB2 - Details ${widget.number}'),
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
                    path: '/tab2',
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
