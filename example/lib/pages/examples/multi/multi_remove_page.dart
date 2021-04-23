import 'package:aps_navigator/aps.dart';
import 'package:flutter/material.dart';

class MultiRemovePage extends StatefulWidget {
  MultiRemovePage({Key? key}) : super(key: key);

  @override
  _MultiRemovePageState createState() => _MultiRemovePageState();

  static Page route(RouteData _) {
    return MaterialPage(
      key: ValueKey('MultiRemovePage'), // Important! Always include a key
      child: MultiRemovePage(),
    );
  }
}

class _MultiRemovePageState extends State<MultiRemovePage> {
  var _removed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi Remove Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('It was pushed 6 Pages before the current one'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  var msg = '';
                  if (!_removed) {
                    _removed = true;
                    APSNavigator.of(context).removeRange(start: 2, end: 5);
                    msg = 'Pages [2-4] removed';
                  } else {
                    msg = 'Already removed';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg)),
                  );
                },
                child: Text(
                    'click here to remove the range: [2-4], then navigate back to see the result'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
