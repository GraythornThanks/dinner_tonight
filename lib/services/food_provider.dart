import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/history_record.dart';
import 'database_service.dart';

class FoodProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<FoodItem> _foodItems = [];
  List<HistoryRecord> _historyRecords = [];
  
  FoodItem? _selectedFood;
  bool _isSpinning = false;

  // 获取数据的getter
  List<FoodItem> get foodItems => _foodItems;
  List<HistoryRecord> get historyRecords => _historyRecords;
  FoodItem? get selectedFood => _selectedFood;
  bool get isSpinning => _isSpinning;

  // 初始化，从数据库加载数据
  Future<void> initialize() async {
    print('[状态] 初始化食品数据');
    await loadFoodItems();
    await loadHistoryRecords();
  }

  // 加载食品列表
  Future<void> loadFoodItems() async {
    _foodItems = await _dbService.getAllFoodItems();
    notifyListeners();
  }

  // 加载历史记录
  Future<void> loadHistoryRecords() async {
    _historyRecords = await _dbService.getAllHistoryRecords();
    notifyListeners();
  }

  // 添加食品
  Future<void> addFoodItem(String name) async {
    if (name.isEmpty) return;
    
    final newItem = FoodItem(name: name);
    await _dbService.insertFoodItem(newItem);
    await loadFoodItems();
  }

  // 删除食品
  Future<void> deleteFoodItem(int id) async {
    await _dbService.deleteFoodItem(id);
    await loadFoodItems();
  }

  // 开始旋转轮盘
  void startSpinning() {
    if (_foodItems.isEmpty) return;
    
    print('[轮盘] 开始旋转');
    _isSpinning = true;
    _selectedFood = null;
    notifyListeners();
  }

  // 停止旋转并设置选中的食品
  Future<void> stopSpinning(FoodItem? selectedFood) async {
    if (_foodItems.isEmpty) return;

    // 设置由轮盘指针选中的食品
    _selectedFood = selectedFood;
    _isSpinning = false;
    
    print('[轮盘] 停止旋转，选中：${_selectedFood?.name ?? "无"}');
    
    // 添加到历史记录
    if (_selectedFood != null) {
      await _dbService.insertHistoryRecord(
        HistoryRecord(foodName: _selectedFood!.name)
      );
    }
    
    // 更新历史记录列表
    await loadHistoryRecords();
    
    notifyListeners();
  }

  // 清空历史记录
  Future<void> clearHistory() async {
    await _dbService.deleteAllHistoryRecords();
    await loadHistoryRecords();
  }

  // 添加特定食品到历史记录
  Future<void> addHistoryRecord(FoodItem foodItem) async {
    await _dbService.insertHistoryRecord(
      HistoryRecord(foodName: foodItem.name)
    );
    await loadHistoryRecords();
  }

  // 删除单条历史记录
  Future<void> deleteHistoryRecord(int id) async {
    await _dbService.deleteHistoryRecord(id);
    await loadHistoryRecords();
  }

  // 恢复历史记录
  Future<void> restoreHistoryRecord(HistoryRecord record) async {
    await _dbService.insertHistoryRecord(record);
    await loadHistoryRecords();
  }
}
