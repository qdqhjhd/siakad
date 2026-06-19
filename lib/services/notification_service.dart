import '../models/notification_model.dart';

class NotificationService {
  static final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      title: 'Validasi KRS Diperlukan',
      message:
          'Mahasiswa Vidi Aurel Lapa meminta validasi KRS untuk Semester Ganjil 2024/2025.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.validation,
      actionRoute: '/validasi_krs',
      targetRole: 'dosen',
    ),
    AppNotification(
      id: '2',
      title: 'Materi Baru Diupdate',
      message:
          'Dosen Ir. Totok Michael telah mengunggah materi baru: Pemrograman Mobile Pertemuan 5.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.material,
      targetRole: 'mahasiswa',
    ),
    AppNotification(
      id: '3',
      title: 'Jadwal UTS Diterbitkan',
      message:
          'Jadwal Ujian Tengah Semester Ganjil sudah dapat diakses di menu Akademik.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.academic,
      targetRole: 'mahasiswa',
    ),
  ];

  static void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
  }

  static List<AppNotification> getNotificationsForUser(
    String role, {
    String? userId,
  }) {
    return _notifications.where((n) {
      if (n.targetRole != null && n.targetRole != role) return false;
      if (n.targetId != null && userId != null && n.targetId != userId)
        return false;
      return true;
    }).toList();
  }
}
