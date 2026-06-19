import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/mahasiswa.dart';
import '../theme/app_colors.dart';
import '../services/mahasiswa_service.dart';

class AdminMahasiswaPage extends StatefulWidget {
  const AdminMahasiswaPage({super.key});

  @override
  State<AdminMahasiswaPage> createState() => _AdminMahasiswaPageState();
}

class _AdminMahasiswaPageState extends State<AdminMahasiswaPage> {
  final MahasiswaService _mahasiswaService = const MahasiswaService();

  void formMahasiswa({Mahasiswa? mahasiswa, int? index}) {
    final nimController = TextEditingController(text: mahasiswa?.nim ?? '');
    final namaController = TextEditingController(text: mahasiswa?.namaLengkap ?? '');
    final angkatanController = TextEditingController(
      text: mahasiswa?.angkatan.toString() ?? '',
    );

    bool jk = mahasiswa?.jk ?? false;
    String kodeProdi = mahasiswa?.kodeProdi ?? AppData.daftarProdi.first.kodeProdi;
    DateTime tanggalLahir = mahasiswa?.tanggalLahir ?? DateTime(2005, 1, 1);
    bool isAktif = mahasiswa?.isAktif ?? true;

    String dosenPembimbingNidn = mahasiswa?.dosenPembimbingNidn ??
        AppData.daftarDosen.first.nidn;

    final tanggalController = TextEditingController(
      text: '${tanggalLahir.day}-${tanggalLahir.month}-${tanggalLahir.year}',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
          mahasiswa == null ? 'Tambah Mahasiswa' : 'Edit Mahasiswa',
          style: const TextStyle(color: AppColors.primaryLight),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            final dosenSesuaiProdi = AppData.daftarDosen
                .where((dosen) => dosen.kodeProdi == kodeProdi)
                .toList();

            if (dosenSesuaiProdi.isNotEmpty &&
                !dosenSesuaiProdi.any((d) => d.nidn == dosenPembimbingNidn)) {
              dosenPembimbingNidn = dosenSesuaiProdi.first.nidn;
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  darkInput(controller: nimController, label: 'NIM'),
                  darkInput(controller: namaController, label: 'Nama Lengkap'),

                  DropdownButtonFormField<bool>(
                    value: jk,
                    dropdownColor: AppColors.white,
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
                    value: kodeProdi,
                    dropdownColor: AppColors.white,
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
                        final dosenBaru = AppData.daftarDosen
                            .where((d) => d.kodeProdi == kodeProdi)
                            .toList();

                        if (dosenBaru.isNotEmpty) {
                          dosenPembimbingNidn = dosenBaru.first.nidn;
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: dosenSesuaiProdi.isEmpty ? null : dosenPembimbingNidn,
                    dropdownColor: AppColors.white,
                    style: const TextStyle(color: AppColors.white),
                    decoration: darkDropdownDecoration('Dosen Pembimbing'),
                    items: dosenSesuaiProdi.map((dosen) {
                      return DropdownMenuItem(
                        value: dosen.nidn,
                        child: Text('${dosen.nama} - ${dosen.nidn}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        dosenPembimbingNidn = value!;
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
                      suffixIcon: Icon(Icons.calendar_month, color: AppColors.primaryLight),
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

                  if (mahasiswa != null) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<bool>(
                      value: isAktif,
                      dropdownColor: AppColors.white,
                      style: const TextStyle(color: AppColors.white),
                      decoration: darkDropdownDecoration('Status Keaktifan'),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Aktif')),
                        DropdownMenuItem(value: false, child: Text('Tidak Aktif')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          isAktif = value!;
                        });
                      },
                    ),
                  ],
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
                  final newMhs = Mahasiswa(
                    nim: nimController.text,
                    namaLengkap: namaController.text,
                    jk: jk,
                    kodeProdi: kodeProdi,
                    angkatan: int.parse(angkatanController.text),
                    tanggalLahir: tanggalLahir,
                    dosenPembimbingNidn: dosenPembimbingNidn,
                    isAktif: isAktif,
                  );
                  final error = _mahasiswaService.tambahMahasiswa(newMhs);
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                    return; // Prevent pop
                  }
                } else {
                  final updatedMhs = Mahasiswa(
                    nim: nimController.text,
                    namaLengkap: namaController.text,
                    jk: jk,
                    kodeProdi: kodeProdi,
                    angkatan: int.parse(angkatanController.text),
                    tanggalLahir: tanggalLahir,
                    dosenPembimbingNidn: dosenPembimbingNidn,
                    isAktif: isAktif,
                  );
                  _mahasiswaService.updateMahasiswa(mahasiswa.nim, updatedMhs);
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
    final error = _mahasiswaService.hapusMahasiswa(mhs.nim);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() {});
  }

  String getNamaProdi(String kodeProdi) {
    final prodi = AppData.daftarProdi.firstWhere(
      (p) => p.kodeProdi == kodeProdi,
      orElse: () => AppData.daftarProdi.first,
    );

    return prodi.namaProdi;
  }

  String getNamaDosen(String nidn) {
    final dosen = AppData.daftarDosen.firstWhere(
      (d) => d.nidn == nidn,
      orElse: () => AppData.daftarDosen.first,
    );

    return dosen.nama;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AppData.daftarMahasiswa.isEmpty
          ? const Center(
              child: Text(
                'Belum ada data mahasiswa',
                style: TextStyle(color: AppColors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: AppData.daftarMahasiswa.length,
              itemBuilder: (context, index) {
                final mhs = AppData.daftarMahasiswa[index];

                return Card(
                  color: AppColors.white,
                  elevation: 10,
                  shadowColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.primaryLight, width: 0.8),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        mhs.namaLengkap[0],
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          mhs.namaLengkap,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: mhs.isAktif ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: mhs.isAktif ? Colors.green : Colors.red,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            mhs.isAktif ? 'Aktif' : 'Tidak Aktif',
                            style: TextStyle(
                              color: mhs.isAktif ? Colors.green : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'NIM: ${mhs.nim}\n'
                      'JK: ${mhs.jk ? 'Perempuan' : 'Laki-laki'}\n'
                      'Prodi: ${getNamaProdi(mhs.kodeProdi)}\n'
                      'Angkatan: ${mhs.angkatan}\n'
                      'Tanggal Lahir: ${mhs.tanggalLahir.day}-${mhs.tanggalLahir.month}-${mhs.tanggalLahir.year}\n'
                      'Pembimbing: ${getNamaDosen(mhs.dosenPembimbingNidn ?? "")}',
                      style: const TextStyle(color: AppColors.grey),
                    ),
                    isThreeLine: false,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () =>
                              formMahasiswa(mahasiswa: mhs, index: index),
                          icon: const Icon(Icons.edit, color: AppColors.primaryLight),
                        ),
                        IconButton(
                          tooltip: 'Hapus',
                          onPressed: () => hapusMahasiswa(index),
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.black,
        onPressed: () => formMahasiswa(),
        child: const Icon(Icons.add),
      ),
    );
  }
}