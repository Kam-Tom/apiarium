part of 'edit_hive_type_bloc.dart';

abstract class EditHiveTypeEvent extends Equatable {
  const EditHiveTypeEvent();

  @override
  List<Object?> get props => [];
}

class EditHiveTypeLoadData extends EditHiveTypeEvent {
  final String? hiveTypeId;

  const EditHiveTypeLoadData({this.hiveTypeId});

  @override
  List<Object?> get props => [hiveTypeId];
}

class EditHiveTypeNameChanged extends EditHiveTypeEvent {
  final String name;

  const EditHiveTypeNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class EditHiveTypeManufacturerChanged extends EditHiveTypeEvent {
  final String? manufacturer;

  const EditHiveTypeManufacturerChanged(this.manufacturer);

  @override
  List<Object?> get props => [manufacturer];
}

class EditHiveTypeMaterialChanged extends EditHiveTypeEvent {
  final HiveMaterial material;

  const EditHiveTypeMaterialChanged(this.material);

  @override
  List<Object?> get props => [material];
}

class EditHiveTypeHasFramesChanged extends EditHiveTypeEvent {
  final bool hasFrames;

  const EditHiveTypeHasFramesChanged(this.hasFrames);

  @override
  List<Object?> get props => [hasFrames];
}

class EditHiveTypeFrameStandardChanged extends EditHiveTypeEvent {
  final String? frameStandard;

  const EditHiveTypeFrameStandardChanged(this.frameStandard);

  @override
  List<Object?> get props => [frameStandard];
}

class EditHiveTypeFramesPerBoxChanged extends EditHiveTypeEvent {
  final int? framesPerBox;

  const EditHiveTypeFramesPerBoxChanged(this.framesPerBox);

  @override
  List<Object?> get props => [framesPerBox];
}

class EditHiveTypeBroodFrameCountChanged extends EditHiveTypeEvent {
  final int? count;

  const EditHiveTypeBroodFrameCountChanged(this.count);

  @override
  List<Object?> get props => [count];
}

class EditHiveTypeHoneyFrameCountChanged extends EditHiveTypeEvent {
  final int? count;

  const EditHiveTypeHoneyFrameCountChanged(this.count);

  @override
  List<Object?> get props => [count];
}

class EditHiveTypeBoxCountChanged extends EditHiveTypeEvent {
  final int? count;

  const EditHiveTypeBoxCountChanged(this.count);

  @override
  List<Object?> get props => [count];
}

class EditHiveTypeSuperBoxCountChanged extends EditHiveTypeEvent {
  final int? count;

  const EditHiveTypeSuperBoxCountChanged(this.count);

  @override
  List<Object?> get props => [count];
}

class EditHiveTypeCostChanged extends EditHiveTypeEvent {
  final double? cost;

  const EditHiveTypeCostChanged(this.cost);

  @override
  List<Object?> get props => [cost];
}

class EditHiveTypeToggleStarred extends EditHiveTypeEvent {
  const EditHiveTypeToggleStarred();
}

class EditHiveTypeSubmitted extends EditHiveTypeEvent {
  const EditHiveTypeSubmitted();
}

class EditHiveTypeIconChanged extends EditHiveTypeEvent {
  final IconData icon;

  const EditHiveTypeIconChanged(this.icon);

  @override
  List<Object?> get props => [icon];
}

class EditHiveTypeImageChanged extends EditHiveTypeEvent {
  final String? imagePath;

  const EditHiveTypeImageChanged(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class EditHiveTypeImageDeleted extends EditHiveTypeEvent {
  const EditHiveTypeImageDeleted();
}