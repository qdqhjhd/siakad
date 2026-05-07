import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../services/akademik_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_scaffold.dart';
import '../widgets/cyber_widgets.dart';

class InputNilaiPage extends StatefulWidget {
  const InputNilaiPage({super.key});

  @override
  State<InputNilaiPage> createState() => _InputNilaiPageState();
}

class _InputNilaiPageState extends State<InputNilaiPage> {
  String? selectedKelasId;
  final akademik = const AkademikService();

  @override
  Widget build(BuildContext context) {
    final kelasDosen = AppData.daftarKelas.where((kelas) {
      return kelas.dosenPengampu.trim() == AppData.currentDosenNama.trim() &&
          kelas.kodeProdi == AppData.currentDosenProdi;
    }).toList();

    final nilaiMahasiswa = selectedKelasId == null
        ? []
        : AppData.daftarNilai.where((nilai) {
            return nilai.idKelasKuliah == selectedKelasId;
          }).toList();

    return CyberScaffold(
      appBar: AppBar(title: const Text('Input Nilai Mahasiswa')),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CyberHeader(
              tag: '// Dosen',
              title: 'Input Nilai',
              subtitle: 'Nilai angka otomatis dikonversi menjadi nilai huruf.',
              icon: Icons.edit_note,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedKelasId,
              dropdownColor: AppColors.card,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                labelText: 'Pilih Kelas yang Diampu',
              ),
              items: kelasDosen.map((kelas) {
                final mk = AppData.daftarMataKuliah.firstWhere(
                  (m) => m.kodeMataKuliah == kelas.kodeMataKuliah,
                );

                return DropdownMenuItem(
                  value: kelas.id,
                  child: Text(
                    '${mk.namaMataKuliah} - Kelas ${kelas.namaKelas}',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedKelasId = value;
                });
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: selectedKelasId == null
                  ? const Center(
                      child: Text(
                        'Pilih kelas terlebih dahulu',
                        style: TextStyle(color: AppColors.white),
                      ),
                    )
                  : nilaiMahasiswa.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada mahasiswa yang mengambil kelas ini',
                        style: TextStyle(color: AppColors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: nilaiMahasiswa.length,
                      itemBuilder: (context, index) {
                        final nilai = nilaiMahasiswa[index];

                        final mhs = AppData.daftarMahasiswa.firstWhere(
                          (m) => m.nim == nilai.nim,
                        );

                        final nilaiController = TextEditingController(
                          text: nilai.nilaiAngka?.toString() ?? '',
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CyberPanel(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mhs.namaLengkap,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'NIM: ${mhs.nim}',
                                    style: const TextStyle(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Mata Kuliah: ${nilai.namaMataKuliah}',
                                    style: const TextStyle(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: nilaiController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Nilai Angka',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.cyan,
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      final angka = double.tryParse(
                                        nilaiController.text,
                                      );

                                      if (angka == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Nilai harus berupa angka',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() {
                                        nilai.nilaiAngka = angka;
                                        nilai.nilaiHuruf = akademik.nilaiHuruf(
                                          angka,
                                        );
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Nilai ${mhs.namaLengkap} berhasil disimpan',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      nilai.nilaiHuruf == null
                                          ? 'Simpan Nilai'
                                          : 'Update Nilai (${nilai.nilaiHuruf})',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
