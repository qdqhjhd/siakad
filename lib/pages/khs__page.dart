import 'package:flutter/material.dart';

import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
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

    return ListView(
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
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (nilaiMahasiswa.isEmpty)
            const CyberPanel(
              child: Text(
                'Belum ada KRS atau nilai untuk mahasiswa ini.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            CyberPanel(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  dataTextStyle: const TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  columns: const [
                    DataColumn(label: Text('Kode')),
                    DataColumn(label: Text('Mata Kuliah')),
                    DataColumn(label: Text('SKS')),
                    DataColumn(label: Text('Nilai Huruf')),
                    DataColumn(label: Text('Nilai Angka')),
                  ],
                  rows: nilaiMahasiswa.map((nilai) {
                    return DataRow(
                      cells: [
                        DataCell(Text(nilai.kodeMataKuliah)),
                        DataCell(Text(nilai.namaMataKuliah)),
                        DataCell(Text('${nilai.sksMataKuliah}')),
                        DataCell(
                          Text(
                            nilai.nilaiHuruf ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        DataCell(
                          Text(nilai.nilaiAngka?.toStringAsFixed(0) ?? '-'),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
    );
  }
}
