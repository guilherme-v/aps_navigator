import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// [ApsRouteDescriptor] includes all the information [APSNavigator] needs to create a new route (page)
class ApsRouteDescriptor<T> {
  /// Represents the template that [location] will match. E.g.: `/path/{var1}/abc/?{?tab}`
  final String template;

  /// The current location that this descritor will build. E.g: `/path/post_a/abc/?tab=0`
  final String location;

  /// Values extracted from [location], based on [template]. It'll contain both path and query values
  final Map<String, dynamic> values;

  /// Completer returned to this 'child' page
  ///
  /// This won't be serialized in browser's history, so we need to recreate this when loading pages from history
  Completer<T> popCompleter;

  ApsRouteDescriptor({
    required this.template,
    required this.location,
    this.values = const {},
    Completer<T>? completer,
  }) : this.popCompleter = completer ?? Completer<T>();

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
      completer: this.popCompleter,
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
      template: map['template'],
      location: map['location'],
      values: Map<String, dynamic>.from(map['values']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ApsRouteDescriptor.fromJson(String source) =>
      ApsRouteDescriptor.fromMap(json.decode(source));

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
