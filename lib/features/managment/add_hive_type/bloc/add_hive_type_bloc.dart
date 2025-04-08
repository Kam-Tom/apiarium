import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_hive_type_event.dart';
part 'add_hive_type_state.dart';

class AddHiveTypeBloc extends Bloc<AddHiveTypeEvent, AddHiveTypeState> {
  AddHiveTypeBloc() : super(AddHiveTypeInitial()) {
    on<AddHiveTypeEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
