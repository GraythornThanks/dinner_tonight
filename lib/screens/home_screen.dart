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
    final isSmallScreen = size.height < 700; // 对于小屏幕手机进行适配
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '今晚吃什么',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 20 : 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, size: isSmallScreen ? 24 : 28),
            onPressed: () => _navigateToHistory(context),
            tooltip: '查看历史',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          // 点击空白处收起键盘
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // 轮盘区域
              Container(
                height: isSmallScreen ? size.height * 0.35 : size.height * 0.4,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 8 : 16,
                  horizontal: isSmallScreen ? 8 : 16,
                ),
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
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
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
              
              // 食品列表部分 (采用Expanded + 滚动视图的布局)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(top: isSmallScreen ? 8 : 12),
                    child: CustomScrollView(
                      physics: BouncingScrollPhysics(),
                      slivers: [
                        // 食品列表标题
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '食品列表',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    fontSize: isSmallScreen ? 18 : 20,
                                  ),
                                ),
                                Consumer<FoodProvider>(
                                  builder: (context, provider, _) {
                                    return Text(
                                      '共 ${provider.foodItems.length} 项',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // 食品输入表单
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: isSmallScreen ? 8.0 : 12.0,
                            ),
                            child: AddFoodForm(),
                          ),
                        ),
                        
                        // 食品列表
                        SliverFillRemaining(
                          child: FoodList(),
                          hasScrollBody: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer<FoodProvider>(
        builder: (context, provider, child) {
          if (provider.foodItems.isEmpty || provider.isSpinning) {
            return SizedBox.shrink();
          }
          return FloatingActionButton(
            onPressed: () {
              provider.startSpinning();
            },
            backgroundColor: theme.colorScheme.secondary,
            child: FaIcon(
              FontAwesomeIcons.dice,
              size: isSmallScreen ? 24 : 28,
            ),
            tooltip: '开始抽奖',
            elevation: 4,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
