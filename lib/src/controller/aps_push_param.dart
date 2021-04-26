class ApsPushParam {
  final String path;
  final Map<String, dynamic> params;

  ApsPushParam({
    required this.path,
    this.params = const {},
  });
}
