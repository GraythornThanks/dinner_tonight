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
    if (widget.items.isEmpty) {
      return _buildEmptyWheel();
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildWheel(size),
            _buildPointer(size),
          ],
        );
      },
    );
  }

  Widget _buildEmptyWheel() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '请先添加食品选项',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildWheel(double size) {
    final currentAngle = _startAngle + (_finalAngle - _startAngle) * _animation.value;
    
    return Transform.rotate(
      angle: currentAngle,
      child: Container(
        width: size * 0.9,
        height: size * 0.9,
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
          ),
        ),
      ),
    );
  }

  Widget _buildPointer(double size) {
    return Positioned(
      top: 0,
      child: Container(
        width: 30,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Icon(
          Icons.arrow_drop_down,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class RouletteWheelPainter extends CustomPainter {
  final List<FoodItem> items;
  final List<Color> colors = [
    Colors.red.shade200,
    Colors.blue.shade200,
    Colors.green.shade200,
    Colors.orange.shade200,
    Colors.purple.shade200,
    Colors.teal.shade200,
    Colors.amber.shade200,
    Colors.cyan.shade200,
  ];

  RouletteWheelPainter({required this.items});

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
        ..color = colors[i % colors.length]
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
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.bold,
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
