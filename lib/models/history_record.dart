class HistoryRecord {
  int? id;
  String foodName;
  DateTime timestamp;

  HistoryRecord({
    this.id,
    required this.foodName,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_name': foodName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryRecord.fromMap(Map<String, dynamic> map) {
    return HistoryRecord(
      id: map['id'],
      foodName: map['food_name'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  @override
  String toString() {
    return 'HistoryRecord(id: $id, foodName: $foodName, timestamp: $timestamp)';
  }
}
