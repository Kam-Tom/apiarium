import 'dart:ui';

import 'package:apiarium/shared/shared.dart';
import 'package:equatable/equatable.dart';

class Queen extends Equatable {
  final String id;
  final String name;  // Name or marking number
  final QueenBreed breed;
  final DateTime birthDate;
  final QueenSource source;
  final bool marked;
  final Color? markColor;
  final QueenStatus status;
  final String? origin; // Where the queen comes from
  final Apiary? apiary;
  final Hive? hive;
  
  const Queen({
    required this.id,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.source,
    required this.marked,
    this.markColor,
    required this.status,
    this.origin,
    this.apiary,
    this.hive,
  });

  @override
  List<Object?> get props => [
    id, name, breed, birthDate, source,
    marked, markColor, status, origin, apiary, hive
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed_id': breed.id,
      'birthDate': birthDate.toIso8601String(),
      'source': source.name,
      'marked': marked ? 1 : 0,
      'markColor': markColor?.toHex(),
      'status': status.name,
      'origin': origin,
    };
  }
  
  Queen copyWith({
    String Function()? id,
    String Function()? name,
    QueenBreed Function()? breed,
    DateTime Function()? birthDate,
    QueenSource Function()? source,
    bool Function()? marked,
    Color? Function()? markColor,
    QueenStatus Function()? status,
    String? Function()? origin,
    Apiary? Function()? apiary,
    Hive? Function()? hive,
  }) {
    return Queen(
      id: id != null ? id() : this.id,
      name: name != null ? name() : this.name,
      breed: breed != null ? breed() : this.breed,
      birthDate: birthDate != null ? birthDate() : this.birthDate,
      source: source != null ? source() : this.source,
      marked: marked != null ? marked() : this.marked,
      markColor: markColor != null ? markColor() : this.markColor,
      status: status != null ? status() : this.status,
      origin: origin != null ? origin() : this.origin,
      apiary: apiary != null ? apiary() : this.apiary,
      hive: hive != null ? hive() : this.hive,
    );
  }
}
