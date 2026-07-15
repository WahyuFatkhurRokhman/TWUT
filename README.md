# 🎵 TWUT (The Way U Tune) — Cross-Platform Music Player

**TWUT (The Way U Tune)** adalah aplikasi pemutar musik modern, responsif, dan *cross-platform* yang
dikembangkan menggunakan **Flutter**. Aplikasi ini memadukan kemudahan pemutaran file musik lokal (
secara offline) dengan kemampuan streaming lagu dan video dari **YouTube** (secara online) dalam
satu antarmuka gelap (*Dark Theme*) yang elegan dan terintegrasi secara mulus.

---

## ✨ Fitur Utama

### 📁 1. Pemutar & Pemindaian Musik Lokal (Offline)

* **Pindai Cepat Tanpa Lag:** Proses pencarian file audio di penyimpanan lokal berjalan secara
  asinkron di latar belakang menggunakan **Flutter Isolate (Multi-threading)**, sehingga performa
  antarmuka (UI) tetap mulus (60/120 FPS).
* **Ekstraksi Metadata Pintar:** Membaca tag metadata file audio (ID3 Tags seperti judul, nama
  artis, judul album, dan cover art/artwork) menggunakan `audio_metadata_reader`.
* **Pengelompokan Otomatis (Grouping):** Mengkategorikan lagu secara otomatis berdasarkan **Folder
  **, **Album**, dan **Artis** untuk kemudahan navigasi.

### 🌐 2. Integrasi Streaming YouTube (Online)

* **Pencarian Komprehensif:** Cari video, playlist, atau channel YouTube secara instan menggunakan
  API terintegrasi.
* **Pemutaran Mulus:** Memutar video/audio YouTube menggunakan iframe player (
  `youtube_player_iframe`) tanpa memerlukan pemutar eksternal.
* **Keamanan API:** Menggunakan server backend proxy terdedikasi (
  `https://twut-backend.vercel.app/api`) dengan pengamanan API Key serta manajemen ID Perangkat
  unik.

### 🎛️ 3. Kontrol Audio Terpadu (`AudioManager`)

* **Unified State Controller:** Mengontrol pemutaran musik lokal (`audioplayers`) dan YouTube (
  `youtube_player_iframe`) di bawah satu kendali manajer terpusat. Ketika Anda memutar lagu YouTube,
  lagu lokal akan berhenti otomatis, dan sebaliknya.
* **Mode Putar Kreatif:** Mendukung mode pengulangan lagu (`REPEAT_MODE`: OFF, ONE/Loop Tunggal,
  ALL/Loop Semua) dan pengaturan antrean musik (*play queue*).
* **Navigasi Presisi:** Fitur *seeking* durasi waktu, kontrol volume yang dinamis, serta indikator
  status pemutaran (loading, playing, paused).

### 💾 4. Manajemen Playlist & Database Tangguh

* **Database Lokal Kencang:** Menggunakan **Drift** (SQLite wrapper yang reaktif dan *type-safe*
  untuk Flutter) untuk menyimpan data secara permanen dan aman.
* **Sistem Playlist Kustom:** Buat playlist baru, tambahkan/hapus lagu, ganti nama playlist, dan
  hapus playlist (dengan relasi kaskade otomatis).
* **Histori Pemutaran Pintar:** Mencatat riwayat lagu yang baru saja diputar (*recently played*)
  serta melacak lagu yang paling sering diputar (*frequently played*) untuk menyusun rekomendasi
  otomatis di Beranda.

### 🎨 5. Desain Antarmuka Premium (UI/UX)

* **Estetika Modern:** UI berbasis *Dark Theme* yang konsisten dengan warna hijau neon kontras yang
  nyaman di mata.
* **Bento Grid & Sidebar:** Tata letak menu utama menggunakan model *Bento Card* yang dinamis serta
  navigasi *Sidebar* yang efisien.
* **Floating Mini-Player:** Mini-player yang tetap melayang di bawah layar agar Anda tetap bisa
  mengontrol musik saat menjelajahi halaman lain.

---

## 🏗️ Arsitektur Aplikasi

Aplikasi TWUT dirancang dengan memisahkan *logic*, *data*, dan *presentation layer* secara bersih
guna memastikan skalabilitas tinggi:

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│         (Pages, Layouts, Widgets, Providers)           │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│                   AudioManager (Core)                  │
│       (Sinkronisasi Kontrol Lagu Lokal & YouTube)       │
└─────────────┬────────────────────────────┬─────────────┘
              │                            │
              ▼                            ▼
┌───────────────────────────┐┌───────────────────────────┐
│    LocalPlayerManager     ││   YoutubePlayerManager    │
│      (audioplayers)       ││  (youtube_player_iframe)  │
└─────────────┬─────────────┘└─────────────┬─────────────┘
              │                            │
              ▼                            ▼
