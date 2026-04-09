import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/location_bloc/location_bloc.dart';

class LocationView extends StatelessWidget {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        return switch (state) {
          LocationInitial() => const SizedBox.shrink(),
          LocationLoading() => Container(
            padding: const EdgeInsets.all(16),
            height: 35,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
          ),
          LocationLoaded(:var readableAddress) => Container(
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.deepOrange),
                Text(
                  readableAddress,
                  style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                ),
              ],
            ),
          ),
          LocationError(:var message, :var isPermanentlyDenied) => Column(
            children: [
              Text(message),
              if (isPermanentlyDenied)
                const Text('Please enable location permissions from settings.'),
            ],
          ),
        };
      },
    );
  }
}
