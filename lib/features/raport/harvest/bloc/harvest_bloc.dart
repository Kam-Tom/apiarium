import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'harvest_event.dart';
part 'harvest_state.dart';

class HarvestBloc extends Bloc<HarvestEvent, HarvestState> {
  HarvestBloc() : super(HarvestInitial()) {
    on<HarvestEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
