import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../utils/logout.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';
import 'khs__page.dart';
import 'krs_page.dart';

class MahasiswaDashboardPage extends StatelessWidget {
  const MahasiswaDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const akademik = AkademikService();
    final mahasiswa = akademik.mahasiswaAktif();
    final nilai = akademik.khsMahasiswaAktif();
    final totalSks = akademik.totalSks(nilai);
    final belumDinilai = akademik.jumlahBelumDinilai(nilai);
    final ipk = akademik.ipkMahasiswaAktif();
    final kehadiran = akademik.persentaseKehadiranMahasiswa(mahasiswa.nim);
    final prodi = AppData.daftarProdi.firstWhere(
      (p) => p.kodeProdi == mahasiswa.kodeProdi,
    );

    return CyberScaffold(
      appBar: AppBar(
        title: const Text('Dashboard Mahasiswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CyberHeader(
            tag: '// Portal Mahasiswa',
            title: mahasiswa.namaLengkap,
            subtitle: 'NIM ${mahasiswa.nim} - ${prodi.namaProdi}',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatTile(value: ipk.toStringAsFixed(2), label: 'IPK Saat Ini'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(value: '${(kehadiran * 100).round()}%', label: 'Kehadiran'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatTile(value: '$totalSks', label: 'SKS Diambil')),
              const SizedBox(width: 12),
              Expanded(child: StatTile(value: '$belumDinilai', label: 'Belum Dinilai')),
            ],
          ),
          const SizedBox(height: 16),
          CyberPanel(
            child: Column(
              children: [
                ProgressMetric(
                  label: 'Kehadiran Semester',
                  value: '${(kehadiran * 100).round()}%',
                  progress: kehadiran,
                ),
                const SizedBox(height: 16),
                ProgressMetric(
                  label: 'Progres Nilai Masuk',
                  value: nilai.isEmpty
                      ? '0%'
                      : '${(((nilai.length - belumDinilai) / nilai.length) * 100).round()}%',
                  progress: nilai.isEmpty
                      ? 0
                      : (nilai.length - belumDinilai) / nilai.length,
                  color: AppColors.goldLight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MenuCard(
            icon: Icons.fact_check,
            title: 'KRS - Ambil Mata Kuliah',
            subtitle: 'Pilih kelas sesuai prodi dengan validasi kapasitas.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KrsPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          MenuCard(
            icon: Icons.workspace_premium,
            title: 'KHS - Lihat Nilai',
            subtitle: 'Pantau nilai angka, nilai huruf, dan SKS yang ditempuh.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KhsPage()),
              );
            },
          ),
          const SizedBox(height: 16),
          const CyberPanel(
            child: Text(
              'Status akademik aktif. Pastikan KRS sudah sesuai sebelum periode pengisian berakhir.',
              style: TextStyle(color: AppColors.grey, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
