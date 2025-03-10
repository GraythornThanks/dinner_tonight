import 'dart:math';
import 'package:flutter/material.dart';
import '../models/food_item.dart';

class RouletteWheel extends StatefulWidget {
  final List<FoodItem> items;
  final bool isSpinning;
  final FoodItem? selectedItem;
  final Function(FoodItem?) onSpinComplete;

  const RouletteWheel({
    Key? key,
    required this.items,
    required this.isSpinning,
    required this.selectedItem,
    required this.onSpinComplete,
  }) : super(key: key);

  @override
  State<RouletteWheel> createState() => _RouletteWheelState();
}

class _RouletteWheelState extends State<RouletteWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final double _baseAngle = -pi / 2; // 指针位于顶部 (-90度)
  final Duration _spinDuration = const Duration(seconds: 3);
  double _finalAngle = 0;
  double _startAngle = 0;
  int _selectedIndex = -1; // 记录选中的索引

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _spinDuration,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener(_handleAnimationStatus);
  }

  @override
  void didUpdateWidget(RouletteWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isSpinning && !oldWidget.isSpinning) {
      _startSpin();
    }
  }

  void _startSpin() {
    print('[轮盘] 开始旋转动画');
    _startAngle = _finalAngle;
    
    // 随机旋转次数（5-10圈）加上随机终止角度
    final random = Random();
    final spins = 5 + random.nextInt(6);
    final randomEndAngle = random.nextDouble() * 2 * pi;
    
    // 计算最终角度（从当前位置继续旋转）
    _finalAngle = _startAngle + (spins * 2 * pi) + randomEndAngle;
    print('[轮盘] 旋转从 $_startAngle 到 $_finalAngle');
    
    _controller.reset();
    _controller.forward();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      print('[轮盘] 旋转完成');
      // 计算选中的食品索引
      _selectedIndex = _getSelectedFoodIndex();
      print('[轮盘] 指针指向的食品索引: $_selectedIndex，名称: ${widget.items[_selectedIndex].name}');
      widget.onSpinComplete(widget.items[_selectedIndex]);
    }
  }

  // 根据最终旋转角度计算指针指向的食品
  int _getSelectedFoodIndex() {
    if (widget.items.isEmpty) return -1;
    
    // 计算归一化角度（将角度限制在0到2π之间）
    final normalizedFinalAngle = _finalAngle % (2 * pi);
    
    // 计算指针指向的角度
    // 由于指针固定在顶部(-pi/2位置)，轮盘旋转，所以我们需要计算哪个扇区旋转到了指针下方
    // 指针位置(_baseAngle) - 轮盘旋转角度(normalizedFinalAngle) + 偏移修正(pi*2)，然后取模防止负值
    final pointerAngle = (_baseAngle - normalizedFinalAngle + pi * 2) % (2 * pi);
    
    // 计算每个扇区的角度
    final sliceAngle = 2 * pi / widget.items.length;
    
    // 计算指针指向的扇区索引
    int selectedIndex = (pointerAngle / sliceAngle).floor();
    
    // 确保索引在有效范围内
    selectedIndex = selectedIndex % widget.items.length;
    
    return selectedIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    
    if (widget.items.isEmpty) {
      return _buildEmptyWheel(theme, isSmallScreen);
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final scaleFactor = isSmallScreen ? 0.9 : 0.95; // 在小屏幕上稍微缩小轮盘
        return Stack(
          alignment: Alignment.center,
          children: [
            // 外环装饰
            Container(
              width: size * scaleFactor,
              height: size * scaleFactor,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
            ),
            // 轮盘
            _buildWheel(size * scaleFactor, theme, isSmallScreen),
            // 中心点
            Container(
              width: size * (isSmallScreen ? 0.12 : 0.15),
              height: size * (isSmallScreen ? 0.12 : 0.15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.restaurant,
                color: Colors.white,
                size: size * (isSmallScreen ? 0.05 : 0.07),
              ),
            ),
            // 指针
            _buildPointer(size, theme, isSmallScreen),
          ],
        );
      },
    );
  }

  Widget _buildEmptyWheel(ThemeData theme, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 20.0 : 32.0),
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: isSmallScreen ? 40 : 48,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            '请先添加食品选项',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            '在下方输入框中添加您想要的食品',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWheel(double size, ThemeData theme, bool isSmallScreen) {
    final currentAngle = _startAngle + (_finalAngle - _startAngle) * _animation.value;
    
    return Transform.rotate(
      angle: currentAngle,
      child: Container(
        width: size * (isSmallScreen ? 0.95 : 0.9),
        height: size * (isSmallScreen ? 0.95 : 0.9),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: CustomPaint(
          painter: RouletteWheelPainter(
            items: widget.items,
            colorScheme: theme.colorScheme,
            isSmallScreen: isSmallScreen,
          ),
        ),
      ),
    );
  }

  Widget _buildPointer(double size, ThemeData theme, bool isSmallScreen) {
    return Positioned(
      top: size * (isSmallScreen ? 0.01 : 0.02),
      child: Container(
        width: isSmallScreen ? 24 : 30,
        height: isSmallScreen ? 32 : 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isSmallScreen ? 12 : 15),
            topRight: Radius.circular(isSmallScreen ? 12 : 15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_drop_down,
          color: Colors.white,
          size: isSmallScreen ? 24 : 30,
        ),
      ),
    );
  }
}

