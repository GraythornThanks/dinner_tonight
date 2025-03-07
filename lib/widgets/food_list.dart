import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/food_provider.dart';
import '../models/food_item.dart';

class FoodList extends StatelessWidget {
  const FoodList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.height < 700; // 针对小屏幕设备优化
    
    return Consumer<FoodProvider>(
      builder: (context, provider, child) {
        if (provider.foodItems.isEmpty) {
          return _buildEmptyList(theme, isSmallScreen);
        }
        
        return ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 8 : 16, 
            horizontal: isSmallScreen ? 8 : 12
          ),
          itemCount: provider.foodItems.length,
          itemBuilder: (context, index) {
            return FoodItemTile(
              foodItem: provider.foodItems[index],
              onDelete: () {
                provider.deleteFoodItem(provider.foodItems[index].id!);
              },
              isSmallScreen: isSmallScreen,
            );
          },
        );
      },
    );
  }
  
  Widget _buildEmptyList(ThemeData theme, bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: isSmallScreen ? 48 : 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            '没有食品项目',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            '添加一些美食选项以开始使用',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class FoodItemTile extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onDelete;
  final bool isSmallScreen;

  const FoodItemTile({
    Key? key,
    required this.foodItem,
    required this.onDelete,
    this.isSmallScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key(foodItem.id.toString()),
      background: Container(
        margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 2 : 4),
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
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
      onDismissed: (direction) {
        onDelete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${foodItem.name} 已删除'),
            backgroundColor: theme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: '撤销',
              textColor: Colors.white,
              onPressed: () {
                Provider.of<FoodProvider>(context, listen: false)
                    .addFoodItem(foodItem.name);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 2 : 4, 
          horizontal: 0
        ),
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16, 
            vertical: isSmallScreen ? 6 : 8
          ),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            radius: isSmallScreen ? 18 : 22,
            child: Icon(
              Icons.fastfood,
              color: theme.colorScheme.primary,
              size: isSmallScreen ? 16 : 20,
            ),
          ),
          title: Text(
            foodItem.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          subtitle: Text(
            '添加于: ${_formatDate(foodItem.createdAt)}',
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
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class AddFoodForm extends StatefulWidget {
  const AddFoodForm({Key? key}) : super(key: key);

  @override
  State<AddFoodForm> createState() => _AddFoodFormState();
}

class _AddFoodFormState extends State<AddFoodForm> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 4 : 8, 
        horizontal: isSmallScreen ? 6 : 12
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: TextFormField(
          controller: _textController,
          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
          decoration: InputDecoration(
            hintText: '添加新的食品选项',
            hintStyle: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            prefixIcon: Icon(
              Icons.add_circle_outline,
              color: theme.colorScheme.primary,
              size: isSmallScreen ? 18 : 22,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.send,
                color: theme.colorScheme.secondary,
                size: isSmallScreen ? 18 : 22,
              ),
              onPressed: _submitForm,
              tooltip: '添加',
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: BoxConstraints(),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16, 
              vertical: isSmallScreen ? 10 : 14
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入食品名称';
            }
            
            // 检查重复项
            final provider = Provider.of<FoodProvider>(context, listen: false);
            if (provider.foodItems.any((item) => item.name.toLowerCase() == value.trim().toLowerCase())) {
              return '此食品已在列表中';
            }
            
            return null;
          },
          onFieldSubmitted: (_) => _submitForm(),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final foodName = _textController.text.trim();
      if (foodName.isNotEmpty) {
        Provider.of<FoodProvider>(context, listen: false).addFoodItem(foodName);
        _textController.clear();
        // 添加后收起键盘
        FocusScope.of(context).unfocus();
      }
    }
  }
}
