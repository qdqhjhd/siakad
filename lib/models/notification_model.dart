import 'package:flutter/material.dart';

enum NotificationType { validation, material, academic }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? actionRoute;
  final String? targetId;
  final String? targetRole;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionRoute,
    this.targetId,
    this.targetRole,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.validation:
        return Icons.fact_check_rounded;
      case NotificationType.material:
        return Icons.menu_book_rounded;
      case NotificationType.academic:
        return Icons.school_rounded;
    }
  }
}
