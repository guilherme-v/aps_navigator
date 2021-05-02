class ApsParserData {
  final String location;
  final List<String> descriptorsJsons;
  final bool isUserOpeningAppForTheFirstTime;

  final bool
      isUserRestoringAppStateFromWebHistory; // User DIDN't leave the app and is recoverying from history

  ApsParserData({
    required this.location,
    this.descriptorsJsons = const [],
    this.isUserOpeningAppForTheFirstTime = false,
    this.isUserRestoringAppStateFromWebHistory = false,
  });

  bool get hasPageDescriptorsAvailableFromWebHistory =>
      descriptorsJsons.isNotEmpty;

  ApsParserData copyWith({
    String? location,
    List<String>? descriptorsJsons,
    bool? isUserOpeningAppForTheFirstTime,
    bool? isUserRestoringAppStateFromWebHistory,
  }) {
    return ApsParserData(
      location: location ?? this.location,
      descriptorsJsons: descriptorsJsons ?? this.descriptorsJsons,
      isUserOpeningAppForTheFirstTime: isUserOpeningAppForTheFirstTime ??
          this.isUserOpeningAppForTheFirstTime,
      isUserRestoringAppStateFromWebHistory:
          isUserRestoringAppStateFromWebHistory ??
              this.isUserRestoringAppStateFromWebHistory,
    );
  }

  @override
  String toString() =>
      'ApsParserData(location: $location, descriptorsJsons: $descriptorsJsons, isUserOpeningAppForTheFirstTime: $isUserOpeningAppForTheFirstTime, isUserRestoringAppStateFromWebHistory: $isUserRestoringAppStateFromWebHistory)';
}
