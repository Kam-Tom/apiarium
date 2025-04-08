import 'package:equatable/equatable.dart';

class QueenBreed extends Equatable {
  final String id;
  final String name;           // Common name (e.g., "Carniolan")
  final String? scientificName; // Latin name (optional)
  final String? origin;         // Region of origin (optional)

  // Sorting and filtering fields
  final int priority;
  final String? country;
  final bool isStarred;
  
  const QueenBreed({
    required this.id,
    required this.name,
    this.scientificName,
    this.origin,
    this.priority = 0,
    this.country,
    this.isStarred = false,
  });

  @override
  List<Object?> get props => [
    id, name, scientificName, origin, priority, country, isStarred
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'origin': origin,
      'priority': priority,
      'country': country,
      'isStarred': isStarred ? 1 : 0,
    };
  }
  
  QueenBreed copyWith({
    String Function()? id,
    String Function()? name,
    String? Function()? scientificName,
    String? Function()? origin,
    int Function()? priority,
    String? Function()? country,
    bool Function()? isStarred,
  }) {
    return QueenBreed(
      id: id != null ? id() : this.id,
      name: name != null ? name() : this.name,
      scientificName: scientificName != null ? scientificName() : this.scientificName,
      origin: origin != null ? origin() : this.origin,
      priority: priority != null ? priority() : this.priority,
      country: country != null ? country() : this.country,
      isStarred: isStarred != null ? isStarred() : this.isStarred,
    );
  }
}
