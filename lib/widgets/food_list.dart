import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/food_provider.dart';
import '../models/food_item.dart';

class FoodList extends StatelessWidget {
  const FoodList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<FoodProvider>(
      builder: (context, provider, child) {
        if (provider.foodItems.isEmpty) {
          return _buildEmptyList(theme);
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemCount: provider.foodItems.length,
          itemBuilder: (context, index) {
            return FoodItemTile(
              foodItem: provider.foodItems[index],
              onDelete: () {
                provider.removeFood(provider.foodItems[index].id!);
              },
            );
          },
        );
      },
    );
  }
  
  Widget _buildEmptyList(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            '没有食品项目',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '添加一些美食选项以开始使用',
            style: TextStyle(
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

  const FoodItemTile({
    Key? key,
    required this.foodItem,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key(foodItem.id.toString()),
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete_forever,
          color: Colors.white,
          size: 28,
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
            action: SnackBarAction(
              label: '撤销',
              textColor: Colors.white,
              onPressed: () {
                Provider.of<FoodProvider>(context, listen: false)
                    .addFood(foodItem.name);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.fastfood,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            foodItem.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '添加于: ${_formatDate(foodItem.createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
            ),
            onPressed: onDelete,
            tooltip: '删除',
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
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
          decoration: InputDecoration(
            hintText: '添加新的食品选项',
            prefixIcon: Icon(
              Icons.add_circle_outline,
              color: theme.colorScheme.primary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.send,
                color: theme.colorScheme.secondary,
              ),
              onPressed: _submitForm,
              tooltip: '添加',
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        Provider.of<FoodProvider>(context, listen: false).addFood(foodName);
        _textController.clear();
      }
    }
  }
}
