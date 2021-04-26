class ApsParserData {
  String location;
  List<String> descriptorsJsons;

  ApsParserData({
    required this.location,
    this.descriptorsJsons = const [],
  });

  bool get isANewConfigCreatedByBrowser => descriptorsJsons.isEmpty;
}
