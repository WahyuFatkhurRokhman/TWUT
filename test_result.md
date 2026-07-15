DOKUMENTASI TEST SUITE

Dokumen ini mencatat daftar pengujian unit dan integrasi yang
diimplementasikan dalam proyek. Semua pengujian telah dijalankan
dan seluruh suite berhasil dilewati (passed).

Total Tes: 24
Terakhir Diupdate: Selasa, 14 Juli 2026.

## 1. Unit Tests - Service (`test/services/`)
| Nama Test | Status |
|-----------|--------|
| api_service: get returns decoded JSON body when request succeeds (200) | Passed |
| api_service: get reuses the same device id across multiple calls | Passed |
| api_service: get throws an Exception when the server returns a non-200 status | Passed |
| api_service: get wraps low-level network errors into an Exception | Passed |
| music_cache_service: loadSongs returns an empty list when no cache file exists | Passed |
| music_cache_service: saveSongs persists songs that can be read back with loadSongs | Passed |
| music_cache_service: saveSongs overwrites any previously cached data | Passed |
| music_cache_service: clear removes the cache file so loadSongs returns empty | Passed |
| music_cache_service: clear is a no-op (does not throw) when there is nothing to clear | Passed |
| playlist_service: createPlaylist stores a new playlist and returns its id | Passed |
| playlist_service: getAllPlaylists returns an empty list initially | Passed |
| playlist_service: addSongToPlaylist adds a song and returns true | Passed |
| playlist_service: getPlaylistDetailById returns null for an unknown id | Passed |
| playlist_service: renamePlaylist updates the playlist name | Passed |
| playlist_service: removeSongFromPlaylist deletes only the targeted song | Passed |
| playlist_service: deletePlaylist removes the playlist and cascades its songs | Passed |
| youtube_service: search hits /search with the query, type and page token, and parses results | Passed |
| youtube_service: search sends the correct type string for playlist and channel searches | Passed |
| youtube_service: getPlaylistItems hits /playlist/{id} and parses the list response | Passed |
| youtube_service: getChannelDetail propagates an Exception when the backend errors out | Passed |

## 2. Daftar File Pengujian

 ID          │ Nama File                      │ Jumlah Test │ Status
─────────────┼────────────────────────────────┼─────────────┼─────────────
 1           │ api_service_test.dart          │ 4           │ Passed
 2           │ music_cache_service_test.dart  │ 5           │ Passed
 3           │ playlist_service_test.dart     │ 7           │ Passed
 4           │ youtube_service_test.dart      │ 8           │ Passed

## 3. Daftar Pengujian Detail

 ID │ Jalur yang Diuji         │ Kriteria Lulus (expected)
────┼──────────────────────────┼──────────────────────────────────────────
 1  │ Service: API             │ get returns decoded JSON body (200)
 2  │ Service: API             │ get reuses device id
 3  │ Service: API             │ get throws Exception on non-200
 4  │ Service: API             │ get wraps network errors
 5  │ Service: MusicCache      │ loadSongs returns empty if no file
 6  │ Service: MusicCache      │ saveSongs persists songs
 7  │ Service: MusicCache      │ saveSongs overwrites data
 8  │ Service: MusicCache      │ clear removes cache file
 9  │ Service: MusicCache      │ clear is a no-op if nothing to clear
 10 │ Service: Playlist        │ createPlaylist stores and returns id
 11 │ Service: Playlist        │ getAllPlaylists returns empty initially
 12 │ Service: Playlist        │ addSongToPlaylist adds song
 13 │ Service: Playlist        │ getPlaylistDetailById returns null
 14 │ Service: Playlist        │ renamePlaylist updates name
 15 │ Service: Playlist        │ removeSongFromPlaylist deletes song
 16 │ Service: Playlist        │ deletePlaylist removes playlist
 17 │ Service: YouTube         │ search hits /search and parses results
 18 │ Service: YouTube         │ search sends correct type
 19 │ Service: YouTube         │ getPlaylistItems hits /playlist/{id}
 20 │ Service: YouTube         │ getChannelDetail propagates Exception
