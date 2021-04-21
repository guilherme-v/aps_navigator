import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

class ApsRouteDescriptor<T> {
  final String template;
  final String location;
  final Map<String, dynamic> params;

  // This won't be serialized
  Completer<T> popCompleter;

  ApsRouteDescriptor({
    required this.template,
    required this.location,
    this.params = const {},
    Completer<T>? completer,
  }) : this.popCompleter = completer ?? Completer<T>();

  ApsRouteDescriptor copyWith({
    String? template,
    String? location,
    Map<String, dynamic>? params,
  }) {
    return ApsRouteDescriptor(
      template: template ?? this.template,
      location: location ?? this.location,
      params: params ?? this.params,
      completer: this.popCompleter,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'template': template,
      'location': location,
      'params': params,
    };
  }

  factory ApsRouteDescriptor.fromMap(Map<String, dynamic> map) {
    return ApsRouteDescriptor(
      template: map['template'],
      location: map['location'],
      params: Map<String, dynamic>.from(map['params']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ApsRouteDescriptor.fromJson(String source) =>
      ApsRouteDescriptor.fromMap(json.decode(source));

  @override
  String toString() =>
      'ApsRouteDescriptor(template: $template, location: $location, params: $params)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApsRouteDescriptor &&
        other.template == template &&
        other.location == location &&
        mapEquals(other.params, params);
  }

  @override
  int get hashCode => template.hashCode ^ location.hashCode ^ params.hashCode;
}



/// IDEIA P/ POP:
/// Se for um pop normal: só retorna 
/// Se:
/// - user foi para outro site 
/// - retornou para nosso site 
/// - recrie tds os pop compliters 
/// - retorne o resultado no "params" que é recuperado no didUpdateWidget 
/// 
/// mas isso so vai funcionar com T sendo serializavel ??
///   Future<T> pushNamed<T>({
    ///   required String path,
    ///   Map<String, dynamic> params = const {},
  ///   }) {
  /// 
