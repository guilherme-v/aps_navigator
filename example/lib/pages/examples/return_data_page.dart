import 'package:aps_navigator/aps_navigator.dart';
import 'package:flutter/material.dart';

class ReturnDataPage extends StatefulWidget {
  const ReturnDataPage({Key? key}) : super(key: key);

  @override
  _ReturnDataPageState createState() => _ReturnDataPageState();

  static Page route(RouteData _) {
    return const MaterialPage(
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
          title: const Text('Pick an option'),
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
                  child: const Text('Do!'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    APSNavigator.of(context).pop('Or Do not.');
                  },
                  child: const Text('Or Do not!'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    APSNavigator.of(context).pop('There is no try!');
                  },
                  child: const Text('There is no try!'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
