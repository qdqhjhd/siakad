import '../data/app_data.dart';
import '../models/kelas_kuliah.dart';
import '../models/mahasiswa.dart';
import '../models/mata_kuliah.dart';
import '../models/nilai.dart';

class AkademikService {
  const AkademikService();

  Mahasiswa mahasiswaAktif() {
    return AppData.daftarMahasiswa.firstWhere(
      (m) => m.nim == AppData.currentNim,
      orElse: () => AppData.daftarMahasiswa.first,
    );
  }

  List<KelasKuliah> kelasUntukMahasiswaAktif() {
    final mahasiswa = mahasiswaAktif();
    return AppData.daftarKelas
        .where((kelas) => kelas.kodeProdi == mahasiswa.kodeProdi)
        .toList();
  }

  MataKuliah mataKuliahByKode(String kode) {
    return AppData.daftarMataKuliah.firstWhere(
      (mk) => mk.kodeMataKuliah == kode,
    );
  }

  List<Nilai> khsMahasiswaAktif() {
    return AppData.daftarNilai
        .where((nilai) => nilai.nim == AppData.currentNim)
        .toList();
  }

  double ipkMahasiswaAktif() => hitungIpk(khsMahasiswaAktif());

  double hitungIpk(List<Nilai> nilaiList) {
    final sudahDinilai = nilaiList.where((nilai) => nilai.nilaiHuruf != null);
    final totalSks = sudahDinilai.fold<int>(
      0,
      (sum, nilai) => sum + nilai.sksMataKuliah,
    );
    if (totalSks == 0) return 0;

    final totalBobot = sudahDinilai.fold<double>(
      0,
      (sum, nilai) =>
          sum + (nilai.sksMataKuliah * bobotNilai(nilai.nilaiHuruf)),
    );
    return totalBobot / totalSks;
  }

  double bobotNilai(String? nilaiHuruf) {
    switch (nilaiHuruf) {
      case 'A':
        return 4;
      case 'B':
        return 3;
      case 'C':
        return 2;
      case 'D':
        return 1;
      default:
        return 0;
    }
  }

  int totalSks(List<Nilai> nilaiList) {
    return nilaiList.fold<int>(0, (sum, nilai) => sum + nilai.sksMataKuliah);
  }

  int jumlahBelumDinilai(List<Nilai> nilaiList) {
    return nilaiList.where((nilai) => nilai.nilaiAngka == null).length;
  }

  double persentaseKehadiranMahasiswa(String nim) {
    final preset = <String, double>{
      '2024010001': 0.92,
      '2024010002': 0.86,
      '2024010003': 0.97,
      '2024010004': 0.78,
      '2024010005': 0.89,
      '2024010006': 0.95,
      '2024010007': 0.81,
      '2024010008': 0.99,
      '2024010009': 0.74,
      '2024010010': 0.91,
    };
    return preset[nim] ?? 0.85;
  }

  List<KelasKuliah> kelasDosenAktif() {
    return AppData.daftarKelas.where((kelas) {
      return kelas.dosenPengampu.trim() == AppData.currentDosenNama.trim() &&
          kelas.kodeProdi == AppData.currentDosenProdi;
    }).toList();
  }

  List<Nilai> nilaiDosenAktif() {
    final idKelas = kelasDosenAktif().map((kelas) => kelas.id).toSet();
    return AppData.daftarNilai
        .where((nilai) => idKelas.contains(nilai.idKelasKuliah))
        .toList();
  }

  int nilaiBelumInputDosenAktif() {
    return nilaiDosenAktif().where((nilai) => nilai.nilaiAngka == null).length;
  }

  double rataRataNilaiDosenAktif() {
    final nilaiAngka = nilaiDosenAktif()
        .where((nilai) => nilai.nilaiAngka != null)
        .map((nilai) => nilai.nilaiAngka!)
        .toList();
    if (nilaiAngka.isEmpty) return 0;
    return nilaiAngka.reduce((a, b) => a + b) / nilaiAngka.length;
  }

  double progresInputNilaiDosenAktif() {
    final semua = nilaiDosenAktif();
    if (semua.isEmpty) return 0;
    final sudah = semua.where((nilai) => nilai.nilaiAngka != null).length;
    return sudah / semua.length;
  }

  bool sudahAmbilKelas(String idKelas) {
    return AppData.daftarNilai.any(
      (nilai) =>
          nilai.nim == AppData.currentNim && nilai.idKelasKuliah == idKelas,
    );
  }

  bool kelasPenuh(KelasKuliah kelas) {
    return AppData.hitungPesertaKelas(kelas.id) >= kelas.kapasitas;
  }

  bool ambilKelas(KelasKuliah kelas) {
    if (sudahAmbilKelas(kelas.id) || kelasPenuh(kelas)) return false;

    final mataKuliah = mataKuliahByKode(kelas.kodeMataKuliah);
    AppData.daftarNilai.add(
      Nilai(
        nim: AppData.currentNim,
        idKelasKuliah: kelas.id,
        kodeMataKuliah: mataKuliah.kodeMataKuliah,
        namaMataKuliah: mataKuliah.namaMataKuliah,
        sksMataKuliah: mataKuliah.jumlahSks,
      ),
    );
    return true;
  }

  String nilaiHuruf(double nilai) {
    if (nilai >= 85) return 'A';
    if (nilai >= 75) return 'B';
    if (nilai >= 65) return 'C';
    if (nilai >= 50) return 'D';
    return 'E';
  }
}
