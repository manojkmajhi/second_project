import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:second_project/database/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const String dbName = "toolkit.db";
  static const String userTableName = "users";
  static const String productTableName = "product";
  static const String cartTableName = "cart";
  static const String orderTableName = "orders";
  static const String reviewTableName = "reviews";

  DBHelper._();
  static final DBHelper instance = DBHelper._();
  static Database? _myDB;

  Future<Database> getDB() async {
    if (_myDB != null) return _myDB!;
    _myDB = await openDB();
    return _myDB!;
  }

  Future<Database> openDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    return await openDatabase(
      path,
      version: 6, // Current database version
      onCreate: (Database db, int version) async {
        await db.execute("PRAGMA foreign_keys = ON;");
        await db.execute('''
          CREATE TABLE $userTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            image TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE $productTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_name TEXT NOT NULL,
            product_price REAL NOT NULL,
            product_quantity INTEGER NOT NULL,
            details TEXT,
            category TEXT,
            image_path TEXT,
            search_count INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE $cartTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            FOREIGN KEY (product_id) REFERENCES $productTableName(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE $orderTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            total_price REAL NOT NULL,
            order_date TEXT,
            products TEXT, -- This column is created here for new databases
            delivery_address TEXT,
            status TEXT DEFAULT 'pending',
            FOREIGN KEY (user_id) REFERENCES $userTableName(id) ON DELETE CASCADE
          )
        ''');
        
        await db.execute('''
          CREATE TABLE $reviewTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            reviewer TEXT NOT NULL,
            comment TEXT,
            rating INTEGER,
            timestamp TEXT,
            FOREIGN KEY (product_id) REFERENCES $productTableName(id) ON DELETE CASCADE
          )
        ''');
        await db.execute("CREATE INDEX idx_email ON $userTableName(email);");
        await db.execute(
          "CREATE INDEX idx_user_id ON $orderTableName(user_id);",
        );
        await db.execute(
          "CREATE INDEX idx_product_id_cart ON $cartTableName(product_id);",
        );
       
        await db.execute(
          "CREATE INDEX idx_product_id_reviews ON $reviewTableName(product_id);",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // --- Migration from version 1 to 2 (if any) ---
        // if (oldVersion < 2) {
        //   // Example: Add a column for version 2
        //   // await db.execute("ALTER TABLE some_table ADD COLUMN new_column TEXT");
        // }

        // --- Migration from version 2 to 3 ---
        if (oldVersion < 3) {
          // Add search_count column to product table
          await db.execute(
            "ALTER TABLE $productTableName ADD COLUMN search_count INTEGER DEFAULT 0",
          );
        }

        // --- Migration from version 3 to 4 ---
        // The 'products' column was added in your onCreate for version 6.
        // If it was *not* in onCreate for older versions (e.g., version 3),
        // then this is where it should be added.
        // Assuming 'products' was missing in version 3 and added in version 4.
        if (oldVersion < 4) {
          await db.execute(
            "ALTER TABLE $orderTableName ADD COLUMN products TEXT",
          );
          await db.execute(
            "ALTER TABLE $orderTableName ADD COLUMN status TEXT DEFAULT 'pending'",
          );
        }

        // --- Migration from version 4 to 5 ---
        if (oldVersion < 5) {
          await db.execute(
            "ALTER TABLE $orderTableName ADD COLUMN delivery_address TEXT",
          );
        }

      
      },
    );
  }

  // ==================== AUTH ====================
  Future<bool> loginUser(String email, String password) async {
    final db = await getDB();
    final result = await db.query(
      userTableName,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      final user = result.first;
      await SharedPreferenceHelper().saveUserId(user['id'].toString());
      await SharedPreferenceHelper().saveUserName(user['name'].toString());
      await SharedPreferenceHelper().saveUserEmail(user['email'].toString());
      await SharedPreferenceHelper().saveUserImage(
        user['image']?.toString() ?? '',
      );
      debugPrint("✅ User logged in: ${user['name']}");
      return true;
    }
    debugPrint("❌ No user found with those credentials");
    return false;
  }

  Future<void> logoutUser() async =>
      await SharedPreferenceHelper().clearUserData();
  Future<bool> isUserLoggedIn() async =>
      await SharedPreferenceHelper().isUserLoggedIn();

  Future<Map<String, dynamic>?> getLoggedInUser() async {
    final userIdStr = await SharedPreferenceHelper().getUserId();
    if (userIdStr == null) return null;
    final userId = int.tryParse(userIdStr);
    if (userId == null) return null;
    return await getUserById(userId);
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await getDB();
    final result = await db.query(userTableName, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await getDB();
    return await db.query(userTableName);
  }

  Future<int> deleteUserById(int id) async {
    final db = await getDB();
    return await db.delete(userTableName, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== PRODUCT ====================
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await getDB();
    if (product['category'] != null) {
      String raw = product['category'].toString().trim();
      product['category'] =
          raw[0].toUpperCase() + raw.substring(1).toLowerCase();
    }
    return await db.insert(productTableName, product);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await getDB();
    return await db.query(productTableName);
  }

  Future<int> deleteProductById(int id) async {
    final db = await getDB();
    return await db.delete(productTableName, where: 'id = ?', whereArgs: [id]);
  }

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
  }

  Future<void> incrementSearchCount(String productName) async {
    final db = await getDB();
    await db.rawUpdate(
      'UPDATE $productTableName SET search_count = search_count + 1 WHERE product_name = ?',
      [productName],
    );
  }

  Future<List<Map<String, dynamic>>> getTopSearchedProducts({
    int limit = 10,
  }) async {
    final db = await getDB();
    return await db.query(
      productTableName,
      orderBy: 'search_count DESC',
      limit: limit,
    );
  }

  Future<int> updateProduct(Map<String, dynamic> product) async {
    final db = await getDB();
    return await db.update(
      'product',
      {
        'product_name': product['product_name'],
        'product_price': product['product_price'],
        'product_quantity': product['product_quantity'],
        'details': product['details'],
        'category': product['category'],
        'image_path': product['image_path'],
      },
      where: 'id = ?',
      whereArgs: [product['id']],
    );
  }

  // ==================== CART ====================
  Future<int> addToCart(int productId, int quantity) async {
    final db = await getDB();
    final existing = await db.query(
      cartTableName,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    if (existing.isNotEmpty) {
      final existingQuantity = existing.first['quantity'] as int;
      return await db.update(
        cartTableName,
        {'quantity': existingQuantity + quantity},
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } else {
      return await db.insert(cartTableName, {
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await getDB();
    return await db.rawQuery('''
      SELECT c.id, c.product_id, c.quantity, p.product_name, p.product_price, p.image_path
      FROM $cartTableName c
      JOIN $productTableName p ON c.product_id = p.id
    ''');
  }

  Future<int> clearCart() async => (await getDB()).delete(cartTableName);
  Future<int> removeFromCart(int productId) async => (await getDB()).delete(
    cartTableName,
    where: 'product_id = ?',
    whereArgs: [productId],
  );

  // ==================== ORDER ====================
  Future<void> insertOrder({
    required int userId,
    required double totalPrice,
    required String productsJson,
    required String deliveryAddress,
    String status = 'pending',
  }) async {
    final db = await getDB();
    await db.insert(orderTableName, {
      'user_id': userId,
      'total_price': totalPrice,
      'order_date': DateTime.now().toIso8601String(),
      'products': productsJson,
      'delivery_address': deliveryAddress,
      'status': status,
    });
  }

  Future<List<Map<String, dynamic>>> getOrdersByLoggedInUser() async {
    final db = await getDB();
    final userId = await SharedPreferenceHelper().getUserId();
    if (userId == null) return [];
    return await db.query(
      orderTableName,
      where: 'user_id = ?',
      whereArgs: [int.parse(userId)],
      orderBy: 'order_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async =>
      (await getDB()).query(orderTableName, orderBy: 'order_date DESC');

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final db = await getDB();
    await db.update(
      orderTableName,
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> deleteOrderById(int id) async =>
      (await getDB()).delete(orderTableName, where: 'id = ?', whereArgs: [id]);

  // ==================== REVIEW ====================
  Future<void> insertReview(
    int productId,
    int rating,
    String reviewText,
  ) async {
    final db = await getDB();
    final user = await getLoggedInUser();
    final reviewer = user?['name'] ?? 'Anonymous';
    await db.insert(reviewTableName, {
      'product_id': productId,
      'reviewer': reviewer,
      'comment': reviewText,
      'rating': rating,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getReviewsForProduct(int productId) async {
    final db = await getDB();
    return await db.query(
      reviewTableName,
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getReviewsByProductId(
    int productId,
  ) async {
    final db = await getDB();
    return await db.query(
      reviewTableName,
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'timestamp DESC',
    );
  }

  // ==================== RECOMMENDATION ====================
  Future<List<Map<String, dynamic>>> getRecommendedProductsSimple(
    String category,
    int currentProductId, {
    String? productName,
    String? details,
  }) async {
    final db = await getDB();
    final allProducts = await db.query(
      productTableName,
      where: 'id != ?',
      whereArgs: [currentProductId],
    );

    if (details == null || details.trim().isEmpty) {
      return allProducts;
    }

    String lowerDetails = details.toLowerCase();

    Map<Map<String, dynamic>, int> similarityScores = {};
    for (var product in allProducts) {
      String productDetails =
          (product['details'] ?? '').toString().toLowerCase();
      int matchScore = 0;

      for (var word in lowerDetails.split(' ')) {
        if (productDetails.contains(word)) {
          matchScore += 1;
        }
      }

      similarityScores[product] = matchScore;
    }

    List<MapEntry<Map<String, dynamic>, int>> sortedEntries =
        similarityScores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.map((entry) => entry.key).toList();
  }

  // ==================== DELETE ====================
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    await deleteDatabase(path);
    debugPrint("🗑️ Database deleted");
  }
}
