// import 'package:apiarium/shared/shared.dart';
// import 'package:uuid/uuid.dart';

// /// Repository for managing inspection reports in the database.
// class ReportRepository {
//   final DatabaseHelper _databaseHelper;
//   final Uuid _uuid = const Uuid();

//   ReportRepository({DatabaseHelper? databaseHelper})
//       : _databaseHelper = databaseHelper ?? DatabaseHelper();

//   /// Retrieves all reports from the database, optionally filtered by type, hive, queen, or apiary.
//   Future<List<Report>> getAllReports({
//     ReportType? type,
//     String? hiveId,
//     String? queenId,
//     String? apiaryId,
//   }) async {
//     final db = await _databaseHelper.database;
//     final reportTable = _databaseHelper.reportTable;

//     final List<String> conditions = ['${reportTable.xIsDeleted} = 0'];
//     final List<dynamic> arguments = [];

//     if (type != null) {
//       conditions.add('${reportTable.xType} = ?');
//       arguments.add(type.name);
//     }
//     if (hiveId != null) {
//       conditions.add('${reportTable.xHiveId} = ?');
//       arguments.add(hiveId);
//     }
//     if (queenId != null) {
//       conditions.add('${reportTable.xQueenId} = ?');
//       arguments.add(queenId);
//     }
//     if (apiaryId != null) {
//       conditions.add('${reportTable.xApiaryId} = ?');
//       arguments.add(apiaryId);
//     }

//     final String whereClause = conditions.join(' AND ');

//     final results = await db.rawQuery(
//       '''
//         SELECT ${reportTable.select}
//         FROM ${reportTable.tableName}
//         WHERE $whereClause
//         ORDER BY ${reportTable.xCreatedAt} DESC
//       ''',
//       arguments
//     );

//     final List<Report> reports = [];
//     for(final map in results) {
//       final report = ReportDto.fromMap(map, prefix: '${reportTable.alias}_').toModel();
//       final fields = await getFields(report: report);
//       reports.add(report.copyWith(fields: () => fields));
//     }
//     return reports;
//   }

//   /// Retrieves a report by filters (id, type, hive, queen, apiary).
//   Future<Report?> getReport({
//     String? id,
//     ReportType? type,
//     String? hiveId,
//     String? queenId,
//     String? apiaryId,
//   }) async {
//     final db = await _databaseHelper.database;
//     final reportTable = _databaseHelper.reportTable;

//     final List<String> conditions = ['${reportTable.xIsDeleted} = 0'];
//     final List<dynamic> arguments = [];

//     if(id != null) {
//       conditions.add('${reportTable.xId} = ?');
//       arguments.add(id);
//     }
//     if (type != null) {
//       conditions.add('${reportTable.xType} = ?');
//       arguments.add(type.name);
//     }
//     if (hiveId != null) {
//       conditions.add('${reportTable.xHiveId} = ?');
//       arguments.add(hiveId);
//     }
//     if (queenId != null) {
//       conditions.add('${reportTable.xQueenId} = ?');
//       arguments.add(queenId);
//     }
//     if (apiaryId != null) {
//       conditions.add('${reportTable.xApiaryId} = ?');
//       arguments.add(apiaryId);
//     }

//     final String whereClause = conditions.join(' AND ');

//     final results = await db.rawQuery(
//       '''
//         SELECT ${reportTable.select}
//         FROM ${reportTable.tableName}
//         WHERE $whereClause
//       ''',
//       arguments
//     );

//     if (results.isEmpty) {
//       return null;
//     }

//     final map = results.first;
//     final report = ReportDto.fromMap(map, prefix: '${reportTable.alias}_').toModel();
//     final fields = await getFields(report: report);
//     return report.copyWith(fields: () => fields);
//   }

//   /// Loads fields for a report.
//   Future<List<Field>> getFields({
//     FieldType? type, 
//     required Report report
//   }) async {
//     final db = await _databaseHelper.database;
//     final fieldTable = _databaseHelper.fieldTable;
//     final reportId = report.id;

//     final results = await db.rawQuery('''
//       SELECT ${fieldTable.select}
//       FROM ${fieldTable.tableName}
//       WHERE ${fieldTable.xReportId} = ?
//     ''', [reportId]);

//     return results.map((result) {
//       final fieldDto = FieldDto.fromMap(result, prefix: '${fieldTable.alias}_');
//       return fieldDto.toModel();
//     }).toList();
//   }


// /// Gets the most recent report fields for all hives in an apiary (batch).
// Future<Map<String, List<Field>>> getRecentFieldsForApiary({
//   required String apiaryId,
//   required ReportType type,
// }) async {
//   final db = await _databaseHelper.database;
//   final reportTable = _databaseHelper.reportTable;
//   final fieldTable = _databaseHelper.fieldTable;

