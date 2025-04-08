import 'package:apiarium/shared/shared.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Repository for managing queen breeds in the database
class QueenBreedRepository {
  final DatabaseHelper _databaseHelper;
  final Uuid _uuid = const Uuid();

  QueenBreedRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// Retrieves all queen breeds from the database
  Future<List<QueenBreed>> getAllBreeds() async {
    final db = await _databaseHelper.database;
    final breedTable = _databaseHelper.queenBreedTable;

    final results = await db.query(
      breedTable.tableName,
      where: '${breedTable.isDeleted} = 0',
      orderBy: '${breedTable.isStarred} DESC, ${breedTable.priority} DESC, ${breedTable.name} ASC',
    );

    return results.map((map) {
      final breed = QueenBreedDto.fromMap(map);
      return breed.toModel();
    }).toList();
  }

  /// Gets a breed by ID
  Future<QueenBreed?> getBreedById(String id) async {
    final db = await _databaseHelper.database;
    final breedTable = _databaseHelper.queenBreedTable;

    final results = await db.query(
      breedTable.tableName,
      where: '${breedTable.id} = ? AND ${breedTable.isDeleted} = 0',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      return null;
    }

    final map = results.first;
    final breed = QueenBreedDto.fromMap(map);
    return breed.toModel();
  }

  /// Inserts a new queen breed into the database.
  /// 
  /// If the breed doesn't have an ID, one will be generated.
  /// Returns the inserted queen breed with its ID.
  Future<QueenBreed> insertBreed(QueenBreed breed) async {
    final db = await _databaseHelper.database;
    final breedTable = _databaseHelper.queenBreedTable;

    final breedId = breed.id.isEmpty ? _uuid.v4() : breed.id;

    QueenBreedDto dto = QueenBreedDto.fromModel(
      breed.copyWith(id: () => breedId),
      isDeleted: false,
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    await db.insert(
      breedTable.tableName,
      dto.toMap()
    );

    return breed.copyWith(id: () => breedId);
  }

  /// Updates an existing queen breed in the database.
  /// 
  /// The breed must have a valid ID.
  /// Returns the updated queen breed.
  Future<QueenBreed> updateBreed(QueenBreed breed) async {
    final db = await _databaseHelper.database;
    final breedTable = _databaseHelper.queenBreedTable;
    
    if (breed.id.isEmpty) {
      throw ArgumentError('Cannot update a breed without an ID');
    }

    QueenBreedDto dto = QueenBreedDto.fromModel(
      breed,
      isDeleted: false,
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    await db.update(
      breedTable.tableName,
      dto.toMap(),
      where: '${breedTable.id} = ?',
      whereArgs: [breed.id],
    );

    return breed;
  }
}
