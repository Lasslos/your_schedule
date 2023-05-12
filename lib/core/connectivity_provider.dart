import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//TODO: Add possibility to request something as soon as there is a connection
//TODO: Catch connection error and don't report them more reliably
final connectivityProvider = StreamProvider<ConnectivityResult>(
  (ref) async* {
    yield await Connectivity().checkConnectivity();
    yield* Connectivity().onConnectivityChanged;
  },
);
