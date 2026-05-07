class Semester {
  String kodeSemester;
  String namaSemester;

  Semester({required this.kodeSemester, required this.namaSemester});

  int get tahunAjaran {
    return int.parse(kodeSemester.substring(0, 4));
  }
}
