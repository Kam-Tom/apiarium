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

class EditQueenHiveNameChanged extends EditQueenEvent {
  final String hiveName;
  
  const EditQueenHiveNameChanged(this.hiveName);
  
  @override
  List<Object> get props => [hiveName];
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
  
  const EditQueenApiaryChanged({
    this.apiary,
  });
  
  @override
  List<Object?> get props => [apiary];
}

class EditQueenHiveChanged extends EditQueenEvent {
  final Hive? hive;
  
  const EditQueenHiveChanged({
    this.hive,
  });
  
  @override
  List<Object?> get props => [hive];
}

class EditQueenCreateBreed extends EditQueenEvent {
  final String name;
  final String? scientificName;
  final String? origin;
  final String? country;
  final bool isStarred;
  
  const EditQueenCreateBreed({
    required this.name,
    this.scientificName,
    this.origin,
    this.country,
    this.isStarred = false,
  });
  
  @override
  List<Object?> get props => [
    name, scientificName, origin, country, isStarred
  ];
}

class EditQueenToggleBreedStar extends EditQueenEvent {
  final QueenBreed breed;
  
  const EditQueenToggleBreedStar(this.breed);
  
  @override
  List<Object> get props => [breed];
}

class EditQueenSubmitted extends EditQueenEvent {}