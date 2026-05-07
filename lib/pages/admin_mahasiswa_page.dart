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
        backgroundColor: AppColors.card,
        title: Text(
          mahasiswa == null ? 'Tambah Mahasiswa' : 'Edit Mahasiswa',
          style: const TextStyle(color: AppColors.cyan),
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
                    dropdownColor: AppColors.card,
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
                    dropdownColor: AppColors.card,
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
                      labelStyle: TextStyle(color: AppColors.cyan),
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        color: AppColors.cyan,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.cyan),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.cyan, width: 2),
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
              backgroundColor: AppColors.cyan,
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
        labelStyle: const TextStyle(color: AppColors.cyan),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.cyan),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.cyan, width: 2),
        ),
      ),
    );
  }

  InputDecoration darkDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.cyan),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.cyan),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.cyan, width: 2),
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
                  color: AppColors.card,
                  elevation: 10,
                  shadowColor: AppColors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.cyan, width: 0.8),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.cyan,
                      child: Text(
                        mhs.namaLengkap[0],
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      mhs.namaLengkap,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'NIM: ${mhs.nim}\n'
                      'JK: ${mhs.jk ? 'Perempuan' : 'Laki-laki'}\n'
                      'Prodi: ${getNamaProdi(mhs.kodeProdi)}\n'
                      'Angkatan: ${mhs.angkatan}\n'
                      'Tanggal Lahir: ${mhs.tanggalLahir.day}-${mhs.tanggalLahir.month}-${mhs.tanggalLahir.year}',
                      style: const TextStyle(color: AppColors.grey),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () =>
                              formMahasiswa(mahasiswa: mhs, index: index),
                          icon: const Icon(Icons.edit, color: AppColors.cyan),
                        ),
                        IconButton(
                          tooltip: 'Hapus',
                          onPressed: () => hapusMahasiswa(index),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.cyan,
        foregroundColor: Colors.black,
        onPressed: () => formMahasiswa(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
