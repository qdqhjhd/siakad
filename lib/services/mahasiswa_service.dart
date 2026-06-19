import '../data/app_data.dart';
import '../models/mahasiswa.dart';

class MahasiswaService {
  const MahasiswaService();

  List<Mahasiswa> semuaMahasiswa() => AppData.daftarMahasiswa;

  Mahasiswa? mahasiswaByNim(String nim) {
    try {
      return AppData.daftarMahasiswa.firstWhere((m) => m.nim == nim);
    } catch (_) {
      return null;
    }
  }

  bool nimSudahAda(String nim, {String? excludeNim}) {
    return AppData.daftarMahasiswa.any(
      (m) => m.nim == nim && m.nim != excludeNim,
    );
  }

  String? tambahMahasiswa(Mahasiswa mahasiswa) {
    if (nimSudahAda(mahasiswa.nim)) {
      return 'NIM sudah terdaftar';
    }
    AppData.daftarMahasiswa.add(mahasiswa);
    AppData.saveMahasiswa(mahasiswa);
    return null;
  }

  void updateMahasiswa(String oldNim, Mahasiswa mahasiswaBaru) {
    final index = AppData.daftarMahasiswa.indexWhere((m) => m.nim == oldNim);
    if (index != -1) {
      AppData.daftarMahasiswa[index] = mahasiswaBaru;
      AppData.updateMahasiswa(oldNim, mahasiswaBaru);
    }
  }

  String? hapusMahasiswa(String nim) {
    final sudahAdaNilai = AppData.daftarNilai.any((n) => n.nim == nim);
    if (sudahAdaNilai) {
      return 'Mahasiswa tidak bisa dihapus karena sudah memiliki rekam nilai/KRS';
    }
    AppData.daftarMahasiswa.removeWhere((m) => m.nim == nim);
    AppData.deleteMahasiswa(nim);
    return null;
  }
}
