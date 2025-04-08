part of 'edit_hive_bloc.dart';

abstract class EditHiveEvent extends Equatable {
  const EditHiveEvent();

  @override
  List<Object?> get props => [];
}

class EditHiveLoadData extends EditHiveEvent {
  final String? hiveId;

  const EditHiveLoadData({this.hiveId});
  
  @override
  List<Object?> get props => [hiveId];
}

class EditHiveNameChanged extends EditHiveEvent {
  final String name;

  const EditHiveNameChanged(this.name);
  
  @override
  List<Object> get props => [name];
}

class EditHiveApiaryChanged extends EditHiveEvent {
  final Apiary? apiary;

  const EditHiveApiaryChanged(this.apiary);
  
  @override
  List<Object?> get props => [apiary];
}

class EditHiveTypeChanged extends EditHiveEvent {
  final HiveType hiveType;

  const EditHiveTypeChanged(this.hiveType);
  
  @override
  List<Object> get props => [hiveType];
}

class EditHiveQueenChanged extends EditHiveEvent {
  final Queen? queen;

  const EditHiveQueenChanged(this.queen);
  
  @override
  List<Object?> get props => [queen];
}

class EditHiveCreateDefaultQueen extends EditHiveEvent {
  const EditHiveCreateDefaultQueen();
}

class EditHiveStatusChanged extends EditHiveEvent {
  final HiveStatus status;

  const EditHiveStatusChanged(this.status);
  
  @override
  List<Object> get props => [status];
}

class EditHiveAcquisitionDateChanged extends EditHiveEvent {
  final DateTime date;

  const EditHiveAcquisitionDateChanged(this.date);
  
  @override
  List<Object> get props => [date];
}

class EditHiveColorChanged extends EditHiveEvent {
  final Color? color;

  const EditHiveColorChanged(this.color);
  
  @override
  List<Object?> get props => [color];
}

class EditHiveFrameCountChanged extends EditHiveEvent {
  final int? count;

  const EditHiveFrameCountChanged(this.count);
  
  @override
  List<Object?> get props => [count];
}

class EditHiveBroodFrameCountChanged extends EditHiveEvent {
  final int? count;

  const EditHiveBroodFrameCountChanged(this.count);
  
  @override
  List<Object?> get props => [count];
}

class EditHiveBroodBoxCountChanged extends EditHiveEvent {
  final int? count;

  const EditHiveBroodBoxCountChanged(this.count);

  @override
  List<Object?> get props => [count];
}

class EditHiveHoneySuperBoxCountChanged extends EditHiveEvent {
  final int? count;

  const EditHiveHoneySuperBoxCountChanged(this.count);

  @override
  List<Object?> get props => [count];
}

class EditHiveToggleStarHiveType extends EditHiveEvent {
  final HiveType hiveType;

  const EditHiveToggleStarHiveType(this.hiveType);
  
  @override
  List<Object> get props => [hiveType];
}

class EditHiveAddNewHiveType extends EditHiveEvent {
  final HiveType hiveType;

  const EditHiveAddNewHiveType(this.hiveType);
  
  @override
  List<Object> get props => [hiveType];
}

class EditHiveCreateQueen extends EditHiveEvent {
  final Queen queen;

  const EditHiveCreateQueen(this.queen);
  
  @override
  List<Object> get props => [queen];
}

class EditHiveUpdateQueen extends EditHiveEvent {
  final Queen queen;

  const EditHiveUpdateQueen(this.queen);
  
  @override
  List<Object> get props => [queen];
}

class EditHiveSubmitted extends EditHiveEvent {}