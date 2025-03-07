import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/food_provider.dart';
import '../models/history_record.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // 加载历史记录
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoodProvider>(context, listen: false).loadHistoryRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '历史记录',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Consumer<FoodProvider>(
            builder: (context, provider, _) {
              if (provider.historyRecords.isEmpty) {
                return SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(Icons.delete_sweep),
                onPressed: () => _confirmClearHistory(context),
                tooltip: '清空历史',
              );
            },
          ),
        ],
      ),
      body: Consumer<FoodProvider>(
        builder: (context, provider, child) {
          if (provider.historyRecords.isEmpty) {
            return _buildEmptyHistory(theme);
          }
          
          // 按日期分组
          final groupedRecords = _groupRecordsByDate(provider.historyRecords);
          
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: groupedRecords.length,
              itemBuilder: (context, index) {
                final date = groupedRecords.keys.elementAt(index);
                final records = groupedRecords[date]!;
                
                return _buildDateGroup(context, date, records, theme);
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyHistory(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          SizedBox(height: 24),
          Text(
            '暂无历史记录',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              '使用轮盘选择食品后，结果将显示在这里',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
            label: Text('返回首页'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDateGroup(BuildContext context, String date, List<HistoryRecord> records, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期标题
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  date,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${records.length} 条记录',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // 记录列表
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: records.length,
            itemBuilder: (context, i) {
              return _buildHistoryItem(context, records[i], i == records.length - 1, theme);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildHistoryItem(BuildContext context, HistoryRecord record, bool isLast, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
          child: Icon(
            Icons.restaurant,
            color: theme.colorScheme.secondary,
            size: 20,
          ),
        ),
        title: Text(
          record.foodName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _formatTime(record.timestamp),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.check_circle_outline,
          color: theme.colorScheme.secondary,
          size: 20,
        ),
      ),
    );
  }
  
  Map<String, List<HistoryRecord>> _groupRecordsByDate(List<HistoryRecord> records) {
    final Map<String, List<HistoryRecord>> grouped = {};
    
    for (var record in records) {
      final date = _formatDate(record.timestamp);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(record);
    }
    
    // 按日期排序（从最近到最早）
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    
    final sortedMap = Map<String, List<HistoryRecord>>.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
    
    return sortedMap;
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '今天';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return '昨天';
    } else {
      return DateFormat('yyyy年MM月dd日').format(date);
    }
  }
  
  String _formatTime(DateTime date) {
    return DateFormat('HH:mm:ss').format(date);
  }
  
  void _confirmClearHistory(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认清空'),
        content: Text('您确定要清空所有历史记录吗？此操作不可恢复。'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            child: Text(
              '取消',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('清空'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () {
              Provider.of<FoodProvider>(context, listen: false).clearHistory();
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('历史记录已清空'),
                  backgroundColor: theme.colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
