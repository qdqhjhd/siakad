import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/kelas_kuliah.dart';

class KelasKuliahPage extends StatefulWidget {
  const KelasKuliahPage({super.key});

  @override
  State<KelasKuliahPage> createState() => _KelasKuliahPageState();
}

class _KelasKuliahPageState extends State<KelasKuliahPage> {
  void tambah() {
    String kodeProdi = AppData.currentAdminProdiKode;
    String? mk;
    String? dosen;
    final nama = TextEditingController();
    final kapasitas = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Buka Kelas Kuliah'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            final mataKuliahProdi = AppData.daftarMataKuliah
                .where((m) => m.kodeProdi == kodeProdi)
                .toList();

            final dosenProdi = AppData.daftarDosen
                .where((d) => d.kodeProdi == kodeProdi)
                .toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (AppData.currentAdminProdiKode.isEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: kodeProdi.isEmpty ? null : kodeProdi,
                    hint: const Text('Pilih Prodi'),
                    items: AppData.daftarProdi.map((prodi) {
                      return DropdownMenuItem(
                        value: prodi.kodeProdi,
                        child: Text(prodi.namaProdi),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setDialogState(() {
                        kodeProdi = v ?? '';
                        mk = null;
                        dosen = null;
                      });
                    },
                  ),
                DropdownButtonFormField<String>(
                  initialValue: mk,
                  hint: const Text('Pilih Mata Kuliah'),
                  items: mataKuliahProdi.map((m) {
                    return DropdownMenuItem(
                      value: m.kodeMataKuliah,
                      child: Text(m.namaMataKuliah),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setDialogState(() {
                      mk = v;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: dosen,
                  hint: const Text('Pilih Dosen'),
                  items: dosenProdi.map((d) {
                    return DropdownMenuItem(value: d.nama, child: Text(d.nama));
                  }).toList(),
                  onChanged: (v) {
                    setDialogState(() {
                      dosen = v;
                    });
                  },
                ),
                TextField(
                  controller: nama,
                  decoration: const InputDecoration(labelText: 'Nama Kelas'),
                ),
                TextField(
                  controller: kapasitas,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Kapasitas'),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (kodeProdi.isEmpty ||
                  mk == null ||
                  dosen == null ||
                  nama.text.isEmpty ||
                  kapasitas.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua data wajib diisi')),
                );
                return;
              }

              setState(() {
                AppData.daftarKelas.add(
                  KelasKuliah(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    kodeSemester: AppData.semesterAktif,
                    kodeProdi: kodeProdi,
                    kodeMataKuliah: mk!,
                    namaKelas: nama.text,
                    dosenPengampu: dosen!,
                    kapasitas: int.parse(kapasitas.text),
                    jumlahPeserta: 0, jadwal: 'TBD',
                  ),
                );
              });

              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void hapusKelas(String idKelas) {
    final sudahAdaPeserta = AppData.daftarNilai.any(
      (nilai) => nilai.idKelasKuliah == idKelas,
    );

    if (sudahAdaPeserta) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kelas tidak bisa dihapus karena sudah ada peserta'),
        ),
      );
      return;
    }

    setState(() {
      AppData.daftarKelas.removeWhere((kelas) => kelas.id == idKelas);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = AppData.currentAdminProdiKode.isEmpty
        ? AppData.daftarKelas
        : AppData.daftarKelas
            .where((k) => k.kodeProdi == AppData.currentAdminProdiKode)
            .toList();

    return Scaffold(
      body: data.isEmpty
          ? const Center(child: Text('Belum ada kelas kuliah'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              itemBuilder: (_, i) {
                final k = data[i];

                final mk = AppData.daftarMataKuliah.firstWhere(
                  (m) => m.kodeMataKuliah == k.kodeMataKuliah,
                );

                return Card(
                  child: ListTile(
                    title: Text('${mk.namaMataKuliah} - Kelas ${k.namaKelas}'),
                    subtitle: Text(
                      'Semester: ${k.kodeSemester}\n'
                      'Dosen: ${k.dosenPengampu}\n'
                      'Kapasitas: ${AppData.hitungPesertaKelas(k.id)}/${k.kapasitas}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => hapusKelas(k.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: tambah,
        child: const Icon(Icons.add),
      ),
    );
  }
}
