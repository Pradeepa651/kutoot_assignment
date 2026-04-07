import 'package:flutter_bloc/flutter_bloc.dart';

class FastScrollingCubit extends Cubit<bool> {
  FastScrollingCubit() : super(false);

  void updateScrollState(bool isFastScrolling) {
    if (state != isFastScrolling) {
      emit(isFastScrolling);
    }
  }
}
