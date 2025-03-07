# 今晚吃什么

一个帮助解决"今晚吃什么"选择困难的Flutter应用。

## 功能特点

- 食品选择轮盘，随机决定今晚吃什么
- 添加、删除食品选项
- 记录历史抽奖结果
- 支持多平台（Android、iOS、Windows、Linux、macOS）

## 技术栈

- Flutter SDK
- Provider状态管理
- SQLite本地数据库
- 自定义动画

## 系统要求

- Flutter 3.0.0 或更高版本
- Dart 2.17.0 或更高版本

## 安装与运行

1. 确保您已安装Flutter环境
2. 克隆项目到本地
   ```
   git clone https://your-repository-url/dinner_tonight.git
   ```
3. 进入项目目录
   ```
   cd dinner_tonight
   ```
4. 获取依赖
   ```
   flutter pub get
   ```
5. 运行应用
   ```
   flutter run
   ```

## 项目结构

```
lib/
  ├── models/             # 数据模型
  ├── screens/            # 页面
  ├── services/           # 服务
  ├── utils/              # 工具函数
  ├── widgets/            # 可复用组件
  └── main.dart           # 应用入口
```

## 使用说明

1. 在主页面添加您想吃的食品选项
2. 点击底部的骰子按钮开始抽奖
3. 轮盘旋转后会显示随机选中的食品
4. 点击右上角的历史图标可查看历史抽奖记录

## 贡献

欢迎提交PR或Issues来帮助改进这个项目。

## 许可证

MIT License
