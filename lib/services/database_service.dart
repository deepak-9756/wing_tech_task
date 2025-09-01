import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('customers.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY,
        login TEXT NOT NULL,
        avatar_url TEXT NOT NULL,
        url TEXT NOT NULL,
        is_followed INTEGER DEFAULT 0,
        followed_by TEXT,
        followed_at TEXT
      )
    ''');
  }

  Future<void> insertCustomer(Customer customer) async {
    final db = await instance.database;

    await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Customer>> getCustomers() async {
    final db = await instance.database;
    final maps = await db.query('customers', orderBy: 'id ASC');

    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  Future<void> markCustomerAsFollowed(
    int customerId,
    String employeeEmail,
  ) async {
    final db = await instance.database;

    await db.update(
      'customers',
      {
        'is_followed': 1,
        'followed_by': employeeEmail,
        'followed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  Future<List<Customer>> getFollowedCustomers(String employeeEmail) async {
    final db = await instance.database;
    final maps = await db.query(
      'customers',
      where: 'followed_by = ?',
      whereArgs: [employeeEmail],
    );

    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
