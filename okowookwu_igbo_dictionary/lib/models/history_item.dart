class HistoryItem {
  final int? id;
  final String query;
  final DateTime timestamp;

  HistoryItem({
    this.id,
    required this.query,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'query': query,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'],
      query: map['query'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}