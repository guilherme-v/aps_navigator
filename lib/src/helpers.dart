abstract class Helpers {
  static String mergeLocationAndParams(
    String plainPath,
    Map<String, dynamic> params,
  ) {
    var pathWithParams = plainPath;

    // Add '?' if needed
    if (params.isNotEmpty) {
      pathWithParams += '?';
    }

    // Add all 'param=value&' queries
    params.entries.forEach((entry) {
      pathWithParams += '${entry.key}=${entry.value}&';
    });

    // remove any trailing '&'
    if (pathWithParams.endsWith("&")) {
      pathWithParams = pathWithParams.substring(0, pathWithParams.length - 1);
    }

    return pathWithParams;
  }

  static String locationWithoutQueries(String path) {
    var queryStartAt = path.indexOf('?');
    if (queryStartAt == -1) queryStartAt = path.length;
    return path.substring(0, queryStartAt);
  }
}
