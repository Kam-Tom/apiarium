part of 'edit_queen_bloc.dart';

enum EditQueenStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure
}

class EditQueenState extends Equatable {
  final EditQueenStatus status;
  final String? errorMessage;
  final String? id;
  final String name;
  final QueenBreed? queenBreed;
  final DateTime birthDate;
  final QueenSource source;
  final bool marked;
  final Color? markColor;
  final QueenStatus queenStatus;
  final String? origin;
  final List<QueenBreed> availableBreeds;
  final List<Apiary> availableApiaries;
  final List<Hive> availableHives;
  final Apiary? selectedApiary;
  final Hive? selectedHive;
  final bool isCreatedFromHive;
  final bool shouldShowLocation;
  final Queen? queen;

  static Color getColorForYear(int year) {
    int lastDigit = year % 10;
    switch (lastDigit) {
      case 1:
      case 6:
        return Colors.white;
      case 2:
      case 7:
        return Colors.yellow;
      case 3:
      case 8:
        return Colors.red;
      case 4:
      case 9:
        return Colors.green;
      case 0:
      case 5:
        return Colors.blue;
      default:
        return Colors.white;
    }
  }
  
  const EditQueenState({
    this.status = EditQueenStatus.initial,
    this.errorMessage,
    this.id,
    this.name = '',
    this.availableBreeds = const [],
    this.availableApiaries = const [],
    this.availableHives = const [],
    this.selectedApiary,
    this.selectedHive,
    this.queenBreed,
    required this.birthDate,
    this.source = QueenSource.bought,
    this.marked = true,
    this.markColor,
    this.queenStatus = QueenStatus.active,
    this.origin,
    this.isCreatedFromHive = false,
    this.shouldShowLocation = true,
    this.queen,
  });

  EditQueenState copyWith({
    EditQueenStatus Function()? status,
    String? Function()? errorMessage,
    String? Function()? id,
    String? Function()? name,
    List<QueenBreed> Function()? availableBreeds,
    List<Apiary> Function()? availableApiaries,
    List<Hive> Function()? availableHives,
    Apiary? Function()? selectedApiary,
    Hive? Function()? selectedHive,
    QueenBreed? Function()? queenBreed,
    DateTime? Function()? birthDate,
    QueenSource? Function()? source,
    bool? Function()? marked,
    Color? Function()? markColor,
    QueenStatus? Function()? queenStatus,
    String? Function()? origin,
    bool Function()? isCreatedFromHive,
    bool Function()? shouldShowLocation,
    Queen? Function()? queen,
  }) {
    return EditQueenState(
      status: status != null ? status() : this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      id: id != null ? id() : this.id,
      name: name != null ? name()! : this.name,
      availableBreeds: availableBreeds != null ? availableBreeds() : this.availableBreeds,
      availableApiaries: availableApiaries != null ? availableApiaries() : this.availableApiaries,
      availableHives: availableHives != null ? availableHives() : this.availableHives,
      selectedApiary: selectedApiary != null ? selectedApiary() : this.selectedApiary,
      selectedHive: selectedHive != null ? selectedHive() : this.selectedHive,
      queenBreed: queenBreed != null ? queenBreed() : this.queenBreed,
      birthDate: birthDate != null ? birthDate()! : this.birthDate,
      source: source != null ? source()! : this.source,
      marked: marked != null ? marked()! : this.marked,
      markColor: markColor != null ? markColor() : this.markColor,
      queenStatus: queenStatus != null ? queenStatus()! : this.queenStatus,
      origin: origin != null ? origin() : this.origin,
      isCreatedFromHive: isCreatedFromHive != null ? isCreatedFromHive() : this.isCreatedFromHive,
      shouldShowLocation: shouldShowLocation != null ? shouldShowLocation() : this.shouldShowLocation,
      queen: queen != null ? queen() : this.queen,
    );
  }
  
  @override
  List<Object?> get props => [
    status, errorMessage,
    id, name, availableBreeds, availableApiaries, availableHives, 
    selectedApiary, selectedHive, queenBreed, birthDate,
    source, marked, markColor, queenStatus, origin,
    isCreatedFromHive, shouldShowLocation,
    queen,
  ];
}