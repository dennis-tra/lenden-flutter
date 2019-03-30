import 'package:lenden/store/state.dart';
import 'package:lenden/main.dart';
import 'package:lenden/store/prefs/actions.dart';
import 'package:lenden/store/prefs/state.dart' as Prefs;
import 'package:lenden/store/auth/state.dart' as Auth;
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/meta/actions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

Epic<AppState> metaEpics() {
  return combineEpics([observeInitStateEpic()]);
}

Epic<AppState> observeInitStateEpic({Firestore firestore}) {
  firestore = firestore ?? Firestore.instance;

  return (Stream<dynamic> actions, EpicStore<AppState> store) {
    return Observable(actions)
        .ofType(TypeToken<StartObservingInitState>())
        .switchMap((StartObservingInitState action) {
      final actionLogInCompleted =
          Observable(actions).ofType(TypeToken<LogInCompleted>());

      final stateLogInCompleted = Observable.just(store.state.auth)
          .where((auth) => auth.status == Auth.Status.LoggedIn);

      final logInObservable =
          Observable.merge([actionLogInCompleted, stateLogInCompleted]);

      final actionSavePlopSoundCompleted =
          Observable(actions).ofType(TypeToken<InitAudioplayerCompleted>());

      final stateSavePlopSoundCompleted = Observable.just(store.state.meta)
          .where((auth) => auth.plopFilePath.isNotEmpty);

      final savePlopSoundObservable = Observable.merge(
          [actionSavePlopSoundCompleted, stateSavePlopSoundCompleted]);

      final actionLoadPreferencesCompleted =
          Observable(actions).ofType(TypeToken<LoadPreferencesCompleted>());

      final stateLoadPreferencesCompleted = Observable.just(store.state.prefs)
          .where((prefs) =>
              prefs.status == Prefs.Status.Loaded ||
              prefs.status == Prefs.Status.Failed)
          .map((prefs) =>
              LoadPreferencesCompleted(launchCount: prefs.launchCount));

      final preferencesObservable = Observable.merge(
          [actionLoadPreferencesCompleted, stateLoadPreferencesCompleted]);

      final firestoreSettingsObservable = Observable.fromFuture(
          firestore.settings(timestampsInSnapshotsEnabled: true));

      return Observable.combineLatest4(
              savePlopSoundObservable,
              firestoreSettingsObservable,
              logInObservable,
              preferencesObservable,
              (_, __, ___, LoadPreferencesCompleted prefs) => prefs.launchCount)
          .map((_) => InitCompleted())
          .onErrorReturnWith((error) => InitCompleted())
          .take(1)
          .takeUntil(
              actions.where((action) => action is StopObservingInitState));
    });
  };
}
