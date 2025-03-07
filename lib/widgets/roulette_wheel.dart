import 'dart:math';
import 'package:flutter/material.dart';
import '../models/food_item.dart';

class RouletteWheel extends StatefulWidget {
  final List<FoodItem> items;
  final bool isSpinning;
  final FoodItem? selectedItem;
  final Function() onSpinComplete;

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
      widget.onSpinComplete();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.items.isEmpty) {
      return _buildEmptyWheel(theme);
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        return Stack(
          alignment: Alignment.center,
          children: [
            // 外环装饰
            Container(
              width: size * 0.95,
              height: size * 0.95,
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
            _buildWheel(size, theme),
            // 中心点
            Container(
              width: size * 0.15,
              height: size * 0.15,
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
                size: size * 0.07,
              ),
            ),
            // 指针
            _buildPointer(size, theme),
          ],
        );
      },
    );
  }

  Widget _buildEmptyWheel(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
      padding: const EdgeInsets.all(12.0),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 36,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 8),
          Text(
            '请先添加食品选项',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWheel(double size, ThemeData theme) {
    final currentAngle = _startAngle + (_finalAngle - _startAngle) * _animation.value;
    
    return Transform.rotate(
      angle: currentAngle,
      child: CustomPaint(
        size: Size(size * 0.95, size * 0.95),
        painter: RouletteWheelPainter(
          items: widget.items,
          theme: theme,
        ),
      ),
    );
  }

  Widget _buildPointer(double size, ThemeData theme) {
    return Positioned(
      top: 0,
      child: Container(
        width: size * 0.15,
        height: size * 0.12,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.secondary,
                size: size * 0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RouletteWheelPainter extends CustomPainter {
  final List<FoodItem> items;
  final ThemeData theme;
  final List<Color>? colors;

  RouletteWheelPainter({
    required this.items, 
    required this.theme,
    this.colors,
  });

  List<Color> get _colors => colors ?? [
    theme.colorScheme.primary.withOpacity(0.8),
    theme.colorScheme.secondary.withOpacity(0.8),
    theme.colorScheme.tertiary.withOpacity(0.8),
    theme.colorScheme.primary.withOpacity(0.6),
    theme.colorScheme.secondary.withOpacity(0.6),
    theme.colorScheme.tertiary.withOpacity(0.6),
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
      final textRadius = radius * 0.7; // 文字位置在半径的70%处
      final x = center.dx + textRadius * cos(midSliceAngle);
      final y = center.dy + textRadius * sin(midSliceAngle);

      textPainter.text = TextSpan(
        text: items[i].name,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
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
