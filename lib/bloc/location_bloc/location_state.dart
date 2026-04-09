part of 'location_bloc.dart';

sealed class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object> get props => [];
}

final class LocationInitial extends LocationState {}

final class LocationLoading extends LocationState {}

final class LocationLoaded extends LocationState {
  final Position position;
  final String readableAddress; // <-- Add this field

  const LocationLoaded({required this.position, required this.readableAddress});

  @override
  List<Object> get props => [position, readableAddress]; // <-- Include in props
}

final class LocationError extends LocationState {
  final String message;
  final bool isPermanentlyDenied;

  const LocationError(this.message, {this.isPermanentlyDenied = false});
}
