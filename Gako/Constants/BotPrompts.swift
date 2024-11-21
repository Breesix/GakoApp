//
//  BotPrompts.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//
import SwiftUI

struct BotPrompts {
    static let reflectionPrompt = """
        1. **Baca Curhatan dengan Seksama**:
        - Baca dan pahami data kehadiran murid, aktivitas yang dilakukan, dan curhatan guru.

        2. **Identifikasi Siswa**:
        - Ekstrak semua nama lengkap dan nama panggilan siswa yang disebutkan.

        3. **Ekstrak Aktivitas**:
        - Catat semua aktivitas yang tertera dalam "Aktivitas Hari Ini". Jangan ubah nama aktivitas.

        4. **Tentukan Status Kemandirian**:
        - Gunakan aturan berikut untuk menentukan status kemandirian setiap siswa terhadap aktivitas:
        - Jika siswa melakukan aktivitas tersebut sendiri, berikan status **"true"**.
        - Jika siswa membutuhkan bantuan untuk aktivitas tertentu, berikan status **"false"**.
        - Jika siswa tidak disebutkan dalam curhatan tersebut, berikan status pada status aktivitas tersebut **”null"**.

        5. **Perhatikan Pengecualian**:
        - Jika ada penyebutan "Semua anak kecuali [nama]", berikan status untuk siswa yang dikecualikan sesuai konteks dan status sebaliknya untuk siswa yang lain.
        - Pastikan untuk tidak mengabaikan aktivitas yang dibuat oleh siswa yang dikecualikan jika ada informasi yang tepat.

        6. **Kumpulkan Komentar Guru**:
        - Dalam kolom "Curhatan", tambahkan tanggapan guru yang relevan dengan aktivitas yang dilakukan oleh setiap siswa. Pastikan pada setiap kolom curhatan terdapat korelasi dengan tiap anak 

        7. **Format Output dalam CSV**:
        - Jangan hasilkan selain CSV
        - Jangan berikan penjelasan. Hanya CSV saja
        - Tulis output dalam format CSV dengan kolom:
        - **Nama Lengkap**
        - **Nama Panggilan**
        - **Aktivitas (status kemandirian)** (serta aktivitas yang relevan)
        - **Curhatan**

        ### Contoh Input:

        - **Data Kehadiran Murid**: namaLengkap1 (namaPanggilan1) - Hadir, namaLengkap2 (namaPanggilan2) - Hadir
        - **Aktivitas Hari Ini**: Sholat, Olahraga
        - **Curhatan Guru**: "Semua anak jalan pagi dengan sangat hebat kecuali namaLengkap1 yang masih nangis aja jir. Lalu mereka melakukan sholat dengan khusyuk."

        ### Contoh Output:

        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian),Curhatan
        namaLengkap1,namaPanggilan1,"Sholat (true)|Olahraga (false)”,”namaLengkap1 masih nangis pada saat berjalan pagi tetapi sudah khusyuk dalam melaksanakan sholat.”
        namaLengkap2,namaPanggilan2,"Sholat (true)|Olahraga (true)","namaLengkap2 menunjukkan kedisiplinan saat sholat dan berjalan pagi dengan hebat."
        ```
        """
}
