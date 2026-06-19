import '../data/app_data.dart';
import '../models/mata_kuliah.dart';

class MataKuliahService {
  const MataKuliahService();

  List<MataKuliah> semuaMataKuliah() => AppData.daftarMataKuliah;

  MataKuliah? mataKuliahByKode(String kode) {
    try {
      return AppData.daftarMataKuliah.firstWhere(
        (mk) => mk.kodeMataKuliah == kode,
      );
    } catch (_) {
      return null;
    }
  }

  bool kodeMataKuliahSudahAda(String kode, {String? excludeKode}) {
    return AppData.daftarMataKuliah.any(
      (mk) => mk.kodeMataKuliah == kode && mk.kodeMataKuliah != excludeKode,
    );
  }

  String? tambahMataKuliah(MataKuliah mk) {
    if (kodeMataKuliahSudahAda(mk.kodeMataKuliah)) {
      return 'Kode mata kuliah sudah digunakan';
    }
    AppData.daftarMataKuliah.add(mk);
    AppData.saveMataKuliah(mk);
    return null;
  }

  void updateMataKuliah(String kodeMataKuliahLama, MataKuliah mkBaru) {
    final index = AppData.daftarMataKuliah.indexWhere(
      (mk) => mk.kodeMataKuliah == kodeMataKuliahLama,
    );
    if (index != -1) {
      AppData.daftarMataKuliah[index] = mkBaru;
      AppData.updateMataKuliah(kodeMataKuliahLama, mkBaru);
    }
  }

  String? hapusMataKuliah(String kodeMataKuliah) {
    final sudahAdaKelas = AppData.daftarKelas.any(
      (k) => k.kodeMataKuliah == kodeMataKuliah,
    );
    if (sudahAdaKelas) {
      return 'Mata kuliah tidak bisa dihapus karena sudah dipakai di kelas';
    }
    AppData.daftarMataKuliah.removeWhere(
      (mk) => mk.kodeMataKuliah == kodeMataKuliah,
    );
    AppData.deleteMataKuliah(kodeMataKuliah);
    return null;
  }
}
