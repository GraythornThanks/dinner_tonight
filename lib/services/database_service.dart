import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/food_item.dart';
import '../models/history_record.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static bool _tablesCreated = false;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    
    // 确保表格创建
    if (!_tablesCreated) {
      await _ensureTablesCreated(_database!);
      _tablesCreated = true;
    }
    
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 初始化FFI，适配多平台
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    try {
      // 在Linux上，我们可能需要创建自定义目录
      Directory appDirectory;
      if (Platform.isLinux) {
        final homeDir = Directory('/home/graythorn');
        if (await homeDir.exists()) {
          final appDir = Directory('${homeDir.path}/workplace/dinner_tonight/data');
          if (!await appDir.exists()) {
            await appDir.create(recursive: true);
          }
          appDirectory = appDir;
        } else {
          appDirectory = await getApplicationDocumentsDirectory();
        }
      } else {
        appDirectory = await getApplicationDocumentsDirectory();
      }
      
      String path = join(appDirectory.path, 'dinner_tonight.db');
      print('[数据库] 初始化数据库：$path');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('[数据库] 初始化错误：$e');
      // 如果出错，使用内存数据库作为后备
      return await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _ensureTablesCreated(Database db) async {
    // 检查表是否已经存在
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='food_items';"
    );
    
    if (tables.isEmpty) {
      print('[数据库] 表不存在，正在创建...');
      await _onCreate(db, 1);
    } else {
      print('[数据库] 表已存在');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    print('[数据库] 创建数据库表');
    
    // 创建食品表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS food_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 创建历史记录表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS history_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // 食品相关操作
  Future<int> insertFoodItem(FoodItem item) async {
    Database db = await database;
    print('[数据库] 添加食品：${item.name}');
    return await db.insert('food_items', item.toMap());
  }

  Future<List<FoodItem>> getAllFoodItems() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('food_items');
    print('[数据库] 获取所有食品，数量：${maps.length}');
    return List.generate(maps.length, (i) => FoodItem.fromMap(maps[i]));
  }

  Future<int> deleteFoodItem(int id) async {
    Database db = await database;
    print('[数据库] 删除食品ID：$id');
    return await db.delete(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 历史记录相关操作
  Future<int> insertHistoryRecord(HistoryRecord record) async {
    Database db = await database;
    print('[数据库] 添加历史记录：${record.foodName}');
    return await db.insert('history_records', record.toMap());
  }

  Future<List<HistoryRecord>> getAllHistoryRecords() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'history_records', 
      orderBy: 'timestamp DESC'
    );
    print('[数据库] 获取所有历史记录，数量：${maps.length}');
    return List.generate(maps.length, (i) => HistoryRecord.fromMap(maps[i]));
  }

  Future<int> deleteAllHistoryRecords() async {
    Database db = await database;
    print('[数据库] 清空历史记录');
    return await db.delete('history_records');
  }

  // 删除单条历史记录
  Future<int> deleteHistoryRecord(int id) async {
    Database db = await database;
    print('[数据库] 删除历史记录ID：$id');
    return await db.delete(
      'history_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
