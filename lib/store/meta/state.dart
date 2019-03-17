enum InitState { Unknown, Loading, Loaded }

class MetaState {
  final InitState initState;

  MetaState({this.initState = InitState.Unknown});

  MetaState copyWith({InitState initState}) {
    return MetaState(
      initState: initState ?? this.initState,
    );
  }

  static MetaState initialState() {
    return MetaState();
  }

  @override
  String toString() {
    return "MetaState{initState: $initState}";
  }
}
