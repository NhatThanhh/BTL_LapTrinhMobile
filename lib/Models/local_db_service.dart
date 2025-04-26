import 'package:money_management/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../Models/category_model.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  static LocalDbService get instance => _instance;
  LocalDbService._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user.db');
    // await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            email TEXT UNIQUE,
            password TEXT,
            phone TEXT,
            remainingAmount INTEGER,
            totalCredit INTEGER,
            totalDebit INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount INTEGER,
            type TEXT,
            timestamp INTEGER,
            categoryId INTEGER,
            date TEXT,
            monthYear TEXT,
            userId INTEGER, 
            FOREIGN KEY (categoryId) REFERENCES categories(id),
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertUser(UserModel user) async {
    final database = await db;
    return await database.insert('users', user.toMap());
  }
  Future<int> updateUser(UserModel user) async {
    final database = await db;
    return await database.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
  Future<UserModel?> getUserByEmail(String email) async {
    final database = await db;
    final result = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    } else {
      return null;
    }
  }
  Future<int> insertTransaction(TransactionModel tx) async {
    final database = await db;
    return await database.insert('transactions', tx.toMap());
  }
  Future<List<TransactionModel>> getAllTransactions(int userId) async {
    final database = await db;
    final result = await database.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }
  Future<int> updateTransaction(TransactionModel tx) async {
    final database = await db;
    return await database.update(
      'transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }
  Future<List<Map<String, dynamic>>> getRecentTransactions(int userId) async {
    final database = await db;
    return await database.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: 10,
    );
  }

  Future<void> deleteTransaction(int id) async {
    final database = await db;
    await database.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<UserModel?> getUserById(int id) async {
    final database = await db;
    final result = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }
  Future<int> insertCategory(CategoryModel category) async {
    final database = await db;
    return await database.insert('categories', category.toMap());
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final database = await db;
    final result = await database.query('categories');
    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<int> updateCategory(CategoryModel category) async {
    final database = await db;
    return await database.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(int id) async {
    final database = await db;
    await database.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<CategoryModel?> getCategoryById(int id) async {
    final database = await db;
    final result = await database.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return CategoryModel.fromMap(result.first);
    }
    return null;
  }
  Future<List<TransactionModel>> getTransactionsByFilter({
    required int userId,
    required String type,
    required String monthYear,
    String? category,
  }) async {
    final database = await db;
    // Tạo điều kiện WHERE
    String where = 'userId = ? AND type = ? AND monthYear = ?';
    List<dynamic> whereArgs = [userId, type, monthYear];

    if (category != null) {
      where += ' AND categoryId IN (SELECT id FROM categories WHERE name = ?)';
      whereArgs.add(category);
    }

    final result = await database.query(
      'transactions',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );

    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }
  Future<void> deleteTransactionsByUserId(int userId) async {
    final database = await db;
    await database.delete(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }


}


