part of 'internet_connection_cubit.dart';

sealed class InternetConnectionState extends Equatable {
  const InternetConnectionState();

  @override
  List<Object> get props => [];
}

final class InternetConnectionInitial extends InternetConnectionState {}

final class InternetConnectionConnected extends InternetConnectionState {}

final class InternetConnectionDisconnected extends InternetConnectionState {}

final class InternetConnectionError extends InternetConnectionState {
  final String error;
  const InternetConnectionError({required this.error});

  @override
  List<Object> get props => [error];
}
