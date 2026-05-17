import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';
import '../data/app_data.dart';

class NotificationPage extends StatelessWidget {
  final String userRole;
  final String userName;
  const NotificationPage({super.key, required this.userRole, required this.userName});

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationService.getNotificationsForUser(
      userRole,
      userId: userRole == 'mahasiswa'
          ? AppData.currentNim
          : (userRole == 'dosen' ? AppData.currentDosenNidn : null),
    );

    return CyberScaffold(
      userName: userName,
      userRole: userRole,
      breadcrumbs: const ['Beranda', 'Daftar Notifikasi'],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CyberHeader(
            tag: '// Pusat Informasi',
            title: 'Notifikasi',
            subtitle: 'Dapatkan informasi terbaru mengenai aktivitas akademik Anda.',
            icon: Icons.notifications_active,
          ),
          const SizedBox(height: 20),
          if (notifications.isEmpty)
            const CyberPanel(
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.grey),
                    SizedBox(height: 12),
                    Text('Tidak ada notifikasi terbaru', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            ...notifications.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CyberPanel(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.surfaceLayer,
                          child: Icon(n.icon, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(n.message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              const SizedBox(height: 8),
                              Text(
                                '${n.timestamp.day}/${n.timestamp.month}/${n.timestamp.year} ${n.timestamp.hour}:${n.timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: AppColors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        if (n.actionRoute != null)
                          TextButton(
                            onPressed: () {
                              if (n.actionRoute == '/validasi_krs') {
                                // If already on DosenPage, we might need to change the tab.
                                // But for now, we'll just pop to DosenPage if possible or navigate.
                                Navigator.pop(context); // Go back to dashboard which has the tabs
                              }
                            },
                            child: const Text('Lihat'),
                          ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
