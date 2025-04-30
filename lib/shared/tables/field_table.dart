import 'package:apiarium/shared/shared.dart';

class FieldTable extends BaseTable {
  @override
  String get tableName => 'fields';
  @override
  String get alias => 'f';

  String get reportId => 'report_id';
  String get attributeId => 'attribute_id';  
  String get value => 'value';
  String get createdAt => 'created_at';

  // Aliased column names
  String get xReportId => '${alias}_$reportId';
  String get xAttributeId => '${alias}_$attributeId';
  String get xValue => '${alias}_$value';
  String get xCreatedAt => '${alias}_$createdAt';
  
  @override
  String get createTableQuery => '''
    CREATE TABLE $tableName (
      $reportId TEXT NOT NULL,
      $attributeId TEXT NOT NULL,
      $value TEXT,
      $createdAt TEXT NOT NULL,
      PRIMARY KEY ($reportId, $attributeId),
      FOREIGN KEY ($reportId) REFERENCES reports(id)
    )
  ''';
  
  @override
  String get select => '''
    $tableName.$reportId AS ${alias}_$reportId,
    $tableName.$attributeId AS ${alias}_$attributeId,
    $tableName.$value AS ${alias}_$value,
    $tableName.$createdAt AS ${alias}_$createdAt
  ''';
}
