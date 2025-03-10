import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../services/food_provider.dart';

class ResultDialog extends StatelessWidget {
  final FoodItem selectedFood;

  const ResultDialog({
    Key? key,
    required this.selectedFood,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    
    // 添加成功音效
    // 注意：在实际应用中可以使用audioplayers或just_audio包添加音效
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部背景
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 16 : 24, 
                horizontal: 0
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: isSmallScreen ? 48 : 64,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 16),
                  Text(
                    '抽奖结果',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // 内容区域
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 16 : 24, 
                horizontal: isSmallScreen ? 16 : 24
              ),
              child: Column(
                children: [
                  Text(
                    '今晚吃',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 16),
                  Text(
                    selectedFood.name,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        '重新抽奖',
                        Icons.refresh,
                        theme.colorScheme.secondary,
                        isSmallScreen,
                        iconColor: Colors.amber,
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startNewSpin(context);
                        },
                      ),
                      _buildActionButton(
                        context,
                        '确认',
                        Icons.check_circle_outline,
                        theme.colorScheme.primary,
                        isSmallScreen,
                        iconColor: Colors.greenAccent,
                        onPressed: () {
                          _saveResult(context);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    bool isSmallScreen,
    {required VoidCallback onPressed, Color iconColor = Colors.white}
  ) {
    return ElevatedButton.icon(
      icon: Icon(
        icon,
        size: isSmallScreen ? 18 : 22,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: isSmallScreen ? 12 : 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white, // 文字颜色
        iconColor: iconColor, // 图标颜色
        elevation: 2,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16, 
          vertical: isSmallScreen ? 8 : 12
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _startNewSpin(BuildContext context) {
    final provider = Provider.of<FoodProvider>(context, listen: false);
    provider.startSpinning();
  }

  void _saveResult(BuildContext context) {
    final provider = Provider.of<FoodProvider>(context, listen: false);
    provider.addHistoryRecord(selectedFood);
    
    // 显示保存成功的提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已保存到历史记录'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
