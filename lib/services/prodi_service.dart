import '../data/app_data.dart';
import '../models/prodi.dart';

class ProdiService {
  const ProdiService();

  List<Prodi> semuaProdi() => AppData.daftarProdi;

  Prodi? prodiByKode(String kode) {
    try {
      return AppData.daftarProdi.firstWhere((p) => p.kodeProdi == kode);
    } catch (_) {
      return null;
    }
  }

  bool kodeProdiSudahAda(String kode, {String? excludeKode}) {
    return AppData.daftarProdi.any(
      (p) => p.kodeProdi == kode && p.kodeProdi != excludeKode,
    );
  }

  String? tambahProdi(Prodi prodi) {
    if (kodeProdiSudahAda(prodi.kodeProdi)) {
      return 'Kode prodi sudah digunakan';
    }
    AppData.daftarProdi.add(prodi);
    AppData.saveProdi(prodi);
    return null;
  }

  void updateProdi(String kodeProdiLama, Prodi prodiBaru) {
    final index = AppData.daftarProdi.indexWhere(
      (p) => p.kodeProdi == kodeProdiLama,
    );
    if (index != -1) {
      AppData.daftarProdi[index] = prodiBaru;
      AppData.updateProdi(kodeProdiLama, prodiBaru);
    }
  }

  String? hapusProdi(String kodeProdi) {
    final sedangDigunakan =
        AppData.daftarMahasiswa.any((m) => m.kodeProdi == kodeProdi) ||
        AppData.daftarDosen.any((d) => d.kodeProdi == kodeProdi) ||
        AppData.daftarMataKuliah.any((mk) => mk.kodeProdi == kodeProdi);
    if (sedangDigunakan) {
      return 'Prodi tidak bisa dihapus karena sedang digunakan';
    }
    AppData.daftarProdi.removeWhere((p) => p.kodeProdi == kodeProdi);
    AppData.deleteProdi(kodeProdi);
    return null;
  }
}
