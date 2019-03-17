enum Status { Unknown, Loading, Loaded, Failed }

class PrefsState {
  final int launchCount;
  final Status status;
  final dynamic error;

  PrefsState({this.launchCount, this.status = Status.Unknown, this.error});

  PrefsState copyWith({int launchCount, Status status, dynamic error}) {
    return PrefsState(
      launchCount: launchCount,
      status: status,
      error: error,
    );
  }

  static PrefsState initialState() {
    return PrefsState();
  }

  @override
  String toString() {
    return "PrefsState{launchCount: $launchCount, status: $status, error: $error}";
  }
}
