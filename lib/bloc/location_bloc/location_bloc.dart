import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    on<FetchLocationRequested>(_onFetchLocationRequested);
  }

  Future<void> _onFetchLocationRequested(
    FetchLocationRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      // 1. Check if location services (GPS) are enabled on the device
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationError("Location services are disabled on your device."));
        return;
      }

      // 2. Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // 3. Request permission if it is currently denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 4. Handle permanent denial (user checked "Never ask again")
      if (permission == LocationPermission.deniedForever) {
        emit(
          LocationError(
            "Location permission is permanently denied. Please enable it in app settings.",
            isPermanentlyDenied: true,
          ),
        );
        return;
      }

      // 5. If still not granted, emit error
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        emit(LocationError("Location permission was denied."));
        return;
      }

      // 6. Permission granted! Fetch the coordinates.

      Position position = await Geolocator.getCurrentPosition();
      String address = "Address not found";

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Format the address string how you like it
        address = ' ${place.subLocality}';
      }

      emit(LocationLoaded(position: position, readableAddress: address));
    } on LocationServiceDisabledException catch (e) {
      log("Location services are disabled: $e");
      emit(LocationError("Location services are disabled on your device."));
    } on PermissionDeniedException catch (e) {
      log("Location permission denied: ${e.message}");
      emit(LocationError(e.toString()));
    } on PlatformException catch (e) {
      log("Platform exception: $e");
      emit(LocationError(e.message ?? "Failed to fetch location: ${e.code}"));
    } on Exception catch (e) {
      emit(LocationError("Failed to fetch location: $e"));
    } catch (e) {
      emit(LocationError("An unexpected error occurred: $e"));
    }
  }
}
