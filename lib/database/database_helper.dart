import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal.dart';
import '../models/transaction_model.dart';
import '../utils/goal_data_notifier.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Future<Database>? _databaseFuture;

  DatabaseHelper._init();

  Future<Database> get database {
    final openDatabase = _database;
    if (openDatabase != null) return Future.value(openDatabase);
    final opening = _databaseFuture;
    if (opening != null) return opening;

    final initialization = _initDB('mysaving.db').then((db) {
      _database = db;
      return db;
    });
    _databaseFuture = initialization.catchError((
      Object error,
      StackTrace stack,
    ) {
      _databaseFuture = null;
      Error.throwWithStackTrace(error, stack);
    });
    return _databaseFuture!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Buka koneksi database. Tambahkan onConfigure untuk mengaktifkan Foreign Key.
    return await openDatabase(
      path,
      version: 3,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onConfigure(Database db) async {
    // Wajib dieksekusi agar fitur ON DELETE CASCADE berjalan di SQLite
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // Tabel Target (Goals)
    await db.execute('''
      CREATE TABLE goals (
        id $idType,
        name $textType,
        target_price $realType,
        target_date $textType,
        note $textNullable,
        image $textNullable,
        status $textType,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // Tabel Transaksi (Transactions)
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        goal_id $integerType,
        amount $realType,
        transaction_date $textType,
        note $textNullable,
        created_at $textType,
        updated_at $textType,
        FOREIGN KEY (goal_id) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');

    await _createSettingsTable(db);
    await _createPerformanceIndexes(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createSettingsTable(db);
    if (oldVersion < 3) await _createPerformanceIndexes(db);
  }

  Future<void> _createPerformanceIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_goal_created '
      'ON transactions(goal_id, created_at DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transactions_date '
      'ON transactions(transaction_date)',
    );
  }

  Future<void> _createSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE app_settings (
        setting_key TEXT PRIMARY KEY,
        setting_value TEXT NOT NULL
      )
    ''');
  }

  Future<String?> readUserName() async {
    final db = await instance.database;
    final rows = await db.query(
      'app_settings',
      columns: ['setting_value'],
      where: 'setting_key = ?',
      whereArgs: ['user_name'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final name = rows.first['setting_value'] as String?;
    return name?.trim().isEmpty == true ? null : name?.trim();
  }

  Future<void> saveUserName(String name) async {
    await saveSetting('user_name', name.trim());
  }

  Future<String?> readProfileImage() => readSetting('profile_image');

  Future<void> saveProfileImage(String? path) async {
    final db = await instance.database;
    if (path == null || path.trim().isEmpty) {
      await db.delete(
        'app_settings',
        where: 'setting_key = ?',
        whereArgs: ['profile_image'],
      );
      return;
    }
    await saveSetting('profile_image', path.trim());
  }

  Future<String?> readSetting(String key) async {
    final db = await instance.database;
    final rows = await db.query(
      'app_settings',
      columns: ['setting_value'],
      where: 'setting_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final value = rows.first['setting_value'] as String?;
    return value?.trim().isEmpty == true ? null : value?.trim();
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert('app_settings', {
      'setting_key': key,
      'setting_value': value.trim(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // === Fungsi CRUD Dasar (Sementara) ===

  Future<Goal> createGoal(Goal goal) async {
    final db = await instance.database;
    final id = await db.insert('goals', goal.toMap());
    notifyGoalDataChanged();
    return Goal(
      id: id,
      name: goal.name,
      targetPrice: goal.targetPrice,
      targetDate: goal.targetDate,
      note: goal.note,
      image: goal.image,
      status: goal.status,
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
    );
  }

  Future<List<Goal>> readAllGoals() async {
    final db = await instance.database;
    final result = await db.query('goals', orderBy: 'created_at DESC');
    return result.map((json) => Goal.fromMap(json)).toList();
  }

  Future<Goal?> readGoalById(int id) async {
    final db = await instance.database;
    final rows = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Goal.fromMap(rows.first);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    _databaseFuture = null;
  }

  // Menambah transaksi setoran baru
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    final db = await instance.database;
    final id = await db.insert('transactions', transaction.toMap());
    notifyGoalDataChanged();
    return TransactionModel(
      id: id,
      goalId: transaction.goalId,
      amount: transaction.amount,
      transactionDate: transaction.transactionDate,
      note: transaction.note,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  // Mengambil total nominal yang sudah terkumpul untuk target tertentu
  Future<double> getTotalProgressForGoal(int goalId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE goal_id = ?',
      [goalId],
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<Map<int, double>> getProgressForGoals(List<int> goalIds) async {
    if (goalIds.isEmpty) return {};
    final db = await instance.database;
    final placeholders = List.filled(goalIds.length, '?').join(', ');
    final rows = await db.rawQuery(
      'SELECT goal_id, SUM(amount) AS total FROM transactions '
      'WHERE goal_id IN ($placeholders) GROUP BY goal_id',
      goalIds,
    );
    return {
      for (final row in rows)
        row['goal_id'] as int: (row['total'] as num).toDouble(),
    };
  }

  Future<int> getGoalCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM goals');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Total seluruh setoran dari semua target
  Future<double> getGrandTotal() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions',
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<List<Map<String, Object?>>> getMonthlySavingSummary({
    required String fromDate,
    required String untilDate,
  }) async {
    final db = await instance.database;
    return db.rawQuery(
      'SELECT substr(transaction_date, 1, 7) AS month, '
      'SUM(amount) AS total, COUNT(*) AS deposit_count '
      'FROM transactions '
      'WHERE transaction_date >= ? AND transaction_date < ? '
      'GROUP BY month ORDER BY month ASC',
      [fromDate, untilDate],
    );
  }

  // Memperbarui data target
  Future<int> updateGoal(Goal goal) async {
    final db = await instance.database;
    final changed = await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
    if (changed > 0) notifyGoalDataChanged();
    return changed;
  }

  // Menghapus data target (Transaksi terkait akan otomatis terhapus karena ON DELETE CASCADE)
  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    final changed = await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    if (changed > 0) notifyGoalDataChanged();
    return changed;
  }

  // Mengambil semua riwayat transaksi untuk suatu target
  Future<List<TransactionModel>> getTransactionsForGoal(int goalId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // Menghapus transaksi (jika salah input nominal setoran)
  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    final changed = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (changed > 0) notifyGoalDataChanged();
    return changed;
  }

  // Memperbarui transaksi (edit nominal/tanggal/catatan setoran)
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    final changed = await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    if (changed > 0) notifyGoalDataChanged();
    return changed;
  }
}
