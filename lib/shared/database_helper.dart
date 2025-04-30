import 'package:apiarium/shared/shared.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Table definitions
  final queenTable = QueenTable();
  final queenBreedTable = QueenBreedTable();
  final apiaryTable = ApiaryTable();
  final hiveTable = HiveTable();
  final hiveTypeTable = HiveTypeTable();
  final historylogTable = HistoryLogTable();
  final reportTable = ReportTable();
  final fieldTable = FieldTable();

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database = _database ?? await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'apiarium.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tables in proper order for foreign key constraints
    // The order of table creation matters due to foreign key constraints
    await db.execute(apiaryTable.createTableQuery);
    await db.execute(queenBreedTable.createTableQuery);
    await db.execute(queenTable.createTableQuery);
    await db.execute(hiveTypeTable.createTableQuery);
    await db.execute(hiveTable.createTableQuery);
    await db.execute(historylogTable.createTableQuery);
    await db.execute(reportTable.createTableQuery);
    await db.execute(fieldTable.createTableQuery);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // example migration from version 1 to 2
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE hive ADD COLUMN hive_type TEXT');
    // }
  }
}