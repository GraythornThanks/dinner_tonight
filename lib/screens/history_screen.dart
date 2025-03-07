import 'package:flutter/material.dart';
import '../widgets/history_list.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('抽奖历史记录'),
        centerTitle: true,
      ),
      body: HistoryList(),
    );
  }
}
