# TWUT Music Player

TWUT adalah aplikasi pemutar musik lintas platform (*cross-platform*) yang dibangun dengan **Flutter**. Aplikasi ini dirancang untuk memberikan pengalaman mendengarkan musik yang mulus, baik dari koleksi file audio lokal di perangkat Anda maupun streaming langsung dari YouTube.

## 🚀 Fitur Utama

- **Pemutar Audio Lokal:** Memindai dan memutar file musik yang tersimpan di penyimpanan perangkat Anda dengan antarmuka yang intuitif.
- **Integrasi YouTube:** Streaming musik favorit Anda langsung dari YouTube di dalam aplikasi.
- **Manajemen Daftar Putar (*Playlist*):** Membuat, mengelola, dan menyusun lagu-lagu favorit ke dalam daftar putar kustom.
- **Lintas Platform:** Dukungan penuh untuk **Android**, **Windows**, dan **Linux**.
- **Penyimpanan Persisten:** Menggunakan *database* **Drift (SQLite)** untuk pengelolaan daftar putar yang tangguh dan **SharedPreferences** untuk pengaturan preferensi pengguna.

---

## 🛠 Teknologi yang Digunakan

- **Framework:** [Flutter](https://flutter.dev/)
- **Pemutar Audio:** `audioplayers`, `audio_metadata_reader`
- **Streaming:** `youtube_player_iframe`
- **Database:** `drift`, `drift_flutter`
- **Manajemen Izin:** `permission_handler`
- **Utilitas:** `path_provider`, `http`, `uuid`

---

## ⚙️ Persyaratan Sistem (*Prerequisites*)

Sebelum memulai, pastikan Anda telah menginstal alat-alat berikut:

1. **Flutter SDK:** Versi stabil terbaru.
2. **Platform Build Tools:**
   - **Android:** Android Studio dengan Android SDK terbaru.
   - **Windows:** Visual Studio dengan *workload* "Desktop development with C++" diinstal.
   - **Linux:** Paket pengembangan: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`.

---

## 📦 Panduan Instalasi & Pengaturan

1. **Kloning Repositori:**
   ```bash
   git clone <url-repositori-anda>
   cd TWUT
   ```

2. **Instal Dependensi:**
   ```bash
   flutter pub get
   ```

3. **Generate File Database (Penting):**
   Aplikasi ini menggunakan `build_runner` untuk menghasilkan kode database. Jalankan perintah ini setiap kali Anda mengubah skema database:
   ```bash
   dart run build_runner build
   # Jika ada konflik, gunakan perintah berikut:
   dart run build_runner build --delete-conflicting-outputs
   ```

---

## 📖 Cara Penggunaan Aplikasi

Berikut adalah panduan dasar untuk menggunakan fitur-fitur TWUT:

### 1. Izin Akses (PENTING)
Saat aplikasi pertama kali dibuka (terutama di Android), Anda **wajib** memberikan izin akses ke penyimpanan perangkat untuk memindai file musik. Jika Anda menolaknya, fitur pemutar lokal tidak akan berfungsi.

### 2. Memindai Musik Lokal
- Buka aplikasi.
- Navigasikan ke halaman **Local Music**.
- Aplikasi akan memindai penyimpanan Anda secara otomatis. Jika tidak, cari tombol "Scan" atau "Refresh" untuk menyegarkan daftar lagu.

### 3. Streaming YouTube
- Buka tab atau menu **YouTube**.
- Gunakan fitur pencarian untuk menemukan lagu atau video musik.
- Klik pada hasil pencarian untuk memulai pemutaran langsung.

### 4. Mengelola Playlist
- **Menambah Lagu:** Klik ikon menu (titik tiga) di sebelah lagu, lalu pilih **"Add to Playlist"**.
- **Membuat Playlist Baru:** Anda dapat membuat playlist baru melalui dialog "Add to Playlist" tersebut.
- **Melihat Playlist:** Navigasikan ke tab **Playlist** untuk melihat semua daftar putar yang telah Anda buat.

---

## 🏗 Build & Kompilasi

### Android
```bash
# Menjalankan di emulator/perangkat
flutter run -d android

# Membangun file APK rilis
flutter build apk --release
```

### Windows
```bash
# Menjalankan di desktop
flutter run -d windows

# Membangun file executable (.exe) rilis
flutter build windows --release
```

### Linux
```bash
# Menjalankan di desktop
flutter run -d linux

# Membangun file executable rilis
flutter build linux --release
```

---

## 📁 Lokasi Penyimpanan Data
Aplikasi menyimpan data secara otomatis di folder aplikasi perangkat Anda:

- **Database (Playlist & Data Lagu):** Dikelola oleh `drift_flutter`, biasanya disimpan di direktori data aplikasi standar sistem (berbasis SQLite).
- **Cache Musik/Data Konfigurasi:** Disimpan di direktori dokumen aplikasi dengan struktur:
  `[Folder Dokumen Aplikasi]/Twut/music_cache.json`

---

### Konfigurasi Android (`AndroidManifest.xml`)
Pastikan izin berikut sudah terpasang di `android/app/src/main/AndroidManifest.xml` agar fitur berjalan normal:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### Masalah Umum (*Troubleshooting*)

- **Izin Tidak Terdeteksi:** Jika aplikasi tidak bisa membaca musik, pastikan Anda telah mengaktifkan izin secara manual di *Pengaturan Aplikasi* pada ponsel Android Anda.
- **Gagal Build (Windows):** Pastikan Visual Studio diinstal dengan komponen pengembangan C++ (Desktop development with C++).
- **Gagal Build (Linux):** Pastikan *library* pengembangan GTK3 sudah terinstal (`sudo apt install libgtk-3-dev`).
- **Database Bermasalah:** Jika Anda mengubah file `database.dart`, **selalu** jalankan kembali perintah `dart run build_runner build --delete-conflicting-outputs`.
