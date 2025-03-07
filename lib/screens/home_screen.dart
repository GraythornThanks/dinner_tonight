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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '今晚吃什么',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.history, size: 28),
              onPressed: () => _navigateToHistory(context),
              tooltip: '查看历史',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // 食品轮盘部分
              Column(
                children: [
                  Text(
                    '食品轮盘',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: size.height * 0.3,
                    constraints: BoxConstraints(
                      maxHeight: 300,
                    ),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
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
                  SizedBox(height: 8),
                  Consumer<FoodProvider>(
                    builder: (context, provider, child) {
                      if (provider.foodItems.isEmpty || provider.isSpinning) {
                        return SizedBox.shrink();
                      }
                      return ElevatedButton.icon(
                        onPressed: () {
                          provider.startSpinning();
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.dice,
                          size: 18,
                        ),
                        label: Text('开始抽奖'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // 食品列表部分
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '食品列表',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Consumer<FoodProvider>(
                        builder: (context, provider, _) {
                          return Text(
                            '共 ${provider.foodItems.length} 项',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AddFoodForm(),
                  ),
                  
                  Container(
                    height: size.height * 0.4,
                    constraints: BoxConstraints(
                      maxHeight: 400,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: FoodList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
