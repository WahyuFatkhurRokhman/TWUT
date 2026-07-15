# Test Summary

This document lists the tests implemented in the project and their expected outcomes.

## 1. ApiService (`test/services/api_service_test.dart`)

| Test Case | Expected Outcome |
| :--- | :--- |
| `get` - Success | Returns decoded JSON body when request succeeds (200 OK). |
| `get` - Device ID | Reuses the same device ID across multiple calls. |
| `get` - Non-200 | Throws an `Exception` when server returns a non-200 status (e.g., 404). |
| `get` - Network Error | Wraps low-level network errors into an `Exception`. |

## 2. MusicCacheService (`test/services/music_cache_service_test.dart`)

| Test Case | Expected Outcome |
| :--- | :--- |
| `loadSongs` | Returns an empty list when no cache file exists. |
| `saveSongs` | Persists songs that can be read back with `loadSongs`. |
| `saveSongs` - Overwrite | Overwrites any previously cached data. |
| `clear` | Removes the cache file so `loadSongs` returns empty. |
| `clear` - No-op | Does not throw an error when there is nothing to clear. |

## 3. PlaylistService (`test/services/playlist_service_test.dart`)

| Test Case | Expected Outcome |
| :--- | :--- |
| `createPlaylist` | Stores a new playlist and returns its ID. |
| `getAllPlaylists` | Returns an empty list initially. |
| `addSongToPlaylist` | Adds a song and returns `true`. |
| `addSongToPlaylist` - Duplicate | Returns `false` for a duplicate song path. |
| `getSongsInPlaylist` | Only returns songs for the given playlist. |
| `getPlaylistDetailById` | Returns the matching playlist. |
| `getPlaylistDetailById` - Null | Returns `null` for an unknown ID. |
| `renamePlaylist` | Updates the playlist name. |
| `removeSongFromPlaylist` | Deletes only the targeted song. |
| `deletePlaylist` | Removes the playlist and cascades its songs. |

## 4. YoutubeService (`test/services/youtube_service_test.dart`)

| Test Case | Expected Outcome |
| :--- | :--- |
| `search` | Hits `/search` with query, type, and page token; parses results. |
| `search` - Types | Sends the correct type string for playlist and channel searches. |
| `getPlaylistItems` | Hits `/playlist/{id}` and parses the list response. |
| `getChannelDetail` | Hits `/channel/{id}` and parses channel + playlists. |
| `getChannelDetail` - Error | Propagates an `Exception` when the backend errors out. |
