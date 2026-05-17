import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/nilai.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_widgets.dart';

class ValidasiKrsPage extends StatefulWidget {
  const ValidasiKrsPage({super.key});

  @override
  State<ValidasiKrsPage> createState() => _ValidasiKrsPageState();
}

class _ValidasiKrsPageState extends State<ValidasiKrsPage> {
  final akademik = const AkademikService();

  @override
  Widget build(BuildContext context) {
    final mahasiswaBimbingan = akademik.mahasiswaBimbinganDosenAktif();
    final bimbinganNim = mahasiswaBimbingan.map((m) => m.nim).toSet();
    final pengajuan = akademik.pengajuanKrsDosenAktif();

    final validasiDulu = AppData.daftarNilai
        .where((n) => bimbinganNim.contains(n.nim) && n.statusKrs == 'valid')
        .isNotEmpty;

    // Grouping pengajuan by NIM
    final Map<String, List<Nilai>> groupedPengajuan = {};
    for (var n in pengajuan) {
      groupedPengajuan.putIfAbsent(n.nim, () => []).add(n);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CyberHeader(
          tag: '// Dosen Pembimbing',
          title: 'Validasi KRS',
          subtitle:
              '${pengajuan.length} mata kuliah menunggu persetujuan dari ${groupedPengajuan.keys.length} mahasiswa bimbingan.',
          icon: Icons.fact_check,
        ),
        const SizedBox(height: 16),
        if (groupedPengajuan.isEmpty)
          CyberPanel(
            child: Text(
              validasiDulu
                  ? 'KRS Mahasiswa telah divalidasi.'
                  : 'Belum ada KRS yang diajukan untuk divalidasi.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ...groupedPengajuan.entries.map((entry) {
            final nim = entry.key;
            final listNilai = entry.value;
            final mhs =
                AppData.daftarMahasiswa.firstWhere((m) => m.nim == nim);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CyberPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.surfaceLayer,
                          child: Icon(Icons.person, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mhs.namaLengkap,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'NIM: $nim • ${listNilai.length} Mata Kuliah',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    ...listNilai.map(
                      (nilai) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.book_outlined,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${nilai.kodeMataKuliah} - ${nilai.namaMataKuliah} (${nilai.sksMataKuliah} SKS)',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                for (var n in listNilai) {
                                  akademik.tolakKrs(n);
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'KRS ${mhs.namaLengkap} ditolak')),
                              );
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Tolak Semua'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                for (var n in listNilai) {
                                  akademik.validasiKrs(n);
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'KRS ${mhs.namaLengkap} divalidasi')),
                              );
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Setujui Semua'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