┌───────────────────────────┐┌───────────────────────────┐
│     Drift DB (SQLite)     ││    YouTube Proxy API      │
│ (Playlist, History, Song) ││ (Search, Playlist, Channel)│
└───────────────────────────┘└───────────────────────────┘
```

---

## 📂 Struktur Direktori Proyek

Berikut adalah peta struktur folder di dalam direktori `lib/`:

```text
lib/
├── main.dart                      # Titik masuk utama aplikasi (entrypoint)
├── config/                        # Konfigurasi visual (AppTheme, AppColors, AppTextStyle)
├── data/                          # Lapisan database lokal (Drift DB & pendefinisian skema Tabel)
│   ├── database.dart              # Inisialisasi Drift SQLite
│   └── table/                     # Tabel Drift (playlists.dart, history.dart)
├── layouts/                       # Layout utama aplikasi (MainLayout dengan sidebar)
├── models/                        # Model data (Song, YtSong, AlbumGroup, dsb.)
│   └── constant/                  # Enum konstanta (REPEAT_MODE, PLAYBACK_SOURCE)
├── pages/                         # Halaman-halaman UI (HomePage, LocalPage, YoutubePage, dsb.)
├── providers/                     # Manajemen State (LocalProvider, NavigationProvider)
├── routes/                        # Pengaturan rute aplikasi (AppRouter & sub-routing)
├── services/                      # Logika bisnis & API (AudioManager, MusicScanner, YoutubeService, dsb.)
├── utils/                         # Utilitas helper (PlatformUtil, SnackbarUtil, TimeUtils)
└── widgets/                       # Komponen UI modular/reusable (MiniPlayer, BentoCard, QueueDrawer)
```

---

## 🛠️ Spesifikasi Teknologi & Paket Utama

Aplikasi ini didukung oleh paket-paket Flutter berkualitas tinggi:

| Kategori        | Paket (Dependencies)                | Deskripsi                                            |
|:----------------|:------------------------------------|:-----------------------------------------------------|
| **Local Audio** | `audioplayers` (v6.6.0)             | Pemutar audio untuk file lokal.                      |
| **Tag Reader**  | `audio_metadata_reader` (v1.4.2)    | Membaca metadata file ID3 (.mp3, .m4a, dll).         |
| **YouTube**     | `youtube_player_iframe` (v6.0.2)    | Pemutar video YouTube inline menggunakan Webview.    |
| **Database**    | `drift` & `drift_flutter` (v2.34.0) | Solusi ORM/database SQLite yang reaktif.             |
| **State**       | `provider` (v6.1.5)                 | Pengelola state aplikasi yang ringan dan efisien.    |
| **Network**     | `http` & `connectivity_plus`        | Komunikasi HTTP dan deteksi status koneksi internet. |

---

## 🚀 Panduan Memulai

Ikuti langkah-langkah di bawah ini untuk menjalankan proyek TWUT di mesin lokal Anda:

### 📋 Prasyarat

* **Flutter SDK** (versi `3.11.4` atau lebih tinggi) terpasang di komputer Anda.
* **Dart SDK** yang kompatibel.
* **Spesifikasi Sistem Minimum:**
    * **Android:** Android 5.0 (API Level 21) atau lebih baru.
    * **Windows:** Windows 10 (version 1809, build 17763) atau lebih baru.
    * **Linux:** Distribusi Linux dengan GTK 3.0 atau lebih baru.
* Emulator Android, perangkat Android fisik, atau OS Desktop yang didukung (Windows / Linux) dengan
  mode pengembang (*developer mode*) aktif.

### ⚙️ Langkah Instalasi

1. **Kloning Repositori:**
   ```bash
   git clone <url-repositori-twut>
   cd TWUT
   ```

2. **Unduh Dependensi:**
   ```bash
   flutter pub get
   ```

3. **Jalankan Code Generation (Drift Database):**
   Gunakan `build_runner` untuk mengompilasi kode database reaktif (`database.g.dart`):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Jalankan Aplikasi:**
    * **Android:**
      ```bash
      flutter run -d android
      ```
    * **Windows:**
      ```bash
      flutter run -d windows
      ```
    * **Linux:**
      ```bash
      flutter run -d linux
      ```

---

## 🧪 Pengujian (Unit & Integration Testing)

Aplikasi TWUT dilengkapi dengan suite pengujian komprehensif untuk menjamin kualitas kode dan
fungsionalitas logika bisnis:

* **Total Tes:** 24 Kasus Pengujian (Semua Lulus/Passed)
* **Utilitas Testing:** `flutter_test`, `mocktail` (untuk mocking service)

### Kategori Pengujian

1. **`api_service_test.dart`**: Memastikan API decoder berhasil menangani response `200 OK`,
   mendeteksi error jaringan, menguji penggunaan ID Perangkat unik secara konsisten, dan memproses
   kode status non-200.
2. **`music_cache_service_test.dart`**: Menguji penulisan, penyimpanan, pembaruan, pembersihan, dan
   pembacaan *cache* lagu lokal agar mempercepat proses muat ulang.
3. **`playlist_service_test.dart`**: Memvalidasi operasi CRUD database untuk playlist (pembuatan,
   penggantian nama, penghapusan, relasi cascade lagu yang terhapus).
4. **`youtube_service_test.dart`**: Memvalidasi fungsionalitas pencarian, parsing payload response,
   detail channel, dan penanganan kegagalan pada API backend proxy YouTube.

### Cara Menjalankan Tes

Untuk mengeksekusi seluruh suite pengujian, jalankan perintah berikut:

```bash
flutter test
```

Laporan pengujian lengkap dapat diakses secara detail pada file [test_result.md](test_result.md) dan
ringkasan kasus di [TEST_SUMMARY.md](TEST_SUMMARY.md).

---

## 👥 Kontribusi

Kontribusi selalu diterima hangat! Jika Anda ingin menyempurnakan fitur TWUT, silakan buat *issue*
terlebih dahulu atau langsung kirimkan *Pull Request* dengan mengikuti standar penulisan kode yang
bersih dan melampirkan pengujian unit yang relevan.

---

## 📄 Lisensi

Proyek ini dibuat untuk kebutuhan pembelajaran dan pengembangan aplikasi lintas platform. Hak cipta
milik pengembang proyek TWUT.

---
*Developed with ❤️ by TWUT Dev Team.*
