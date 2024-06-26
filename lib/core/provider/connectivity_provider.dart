import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@riverpod
Stream<List<ConnectivityResult>> connectivity(ConnectivityRef ref) async* {
  yield await Connectivity().checkConnectivity();
  yield* Connectivity().onConnectivityChanged;
}

@riverpod
bool canMakeRequest(CanMakeRequestRef ref) {
  var connectivity = ref.watch(connectivityProvider);
  return connectivity.hasValue && !connectivity.requireValue.contains(ConnectivityResult.none);
}
