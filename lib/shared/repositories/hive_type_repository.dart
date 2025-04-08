import 'package:apiarium/shared/shared.dart';
import 'package:uuid/uuid.dart';

/// Repository for managing hive types in the database
class HiveTypeRepository {
  final DatabaseHelper _databaseHelper;
  final Uuid _uuid = const Uuid();

  HiveTypeRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// Retrieves all queen breeds from the database
  Future<List<HiveType>> getAllTypes() async {
    final db = await _databaseHelper.database;
    final hiveTypeTable = _databaseHelper.hiveTypeTable;

    final results = await db.query(
      hiveTypeTable.tableName,
      where: '${hiveTypeTable.isDeleted} = 0',
      orderBy: '${hiveTypeTable.isStarred} DESC, ${hiveTypeTable.priority} DESC, ${hiveTypeTable.name} ASC',
    );

    return results.map((map) {
      final type = HiveTypeDto.fromMap(map);
      return type.toModel();
    }).toList();
  }

  /// Gets a hive type by ID
  Future<HiveType?> getTypeById(String id) async {
    final db = await _databaseHelper.database;
    final hiveTypeTable = _databaseHelper.hiveTypeTable;

    final results = await db.query(
      hiveTypeTable.tableName,
      where: '${hiveTypeTable.id} = ? AND ${hiveTypeTable.isDeleted} = 0',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      return null;
    }

    final map = results.first;
    final type = HiveTypeDto.fromMap(map, prefix: '${hiveTypeTable.alias}_');
    return type.toModel();
  }

  /// Inserts a new hive type into the database or updates an existing one.
  /// 
  /// If the type doesn't have an ID, one will be generated.
  /// Returns the inserted/updated hive type with its ID.
  Future<HiveType> insertType(HiveType type) async {
    final db = await _databaseHelper.database;
    final hiveTypeTable = _databaseHelper.hiveTypeTable;

    final typeId = type.id.isEmpty ? _uuid.v4() : type.id;

    HiveTypeDto dto = HiveTypeDto.fromModel(
      type.copyWith(id: () => typeId),
      isDeleted: false,
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    await db.insert(
      hiveTypeTable.tableName,
      dto.toMap(),
    );

    return type.copyWith(id: () => typeId);
  }

  /// Updates an existing hive type in the database.
  /// 
  /// The hive type must have a valid ID.
  /// Returns the updated hive type.
  Future<HiveType> updateType(HiveType type) async {
    final db = await _databaseHelper.database;
    final hiveTypeTable = _databaseHelper.hiveTypeTable;
    
    if (type.id.isEmpty) {
      throw ArgumentError('Cannot update a hive type without an ID');
    }
    
    HiveTypeDto dto = HiveTypeDto.fromModel(
      type,
      isDeleted: false,
      isSynced: false,
      updatedAt: DateTime.now(),
    );
    
    await db.update(
      hiveTypeTable.tableName,
      dto.toMap(),
      where: '${hiveTypeTable.id} = ?',
      whereArgs: [type.id],
    );
    
    return type;
  }
}
