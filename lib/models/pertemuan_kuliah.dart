class PertemuanKuliah {
  final String id;
  final int nomorPertemuan; // 1 - 16
  final DateTime tanggal;
  final String idKelasKuliah;
  String statusSesi; // 'aktif' | 'tutup'
  final String? catatan;

  // Konteks akademik – disimpan saat pertemuan dibuat
  final String tahunAkademik;  // e.g. '2024/2025'
  final String semester;       // 'Ganjil' | 'Genap'
  final String kodeRuangan;    // e.g. 'R103'
  final String namaRuangan;    // e.g. 'Lab Komputer'
  final String jamMulai;       // e.g. '08:00'
  final String jamSelesai;     // e.g. '10:30'
  final String hari;           // e.g. 'Senin'

  PertemuanKuliah({
    required this.id,
    required this.nomorPertemuan,
    required this.tanggal,
    required this.idKelasKuliah,
    required this.statusSesi,
    this.catatan,
    this.tahunAkademik = '2024/2025',
    this.semester = 'Ganjil',
    this.kodeRuangan = '',
    this.namaRuangan = '',
    this.jamMulai = '',
    this.jamSelesai = '',
    this.hari = '',
  });
}
