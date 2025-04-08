// Define a contract for database tables
abstract class BaseTable {
  String get tableName;
  String get alias;
  String get select;
  String get createTableQuery;
}