//   final results = await db.rawQuery('''
//     SELECT 
//       f.${fieldTable.reportId}, 
//       f.${fieldTable.attributeId}, 
//       f.${fieldTable.value}, 
//       r.${reportTable.createdAt} as created_at,
//       r.${reportTable.hiveId}
//     FROM ${fieldTable.tableName} f
//     JOIN ${reportTable.tableName} r ON f.${fieldTable.reportId} = r.${reportTable.id}
//     JOIN (
//       SELECT r2.${reportTable.hiveId} as hiveId, f2.${fieldTable.attributeId} as attributeId, MAX(r2.${reportTable.createdAt}) as maxCreated
//       FROM ${fieldTable.tableName} f2
//       JOIN ${reportTable.tableName} r2 ON f2.${fieldTable.reportId} = r2.${reportTable.id}
//       WHERE r2.${reportTable.apiaryId} = ? AND r2.${reportTable.type} = ? AND r2.${reportTable.isDeleted} = 0
//       GROUP BY r2.${reportTable.hiveId}, f2.${fieldTable.attributeId}
//     ) latest
//     ON r.${reportTable.hiveId} = latest.hiveId
//     AND f.${fieldTable.attributeId} = latest.attributeId
//     AND r.${reportTable.createdAt} = latest.maxCreated
//     WHERE r.${reportTable.apiaryId} = ? AND r.${reportTable.type} = ? AND r.${reportTable.isDeleted} = 0
//   ''', [apiaryId, type.name, apiaryId, type.name]);

//   final Map<String, List<Field>> result = {};
//   for (final row in results) {
//     final hiveId = row[reportTable.hiveId] as String;
//     final field = FieldDto.fromMap({
//       'report_id': row[fieldTable.reportId],
//       'attribute_id': row[fieldTable.attributeId],
//       'value': row[fieldTable.value],
//       'created_at': row['created_at'],
//     }).toModel();
//     result[hiveId] = (result[hiveId] ?? [])..add(field);
//   }
//   return result;
// }

//   /// Inserts a new report into the database.
//   Future<String> insertReport(Report report) async {
//     final db = await _databaseHelper.database;
//     final reportTable = _databaseHelper.reportTable;
//     final fieldTable = _databaseHelper.fieldTable;
    
//     return await db.transaction((txn) async {
//       final reportDto = ReportDto.fromModel(report);
//       final reportId = reportDto.id.isEmpty ? _uuid.v4() : reportDto.id;
//       final updatedReportDto = reportDto.copyWith(id: () => reportId);
      
//       await txn.insert(
//         reportTable.tableName,
//         updatedReportDto.toMap(),
//       );
      
//       // Handle fields
//       if (report.fields != null && report.fields!.isNotEmpty) {
//         for (final field in report.fields!) {
//           final fieldDto = FieldDto(
//             reportId: reportId,
//             attributeId: field.attributeId,
//             value: field.value,
//             createdAt: report.createdAt,
//           );
//           await txn.insert(
//             fieldTable.tableName, 
//             fieldDto.toMap(),
//           );
//         }
//       }
      
//       return reportId;
//     });
//   }

//   /// Updates an existing report in the database.
//   Future<bool> updateReport(Report report) async {
//     final db = await _databaseHelper.database;
//     final reportTable = _databaseHelper.reportTable;
//     final fieldTable = _databaseHelper.fieldTable;
    
//     return await db.transaction((txn) async {
//       try {
//         final reportDto = ReportDto.fromModel(report);
//         await txn.update(
//           reportTable.tableName,
//           reportDto.toMap(),
//           where: '${reportTable.id} = ?',
//           whereArgs: [report.id],
//         );
        
//         // Delete existing fields for this report
//         await txn.delete(
//           fieldTable.tableName,
//           where: '${fieldTable.reportId} = ?',
//           whereArgs: [report.id],
//         );
        
//         // Insert fields
//         if (report.fields != null && report.fields!.isNotEmpty) {
//           for (final field in report.fields!) {
//             final fieldDto = FieldDto(
//               reportId: report.id,
//               attributeId: field.attributeId,
//               value: field.value,
//               createdAt: report.createdAt,
//             );
//             await txn.insert(
//               fieldTable.tableName,
//               fieldDto.toMap(),
//             );
//           }
//         }
        
//         return true;
//       } catch (e) {
//         return false;
//       }
//     });
//   }

//   /// Deletes a report from the database (soft delete by default).
//   Future<bool> deleteReport(String reportId, {bool hardDelete = false}) async {
//     final db = await _databaseHelper.database;
//     final reportTable = _databaseHelper.reportTable;
//     final fieldTable = _databaseHelper.fieldTable;
    
//     return await db.transaction((txn) async {
//       try {
//         if (hardDelete) {
//           await txn.delete(
//             fieldTable.tableName,
//             where: '${fieldTable.reportId} = ?',
//             whereArgs: [reportId],
//           );
//           await txn.delete(
//             reportTable.tableName,
//             where: '${reportTable.id} = ?',
//             whereArgs: [reportId],
//           );
//         } else {
//           await txn.update(
//             reportTable.tableName,
//             {
//               'is_deleted': 1,
//               'updated_at': DateTime.now().toIso8601String(),
//             },
//             where: '${reportTable.id} = ?',
//             whereArgs: [reportId],
//           );
//           await txn.delete(
//             fieldTable.tableName,
//             where: '${fieldTable.reportId} = ?',
//             whereArgs: [reportId],
//           );
//         }
//         return true;
//       } catch (e) {
//         return false;
//       }
//     });
//   }
// }