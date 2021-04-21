import 'package:flutter/widgets.dart';

import 'aps_controller.dart';

/// Used internally by [APSNavigator] to provide an instance of [APSController] down to widget tree.
class APSInheritedController extends InheritedWidget {
  final APSController controller;

  const APSInheritedController({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
