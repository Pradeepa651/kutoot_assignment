import 'package:flutter_bloc/flutter_bloc.dart';

class FastSrcollingCubit extends Cubit<bool> {
  FastSrcollingCubit() : super(false);

  void updateScrollState(bool isFastScrolling) {
    if (state != isFastScrolling) {
      emit(isFastScrolling);
    }
  }
}
