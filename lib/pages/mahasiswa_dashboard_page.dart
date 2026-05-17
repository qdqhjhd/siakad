import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';
import 'khs__page.dart';
import 'krs_page.dart';
import 'profile_page.dart';

class MahasiswaDashboardPage extends StatefulWidget {
  const MahasiswaDashboardPage({super.key});

  @override
  State<MahasiswaDashboardPage> createState() => _MahasiswaDashboardPageState();
}

class _MahasiswaDashboardPageState extends State<MahasiswaDashboardPage> {
  int _selectedIndex = 0;
  List<String> _breadcrumbs = const ['Beranda', 'Dashboard'];

  static const List<SidebarItem> _sidebarItems = [
    SidebarItem(icon: Icons.dashboard_rounded, label: 'Beranda'),
    SidebarItem(icon: Icons.edit_note_rounded, label: 'Isi KRS'),
    SidebarItem(icon: Icons.library_books_rounded, label: 'Lihat KHS'),
    SidebarItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  void _onNavSelected(int i) {
    setState(() {
      _selectedIndex = i;
      switch (i) {
        case 0:
          _breadcrumbs = const ['Beranda', 'Dashboard'];
          break;
        case 1:
          _breadcrumbs = const ['Beranda', 'Akademik', 'Isi KRS'];
          break;
        case 2:
          _breadcrumbs = const ['Beranda', 'Hasil Studi', 'KHS'];
          break;
        case 3:
          _breadcrumbs = const ['Beranda', 'Profil Mahasiswa'];
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const akademik = AkademikService();
    final mahasiswa = akademik.mahasiswaAktif();

    // Pages as content-only widgets (no double scaffold)
    final List<Widget> pages = [
      _MahasiswaDashboardContent(onNavigate: _onNavSelected),
      const KrsContent(),
      const KhsContent(),
      const ProfileContent(),
    ];

    return CyberScaffold(
      userName: mahasiswa.namaLengkap,
      userRole: 'mahasiswa',
      breadcrumbs: _breadcrumbs,
      sidebarItems: _sidebarItems,
      selectedIndex: _selectedIndex,
      onItemSelected: _onNavSelected,
      child: pages[_selectedIndex],
    );
  }
}

// ─── Dashboard Content ─────────────────────────────────────────────────────────
class _MahasiswaDashboardContent extends StatelessWidget {
  final Function(int)? onNavigate;
  const _MahasiswaDashboardContent({this.onNavigate});

  @override
  Widget build(BuildContext context) {
    const akademik = AkademikService();
    final mahasiswa = akademik.mahasiswaAktif();
    final ipk = akademik.ipkMahasiswaAktif();
    final kehadiran = akademik.persentaseKehadiranMahasiswa(mahasiswa.nim);
    final krsValid = akademik.krsValidMahasiswaAktif();
    final krsPending = akademik.krsPendingMahasiswaAktif();
    final krsDraft = akademik.krsDraftMahasiswaAktif();

    String krsStatus = 'Belum Mengisi KRS';
    Color krsStatusColor = AppColors.warning;
    if (krsValid.isNotEmpty) {
      krsStatus = 'KRS Divalidasi ✓';
      krsStatusColor = AppColors.success;
    } else if (krsPending.isNotEmpty) {
      krsStatus = 'Menunggu Validasi...';
      krsStatusColor = AppColors.primary;
    } else if (krsDraft.isNotEmpty) {
      krsStatus = 'Draft KRS (${krsDraft.length} MK)';
      krsStatusColor = AppColors.warning;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            'Hai, ${mahasiswa.namaLengkap.split(' ').first}! 👋',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          Text(
            'NIM: ${mahasiswa.nim} · ${AppData.semesterAktif}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Stat Cards Row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'IPK',
                  value: ipk.toStringAsFixed(2),
                  icon: Icons.workspace_premium_rounded,
                  color: AppColors.primary,
                  subtitle: 'Skala 4.00',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  label: 'Kehadiran',
                  value: '${(kehadiran * 100).round()}%',
                  icon: Icons.how_to_reg_rounded,
                  color: AppColors.success,
                  subtitle: 'Rata-rata semester ini',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  label: 'SKS Diambil',
                  value: '${krsValid.fold(0, (s, n) => s + n.sksMataKuliah)}',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.warning,
                  subtitle: 'Semester aktif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KRS Status Card
          CyberPanel(
            isGlass: false,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: krsStatusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.assignment_turned_in_rounded,
                      color: krsStatusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status KRS Semester Ini',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      Text(krsStatus,
                          style: TextStyle(
                              color: krsStatusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ),
                if (krsValid.isEmpty)
                  ElevatedButton(
                    onPressed: () => onNavigate?.call(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Isi KRS'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Links
          const Text(
            'Menu Cepat',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickLinkCard(
                  icon: Icons.edit_note_rounded,
                  label: 'Isi KRS',
                  subtitle: 'Daftarkan Mata Kuliah',
                  color: AppColors.primary,
                  onTap: () => onNavigate?.call(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickLinkCard(
                  icon: Icons.library_books_rounded,
                  label: 'Lihat KHS',
                  subtitle: 'Hasil Studi & Nilai',
                  color: AppColors.success,
                  onTap: () => onNavigate?.call(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickLinkCard(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  subtitle: 'Data Diri Mahasiswa',
                  color: AppColors.warning,
                  onTap: () => onNavigate?.call(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent KRS activity
          if (krsValid.isNotEmpty) ...[
            const Text(
              'Mata Kuliah Semester Ini',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            CyberPanel(
              isGlass: false,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < krsValid.take(5).length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.book_rounded,
                                color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(krsValid[i].namaMataKuliah,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        fontSize: 14)),
                                Text(
                                    '${krsValid[i].sksMataKuliah} SKS · ${krsValid[i].kodeMataKuliah}',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              krsValid[i].nilaiHuruf ?? 'Valid',
                              style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (krsValid.length > 5)
                    TextButton(
                      onPressed: () => onNavigate?.call(2),
                      child: const Text('Lihat semua di KHS →'),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Quick Link Card ───────────────────────────────────────────────────────────
class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CyberPanel(
        isGlass: false,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return CyberPanel(
      isGlass: false,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 30,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── Embedded Content Pages (no double scaffold) ───────────────────────────────

/// KRS tanpa CyberScaffold wrapper
class KrsContent extends StatefulWidget {
  const KrsContent({super.key});

  @override
  State<KrsContent> createState() => _KrsContentState();
}

class _KrsContentState extends State<KrsContent> {
  @override
  Widget build(BuildContext context) {
    // KrsPage sudah tidak punya CyberScaffold sendiri, langsung tampilkan
    return const KrsPage();
  }
}

/// KHS tanpa CyberScaffold wrapper
class KhsContent extends StatelessWidget {
  const KhsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhsPage();
  }
}

/// Profile tanpa CyberScaffold wrapper
class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}

