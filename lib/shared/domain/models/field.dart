import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

class Field extends Equatable {
  final String reportId;
  final String attributeId;
  final String value;
  final Attribute attribute;
  final DateTime createdAt; // Add createdAt property

  const Field({
    required this.reportId,
    required this.attributeId,
    required this.value,
    required this.attribute,
    required this.createdAt, // Add createdAt to constructor
  });

  @override
  List<Object?> get props => [
    reportId, 
    attributeId, 
    value,
    attribute,
    createdAt, // Include createdAt in props
  ];

  /// Get the field value converted to the specified type
  T? getValue<T>({T? defaultValue}) {
    if (value.isEmpty) {
      return defaultValue;
    } else if (T == bool) {
      final boolValue = value.toLowerCase() == 'true';
      return boolValue as T?;
    } else if (T == int) {
      final intValue = int.tryParse(value) ?? defaultValue;
      return intValue as T?;
    } else if (T == double) {
      final doubleValue = double.tryParse(value) ?? defaultValue;
      return doubleValue as T?;
    } else if (T == List<String>) {
      final listValue = value.split(',').map((e) => e.trim()).toList();
      return listValue as T?;
    }    
    else {
      return value as T?;
    }
  }

  /// Create a new field with the same attributeId but different value
  Field withValue(dynamic newValue) {
    return Field(
      reportId: reportId,
      attributeId: attributeId,
      value: newValue.toString(),
      attribute: attribute,
      createdAt: createdAt, // Add createdAt to withValue
    );
  }

  Field copyWith({
    String Function()? reportId,
    String Function()? attributeId,
    String Function()? value,
    Attribute Function()? attribute,
    DateTime Function()? createdAt, // Add createdAt to copyWith
  }) {
    return Field(
      reportId: reportId != null ? reportId() : this.reportId,
      attributeId: attributeId != null ? attributeId() : this.attributeId,
      value: value != null ? value() : this.value,
      attribute: attribute != null ? attribute() : this.attribute,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
    );
  }
}
