import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/mahasiswa.dart';
import '../theme/app_colors.dart';

class AdminMahasiswaPage extends StatefulWidget {
  const AdminMahasiswaPage({super.key});

  @override
  State<AdminMahasiswaPage> createState() => _AdminMahasiswaPageState();
}

class _AdminMahasiswaPageState extends State<AdminMahasiswaPage> {
  void formMahasiswa({Mahasiswa? mahasiswa, int? index}) {
    final nimController = TextEditingController(text: mahasiswa?.nim ?? '');
    final namaController = TextEditingController(
      text: mahasiswa?.namaLengkap ?? '',
    );
    final angkatanController = TextEditingController(
      text: mahasiswa?.angkatan.toString() ?? '',
    );

    bool jk = mahasiswa?.jk ?? false;
    String kodeProdi =
        mahasiswa?.kodeProdi ?? AppData.daftarProdi.first.kodeProdi;
    DateTime tanggalLahir = mahasiswa?.tanggalLahir ?? DateTime(2005, 1, 1);

    final tanggalController = TextEditingController(
      text: '${tanggalLahir.day}-${tanggalLahir.month}-${tanggalLahir.year}',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          mahasiswa == null ? 'Tambah Mahasiswa' : 'Edit Mahasiswa',
          style: const TextStyle(color: AppColors.primaryLight),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  darkInput(controller: nimController, label: 'NIM'),
                  darkInput(controller: namaController, label: 'Nama Lengkap'),
                  DropdownButtonFormField<bool>(
                    initialValue: jk,
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.white),
                    decoration: darkDropdownDecoration('Jenis Kelamin'),
                    items: const [
                      DropdownMenuItem(value: false, child: Text('Laki-laki')),
                      DropdownMenuItem(value: true, child: Text('Perempuan')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        jk = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: kodeProdi,
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.white),
                    decoration: darkDropdownDecoration('Prodi'),
                    items: AppData.daftarProdi.map((prodi) {
                      return DropdownMenuItem(
                        value: prodi.kodeProdi,
                        child: Text(prodi.namaProdi),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        kodeProdi = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  darkInput(
                    controller: angkatanController,
                    label: 'Angkatan',
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: tanggalController,
                    readOnly: true,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir',
                      labelStyle: TextStyle(color: AppColors.primaryLight),
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        color: AppColors.primaryLight,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryLight),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
                      ),
                    ),
                    onTap: () async {
                      final hasil = await showDatePicker(
                        context: context,
                        initialDate: tanggalLahir,
                        firstDate: DateTime(1990),
                        lastDate: DateTime(2030),
                      );

                      if (hasil != null) {
                        setDialogState(() {
                          tanggalLahir = hasil;
                          tanggalController.text =
                              '${hasil.day}-${hasil.month}-${hasil.year}';
                        });
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (nimController.text.isEmpty ||
                  namaController.text.isEmpty ||
                  angkatanController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data wajib diisi lengkap')),
                );
                return;
              }

              setState(() {
                if (mahasiswa == null) {
                  AppData.daftarMahasiswa.add(
                    Mahasiswa(
                      nim: nimController.text,
                      namaLengkap: namaController.text,
                      jk: jk,
                      kodeProdi: kodeProdi,
                      angkatan: int.parse(angkatanController.text),
                      tanggalLahir: tanggalLahir,
                    ),
                  );
                } else {
                  AppData.daftarMahasiswa[index!].nim = nimController.text;
                  AppData.daftarMahasiswa[index].namaLengkap =
                      namaController.text;
                  AppData.daftarMahasiswa[index].jk = jk;
                  AppData.daftarMahasiswa[index].kodeProdi = kodeProdi;
                  AppData.daftarMahasiswa[index].angkatan = int.parse(
                    angkatanController.text,
                  );
                  AppData.daftarMahasiswa[index].tanggalLahir = tanggalLahir;
                }
              });

              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  TextField darkInput({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.primaryLight),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryLight),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
        ),
      ),
    );
  }

  InputDecoration darkDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.primaryLight),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryLight),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
      ),
    );
  }

  void hapusMahasiswa(int index) {
    final mhs = AppData.daftarMahasiswa[index];

    final sudahAdaNilai = AppData.daftarNilai.any(
      (nilai) => nilai.nim == mhs.nim,
    );

    if (sudahAdaNilai) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mahasiswa tidak bisa dihapus karena sudah ada nilai'),
        ),
      );
      return;
    }

    setState(() {
      AppData.daftarMahasiswa.removeAt(index);
    });
  }

  String getNamaProdi(String kodeProdi) {
    final prodi = AppData.daftarProdi.firstWhere(
      (p) => p.kodeProdi == kodeProdi,
      orElse: () => AppData.daftarProdi.first,
    );

    return prodi.namaProdi;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Mahasiswa',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              ElevatedButton.icon(
                onPressed: () => formMahasiswa(),
                icon: const Icon(Icons.add),
                label: const Text('TAMBAH'),
              ),
            ],
          ),
        ),
        Expanded(
          child: AppData.daftarMahasiswa.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada data mahasiswa',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: AppData.daftarMahasiswa.length,
                  itemBuilder: (context, index) {
                    final mhs = AppData.daftarMahasiswa[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.bg,
                            child: Text(
                              mhs.namaLengkap[0],
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mhs.namaLengkap,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'NIM: ${mhs.nim} • ${getNamaProdi(mhs.kodeProdi)}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                Text(
                                  'Angkatan: ${mhs.angkatan} • ${mhs.jk ? 'Perempuan' : 'Laki-laki'}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => formMahasiswa(mahasiswa: mhs, index: index),
                            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryLight, size: 20),
                          ),
                          IconButton(
                            onPressed: () => hapusMahasiswa(index),
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
