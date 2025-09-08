import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("grocery_app.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // bump version from 1 → 2
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userEmail TEXT NOT NULL,
        itemName TEXT NOT NULL,
        quantity TEXT NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (userEmail) REFERENCES users (email) ON DELETE CASCADE
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add items table if upgrading from version 1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userEmail TEXT NOT NULL,
          itemName TEXT NOT NULL,
          quantity TEXT NOT NULL,
          price REAL NOT NULL,
          FOREIGN KEY (userEmail) REFERENCES users (email) ON DELETE CASCADE
        )
      ''');
      print("✅ Upgraded DB: items table created");
    }
  }

  // ---------------- USERS ----------------
  Future<int> insertUser(String email, String password) async {
    final db = await instance.database;
    return await db.insert('users', {
      'email': email,
      'password': password,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // ---------------- ITEMS ----------------
  Future<int> insertItem(
      String userEmail,
      String itemName,
      String quantity,
      double price,
      ) async {
    final db = await instance.database;
    return await db.insert('items', {
      'userEmail': userEmail,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
    });
  }

  Future<List<Map<String, dynamic>>> getItems(String userEmail) async {
    final db = await instance.database;
    return await db.query(
      'items',
      where: 'userEmail = ?',
      whereArgs: [userEmail],
      orderBy: 'id DESC',
    );
  }

  Future<int> updateItem(
      int id,
      String itemName,
      String quantity,
      double price,
      ) async {
    final db = await instance.database;
    return await db.update(
      'items',
      {'itemName': itemName, 'quantity': quantity, 'price': price},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }
}
