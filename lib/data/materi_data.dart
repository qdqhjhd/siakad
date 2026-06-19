import '../models/materi_kuliah.dart';

/// Store global untuk rencana materi (silabus) dan materi yang diunggah dosen.
/// Key = id kelas kuliah (e.g. 'IF-01')
class MateriData {
  // ─── Silabus rencana materi per kelas (16 minggu) ───────────────────────────
  // Data akan diisi dari PostgreSQL via AppData.loadFromDatabase()
  static Map<String, List<RencanaMateri>> rencanaPerKelas = {};

  // ─── Materi yang diunggah dosen ──────────────────────────────────────────────
  // Data akan diisi dari PostgreSQL via AppData.loadFromDatabase()
  static List<MateriKuliah> daftarMateri = [];

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  static List<MateriKuliah> materiUntukKelas(String idKelas) =>
      daftarMateri.where((m) => m.idKelasKuliah == idKelas).toList()
        ..sort((a, b) => a.minggu.compareTo(b.minggu));

  static MateriKuliah? materiPadaMinggu(String idKelas, int minggu) {
    try {
      return daftarMateri.firstWhere(
        (m) => m.idKelasKuliah == idKelas && m.minggu == minggu,
      );
    } catch (_) {
      return null;
    }
  }

  static void tambahMateri(MateriKuliah materi) {
    daftarMateri.removeWhere(
      (m) => m.idKelasKuliah == materi.idKelasKuliah && m.minggu == materi.minggu,
    );
    daftarMateri.add(materi);
  }

  static List<RencanaMateri> rencanaPadaKelas(String idKelas) =>
      rencanaPerKelas[idKelas] ?? _silabusDefault();

  // ─── Silabus default (fallback jika belum ada data dari DB) ──────────────────
  static List<RencanaMateri> _silabusDefault() => List.generate(16, (i) => RencanaMateri(
        minggu: i + 1, judulBab: 'Bab ${i + 1}: Materi Minggu ${i + 1}', subBab: 'Sub bab belum tersedia'));
}
