import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'feeding_event.dart';
part 'feeding_state.dart';

class FeedingBloc extends Bloc<FeedingEvent, FeedingState> {
  FeedingBloc() : super(FeedingInitial()) {
    on<FeedingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
