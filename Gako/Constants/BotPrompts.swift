//
//  BotPrompts.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//
import SwiftUI

struct BotPrompts {
    static let reflectionPrompt = """
        Saya ingin Anda membantu saya menghasilkan format CSV berdasarkan curhatan harian seorang guru mengenai aktivitas siswa di sekolah. Berikut adalah panduan yang harus Anda ikuti:
        
        1. Bacalah curhatan dengan seksama dan identifikasi semua siswa yang disebutkan dalam curhatan, baik dengan nama lengkap maupun nama panggilan.
        2. Ekstrak semua aktivitas yang tercantum dalam aktivitas hari ini untuk setiap siswa.
        3. Tentukan untuk setiap aktivitas dengan aturan berikut:
           - "mandiri" = true (jika siswa melakukan sendiri)
           - "dibimbing" = false (jika siswa membutuhkan bantuan)
           - "tidak melakukan" = null (jika siswa tidak disebutkan dalam aktivitas tersebut atau eksplisit tidak melakukan)
        4. PENTING: Jika seorang siswa tidak disebutkan dalam suatu aktivitas, HARUS diberikan status null (tidak melakukan).
        5. Jika ada indikasi pengecualian seperti "Semua anak kecuali [nama]", maka:
           - Siswa yang dikecualikan diberi status sesuai konteks
           - Semua siswa lain diberi status sebaliknya
        6. Tambahkan kolom "Curhatan" yang menggambarkan kesan atau komentar guru. 
        7. Format output harus dalam bentuk CSV dengan kolom:
           - Nama Lengkap
           - Nama Panggilan
           - Aktivitas (status kemandirian)
           - Curhatan
        9. Output adalah berupa CSV saja
        
        Contoh Versi 1:
        
        **Contoh Input:**
        Data Kehadiran Murid: FullnameA (NicknameA) - Hadir, FullnameB (NicknameB) - Hadir, FullnameC (NicknameC) - Hadir
        
        Aktivitas Hari Ini: Upacara, Memotong kuku
        
        Curhatan Guru: "Semua anak upacara dengan disiplin, lalu mereka memotong kuku sendiri kecuali NicknameB yang harus digunting kukunya oleh gurunya."
        
        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian),Curhatan
        FullnameA,NicknameA,"Upacara (true)|Memotong kuku (true)","NicknameA menunjukkan kedisiplinan dalam upacara."
        FullnameB,NicknameB,"Upacara (true)|Memotong kuku (false)","NicknameB perlu banyak latih diri agar bisa mandiri."
        FullnameC,NicknameC,"Upacara (true)|Memotong kuku (true)","NicknameC disiplin saat upacara dan bisa melakukannya sendiri."
        ```
        
        Contoh Versi 2:
        
        **Contoh Input:**
        Data Kehadiran Murid: FullnameA (NicknameA) - Hadir, FullnameB (NicknameB) - Hadir, FullnameC (NicknameC) - Hadir
        
        Aktivitas Hari Ini: Upacara
        
        Curhatan Guru: "Semua anak kecuali NicknameB upacara dengan disiplin."
        
        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian),Curhatan
        FullnameA,NicknameA,"Upacara (true)","NicknameA menunjukkan kedisiplinan dalam upacara."
        FullnameB,NicknameB,"Upacara (false)","NicknameB perlu banyak latih diri agar bisa disiplin."
        FullnameC,NicknameC,"Upacara (true)","NicknameC disiplin saat upacara dan bisa melakukannya sendiri."
        ```
        
        Contoh Versi 3:
        
        **Contoh Input:**
        Data Kehadiran Murid: FullnameA (NicknameA) - Hadir, FullnameB (NicknameB) - Hadir, FullnameC (NicknameC) - Hadir
        
        Aktivitas Hari Ini: Upacara, Menyanyi
        
        Curhatan Guru: "NicknameA Upacara dengan baik. Semua anak bernyanyi dengan sangat baik dan merdu"
        
        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian),Curhatan
        FullnameA,NicknameA,"Upacara (true)|Menyanyi (true)","NicknameA menunjukkan kedisiplinan dalam upacara dan menyanyi sangat merdu."
        FullnameB,NicknameB,"Upacara (null)|Menyanyi (true)","NicknameB menyanyi sangat merdu."
        FullnameC,NicknameC,"Upacara (null)|Menyanyi (true)","NicknameC Menyanyi Sangat Merdu."
        ```
        
        Contoh Versi 4:
        
        **Contoh Input:**
        Data Kehadiran Murid: FullnameA (NicknameA) - Hadir, FullnameB (NicknameB) - Hadir, FullnameC (NicknameC) - Hadir
        
        Aktivitas Hari Ini: Upacara, Menyanyi
        
        Curhatan Guru: "NicknameA Upacara dengan baik dan NicknameC bernyanyi dengan butuh bimbingan"
        
        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian),Curhatan
        FullnameA,NicknameA,"Upacara (true)|Menyanyi (null)","NicknameA menunjukkan kedisiplinan dalam upacara."
        FullnameB,NicknameB,"Upacara (null)|Menyanyi (null)","Tidak ada informasi satupun."
        FullnameC,NicknameC,"Upacara (null)|Menyanyi (false)","Tidak ada informasi satupun."
        ```
        
        Contoh Versi 5:
        
        **Contoh Input:**
        Data Kehadiran Murid: FullnameA (NicknameA) - Hadir, FullnameB (NicknameB) - Hadir, FullnameC (NicknameC) - Hadir
        
        Aktivitas Hari Ini: Upacara
        
        Curhatan Guru: "NicknameA Upacara dengan baik"
        
        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian),Curhatan
        FullnameA,NicknameA,"Upacara (true)","NicknameA menunjukkan kedisiplinan dalam upacara."
        FullnameB,NicknameB,"Upacara (null)","Tidak ada informasi satupun."
        FullnameC,NicknameC,"Upacara (null)","Tidak ada informasi satupun."
        ```
        
        Contoh Versi 6:
        
        **Contoh Input:**
        Data Kehadiran Murid: FullnameA (NicknameA) - Hadir, FullnameB (NicknameB) - Hadir, FullnameC (NicknameC) - Hadir
        
        Aktivitas Hari Ini: Upacara, Senam
        
        Curhatan Guru: "woy gw mau curhat huhuhu semua anak kecuali NicknameB upacara dengan sangat hebatttt. Adapun NicknameC tadi senamnya memerlukan bantuan untuk gerakan khusus seperti tepuk tangan dalam senam"
        
        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian),Curhatan
        FullnameA,NicknameA,"Upacara (true)|Senam (null)","NicknameA menunjukkan kedisiplinan dalam upacara, tapi tidak melakukan senam."
        FullnameB,NicknameB,"Upacara (false)|Senam (null)","NicknameB membutuhkan bimbingan dalam upacara."
        FullnameC,NicknameC,"Upacara (true)|Senam (false)","NicknameC Menunjukkan kedisplinan pada saat upacara dan membutuhkan bimbingan dalam senam seperti pada gerakan tepuk tangan dalam senam."
        ```
        
        **Contoh Input:**
        Data Kehadiran Murid: FullnameA (NicknameA) - Hadir, FullnameB (NicknameB) - Hadir, FullnameC (NicknameC) - Hadir
        
        Aktivitas Hari Ini: Bermain balok
        
        Curhatan Guru: "NicknameA bermain balok dengan mandiri"
        
        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian),Curhatan
        FullnameA,NicknameA,"Bermain balok (true)","NicknameA bermain balok dengan mandiri"
        FullnameB,NicknameB,"Bermain balok (null)","Tidak ada informasi aktivitas"
        FullnameC,NicknameC,"Bermain balok (null)","Tidak ada informasi aktivitas"
        ```     
        
        **Contoh Input:**
        Data Kehadiran Murid: FullnameA (NicknameA) - Hadir, FullnameB (NicknameB) - Hadir, FullnameC (NicknameC) - Hadir
        
        Aktivitas Hari Ini: Bermain balok
        
        Curhatan Guru: "Semua anak menggambar dengan sangat hebat"
        
        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian),Curhatan
        FullnameA,NicknameA,"Bermain balok (null)","NicknameA menggambar dengan hebat"
        FullnameB,NicknameB,"Bermain balok (null)","NicknameB menggambar dengan hebat"
        FullnameC,NicknameC,"Bermain balok (null)","NicknameC menggambar dengan hebat"
        ```
        
        PENTING: Gunakan nama lengkap dan nama panggilan siswa yang sebenarnya, JANGAN gunakan placeholder seperti FullnameA atau FullnameB. JANGAN tambahkan aktivitas baru selain yang disebutkan secara eksplisit oleh guru pada 'aktivitas hari ini'. Jika curhatan tidak ada yang spesifik untuk 'aktivitas hari ini' maka curhatan dari guru tersebut tetap di tambahkan ke dalam kolom curhatan tiap anak.
        """
}
