import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mahasiswa = const AkademikService().mahasiswaAktif();
    final prodi = AppData.daftarProdi.firstWhere(
      (p) => p.kodeProdi == mahasiswa.kodeProdi,
      orElse: () => AppData.daftarProdi.first,
    );

    String getInitials(String name) {
      if (name.isEmpty) return '';
      List<String> parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return (parts[0][0] + parts[1][0]).toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Mahasiswa',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                    Text('Detail Mahasiswa', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('Aksi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            CyberPanel(
              padding: EdgeInsets.zero,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Sidebar
                  Container(
                    width: 200,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: AppColors.border)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 150,
                          height: 150,
                          color: const Color(0xFF2E3D1D), // Dark green from image
                          child: Center(
                            child: Text(
                              getInitials(mahasiswa.namaLengkap),
                              style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text('Ganti Foto (1 MB)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 20),
                        _profileSidebarItem('Biodata', true),
                        _profileSidebarItem('Riwayat Pendaftaran', false),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  // Profile Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _infoGrid([
                                  _infoItem('NIM', mahasiswa.nim),
                                  _infoItem('Nama Mahasiswa', mahasiswa.namaLengkap),
                                  _infoItem('Program Studi', prodi.namaProdi),
                                  _infoItem('Konsentrasi', '-'),
                                  _infoItem('Periode Masuk', '${mahasiswa.angkatan} Ganjil'),
                                  _infoItem('Tahun Kurikulum', '${mahasiswa.angkatan}'),
                                  _infoItem('Sistem Kuliah', 'Reguler'),
                                  _infoItem('Kelas / Kelompok', '-'),
                                  _infoItem('Jenis Pendaftaran', 'Peserta Didik Baru'),
                                ]),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: _infoGrid([
                                  _infoItem('Jalur Pendaftaran', 'SBMPTN / SNBT'),
                                  _infoItem('Gelombang', 'Gelombang 1'),
                                  _infoItem('Tanggal Awal Masuk', '12/07/2025'),
                                  _infoItem('Tanggal Daftar Ulang', '15/07/2025'),
                                  _infoItem('Kebutuhan Khusus', 'Tidak'),
                                  _infoItem('Status Mahasiswa', 'Aktif'),
                                  _infoItem('Biodata Valid', 'Ya', isCheck: true),
                                  _infoItem('Kampus', 'Kampus Utama'),
                                ]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Bottom Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _bottomTab('Informasi Umum', true),
                  _bottomTab('Domisili', false),
                  _bottomTab('Orang Tua', false),
                  _bottomTab('Wali', false),
                  _bottomTab('Sekolah', false),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CyberPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Umum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  const Divider(height: 30),
                  Row(
                    children: [
                      Expanded(child: _infoItem('NIK', '3201234567890001')),
                      Expanded(child: _infoItem('Email', 'vidi.aurel@univ.ac.id')),
                    ],
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }

  Widget _profileSidebarItem(String label, bool active) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: active ? AppColors.freshAir.withValues(alpha: 0.1) : Colors.transparent,
        border: active ? const Border(left: BorderSide(color: Colors.blue, width: 4)) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.blue : AppColors.textSecondary,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _infoGrid(List<Widget> items) {
    return Column(
      children: items,
    );
  }

  Widget _infoItem(String label, String value, {bool isCheck = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Expanded(
            child: isCheck
                ? const Icon(Icons.check, color: Colors.green, size: 18)
                : Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _bottomTab(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: active ? Colors.white : Colors.black54, fontWeight: FontWeight.bold),
      ),
    );
  }
}
