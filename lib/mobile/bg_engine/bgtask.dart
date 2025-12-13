import 'dart:convert';

/// Represents a background task payload with a timestamp and JSON body.
class Bgtask {
  final DateTime timestamp;

  final Map<String, dynamic> body;

  Bgtask({DateTime? timestamp, required Map<String, dynamic> body})
    : timestamp = timestamp ?? DateTime.now().toUtc(),
      body = body;

  factory Bgtask.fromJson(Map<String, dynamic> json) {
    return Bgtask(
      timestamp: _parseTimestamp(json['timestamp']),
      body: (json['body'] is Map<String, dynamic>)
          ? json['body'] as Map<String, dynamic>
          : _decodeBody(json['body']),
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'body': body,
  };

  Bgtask copyWith({DateTime? timestamp, Map<String, dynamic>? body}) =>
      Bgtask(timestamp: timestamp ?? this.timestamp, body: body ?? this.body);

  /// Encode to string for storage if needed.
  String toJsonString() => jsonEncode(toJson());

  /// Decode from string for storage retrieval.
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
