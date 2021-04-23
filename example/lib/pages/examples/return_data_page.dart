import 'package:aps_navigator/aps.dart';
import 'package:flutter/material.dart';

class ReturnDataPage extends StatefulWidget {
  @override
  _ReturnDataPageState createState() => _ReturnDataPageState();

  static Page route(RouteData _) {
    return MaterialPage(
      key: ValueKey('ReturnDataPage'), // Important! Always include a key
      child: ReturnDataPage(),
    );
  }
}

class _ReturnDataPageState extends State<ReturnDataPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pick an option'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    APSNavigator.of(context).pop('Do!');
                  },
                  child: Text('Do!'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    APSNavigator.of(context).pop('Or Do not.');
                  },
                  child: Text('Or Do not!'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    APSNavigator.of(context).pop('There is no try!');
                  },
                  child: Text('There is no try!'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
