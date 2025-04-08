import 'package:equatable/equatable.dart';

abstract class BaseDto extends Equatable {
  final bool isDeleted;
  final bool isSynced;
  final DateTime updatedAt;
  
  const BaseDto({
    this.isDeleted = false,
    this.isSynced = false, 
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [isDeleted, isSynced, updatedAt];

  Map<String, dynamic> toSyncMap() => {
    'is_deleted': isDeleted ? 1 : 0,
    'is_synced': isSynced ? 1 : 0,
    'updated_at': updatedAt.toIso8601String(),
  };
}