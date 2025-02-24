import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
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
    // Add table creation here
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // example migration from version 1 to 2
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE hive ADD COLUMN hive_type TEXT');
    // }

  }

}