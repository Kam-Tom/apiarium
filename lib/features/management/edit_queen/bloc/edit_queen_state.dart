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
  final String? id;
  final String name;
  final QueenBreed? queenBreed;
  final DateTime birthDate;
  final QueenSource source;
  final bool marked;
  final Color? markColor;
  final QueenStatus queenStatus;
  final String? origin;
  final double queenCost; // Add cost field
  final Apiary? selectedApiary;
  final Hive? selectedHive;
  final EditQueenStatus status;
  final List<QueenBreed> availableBreeds;
  final List<Apiary> availableApiaries;
  final List<Hive> availableHives;
  final bool shouldShowLocation;
  final bool isCreatedFromHive;
  final String? errorMessage;
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
    this.id,
    this.name = '',
    this.queenBreed,
    required this.birthDate,
    this.source = QueenSource.bred,
    this.marked = false,
    this.markColor,
    this.queenStatus = QueenStatus.active,
    this.origin,
    this.queenCost = 0.0, // Default cost
    this.selectedApiary,
    this.selectedHive,
    this.status = EditQueenStatus.initial,
    this.availableBreeds = const [],
    this.availableApiaries = const [],
    this.availableHives = const [],
    this.shouldShowLocation = true,
    this.isCreatedFromHive = false,
    this.errorMessage,
    this.queen,
  });

  EditQueenState copyWith({
    String? Function()? id,
    String? Function()? name,
    QueenBreed? Function()? queenBreed,
    DateTime? Function()? birthDate,
    QueenSource? Function()? source,
    bool? Function()? marked,
    Color? Function()? markColor,
    QueenStatus? Function()? queenStatus,
    String? Function()? origin,
    double? Function()? queenCost, // Add to copyWith
    Apiary? Function()? selectedApiary,
    Hive? Function()? selectedHive,
    EditQueenStatus? Function()? status,
    List<QueenBreed>? Function()? availableBreeds,
    List<Apiary>? Function()? availableApiaries,
    List<Hive>? Function()? availableHives,
    bool? Function()? shouldShowLocation,
    bool? Function()? isCreatedFromHive,
    String? Function()? errorMessage,
    Queen? Function()? queen,
  }) {
    return EditQueenState(
      id: id?.call() ?? this.id,
      name: name?.call() ?? this.name,
      queenBreed: queenBreed?.call() ?? this.queenBreed,
      birthDate: birthDate?.call() ?? this.birthDate,
      source: source?.call() ?? this.source,
      marked: marked?.call() ?? this.marked,
      markColor: markColor?.call() ?? this.markColor,
      queenStatus: queenStatus?.call() ?? this.queenStatus,
      origin: origin?.call() ?? this.origin,
      queenCost: queenCost?.call() ?? this.queenCost, // Add to copyWith
      selectedApiary: selectedApiary?.call() ?? this.selectedApiary,
      selectedHive: selectedHive?.call() ?? this.selectedHive,
      status: status?.call() ?? this.status,
      availableBreeds: availableBreeds?.call() ?? this.availableBreeds,
      availableApiaries: availableApiaries?.call() ?? this.availableApiaries,
      availableHives: availableHives?.call() ?? this.availableHives,
      shouldShowLocation: shouldShowLocation?.call() ?? this.shouldShowLocation,
      isCreatedFromHive: isCreatedFromHive?.call() ?? this.isCreatedFromHive,
      errorMessage: errorMessage?.call() ?? this.errorMessage,
      queen: queen?.call() ?? this.queen,
    );
  }

  @override
  List<Object?> get props => [
    id, name, queenBreed, birthDate, source, marked, markColor, 
    queenStatus, origin, queenCost, // Add to props
    selectedApiary, selectedHive, status, availableBreeds, availableApiaries, 
    availableHives, shouldShowLocation, isCreatedFromHive, errorMessage, queen,
  ];
}