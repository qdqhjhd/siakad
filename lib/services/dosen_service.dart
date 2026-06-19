import '../data/app_data.dart';
import '../models/dosen.dart';

class DosenService {
  const DosenService();

  List<Dosen> semuaDosen() => AppData.daftarDosen;

  Dosen? dosenByNidn(String nidn) {
    try {
      return AppData.daftarDosen.firstWhere((d) => d.nidn == nidn);
    } catch (_) {
      return null;
    }
  }

  bool nidnSudahAda(String nidn, {String? excludeNidn}) {
    return AppData.daftarDosen.any(
      (d) => d.nidn == nidn && d.nidn != excludeNidn,
    );
  }

  String? tambahDosen(Dosen dosen) {
    if (nidnSudahAda(dosen.nidn)) {
      return 'NIDN dosen sudah terdaftar';
    }
    AppData.daftarDosen.add(dosen);
    AppData.saveDosen(dosen);
    return null;
  }

  void updateDosen(String oldNidn, Dosen dosenBaru) {
    final index = AppData.daftarDosen.indexWhere((d) => d.nidn == oldNidn);
    if (index != -1) {
      AppData.daftarDosen[index] = dosenBaru;
      AppData.updateDosen(oldNidn, dosenBaru);
    }
  }

  String? hapusDosen(String nidn) {
    final sedangMengajar = AppData.daftarDosenPengajar.any(
      (dp) => dp.nidnDosen == nidn,
    );
    if (sedangMengajar) {
      return 'Dosen tidak bisa dihapus karena sedang mengajar kelas';
    }
    AppData.daftarDosen.removeWhere((d) => d.nidn == nidn);
    AppData.deleteDosen(nidn);
    return null;
  }
}
