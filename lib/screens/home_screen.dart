import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/food_provider.dart';
import '../widgets/food_list.dart';
import '../widgets/roulette_wheel.dart';
import '../widgets/result_dialog.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoodProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '今晚吃什么',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => _navigateToHistory(context),
            tooltip: '查看历史',
          ),
        ],
      ),
      body: Column(
        children: [
          // 轮盘区域
          Container(
            height: size.height * 0.4,
            padding: EdgeInsets.all(16),
            child: Consumer<FoodProvider>(
              builder: (context, provider, child) {
                return RouletteWheel(
                  items: provider.foodItems,
                  isSpinning: provider.isSpinning,
                  selectedItem: provider.selectedFood,
                  onSpinComplete: () {
                    provider.stopSpinning().then((_) {
                      if (provider.selectedFood != null) {
                        _showResult(context, provider.selectedFood!);
                      }
                    });
                  },
                );
              },
            ),
          ),
          
          // 食品输入表单
          AddFoodForm(),
          
          // 食品列表
          Expanded(
            child: FoodList(),
          ),
        ],
      ),
      floatingActionButton: Consumer<FoodProvider>(
        builder: (context, provider, child) {
          if (provider.foodItems.isEmpty || provider.isSpinning) {
            return SizedBox.shrink();
          }
          return FloatingActionButton.large(
            onPressed: () {
              provider.startSpinning();
            },
            backgroundColor: Colors.orange,
            child: FaIcon(
              FontAwesomeIcons.dice,
              size: 32,
            ),
            tooltip: '开始抽奖',
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryScreen()),
    );
  }

  void _showResult(BuildContext context, final selectedFood) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultDialog(selectedFood: selectedFood),
    );
  }
}
