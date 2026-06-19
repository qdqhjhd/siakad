import '../data/app_data.dart';
import '../models/kelas_kuliah.dart';

class KelasKuliahService {
  const KelasKuliahService();

  List<KelasKuliah> semuaKelas() => AppData.daftarKelas;

  KelasKuliah? kelasById(String id) {
    try {
      return AppData.daftarKelas.firstWhere((k) => k.id == id);
    } catch (_) {
      return null;
    }
  }

  bool idKelasSudahAda(String id, {String? excludeId}) {
    return AppData.daftarKelas.any((k) => k.id == id && k.id != excludeId);
  }

  String? tambahKelas(KelasKuliah kelas) {
    if (idKelasSudahAda(kelas.id)) {
      return 'ID Kelas sudah ada';
    }
    AppData.daftarKelas.add(kelas);
    AppData.saveKelas(kelas);
    return null;
  }

  void updateKelas(String oldId, KelasKuliah kelasBaru) {
    final index = AppData.daftarKelas.indexWhere((k) => k.id == oldId);
    if (index != -1) {
      AppData.daftarKelas[index] = kelasBaru;

      // We don't have updateKelas in AppData, we can delete and re-insert
      // or implement updateKelas in AppData. Let's implement delete and re-insert for now
      // if update is not available, or just call AppData.updateKelas assuming we will add it.
      // Wait, let's just implement updateKelas in AppData later, we'll use it here.
      AppData.updateKelas(oldId, kelasBaru);
    }
  }

  String? hapusKelas(String idKelas) {
    final sudahAdaPeserta = AppData.daftarNilai.any(
      (n) => n.idKelasKuliah == idKelas,
    );
    if (sudahAdaPeserta) {
      return 'Kelas tidak bisa dihapus karena sudah ada mahasiswa yang mendaftar';
    }
    AppData.daftarKelas.removeWhere((kelas) => kelas.id == idKelas);
    AppData.deleteKelas(idKelas);

    // Hapus juga dosen pengajar terkait
    AppData.daftarDosenPengajar.removeWhere((dp) => dp.idKelas == idKelas);
    AppData.deleteDosenPengajarByKelas(idKelas);
    return null;
  }
}
