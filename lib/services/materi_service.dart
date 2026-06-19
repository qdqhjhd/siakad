import '../data/app_data.dart';
import '../data/materi_data.dart';
import '../models/materi_kuliah.dart';

class MateriService {
  const MateriService();

  List<RencanaMateri> rencanaPadaKelas(String idKelas) {
    final list = MateriData.rencanaPadaKelas(idKelas);
    // Ensure all items have idKelasKuliah set
    for (var item in list) {
      item.idKelasKuliah ??= idKelas;
    }
    return list;
  }

  List<MateriKuliah> materiPadaMinggu(String idKelas, int minggu) {
    return MateriData.daftarMateri
        .where((m) => m.idKelasKuliah == idKelas && m.minggu == minggu)
        .toList();
  }

  Future<String?> tambahMateri(MateriKuliah materi) async {
    try {
      MateriData.tambahMateri(materi); // Updates local list
      await AppData.saveMateriKuliah(materi); // Save to DB
      for (var file in materi.files) {
        file.idMateri = materi.id;
        await AppData.saveMateriFile(file);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> hapusMateri(MateriKuliah materi) async {
    try {
      MateriData.daftarMateri.removeWhere((m) => m.id == materi.id); // Updates local list
      await AppData.deleteMateriKuliah(materi.id);
      for (var file in materi.files) {
        if (file.id != null) {
          await AppData.deleteMateriFile(file.id!);
        }
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateRencana(RencanaMateri rencana) async {
    try {
      if (rencana.id == null) {
        await tambahRencana(rencana);
      } else {
        await AppData.updateRencanaMateri(rencana);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> tambahRencana(RencanaMateri rencana) async {
    try {
      if (!MateriData.rencanaPerKelas.containsKey(rencana.idKelasKuliah)) {
        MateriData.rencanaPerKelas[rencana.idKelasKuliah!] = [];
      }
      MateriData.rencanaPerKelas[rencana.idKelasKuliah!]!.add(rencana);
      
      await AppData.saveRencanaMateri(rencana);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
