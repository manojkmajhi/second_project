import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper getInstance = DBHelper._();

  static Database? _myDB;

  Future<Database> getDB() async {
    if (_myDB != null) return _myDB!;
    _myDB = await openDB();
    return _myDB!;
  }

  Future<Database> openDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "mydatabase.db");

    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        // Create users table
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');

        // Create product table
        await db.execute('''
          CREATE TABLE product(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_name TEXT NOT NULL,
            product_price REAL NOT NULL,
            details TEXT,
            category TEXT,
            image_path TEXT
          )
        ''');
      },

      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE product ADD COLUMN image_path TEXT');
        }
      },
    );
  }
}
