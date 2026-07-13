# Unit Test — Data Services

Folder ini berisi unit test untuk seluruh service yang berhubungan langsung
dengan data (network call, cache file, dan database lokal):

| File test                      | Menguji                | Teknik mocking                              |
|---------------------------------|-------------------------|----------------------------------------------|
| `api_service_test.dart`         | `ApiService`            | `http.testing.MockClient` + `http.runWithClient` |
| `youtube_service_test.dart`     | `YoutubeService`        | `http.testing.MockClient` + `http.runWithClient` |
| `music_cache_service_test.dart` | `MusicCacheService`     | Fake `PathProviderPlatform` → folder temp     |
| `playlist_service_test.dart`    | `PlaylistService`       | Drift `NativeDatabase.memory()` (in-memory DB) |

`MusicService` tidak diuji sebagai unit test murni karena logikanya
didominasi oleh `Isolate`/stream scanning (butuh integration test
tersendiri), namun ia sudah bergantung pada `MusicCacheService` yang
diuji langsung di atas.

## Perubahan pendukung di source code

1. **`lib/data/database.dart`** — ditambahkan constructor
   `AppDatabase.forTesting(QueryExecutor executor)` (ditandai
   `@visibleForTesting`) supaya test bisa menyuntikkan database in-memory,
   tanpa mengubah perilaku singleton `AppDatabase()` yang dipakai aplikasi.
2. **`pubspec.yaml`** — menambahkan `dev_dependencies`:
   - `mocktail`
   - `sqlite3`
   - `sqlite3_flutter_libs`

## Cara menjalankan

```bash
flutter pub get
flutter test test/services
```

Jalankan semua test di root project (bila ada test lain):

```bash
flutter test
```
