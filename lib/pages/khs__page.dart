import 'package:flutter/material.dart';

import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';

class KhsPage extends StatelessWidget {
  const KhsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const akademik = AkademikService();
    final nilaiMahasiswa = akademik.khsMahasiswaAktif();
    final totalSks = akademik.totalSks(nilaiMahasiswa);
    final belumDinilai = akademik.jumlahBelumDinilai(nilaiMahasiswa);
    final ipk = akademik.hitungIpk(nilaiMahasiswa);

    return CyberScaffold(
      appBar: AppBar(title: const Text('Kartu Hasil Studi')),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CyberHeader(
            tag: '// KHS Mahasiswa',
            title: 'IPK ${ipk.toStringAsFixed(2)}',
            subtitle: '$totalSks SKS tercatat - $belumDinilai nilai belum masuk.',
            icon: Icons.workspace_premium,
          ),
          const SizedBox(height: 16),
          CyberPanel(
            child: Column(
              children: [
                ProgressMetric(
                  label: 'Nilai Sudah Masuk',
                  value: nilaiMahasiswa.isEmpty
                      ? '0%'
                      : '${(((nilaiMahasiswa.length - belumDinilai) / nilaiMahasiswa.length) * 100).round()}%',
                  progress: nilaiMahasiswa.isEmpty
                      ? 0
                      : (nilaiMahasiswa.length - belumDinilai) /
                            nilaiMahasiswa.length,
                ),
                const SizedBox(height: 16),
                ProgressMetric(
                  label: 'Skala IPK',
                  value: ipk.toStringAsFixed(2),
                  progress: ipk / 4,
                  color: AppColors.goldLight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (nilaiMahasiswa.isEmpty)
            const CyberPanel(
              child: Text(
                'Belum ada KRS atau nilai untuk mahasiswa ini.',
                style: TextStyle(color: AppColors.grey),
              ),
            )
          else
            ...nilaiMahasiswa.map(
              (nilai) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CyberPanel(
                  child: Row(
                    children: [
                      const Icon(Icons.grade, color: AppColors.accent),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nilai.namaMataKuliah,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${nilai.kodeMataKuliah} - ${nilai.sksMataKuliah} SKS',
                              style: const TextStyle(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            nilai.nilaiHuruf ?? '-',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nilai.nilaiAngka?.toStringAsFixed(0) ??
                                'Belum dinilai',
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 11,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
