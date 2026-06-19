import '../data/app_data.dart';
import '../models/ruangan.dart';
import '../models/kelas_kuliah.dart';

class RuanganService {
  const RuanganService();

  List<Ruangan> semuaRuangan() => AppData.daftarRuangan;

  Ruangan? ruanganByKode(String kode) {
    try {
      return AppData.daftarRuangan.firstWhere((r) => r.kodeRuangan == kode);
    } catch (_) {
      return null;
    }
  }

  bool kodeRuanganSudahAda(String kode, {String? excludeKode}) {
    return AppData.daftarRuangan.any(
      (r) => r.kodeRuangan == kode && r.kodeRuangan != excludeKode,
    );
  }

  String? tambahRuangan(Ruangan ruangan) {
    if (kodeRuanganSudahAda(ruangan.kodeRuangan)) {
      return 'Kode ruangan sudah digunakan';
    }
    AppData.daftarRuangan.add(ruangan);
    AppData.saveRuangan(ruangan);
    return null;
  }

  void updateRuangan(String kodeRuanganLama, Ruangan ruanganBaru) {
    final index = AppData.daftarRuangan.indexWhere(
      (r) => r.kodeRuangan == kodeRuanganLama,
    );
    if (index != -1) {
      AppData.daftarRuangan[index] = ruanganBaru;
      AppData.updateRuangan(kodeRuanganLama, ruanganBaru);
    }
  }

  String? hapusRuangan(String kodeRuangan) {
    final sedangDigunakan = AppData.daftarKelas.any(
      (k) => k.kodeRuangan == kodeRuangan,
    );
    if (sedangDigunakan) {
      return 'Ruangan sedang digunakan oleh kelas kuliah';
    }
    AppData.daftarRuangan.removeWhere((r) => r.kodeRuangan == kodeRuangan);
    AppData.deleteRuangan(kodeRuangan);
    return null;
  }

  /// Cek bentrok jadwal ruangan
  bool isBentrokRuangan(
    String kodeRuangan,
    String hari,
    String jamMulai,
    String jamSelesai, {
    String? excludeKelasId,
  }) {
    return AppData.daftarKelas.any(
      (k) =>
          k.kodeRuangan == kodeRuangan &&
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

  /// Daftar kelas yang menggunakan ruangan tertentu
  List<KelasKuliah> kelasPerRuangan(String kodeRuangan) {
    return AppData.daftarKelas
        .where((k) => k.kodeRuangan == kodeRuangan)
        .toList();
  }
}
