import 'package:flutter/material.dart';
import '../data/app_data.dart';

class ProdiMahasiswaPage extends StatelessWidget {
  const ProdiMahasiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mahasiswaProdi = AppData.daftarMahasiswa
        .where((m) => m.kodeProdi == AppData.currentAdminProdiKode)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF050A18),
      body: mahasiswaProdi.isEmpty
          ? const Center(
              child: Text(
                'Belum ada mahasiswa di prodi ini',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: mahasiswaProdi.length,
              itemBuilder: (context, index) {
                final mhs = mahasiswaProdi[index];

                return Card(
                  color: const Color(0xFF0B132B),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.cyanAccent),
                    title: Text(
                      mhs.namaLengkap,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'NIM: ${mhs.nim}\nAngkatan: ${mhs.angkatan}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
