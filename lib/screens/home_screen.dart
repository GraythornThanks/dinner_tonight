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
        child: Stack(
          children: [
            // 主体内容
            Column(
              children: [
                // 轮盘区域占位
                SizedBox(
                  height: size.height * 0.4,
                ),
                
                // 食品列表标题
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
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
                ),
                
                // 食品输入表单
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: AddFoodForm(),
                ),
                
                // 食品列表
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: FoodList(),
                    ),
                  ),
                ),
              ],
            ),
            
            // 轮盘区域 - 在Stack顶层
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: Container(
                  height: size.height * 0.4,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.background,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
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
              ),
            ),
          ],
        ),
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
            backgroundColor: theme.colorScheme.secondary,
            child: FaIcon(
              FontAwesomeIcons.dice,
              size: 32,
            ),
            tooltip: '开始抽奖',
            elevation: 8,
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
