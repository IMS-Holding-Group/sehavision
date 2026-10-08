import 'dart:convert';

class ActivityLog {
  final int id;
  final int? userId;
  final String? userName;
  final String? userEmail;
  final String action;
  final String entityType;
  final int? entityId;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    this.userId,
    this.userName,
    this.userEmail,
    required this.action,
    required this.entityType,
    this.entityId,
    this.details,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      action: json['action'],
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      details: json['details'] != null
          ? (json['details'] is String
              ? Map<String, dynamic>.from(jsonDecode(json['details']))
              : Map<String, dynamic>.from(json['details']))
          : null,
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

