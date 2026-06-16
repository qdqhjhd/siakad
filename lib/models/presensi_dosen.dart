class PresensiDosen {
  final String id;
  final String idPertemuan;
  final String nidn;
  String status; // 'Hadir' | 'Izin' | 'Sakit' | 'Alfa' | 'Belum Presensi'
  final DateTime? waktuPresensi;
  final String? catatan;

  PresensiDosen({
    required this.id,
    required this.idPertemuan,
    required this.nidn,
    required this.status,
    this.waktuPresensi,
    this.catatan,
  });
}
