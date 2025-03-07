import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/food_provider.dart';
import '../models/history_record.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '历史记录',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 20 : 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: isSmallScreen ? 22 : 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<FoodProvider>(
            builder: (context, provider, _) {
              if (provider.historyRecords.isEmpty) {
                return SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(Icons.delete_sweep, size: isSmallScreen ? 22 : 24),
                onPressed: () => _showClearHistoryDialog(context),
                tooltip: '清空历史',
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Consumer<FoodProvider>(
        builder: (context, provider, child) {
          if (provider.historyRecords.isEmpty) {
            return _buildEmptyHistory(theme, isSmallScreen);
          }
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.colorScheme.background,
                ],
              ),
            ),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 8 : 16, 
                horizontal: isSmallScreen ? 8 : 16
              ),
              itemCount: provider.historyRecords.length,
              itemBuilder: (context, index) {
                final record = provider.historyRecords[index];
                return HistoryTile(
                  record: record,
                  onDelete: () => _deleteRecord(context, record),
                  isSmallScreen: isSmallScreen,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyHistory(ThemeData theme, bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: isSmallScreen ? 64 : 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            '暂无历史记录',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              '当你抽取并确认食品结果后，将在此处显示历史记录',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(BuildContext context, HistoryRecord record) {
    Provider.of<FoodProvider>(context, listen: false)
        .deleteHistoryRecord(record.id!);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已删除该记录'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: '撤销',
          textColor: Colors.white,
          onPressed: () {
            Provider.of<FoodProvider>(context, listen: false)
                .restoreHistoryRecord(record);
          },
        ),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '清空历史记录',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 20,
            color: theme.colorScheme.primary,
          ),
        ),
        content: Text(
          '确定要清空所有历史记录吗？此操作不可撤销。',
          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            child: Text(
              '取消',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(
              '确认清空',
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Provider.of<FoodProvider>(context, listen: false).clearHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已清空所有历史记录'),
                  backgroundColor: theme.colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class HistoryTile extends StatelessWidget {
  final HistoryRecord record;
  final VoidCallback onDelete;
  final bool isSmallScreen;

  const HistoryTile({
    Key? key,
    required this.record,
    required this.onDelete,
    this.isSmallScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key(record.id.toString()),
      background: Container(
        margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete_forever,
          color: Colors.white,
          size: isSmallScreen ? 24 : 28,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16, 
            vertical: isSmallScreen ? 6 : 8
          ),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            radius: isSmallScreen ? 20 : 24,
            child: Icon(
              Icons.restaurant,
              color: Colors.white,
              size: isSmallScreen ? 18 : 22,
            ),
          ),
          title: Text(
            record.foodName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          subtitle: Text(
            '日期: ${_formatDateTime(record.timestamp)}',
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: Colors.grey[600],
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: onDelete,
            tooltip: '删除',
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: BoxConstraints(),
          ),
        ),
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
