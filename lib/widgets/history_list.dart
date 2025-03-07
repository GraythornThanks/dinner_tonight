import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/history_record.dart';
import '../services/food_provider.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodProvider>(
      builder: (context, provider, child) {
        final records = provider.historyRecords;
        
        if (records.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '暂无历史记录',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          );
        }
        
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(context, records[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _confirmClearHistory(context, provider),
                icon: Icon(Icons.delete_sweep),
                label: Text('清空历史记录'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, HistoryRecord record) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = dateFormat.format(record.timestamp);
    
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: Icon(Icons.restaurant, color: Colors.orange),
        title: Text(
          record.foodName,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(formattedDate),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, FoodProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认清空'),
        content: Text('确定要清空所有历史记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            child: Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('清空', style: TextStyle(color: Colors.red)),
            onPressed: () {
              provider.clearHistory();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
