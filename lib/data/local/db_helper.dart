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
  static const String paymentTableName = "payments";

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
      version: 8, // Incremented version number for new changes
      onCreate: (Database db, int version) async {
        await _createDatabase(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _migrateDatabase(db, oldVersion, newVersion);
      },
    );
  }

  Future<void> _createDatabase(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON;");

    // Create users table
    await db.execute('''
      CREATE TABLE $userTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        image TEXT
      )
    ''');

    // Create products table
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

    // Create cart table
    await db.execute('''
      CREATE TABLE $cartTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (product_id) REFERENCES $productTableName(id) ON DELETE CASCADE
      )
    ''');

    // Create orders table with all columns
    await db.execute('''
      CREATE TABLE $orderTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        total_price REAL,
        order_date TEXT,
        products TEXT,
        delivery_address TEXT,
        status TEXT DEFAULT 'pending',
        payment_method TEXT,        
        customer_name TEXT,
        customer_email TEXT,
        customer_phone TEXT,
        FOREIGN KEY (user_id) REFERENCES $userTableName (id)
      )
    ''');

    // Create reviews table with enhanced columns
    await db.execute('''
      CREATE TABLE $reviewTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        reviewer TEXT NOT NULL,
        comment TEXT,
        rating INTEGER NOT NULL,
        media_path TEXT,  -- For image or video path
        timestamp TEXT,
        FOREIGN KEY (product_id) REFERENCES $productTableName(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES $userTableName(id)
      )
    ''');

    // Create payments table
    await db.execute('''
      CREATE TABLE $paymentTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        user_email TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        transaction_id TEXT,
        status TEXT NOT NULL,
        payment_date TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES $orderTableName(id),
        FOREIGN KEY (user_id) REFERENCES $userTableName(id)
      )
    ''');

    // Create indexes
    await db.execute("CREATE INDEX idx_email ON $userTableName(email);");
    await db.execute("CREATE INDEX idx_user_id ON $orderTableName(user_id);");
    await db.execute(
      "CREATE INDEX idx_product_id_cart ON $cartTableName(product_id);",
    );
    await db.execute(
      "CREATE INDEX idx_product_id_reviews ON $reviewTableName(product_id);",
    );
    await db.execute(
      "CREATE INDEX idx_user_id_reviews ON $reviewTableName(user_id);",
    );
    await db.execute(
      "CREATE INDEX idx_order_id_payments ON $paymentTableName(order_id);",
    );
    await db.execute(
      "CREATE INDEX idx_user_id_payments ON $paymentTableName(user_id);",
    );
  }

  Future<void> _migrateDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Initial migration if needed
    }

    if (oldVersion < 3) {
      // Add search_count column to product table
      await db.execute(
        "ALTER TABLE $productTableName ADD COLUMN search_count INTEGER DEFAULT 0",
      );
    }

    if (oldVersion < 4) {
      await db.execute("ALTER TABLE $orderTableName ADD COLUMN products TEXT");
      await db.execute(
        "ALTER TABLE $orderTableName ADD COLUMN status TEXT DEFAULT 'pending'",
      );
    }

    if (oldVersion < 5) {
      await db.execute(
        "ALTER TABLE $orderTableName ADD COLUMN delivery_address TEXT",
      );
    }

    if (oldVersion < 6) {
      await db.execute(
        "ALTER TABLE $orderTableName ADD COLUMN payment_method TEXT",
      );
      await db.execute(
        "ALTER TABLE $orderTableName ADD COLUMN customer_name TEXT",
      );
      await db.execute(
        "ALTER TABLE $orderTableName ADD COLUMN customer_email TEXT",
      );
      await db.execute(
        "ALTER TABLE $orderTableName ADD COLUMN customer_phone TEXT",
      );
    }

    if (oldVersion < 7) {
      // Any future migrations would go here
    }

    if (oldVersion < 8) {
      // Add new tables and columns for version 8
      await db.execute('''
        CREATE TABLE $paymentTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          user_email TEXT NOT NULL,
          amount REAL NOT NULL,
          payment_method TEXT NOT NULL,
          transaction_id TEXT,
          status TEXT NOT NULL,
          payment_date TEXT NOT NULL,
          FOREIGN KEY (order_id) REFERENCES $orderTableName(id),
          FOREIGN KEY (user_id) REFERENCES $userTableName(id)
        )
      ''');

      await db.execute('''
        ALTER TABLE $reviewTableName ADD COLUMN user_id INTEGER NOT NULL DEFAULT 0
      ''');

      await db.execute('''
        ALTER TABLE $reviewTableName ADD COLUMN media_path TEXT
      ''');

      await db.execute(
        "CREATE INDEX idx_user_id_reviews ON $reviewTableName(user_id);",
      );
      await db.execute(
        "CREATE INDEX idx_order_id_payments ON $paymentTableName(order_id);",
      );
      await db.execute(
        "CREATE INDEX idx_user_id_payments ON $paymentTableName(user_id);",
      );
    }
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
    final result = await db.query(
      userTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
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
  Future<int> insertOrder({
    required int userId,
    required double totalPrice,
    required String productsJson,
    required String deliveryAddress,
    required String paymentMethod,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String status = 'pending',
  }) async {
    final db = await getDB();
    return await db.insert(orderTableName, {
      'user_id': userId,
      'total_price': totalPrice,
      'order_date': DateTime.now().toIso8601String(),
      'products': productsJson,
      'delivery_address': deliveryAddress,
      'status': status,
      'payment_method': paymentMethod,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
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

  // ==================== Reviews ====================
  Future<void> insertReview({
    required int productId,
    required int rating,
    required String reviewText,
    String? mediaPath,
  }) async {
    final db = await getDB();
    final user = await getLoggedInUser();
    if (user == null) throw Exception("User not logged in");

    final reviewer = user['name'] ?? 'Anonymous';
    final review = {
      'product_id': productId,
      'user_id': user['id'],
      'reviewer': reviewer,
      'comment': reviewText,
      'rating': rating,
      'media_path': mediaPath,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Remove media_path if it's null to avoid storing "null" as a string
    if (mediaPath == null) {
      review.remove('media_path');
    }

    try {
      await db.insert(reviewTableName, review);
    } catch (e) {
      print('Failed to insert review: $e');
      rethrow;
    }
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

  // Enhanced version with better error handling
  Future<List<Map<String, dynamic>>> getReviewsByProductId(
    int productId,
  ) async {
    try {
      final db = await getDB();

      // Verify table exists first
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$reviewTableName'",
      );

      if (tables.isEmpty) {
        debugPrint('Reviews table does not exist');
        return [];
      }

      final reviews = await db.query(
        reviewTableName,
        where: 'product_id = ?',
        whereArgs: [productId],
        orderBy: 'timestamp DESC',
      );

      debugPrint('Fetched ${reviews.length} reviews for product $productId');
      return reviews;
    } catch (e) {
      debugPrint('Error in getReviewsByProductId: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserReviews(int userId) async {
    final db = await getDB();
    return await db.query(
      reviewTableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<double> getAverageRatingForProduct(int productId) async {
    final db = await getDB();
    final result = await db.rawQuery(
      '''
      SELECT AVG(rating) as average_rating 
      FROM $reviewTableName 
      WHERE product_id = ?
    ''',
      [productId],
    );

    return result.first['average_rating'] != null
        ? (result.first['average_rating'] as num).toDouble()
        : 0.0;
  }

  Future<List<Map<String, dynamic>>> getAllReviews() async {
    final db = await getDB();

    // Check if table exists
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$reviewTableName'",
    );
    if (tables.isEmpty) {
      debugPrint("reviews table not found.");
      return [];
    }

    final reviews = await db.query(reviewTableName, orderBy: 'timestamp DESC');

    debugPrint(' Fetched ${reviews.length} reviews.');
    return reviews;
  }

  Future<void> deleteReview(int id) async {
    final db = await getDB();
    await db.delete('reviews', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> hasReviewForOrder(int orderId) async {
    final db = await getDB();
    final result = await db.query(
      'reviews',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return result.isNotEmpty;
  }

  // ==================== PAYMENT ====================
  Future<int> insertPayment({
    required int orderId,
    required int userId,
    required String userEmail,
    required double amount,
    required String paymentMethod,
    required String status,
    String? transactionId,
  }) async {
    final db = await getDB();
    return await db.insert(paymentTableName, {
      'order_id': orderId,
      'user_id': userId,
      'user_email': userEmail,
      'amount': amount,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'status': status,
      'payment_date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPaymentsByUser(int userId) async {
    final db = await getDB();
    return await db.query(
      paymentTableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'payment_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getPaymentsByOrder(int orderId) async {
    final db = await getDB();
    return await db.query(
      paymentTableName,
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'payment_date DESC',
    );
  }

  Future<void> updatePaymentStatus(int paymentId, String newStatus) async {
    final db = await getDB();
    await db.update(
      paymentTableName,
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [paymentId],
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
