import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../utils/logout.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';
import 'input_nilai_page.dart';
import 'validasi_krs_page.dart';
import 'presensi_page.dart';

class DosenPage extends StatelessWidget {
  const DosenPage({super.key});

  @override
  Widget build(BuildContext context) {
    const akademik = AkademikService();
    final namaDosen = AppData.currentDosenNama;
    final prodiDosen = AppData.currentDosenProdi;
    final kelasDosen = akademik.kelasDosenAktif();
    final semuaNilai = akademik.nilaiDosenAktif();
    final belumInput = akademik.nilaiBelumInputDosenAktif();
    final progressInput = akademik.progresInputNilaiDosenAktif();
    final rataRata = akademik.rataRataNilaiDosenAktif();
    final pendingKrs = akademik.pengajuanKrsDosenAktif().length;

    return CyberScaffold(
      appBar: AppBar(
        title: const Text('Dashboard Dosen'),
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
            tag: '// Kelas Saya',
            title: namaDosen.isEmpty ? 'Dosen' : namaDosen,
            subtitle: 'NIDN ${AppData.currentDosenNidn} - Prodi $prodiDosen',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: StatTile(
                value: '${kelasDosen.length}',
                label: 'Kelas',
                icon: Icons.class_rounded,
                progress: kelasDosen.isEmpty ? 0 : 1.0,
                color: AppColors.primary,
              )),
              const SizedBox(width: 12),
              Expanded(child: StatTile(
                value: '$belumInput',
                label: 'Belum Input',
                icon: Icons.edit_off_rounded,
                progress: semuaNilai.isEmpty ? 0 : (belumInput / semuaNilai.length).clamp(0.0, 1.0),
                color: belumInput == 0 ? AppColors.success : const Color(0xFFE67E22),
              )),
              const SizedBox(width: 12),
              Expanded(child: StatTile(
                value: '$pendingKrs',
                label: 'Validasi KRS',
                icon: Icons.fact_check_rounded,
                progress: pendingKrs == 0 ? 1.0 : 0.5,
                color: pendingKrs == 0 ? AppColors.success : const Color(0xFFF59E0B),
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: rataRata == 0 ? '-' : rataRata.toStringAsFixed(1),
                  label: 'Rata Nilai',
                  icon: Icons.workspace_premium_rounded,
                  progress: rataRata == 0 ? 0 : (rataRata / 100).clamp(0.0, 1.0),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  value: semuaNilai.length.toString(),
                  label: 'Peserta KRS',
                  icon: Icons.people_rounded,
                  progress: semuaNilai.isEmpty ? 0 : 1.0,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CyberPanel(
            child: Column(
              children: [
                ProgressMetric(
                  label: 'Progress Input Nilai',
                  value: '${(progressInput * 100).round()}%',
                  progress: progressInput,
                ),
                const SizedBox(height: 20),
                ProgressMetric(
                  label: 'Estimasi Absensi Kelas',
                  value: '${(0.88 * 100).round()}%',
                  progress: 0.88,
                  color: const Color(0xFF7C3AED),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MiniBarChart(
            title: 'Nilai Belum Diinput per Kelas',
            values: kelasDosen.map((kelas) {
              final pending = AppData.daftarNilai
                  .where(
                    (nilai) =>
                        nilai.idKelasKuliah == kelas.id &&
                        nilai.nilaiAngka == null,
                  )
                  .length
                  .toDouble();
              return ChartValue(
                label: kelas.id,
                value: pending,
                color: pending == 0 ? AppColors.accent : AppColors.goldLight,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          MenuCard(
            icon: Icons.fact_check,
            title: 'Validasi KRS Mahasiswa',
            subtitle: pendingKrs == 0
                ? 'Belum ada pengajuan KRS dari mahasiswa bimbingan.'
                : '$pendingKrs pengajuan KRS menunggu persetujuan.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ValidasiKrsPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          MenuCard(
            icon: Icons.fingerprint_rounded,
            title: 'Presensi Kelas (Pertemuan)',
            subtitle: 'Kelola sesi pertemuan, buka/tutup presensi, dan isi kehadiran dosen/mahasiswa.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PresensiPage(role: 'dosen')),
              );
            },
          ),
          const SizedBox(height: 12),
          MenuCard(
            icon: Icons.edit_note,
            title: 'Input Nilai Mahasiswa',
            subtitle:
                'Pilih kelas yang diampu dan simpan nilai angka otomatis menjadi huruf.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InputNilaiPage()),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Kelas yang Diampu (${kelasDosen.length})',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (kelasDosen.isEmpty)
            const CyberPanel(
              child: Text(
                'Belum ada kelas yang diampu',
                style: TextStyle(color: AppColors.grey),
              ),
            )
          else
            ...kelasDosen.map((kelas) {
              final mk = AppData.daftarMataKuliah.firstWhere(
                (m) => m.kodeMataKuliah == kelas.kodeMataKuliah,
              );
              final peserta = AppData.hitungPesertaKelas(kelas.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CyberPanel(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.class_, color: AppColors.accent),
                    title: Text(
                      mk.namaMataKuliah,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      'Kelas ${kelas.namaKelas} - ${kelas.kodeMataKuliah}\nPeserta: $peserta/${kelas.kapasitas}',
                      style: const TextStyle(color: AppColors.grey),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
