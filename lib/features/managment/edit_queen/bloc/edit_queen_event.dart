part of 'edit_queen_bloc.dart';

sealed class EditQueenEvent extends Equatable {
  const EditQueenEvent();

  @override
  List<Object?> get props => [];
}

class EditQueenLoadData extends EditQueenEvent {
  final String? queenId;
  
  const EditQueenLoadData({this.queenId});
  
  @override
  List<Object?> get props => [queenId];
}

class EditQueenNameChanged extends EditQueenEvent {
  final String name;
  
  const EditQueenNameChanged(this.name);
  
  @override
  List<Object> get props => [name];
}

class EditQueenBreedChanged extends EditQueenEvent {
  final QueenBreed breed;
  
  const EditQueenBreedChanged(this.breed);
  
  @override
  List<Object> get props => [breed];
}

class EditQueenBirthDateChanged extends EditQueenEvent {
  final DateTime birthDate;
  
  const EditQueenBirthDateChanged(this.birthDate);
  
  @override
  List<Object> get props => [birthDate];
}

class EditQueenSourceChanged extends EditQueenEvent {
  final QueenSource source;
  
  const EditQueenSourceChanged(this.source);
  
  @override
  List<Object> get props => [source];
}

class EditQueenMarkedChanged extends EditQueenEvent {
  final bool marked;
  
  const EditQueenMarkedChanged(this.marked);
  
  @override
  List<Object> get props => [marked];
}

class EditQueenMarkColorChanged extends EditQueenEvent {
  final Color markColor;
  
  const EditQueenMarkColorChanged(this.markColor);
  
  @override
  List<Object> get props => [markColor];
}

class EditQueenStatusChanged extends EditQueenEvent {
  final QueenStatus status;
  
  const EditQueenStatusChanged(this.status);
  
  @override
  List<Object> get props => [status];
}

class EditQueenOriginChanged extends EditQueenEvent {
  final String origin;
  
  const EditQueenOriginChanged(this.origin);
  
  @override
  List<Object> get props => [origin];
}

class EditQueenApiaryChanged extends EditQueenEvent {
  final Apiary? apiary;
  
  const EditQueenApiaryChanged(this.apiary);
  
  @override
  List<Object?> get props => [apiary];
}

class EditQueenHiveChanged extends EditQueenEvent {
  final Hive? hive;
  
  const EditQueenHiveChanged(this.hive);
  
  @override
  List<Object?> get props => [hive];
}

class EditQueenGenerateName extends EditQueenEvent {
  const EditQueenGenerateName();
}

class EditQueenSubmitted extends EditQueenEvent {}

class EditQueenAddSpending extends EditQueenEvent {
  final double amount;
  final DateTime date;
  final Apiary? apiary;
  final String itemName;

  const EditQueenAddSpending({
    required this.amount,
    required this.date,
    required this.apiary,
    required this.itemName,
  });

  @override
  List<Object?> get props => [amount, date, apiary, itemName];
}