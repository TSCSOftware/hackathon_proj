import 'dart:convert';

/// Represents a background task payload with a timestamp and JSON body.
class Bgtask {
  final DateTime timestamp;
  final String task_type;
  final Map<String, dynamic> body;

  Bgtask({
    DateTime? timestamp,
    this.task_type = 'api_request',
    required Map<String, dynamic> body,
  }) : timestamp = timestamp ?? DateTime.now().toUtc(),
       body = body;

  factory Bgtask.fromJson(Map<String, dynamic> json) {
    return Bgtask(
      timestamp: _parseTimestamp(json['timestamp']),
      task_type: json['task_type'] ?? 'api_request',
      body: (json['body'] is Map<String, dynamic>)
          ? json['body'] as Map<String, dynamic>
          : _decodeBody(json['body']),
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'task_type': task_type,
    'body': body,
  };

  Bgtask copyWith({
    DateTime? timestamp,
    String? task_type,
    Map<String, dynamic>? body,
  }) => Bgtask(
    timestamp: timestamp ?? this.timestamp,
    task_type: task_type ?? this.task_type,
    body: body ?? this.body,
  );

  String toJsonString() => jsonEncode(toJson());

  static Bgtask fromJsonString(String source) =>
      Bgtask.fromJson(jsonDecode(source) as Map<String, dynamic>);

  static DateTime _parseTimestamp(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value).toUtc();
    }
    if (value is int) {
      // treat as milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    return DateTime.now().toUtc();
  }

  static Map<String, dynamic> _decodeBody(dynamic value) {
    if (value is String && value.isNotEmpty) {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    return <String, dynamic>{};
  }
}
