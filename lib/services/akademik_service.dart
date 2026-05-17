import '../data/app_data.dart';
import '../models/kelas_kuliah.dart';
import '../models/mahasiswa.dart';
import '../models/mata_kuliah.dart';
import '../models/nilai.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class AkademikService {
  const AkademikService();

  List<Mahasiswa> pesertaKelas(String idKelas) {
    final nims = AppData.daftarNilai
        .where((n) => n.idKelasKuliah == idKelas)
        .map((n) => n.nim)
        .toSet();
    return AppData.daftarMahasiswa.where((m) => nims.contains(m.nim)).toList();
  }

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

  Nilai? nilaiKrsMahasiswaAktif(String idKelas) {
    try {
      return AppData.daftarNilai.firstWhere(
        (nilai) =>
            nilai.nim == AppData.currentNim && nilai.idKelasKuliah == idKelas,
      );
    } catch (_) {
      return null;
    }
  }

  bool ambilDraft(String idKelas) {
    if (sudahAmbilKelas(idKelas)) return false;

    final kelas = AppData.daftarKelas.firstWhere((k) => k.id == idKelas);
    if (kelasPenuh(kelas)) return false;

    final mataKuliah = mataKuliahByKode(kelas.kodeMataKuliah);
    AppData.daftarNilai.add(
      Nilai(
        nim: AppData.currentNim,
        idKelasKuliah: kelas.id,
        kodeMataKuliah: mataKuliah.kodeMataKuliah,
        namaMataKuliah: mataKuliah.namaMataKuliah,
        sksMataKuliah: mataKuliah.jumlahSks,
        statusKrs: 'draft',
      ),
    );
    return true;
  }

  void batalDraft(String idKelas) {
    AppData.daftarNilai.removeWhere(
      (n) => n.nim == AppData.currentNim && n.idKelasKuliah == idKelas && n.statusKrs == 'draft',
    );
  }

  Nilai? riwayatMataKuliah(String kodeMataKuliah) {
    try {
      return AppData.daftarNilai.firstWhere(
        (nilai) => nilai.nim == AppData.currentNim && nilai.kodeMataKuliah == kodeMataKuliah,
      );
    } catch (_) {
      return null;
    }
  }

  void kirimKrs() {
    final draftNilai = AppData.daftarNilai.where(
      (nilai) => nilai.nim == AppData.currentNim && nilai.statusKrs == 'draft',
    );
    for (var nilai in draftNilai) {
      nilai.statusKrs = 'pending';
    }

    if (draftNilai.isNotEmpty) {
      final mahasiswa = mahasiswaAktif();
      final dosenNidn = mahasiswa.dosenPembimbingNidn;
      if (dosenNidn != null) {
        NotificationService.addNotification(
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Permintaan Validasi KRS',
            message: 'Mahasiswa ${mahasiswa.namaLengkap} (${mahasiswa.nim}) meminta validasi KRS.',
            timestamp: DateTime.now(),
            type: NotificationType.validation,
            actionRoute: '/validasi_krs',
            targetRole: 'dosen',
            targetId: dosenNidn,
          ),
        );
      }
    }
  }

  List<Mahasiswa> mahasiswaBimbinganDosenAktif() {
    return AppData.daftarMahasiswa
        .where((m) => m.dosenPembimbingNidn == AppData.currentDosenNidn)
        .toList();
  }

  List<Nilai> krsDraftMahasiswaAktif() {
    return AppData.daftarNilai
        .where((n) => n.nim == AppData.currentNim && n.statusKrs == 'draft')
        .toList();
  }

  List<Nilai> krsPendingMahasiswaAktif() {
    return AppData.daftarNilai
        .where((n) => n.nim == AppData.currentNim && n.statusKrs == 'pending')
        .toList();
  }

  List<Nilai> krsValidMahasiswaAktif() {
    return AppData.daftarNilai
        .where((n) => n.nim == AppData.currentNim && n.statusKrs == 'valid')
        .toList();
  }

  String namaPembimbingMahasiswaAktif() {
    final nidn = mahasiswaAktif().dosenPembimbingNidn;
    if (nidn == null) return '';
    try {
      final dosen = AppData.daftarDosen.firstWhere((d) => d.nidn == nidn);
      return dosen.nama;
    } catch (_) {
      return '';
    }
  }

  List<Nilai> pengajuanKrsDosenAktif() {
    final bimbinganNim = mahasiswaBimbinganDosenAktif().map((m) => m.nim).toSet();
    return AppData.daftarNilai
        .where((n) => bimbinganNim.contains(n.nim) && n.statusKrs == 'pending')
        .toList();
  }

  void tolakKrs(Nilai nilai) {
    nilai.statusKrs = 'draft';
  }

  void validasiKrs(Nilai nilai) {
    nilai.statusKrs = 'valid';
  }

  String nilaiHuruf(double nilai) {
    if (nilai >= 85) return 'A';
    if (nilai >= 75) return 'B';
    if (nilai >= 65) return 'C';
    if (nilai >= 50) return 'D';
    return 'E';
  }
}
