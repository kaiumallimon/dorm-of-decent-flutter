import 'package:equatable/equatable.dart';

class ActivityLog extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final ActivityType type;
  final String description;
  final double amount;
  final DateTime timestamp;

  const ActivityLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.description,
    required this.amount,
    required this.timestamp,
  });

  ActivityLog copyWith({
    String? id,
    String? userId,
    String? userName,
    ActivityType? type,
    String? description,
    double? amount,
    DateTime? timestamp,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    final metadata = json['metadata'] is Map<String, dynamic>
        ? json['metadata'] as Map<String, dynamic>
        : <String, dynamic>{};

    // Extract amount based on entity type
    double amount = 0.0;
    final entityType = json['entity_type'] ?? 'meal';

    if (entityType == 'meal') {
      // For meals, check meal_count
      if (metadata['meal_count'] is num) {
        amount = (metadata['meal_count'] as num).toDouble();
      }
    } else {
      // For expenses and settlements, check amount
      if (metadata['amount'] is num) {
        amount = (metadata['amount'] as num).toDouble();
      }
    }

    return ActivityLog(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: profile?['name'] ?? 'Unknown',
      type: ActivityTypeX.fromString(entityType),
      description: json['action'] ?? '',
      amount: amount,
      timestamp: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'type': type.name,
      'description': description,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    type,
    description,
    amount,
    timestamp,
  ];
}

enum ActivityType { meal, expense, settlement }

extension ActivityTypeX on ActivityType {
  static ActivityType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'meal':
        return ActivityType.meal;
      case 'expense':
        return ActivityType.expense;
      case 'settlement':
        return ActivityType.settlement;
      default:
        throw ArgumentError('Unknown ActivityType: $value');
    }
  }
}
