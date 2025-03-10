import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(1024, 1024);
  final paint = Paint()
    ..color = Colors.deepOrange
    ..style = PaintingStyle.stroke
    ..strokeWidth = 80;
  
  final center = Offset(size.width / 2, size.height / 2);
  
  // 画叉子
  canvas.drawLine(
    Offset(center.dx - 200, center.dy - 300),
    Offset(center.dx - 200, center.dy + 250),
    paint,
  );
  
  // 叉子的尖头
  canvas.drawLine(
    Offset(center.dx - 300, center.dy - 300),
    Offset(center.dx - 100, center.dy - 300),
    paint,
  );
  canvas.drawLine(
    Offset(center.dx - 300, center.dy - 300),
    Offset(center.dx - 300, center.dy - 200),
    paint,
  );
  canvas.drawLine(
    Offset(center.dx - 200, center.dy - 300),
    Offset(center.dx - 200, center.dy - 200),
    paint,
  );
  canvas.drawLine(
    Offset(center.dx - 100, center.dy - 300),
    Offset(center.dx - 100, center.dy - 200),
    paint,
  );
  
  // 画刀
  canvas.drawLine(
    Offset(center.dx + 200, center.dy - 300),
    Offset(center.dx + 200, center.dy + 250),
    paint,
  );
  
  // 刀的刀刃
  canvas.drawLine(
    Offset(center.dx + 100, center.dy - 200),
    Offset(center.dx + 300, center.dy - 300),
    paint,
  );
  
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();
  
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/app_icon.png');
  await file.writeAsBytes(buffer);
  
  print('Icon saved to ${file.path}');
}
