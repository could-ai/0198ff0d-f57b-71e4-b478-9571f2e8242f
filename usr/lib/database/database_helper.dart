import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'passwords.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  Future<int> insertPassword(Password password) async {
    final db = await database;
    return await db.insert('passwords', password.toMap());
  }

  Future<List<Password>> getPasswords() async {
    final db = await database;
    final maps = await db.query('passwords');
    return List.generate(maps.length, (i) => Password.fromMap(maps[i]));
  }

  Future<int> updatePassword(Password password) async {
    final db = await database;
    return await db.update(
      'passwords',
      password.toMap(),
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  Future<int> deletePassword(int id) async {
    final db = await database;
    return await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}