class RouletteWheelPainter extends CustomPainter {
  final List<FoodItem> items;
  final ColorScheme colorScheme;
  final List<Color>? colors;
  final bool isSmallScreen;

  RouletteWheelPainter({
    required this.items, 
    required this.colorScheme,
    this.colors,
    this.isSmallScreen = false,
  });

  List<Color> get _colors => colors ?? [
    colorScheme.primary.withOpacity(0.8),
    colorScheme.secondary.withOpacity(0.8),
    colorScheme.tertiary.withOpacity(0.8),
    colorScheme.primary.withOpacity(0.6),
    colorScheme.secondary.withOpacity(0.6),
    colorScheme.tertiary.withOpacity(0.6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final sliceAngle = 2 * pi / items.length;
    
    // 绘制分割区域
    for (int i = 0; i < items.length; i++) {
      final startAngle = i * sliceAngle;
      final paint = Paint()
        ..color = _colors[i % _colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        rect,
        startAngle,
        sliceAngle,
        true,
        paint,
      );
      
      // 绘制分割线
      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      final x = center.dx + radius * cos(startAngle);
      final y = center.dy + radius * sin(startAngle);
      
      canvas.drawLine(center, Offset(x, y), linePaint);
    }
    
    // 绘制轮盘外圈
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius, borderPaint);
    
    // 绘制文本
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    for (int i = 0; i < items.length; i++) {
      final midSliceAngle = (i * sliceAngle) + (sliceAngle / 2);
      
      // 调整文本位置，使文本能够正常显示
      final textRadius = radius * (isSmallScreen ? 0.65 : 0.7); // 文字位置在半径的70%处
      final x = center.dx + textRadius * cos(midSliceAngle);
      final y = center.dy + textRadius * sin(midSliceAngle);
      
      // 根据食品名称长度适配字体大小
      double fontSize = isSmallScreen ? 12 : 14;
      if (items[i].name.length > 5) {
        fontSize = isSmallScreen ? 10 : 12;
      }
      if (items[i].name.length > 8) {
        fontSize = isSmallScreen ? 8 : 10;
      }

      textPainter.text = TextSpan(
        text: items[i].name,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black54,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
      );
      
      textPainter.layout();
      
      // 旋转画布以使文本水平显示
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(midSliceAngle + pi/2);
      
      // 将文本居中显示
      final offset = Offset(
        -textPainter.width / 2,
        -textPainter.height / 2,
      );
      
      textPainter.paint(canvas, offset);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
