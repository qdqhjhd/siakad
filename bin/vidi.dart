//first try

import 'dart:io';

void main() {

String NIM;
String nama;
String jk;
int angkatan;

  print("Data mahasiswa");
  
  while (true) {
    stdout.write("NIM : ");
    NIM = stdin.readLineSync()!;

    if (RegExp(r'^[0-9]{10}$').hasMatch(NIM)) 
    {
      break;
    } 
    else 
    {
      print("Input salah! NIM harus 10 digit angka.\n");
    }
  }

while(true){
  stdout.write("NAMA :");
  nama = stdin.readLineSync()!;

  if(nama.length>=5&& RegExp(r'^[a-zA-Z ]+$').hasMatch(nama)){
    break;
  }
  if(nama.length<5)
  {
    print("kurang huruf astagaa, minimal 5 huruf plisss");
  }
  else{
    print("nama hanya boleh huruf!");
  }
}
while(true){
  stdout.write("JK (P/L):");
  jk = stdin.readLineSync()!;

  if(jk.toLowerCase()=="p"||jk.toLowerCase()=="l")
  {
    break;
  }
  else{
    print("jenis kelamin hanya ada dua");
  }

  
}
while(true)
  {
  stdout.write("ANGKATAN :");
  angkatan = int.parse(stdin.readLineSync()!);

  if(angkatan>=2018&&angkatan<=2025)
  {
    break;
  }
  if(angkatan<=2018)
  {
    print("harusnya kamu sudah di DO");
    break;
  }
  if(angkatan>=2025)
  {
    print("Dari masa depan kah??");
    break;
  }
  else{
  print("salah Input.");
    }
  }
  print("");
  print("BIODATA ANDA");
  print("");
  print("NIM          : $NIM");
  print("Nama         : $nama");
  print("jenis kelamin: $jk");
  print("ANGKATAN     : $angkatan");
  
}


