part of 'inspection_bloc.dart';

sealed class InspectionEvent extends Equatable {
  const InspectionEvent();

  @override
  List<Object?> get props => [];
}

// MARK: - Apiary & Hive Selection Events
final class LoadApiariesEvent extends InspectionEvent {
  final bool autoSelectApiary;
  
  const LoadApiariesEvent({this.autoSelectApiary = true});
  
  @override
  List<Object?> get props => [autoSelectApiary];
}

final class SelectApiaryEvent extends InspectionEvent {
  final String apiaryId;
  
  const SelectApiaryEvent(this.apiaryId);
  
  @override
  List<Object?> get props => [apiaryId];
}

final class ResetApiaryEvent extends InspectionEvent {
  const ResetApiaryEvent();
}

final class SelectHiveEvent extends InspectionEvent {
  final String hiveId;
  
  const SelectHiveEvent(this.hiveId);
  
  @override
  List<Object?> get props => [hiveId];
}

final class ResetHiveEvent extends InspectionEvent {
  const ResetHiveEvent();
}

// MARK: - Field Management Events
final class UpdateFieldEvent extends InspectionEvent {
  final String fieldName;
  final dynamic value;
  
  const UpdateFieldEvent(this.fieldName, this.value);
  
  @override
  List<Object?> get props => [fieldName, value];
}

final class ResetFieldEvent extends InspectionEvent {
  final String fieldName;
  
  const ResetFieldEvent(this.fieldName);
  
  @override
  List<Object?> get props => [fieldName];
}

final class ResetAllFieldsEvent extends InspectionEvent {}

final class ToggleSectionEvent extends InspectionEvent {
  final String sectionKey;
  
  const ToggleSectionEvent(this.sectionKey);
  
  @override
  List<Object?> get props => [sectionKey];
}

// MARK: - Reporting Events
final class SaveInspectionReport extends InspectionEvent {
  const SaveInspectionReport();
}

class SyncFrameCountsWithHiveEvent extends InspectionEvent {
  const SyncFrameCountsWithHiveEvent();
}

class UpdateFrameNetChangeEvent extends InspectionEvent {
  final String fieldName;
  final int value;

  const UpdateFrameNetChangeEvent({
    required this.fieldName,
    required this.value,
  });

  @override
  List<Object?> get props => [fieldName, value];
}

class UpdateBoxCountEvent extends InspectionEvent {
  final String boxType; // 'brood' or 'honey'
  final int newValue;
  final int oldValue;

  const UpdateBoxCountEvent({
    required this.boxType,
    required this.newValue,
    required this.oldValue,
  });

  @override
  List<Object?> get props => [boxType, newValue, oldValue];
}

class UpdateBoxAndFramesEvent extends InspectionEvent {
  final String boxType; // 'brood' or 'honey'
  final int boxNetChange;
  final Map<String, dynamic> frameUpdates; // Map of field names to values

  const UpdateBoxAndFramesEvent({
    required this.boxType,
    required this.boxNetChange,
    required this.frameUpdates,
  });

  @override
  List<Object?> get props => [boxType, boxNetChange, frameUpdates];
}