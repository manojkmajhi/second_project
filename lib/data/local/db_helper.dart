import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const String dbName = "toolkit.db";
  static const String tableName = "users";
  static const String productTableName = "product";
  static const String cartTableName = "cart";
  static const String orderTableName = "orders";
  static const String wishlistTableName = "wishlist";

  DBHelper._();
  static final DBHelper instance = DBHelper._();

  static Database? _myDB;

  // Get or create database instance
  Future<Database> getDB() async {
    if (_myDB != null) return _myDB!;
    _myDB = await openDB();
    return _myDB!;
  }

  // Open database
  Future<Database> openDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute("PRAGMA foreign_keys = ON;");

        // Create users table
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            image TEXT
          )
        ''');

        // Create product table
        await db.execute('''
          CREATE TABLE $productTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_name TEXT NOT NULL,
            product_price REAL NOT NULL,
            product_quantity INTEGER NOT NULL,
            details TEXT,
            category TEXT,
            image_path TEXT
          )
        ''');

        // Create cart table
        await db.execute('''
          CREATE TABLE $cartTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            FOREIGN KEY (product_id) REFERENCES $productTableName(id) ON DELETE CASCADE
          )
        ''');

        // Create orders table
        await db.execute('''
          CREATE TABLE $orderTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            total_price REAL NOT NULL,
            order_date TEXT,
            FOREIGN KEY (user_id) REFERENCES $tableName(id) ON DELETE CASCADE
          )
        ''');

        // Create wishlist table
        await db.execute('''
          CREATE TABLE $wishlistTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES $tableName(id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES $productTableName(id) ON DELETE CASCADE
          )
        ''');

        // Create indexes
        await db.execute("CREATE INDEX idx_email ON $tableName(email);");
        await db.execute(
          "CREATE INDEX idx_user_id ON $orderTableName(user_id);",
        );
        await db.execute(
          "CREATE INDEX idx_product_id_cart ON $cartTableName(product_id);",
        );
        await db.execute(
          "CREATE INDEX idx_product_id_wishlist ON $wishlistTableName(product_id);",
        );
      },
    );
  }

  // ✅ Insert Product with Category Normalization
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await getDB();

    if (product['category'] != null) {
      String raw = product['category'].toString().trim();
      product['category'] =
          raw[0].toUpperCase() + raw.substring(1).toLowerCase();
    }

    return await db.insert(productTableName, product);
  }

  // ✅ Get All Products
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await getDB();
    return await db.query(productTableName);
  }

  // ✅ DELETE PRODUCT BY ID
  Future<int> deleteProductById(int id) async {
    final db = await getDB();
    return await db.delete(productTableName, where: 'id = ?', whereArgs: [id]);
  }

  // ✅ Normalize Existing Product Categories (Run once)
  Future<void> normalizeProductCategories() async {
    final db = await getDB();
    List<Map<String, dynamic>> products = await db.query(productTableName);

    for (var product in products) {
      final id = product['id'];
      final rawCategory = (product['category'] ?? '').toString().trim();

      if (rawCategory.isEmpty) continue;

      final normalizedCategory =
          rawCategory[0].toUpperCase() + rawCategory.substring(1).toLowerCase();

      await db.update(
        productTableName,
        {'category': normalizedCategory},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    debugPrint("✅ Product categories normalized.");
  }

  // ✅ Get All Users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await getDB();
    return await db.query(tableName);
  }

  // ✅ Get User By ID
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await getDB();
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // ✅ Delete User By ID
  Future<int> deleteUserById(int id) async {
    final db = await getDB();
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }


  // ✅ Delete Entire DB File (for testing)
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    await deleteDatabase(path);
    debugPrint("🗑️ Database deleted");
  }
}
