import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../services/food_provider.dart';

class FoodList extends StatelessWidget {
  const FoodList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodProvider>(
      builder: (context, provider, child) {
        final foodItems = provider.foodItems;
        
        if (foodItems.isEmpty) {
          return Center(
            child: Text(
              '没有食品，请先添加食品选项',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }
        
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: foodItems.length,
          itemBuilder: (context, index) {
            return _buildFoodItem(context, foodItems[index], provider);
          },
        );
      },
    );
  }

  Widget _buildFoodItem(BuildContext context, FoodItem item, FoodProvider provider) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text(
          item.name,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red[400]),
          onPressed: () => _confirmDelete(context, item, provider),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FoodItem item, FoodProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除 "${item.name}" 吗？'),
        actions: [
          TextButton(
            child: Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('删除', style: TextStyle(color: Colors.red)),
            onPressed: () {
              if (item.id != null) {
                provider.deleteFoodItem(item.id!);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class AddFoodForm extends StatefulWidget {
  const AddFoodForm({Key? key}) : super(key: key);

  @override
  State<AddFoodForm> createState() => _AddFoodFormState();
}

class _AddFoodFormState extends State<AddFoodForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<FoodProvider>(context, listen: false);
      provider.addFoodItem(_controller.text.trim());
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: '食品名称',
                  hintText: '输入想要添加的食品',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入食品名称';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submitForm(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('添加'),
            ),
          ],
        ),
      ),
    );
  }
}
