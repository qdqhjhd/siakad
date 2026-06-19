import '../data/app_data.dart';
import '../models/dosen_pengajar.dart';
import '../models/dosen.dart';
import '../models/kelas_kuliah.dart';

class DosenPengajarService {
  const DosenPengajarService();

  List<DosenPengajar> semuaDosenPengajar() => AppData.daftarDosenPengajar;

  List<DosenPengajar> dosenPengajarByKelas(String idKelas) {
    return AppData.daftarDosenPengajar
        .where((dp) => dp.idKelas == idKelas)
        .toList();
  }

  List<DosenPengajar> kelasByDosen(String nidn) {
    return AppData.daftarDosenPengajar
        .where((dp) => dp.nidnDosen == nidn)
        .toList();
  }

  Dosen? dosenByNidn(String nidn) {
    try {
      return AppData.daftarDosen.firstWhere((d) => d.nidn == nidn);
    } catch (_) {
      return null;
    }
  }

  String namaDosenByNidn(String nidn) {
    return dosenByNidn(nidn)?.nama ?? 'Unknown';
  }

  /// Daftar kelas yang diajar oleh dosen tertentu
  List<KelasKuliah> kelasDosenPengajar(String nidn) {
    final idKelasList = kelasByDosen(nidn).map((dp) => dp.idKelas).toSet();
    return AppData.daftarKelas
        .where((k) => idKelasList.contains(k.id))
        .toList();
  }

  String? tambahDosenPengajar(DosenPengajar dp) {
    final sudahAda = AppData.daftarDosenPengajar.any(
      (d) => d.idKelas == dp.idKelas && d.nidnDosen == dp.nidnDosen,
    );
    if (sudahAda) return 'Dosen sudah terdaftar di kelas ini';
    AppData.daftarDosenPengajar.add(dp);
    AppData.saveDosenPengajar(dp);
    return null;
  }

  void hapusDosenPengajar(String id) {
    AppData.daftarDosenPengajar.removeWhere((dp) => dp.id == id);
    AppData.deleteDosenPengajar(id);
  }

  /// Cek bentrok jadwal dosen
  bool isBentrokDosenJadwal(
    String nidn,
    String hari,
    String jamMulai,
    String jamSelesai, {
    String? excludeKelasId,
  }) {
    final kelasIds = kelasByDosen(nidn).map((dp) => dp.idKelas).toSet();
    return AppData.daftarKelas.any(
      (k) =>
          kelasIds.contains(k.id) &&
          k.hari == hari &&
          k.id != excludeKelasId &&
          _isWaktuBentrok(k.jamMulai, k.jamSelesai, jamMulai, jamSelesai),
    );
  }

  bool _isWaktuBentrok(
    String mulai1,
    String selesai1,
    String mulai2,
    String selesai2,
  ) {
    return mulai1.compareTo(selesai2) < 0 && mulai2.compareTo(selesai1) < 0;
  }

  /// Nama dosen utama untuk sebuah kelas
  String dosenUtamaKelas(String idKelas) {
    try {
      final dp = AppData.daftarDosenPengajar.firstWhere(
        (d) => d.idKelas == idKelas && d.peranMengajar == 'Dosen Utama',
      );
      return namaDosenByNidn(dp.nidnDosen);
    } catch (_) {
      // fallback to kelas.dosenPengampu
      try {
        return AppData.daftarKelas
            .firstWhere((k) => k.id == idKelas)
            .dosenPengampu;
      } catch (_) {
        return '-';
      }
    }
  }
}
