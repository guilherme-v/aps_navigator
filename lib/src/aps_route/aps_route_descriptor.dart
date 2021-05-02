import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// It contains all the data required to (re)create a route.
///
/// Each [ApsRouteDescriptor] instance will be later converted to an [Page] added to the route stack.
///
class ApsRouteDescriptor<T> {
  /// The location this descriptor represents. E.g: `/path/post_a/abc/?tab=0`.
  final String location;

  /// The template that [location] will match. E.g.: `/path/{var1}/abc/?{?tab}`.
  final String template;

  /// Values extracted from [location], based on [template]. It'll contain both path and query values.
  final Map<String, dynamic> values;

  /// Completer returned to this 'child' page.
  Completer<T>
      popCompleter; // * This won't be serialized in browser's history, so this is recreated when loading pages from history.

  ApsRouteDescriptor({
    required this.template,
    required this.location,
    this.values = const {},
    Completer<T>? completer,
  }) : popCompleter = completer ?? Completer<T>();

  // *
  // * Generated methods
  // *

  ApsRouteDescriptor copyWith({
    String? template,
    String? location,
    Map<String, dynamic>? values,
  }) {
    return ApsRouteDescriptor(
      template: template ?? this.template,
      location: location ?? this.location,
      values: values ?? this.values,
      completer: popCompleter,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'template': template,
      'location': location,
      'values': values,
    };
  }

  factory ApsRouteDescriptor.fromMap(Map<String, dynamic> map) {
    return ApsRouteDescriptor(
      template: map['template'] as String,
      location: map['location'] as String,
      values: Map<String, dynamic>.from(map['values'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory ApsRouteDescriptor.fromJson(String source) =>
      ApsRouteDescriptor.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ApsRouteDescriptor(template: $template, location: $location, values: $values)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApsRouteDescriptor &&
        other.template == template &&
        other.location == location &&
        mapEquals(other.values, values);
  }

  @override
  int get hashCode => template.hashCode ^ location.hashCode ^ values.hashCode;
}
