import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';

class KrsPage extends StatefulWidget {
  const KrsPage({super.key});

  @override
  State<KrsPage> createState() => _KrsPageState();
}

class _KrsPageState extends State<KrsPage> {
  final akademik = const AkademikService();

  void ambilKelas(String idKelas) {
    final kelas = AppData.daftarKelas.firstWhere((k) => k.id == idKelas);

    if (akademik.sudahAmbilKelas(kelas.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kelas ini sudah kamu ambil')),
      );
      return;
    }

    if (akademik.kelasPenuh(kelas)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kelas penuh')));
      return;
    }

    setState(() => akademik.ambilKelas(kelas));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Berhasil mengambil KRS')));
  }

  @override
  Widget build(BuildContext context) {
    final kelasSesuaiProdi = akademik.kelasUntukMahasiswaAktif();

    return CyberScaffold(
      appBar: AppBar(title: const Text('Kartu Rencana Studi')),
      child: kelasSesuaiProdi.isEmpty
          ? const Center(
              child: Text(
                'Belum ada kelas kuliah di prodi kamu',
                style: TextStyle(color: AppColors.text),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kelasSesuaiProdi.length,
              itemBuilder: (context, index) {
                final kelas = kelasSesuaiProdi[index];
                final mataKuliah = akademik.mataKuliahByKode(
                  kelas.kodeMataKuliah,
                );
                final peserta = AppData.hitungPesertaKelas(kelas.id);
                final sudahAmbil = akademik.sudahAmbilKelas(kelas.id);
                final penuh = peserta >= kelas.kapasitas;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CyberPanel(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.menu_book, color: AppColors.accent),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mataKuliah.namaMataKuliah,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${mataKuliah.kodeMataKuliah} - ${mataKuliah.jumlahSks} SKS - Kelas ${kelas.namaKelas}',
                                style: const TextStyle(color: AppColors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dosen: ${kelas.dosenPengampu}',
                                style: const TextStyle(color: AppColors.grey),
                              ),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: peserta / kelas.kapasitas,
                                minHeight: 5,
                                color: penuh
                                    ? AppColors.gold
                                    : AppColors.accent,
                                backgroundColor: AppColors.cyan.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Kapasitas: $peserta/${kelas.kapasitas}',
                                style: const TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: sudahAmbil || penuh
                              ? null
                              : () => ambilKelas(kelas.id),
                          child: Text(
                            sudahAmbil
                                ? 'Diambil'
                                : penuh
                                ? 'Penuh'
                                : 'Ambil',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
