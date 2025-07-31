part of 'edit_apiary_bloc.dart';

abstract class EditApiaryEvent extends Equatable {
  const EditApiaryEvent();

  @override
  List<Object?> get props => [];
}

class EditApiaryLoadData extends EditApiaryEvent {
  final String? apiaryId;

  const EditApiaryLoadData({this.apiaryId});
  
  @override
  List<Object?> get props => [apiaryId];
}

class EditApiaryNameChanged extends EditApiaryEvent {
  final String name;
  
  const EditApiaryNameChanged(this.name);
  
  @override
  List<Object> get props => [name];
}

class EditApiaryDescriptionChanged extends EditApiaryEvent {
  final String description;
  
  const EditApiaryDescriptionChanged(this.description);
  
  @override
  List<Object> get props => [description];
}

class EditApiaryLocationChanged extends EditApiaryEvent {
  final String location;
  
  const EditApiaryLocationChanged(this.location);
  
  @override
  List<Object> get props => [location];
}

class EditApiaryStatusChanged extends EditApiaryEvent {
  final ApiaryStatus status;
  
  const EditApiaryStatusChanged(this.status);
  
  @override
  List<Object> get props => [status];
}

class EditApiaryLocationCoordinatesChanged extends EditApiaryEvent {
  final double? latitude;
  final double? longitude;
  
  const EditApiaryLocationCoordinatesChanged({this.latitude, this.longitude});
  
  @override
  List<Object?> get props => [latitude, longitude];
}

class EditApiaryIsMigratoryChanged extends EditApiaryEvent {
  final bool isMigratory;
  
  const EditApiaryIsMigratoryChanged(this.isMigratory);
  
  @override
  List<Object> get props => [isMigratory];
}

class EditApiaryColorChanged extends EditApiaryEvent {
  final Color? color;
  
  const EditApiaryColorChanged(this.color);
  
  @override
  List<Object?> get props => [color];
}

class EditApiaryAddQueensWithHivesToggled extends EditApiaryEvent {
  final bool addQueensWithHives;
  
  const EditApiaryAddQueensWithHivesToggled(this.addQueensWithHives);
  
  @override
  List<Object> get props => [addQueensWithHives];
}

class EditApiaryAddExistingHive extends EditApiaryEvent {
  final Hive hive;
  
  const EditApiaryAddExistingHive(this.hive);
  
  @override
  List<Object> get props => [hive];
}

class EditApiaryRemoveHive extends EditApiaryEvent {
  final Hive hive;
  
  const EditApiaryRemoveHive(this.hive);
  
  @override
  List<Object> get props => [hive];
}

class EditApiaryReorderHives extends EditApiaryEvent {
  final List<Hive> reorderedHives;
  // Map of hive IDs to their new positions
  final Map<String, int>? swappedPositions;
  
  const EditApiaryReorderHives(this.reorderedHives, {this.swappedPositions});
  
  @override
  List<Object?> get props => [reorderedHives, swappedPositions];
}

class EditApiarySubmitted extends EditApiaryEvent {
  const EditApiarySubmitted();
}

class EditApiaryGenerateName extends EditApiaryEvent {
  const EditApiaryGenerateName();
}

class EditApiaryImageChanged extends EditApiaryEvent {
  final String? imagePath;
  
  const EditApiaryImageChanged(this.imagePath);
  
  @override
  List<Object?> get props => [imagePath];
}

class EditApiaryImageDeleted extends EditApiaryEvent {
  const EditApiaryImageDeleted();
}