import 'dart:async';
import 'package:flutter/material.dart' show AppLifecycleListener;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

part 'internet_connection_state.dart';

class InternetConnectionCubit extends Cubit<InternetConnectionState> {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  late final AppLifecycleListener _listener;

  InternetConnectionCubit() : super(InternetConnectionInitial()) {
    _checkInternetConnection();
  }

  void _checkInternetConnection() {
    _subscription = Connectivity().onConnectivityChanged
        .debounce(const Duration(milliseconds: 1500))
        .listen(
          (List<ConnectivityResult> result) {
            if (result.contains(ConnectivityResult.wifi) ||
                result.contains(ConnectivityResult.mobile) ||
                result.contains(ConnectivityResult.ethernet)) {
              emit(InternetConnectionConnected());
            } else {
              emit(InternetConnectionDisconnected());
            }
          },
          onError: (error) {
            emit(InternetConnectionError(error: error.toString()));
          },
        );
    _listener = AppLifecycleListener(
      onResume: _subscription.resume,
      onHide: _subscription.pause,
      onPause: _subscription.pause,
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _listener.dispose();
    return super.close();
  }
}
