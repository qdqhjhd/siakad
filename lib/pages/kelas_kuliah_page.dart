import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/kelas_kuliah.dart';
import '../models/ruangan.dart';
import '../models/dosen.dart';
import '../models/dosen_pengajar.dart';
import '../models/mata_kuliah.dart';
import '../services/dosen_pengajar_service.dart';
import '../services/kelas_kuliah_service.dart';
import '../services/ruangan_service.dart';
import '../theme/app_colors.dart';
import '../widgets/cyber_widgets.dart';

class KelasKuliahPage extends StatefulWidget {
  const KelasKuliahPage({super.key});

  @override
  State<KelasKuliahPage> createState() => _KelasKuliahPageState();
}

class _KelasKuliahPageState extends State<KelasKuliahPage> {
  final _ruanganService = const RuanganService();
  final _dosenService = const DosenPengajarService();
  final _kelasService = const KelasKuliahService();

  Future<void> _pilihWaktu(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final jam = picked.hour.toString().padLeft(2, '0');
      final menit = picked.minute.toString().padLeft(2, '0');
      controller.text = '$jam:$menit';
    }
  }

  void updateDosenPengampuString(String idKelas) {
    final dps = AppData.daftarDosenPengajar.where((dp) => dp.idKelas == idKelas).toList();
    final idx = AppData.daftarKelas.indexWhere((k) => k.id == idKelas);
    if (idx != -1) {
      if (dps.isEmpty) {
        AppData.daftarKelas[idx].dosenPengampu = 'Belum Ada Dosen';
      } else {
        final names = dps.map((dp) {
          final d = AppData.daftarDosen.firstWhere(
            (d) => d.nidn == dp.nidnDosen,
            orElse: () => Dosen(nidn: '', nama: 'Unknown', kodeProdi: ''),
          );
          return d.nama;
        }).toList();
        AppData.daftarKelas[idx].dosenPengampu = names.join(', ');
      }
    }
  }

  void tambah() {
    String kodeProdi = AppData.currentAdminProdiKode;
    String? mk;
    Ruangan? selectedRuangan;
    String? hari = 'Senin';
    final nama = TextEditingController();
    final kapasitas = TextEditingController();
    final jamMulai = TextEditingController();
    final jamSelesai = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Buka Kelas Kuliah Baru',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            final mataKuliahProdi = AppData.daftarMataKuliah
                .where((m) => m.kodeProdi == kodeProdi)
                .toList();

            final ruanganList = AppData.daftarRuangan;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (AppData.currentAdminProdiKode.isEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: kodeProdi.isEmpty ? null : kodeProdi,
                      decoration: const InputDecoration(labelText: 'Pilih Program Studi'),
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
                        });
                      },
                    ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: mk,
                    decoration: const InputDecoration(labelText: 'Pilih Mata Kuliah'),
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: nama,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kelas',
                      hintText: 'Misal: A, B, atau C',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Ruangan>(
                    value: selectedRuangan,
                    decoration: const InputDecoration(labelText: 'Pilih Ruangan'),
                    items: ruanganList.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text('${r.namaRuangan} (Kapasitas: ${r.kapasitasRuangan})'),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setDialogState(() {
                        selectedRuangan = v;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: hari,
                    decoration: const InputDecoration(labelText: 'Pilih Hari'),
                    items: const [
                      DropdownMenuItem(value: 'Senin', child: Text('Senin')),
                      DropdownMenuItem(value: 'Selasa', child: Text('Selasa')),
                      DropdownMenuItem(value: 'Rabu', child: Text('Rabu')),
                      DropdownMenuItem(value: 'Kamis', child: Text('Kamis')),
                      DropdownMenuItem(value: 'Jumat', child: Text('Jumat')),
                      DropdownMenuItem(value: 'Sabtu', child: Text('Sabtu')),
                    ],
                    onChanged: (v) {
                      setDialogState(() {
                        hari = v;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: jamMulai,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Jam Mulai',
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          onTap: () => _pilihWaktu(context, jamMulai),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: jamSelesai,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Jam Selesai',
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          onTap: () => _pilihWaktu(context, jamSelesai),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: kapasitas,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kapasitas Kelas',
                      hintText: 'Misal: 30',
                    ),
                  ),
                ],
              ),
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
                  nama.text.isEmpty ||
                  selectedRuangan == null ||
                  hari == null ||
                  jamMulai.text.isEmpty ||
                  jamSelesai.text.isEmpty ||
                  kapasitas.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua data wajib diisi')),
                );
                return;
              }

              final capValue = int.tryParse(kapasitas.text);
              if (capValue == null || capValue <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kapasitas harus berupa angka positif')),
                );
                return;
              }

              // 1. Check if class capacity exceeds room capacity
              if (capValue > selectedRuangan!.kapasitasRuangan) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Kapasitas kelas ($capValue) melebihi kapasitas ruangan ${selectedRuangan!.namaRuangan} (${selectedRuangan!.kapasitasRuangan})',
                    ),
                  ),
                );
                return;
              }

              // 2. Validate time order
              if (jamMulai.text.compareTo(jamSelesai.text) >= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Jam mulai harus lebih awal dari jam selesai')),
                );
                return;
              }

              // 3. Check for room schedule conflict
              final bentrokRuangan = _ruanganService.isBentrokRuangan(
                selectedRuangan!.kodeRuangan,
                hari!,
                jamMulai.text,
                jamSelesai.text,
              );

              if (bentrokRuangan) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Jadwal ruangan ${selectedRuangan!.namaRuangan} bentrok dengan kelas lain pada $hari, ${jamMulai.text} - ${jamSelesai.text}',
                    ),
                  ),
                );
                return;
              }

              setState(() {
                final newKelas = KelasKuliah(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  kodeSemester: AppData.semesterAktif,
                  kodeProdi: kodeProdi,
                  kodeMataKuliah: mk!,
                  namaKelas: nama.text.toUpperCase(),
                  dosenPengampu: 'Belum Ada Dosen',
                  kapasitas: capValue,
                  jumlahPeserta: 0,
                  jadwal: '$hari, ${jamMulai.text} - ${jamSelesai.text}',
                  hari: hari!,
                  jamMulai: jamMulai.text,
                  jamSelesai: jamSelesai.text,
                  ruangan: selectedRuangan!.namaRuangan,
                  kodeRuangan: selectedRuangan!.kodeRuangan,
                );
                
                final error = _kelasService.tambahKelas(newKelas);
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kelas kuliah berhasil dibuat')));
                  Navigator.pop(context);
                }
              });
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void kelolaDosen(KelasKuliah kelas) {
    String? selectedDosenNidn;
    String selectedPeran = 'Dosen Utama';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final currentDosenList = AppData.daftarDosenPengajar
              .where((dp) => dp.idKelas == kelas.id)
              .toList();

          final availableDosen = AppData.daftarDosen
              .where((d) => d.kodeProdi == kelas.kodeProdi)
              .toList();

          final mk = AppData.daftarMataKuliah.firstWhere(
            (m) => m.kodeMataKuliah == kelas.kodeMataKuliah,
            orElse: () => MataKuliah(kodeMataKuliah: '', namaMataKuliah: 'Unknown', jumlahSks: 0, kodeProdi: ''),
          );

          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              'Kelola Pengajar: ${mk.namaMataKuliah} (${kelas.namaKelas})',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16),
            ),
            content: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dosen Pengajar Saat Ini:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  if (currentDosenList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Belum ada dosen pengajar.',
                        style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: currentDosenList.length,
                        itemBuilder: (context, idx) {
                          final dp = currentDosenList[idx];
                          final dosen = AppData.daftarDosen.firstWhere(
                            (d) => d.nidn == dp.nidnDosen,
                            orElse: () => Dosen(nidn: '', nama: 'Unknown', kodeProdi: ''),
                          );
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(dosen.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('NIDN: ${dosen.nidn} | Peran: ${dp.peranMengajar}', style: const TextStyle(fontSize: 11)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () {
                                setDlgState(() {
                                  AppData.daftarDosenPengajar.removeWhere((item) => item.id == dp.id);
                                  updateDosenPengampuString(kelas.id);
                                });
                                setState(() {}); // refresh outer list
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const Divider(height: 24),
                  const Text(
                    'Tambah Dosen Pengajar:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedDosenNidn,
                    hint: const Text('Pilih Dosen'),
                    items: availableDosen.map((d) {
                      return DropdownMenuItem(
                        value: d.nidn,
                        child: Text(d.nama),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDlgState(() {
                        selectedDosenNidn = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedPeran,
                    hint: const Text('Pilih Peran'),
                    items: const [
                      DropdownMenuItem(value: 'Dosen Utama', child: Text('Dosen Utama')),
                      DropdownMenuItem(value: 'Pendamping', child: Text('Dosen Pendamping')),
                      DropdownMenuItem(value: 'Praktikum', child: Text('Dosen Praktikum')),
                    ],
                    onChanged: (val) {
                      setDlgState(() {
                        selectedPeran = val ?? 'Dosen Utama';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah Pengajar'),
                      onPressed: () {
                        if (selectedDosenNidn == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Silakan pilih dosen')),
                          );
                          return;
                        }

                        // 1. Check if already teaching this class
                        final sudahAda = AppData.daftarDosenPengajar.any(
                          (dp) => dp.idKelas == kelas.id && dp.nidnDosen == selectedDosenNidn,
                        );
                        if (sudahAda) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dosen sudah mengajar kelas ini')),
                          );
                          return;
                        }

                        // 2. Check schedule conflict
                        final bentrok = _dosenService.isBentrokDosenJadwal(
                          selectedDosenNidn!,
                          kelas.hari,
                          kelas.jamMulai,
                          kelas.jamSelesai,
                          excludeKelasId: kelas.id,
                        );
                        if (bentrok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Jadwal dosen bentrok dengan kelas lain yang diajarnya')),
                          );
                          return;
                        }

                        // Add to list
                        setDlgState(() {
                          AppData.daftarDosenPengajar.add(
                            DosenPengajar(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              idKelas: kelas.id,
                              nidnDosen: selectedDosenNidn!,
                              peranMengajar: selectedPeran,
                            ),
                          );
                          updateDosenPengampuString(kelas.id);
                        });

                        setState(() {}); // refresh outer list
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Dosen pengajar berhasil ditambahkan')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      ),
    );
  }

  void hapusKelas(String idKelas) {
    final error = _kelasService.hapusKelas(idKelas);
    
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = AppData.currentAdminProdiKode.isEmpty
        ? AppData.daftarKelas
        : AppData.daftarKelas
            .where((k) => k.kodeProdi == AppData.currentAdminProdiKode)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: data.isEmpty
          ? const Center(
              child: Text(
                'Belum ada kelas kuliah',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (_, i) {
                final k = data[i];

                final mk = AppData.daftarMataKuliah.firstWhere(
                  (m) => m.kodeMataKuliah == k.kodeMataKuliah,
                  orElse: () => MataKuliah(kodeMataKuliah: '', namaMataKuliah: 'Unknown', jumlahSks: 0, kodeProdi: ''),
                );

                final dps = AppData.daftarDosenPengajar.where((dp) => dp.idKelas == k.id).toList();
                final dosenNames = dps.isEmpty
                    ? 'Belum Ada Dosen'
                    : dps.map((dp) {
                        final d = AppData.daftarDosen.firstWhere(
                          (d) => d.nidn == dp.nidnDosen,
                          orElse: () => Dosen(nidn: '', nama: 'Unknown', kodeProdi: ''),
                        );
                        return '${d.nama} (${dp.peranMengajar})';
                      }).join(', ');

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: CyberPanel(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${mk.namaMataKuliah} - Kelas ${k.namaKelas}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${mk.jumlahSks} SKS',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 15, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              '${k.hari}, ${k.jamMulai} - ${k.jamSelesai}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.meeting_room_rounded, size: 15, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              k.ruangan,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.people_alt_rounded, size: 15, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'Kapasitas: ${AppData.hitungPesertaKelas(k.id)}/${k.kapasitas}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Dosen: $dosenNames',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => kelolaDosen(k),
                              icon: const Icon(Icons.people, size: 16),
                              label: const Text('Kelola Dosen'),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                              onPressed: () => hapusKelas(k.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: tambah,
        icon: const Icon(Icons.add),
        label: const Text('+ Tambah'),
      ),
    );
  }
}

