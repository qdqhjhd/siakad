class JadwalKrs {
  final String tahunAkademik;
  final String semester; // 'Ganjil' | 'Genap'
  final String status; // 'Aktif' | 'Tutup'
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;

  JadwalKrs({
    required this.tahunAkademik,
    required this.semester,
    required this.status,
    required this.tanggalMulai,
    required this.tanggalSelesai,
  });

  int get sisaHari {
    final diff = tanggalSelesai.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }
}
