import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_player/models/constant/YT_TYPE.dart';
import 'package:music_player/services/youtube_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('YoutubeService.search', () {
    test('hits /search with the query, type and page token, and parses results',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/search');
        expect(request.url.queryParameters['q'], 'lofi hip hop');
        expect(request.url.queryParameters['type'], 'video');
        expect(request.url.queryParameters['pageToken'], 'abc123');

        return http.Response(
          jsonEncode({
            'results': [
              {
                'id': 'vid1',
                'type': 'video',
                'title': 'Lofi Beats',
                'thumbnail': 'https://example.com/thumb.jpg',
                'channelTitle': 'Chill Channel',
              }
            ],
            'nextPageToken': 'next-token',
            'prevPageToken': null,
          }),
          200,
        );
      });

      final response = await http.runWithClient(
        () => YoutubeService.search(
          query: 'lofi hip hop',
          type: YT_TYPE.VIDEO,
          pageToken: 'abc123',
        ),
        () => mockClient,
      );

      expect(response.results, hasLength(1));
      expect(response.results.first.id, 'vid1');
      expect(response.results.first.title, 'Lofi Beats');
      expect(response.nextPageToken, 'next-token');
      expect(response.prevPageToken, isNull);
    });

    test('sends the correct type string for playlist and channel searches',
        () async {
      final requestedTypes = <String>[];

      final mockClient = MockClient((request) async {
        requestedTypes.add(request.url.queryParameters['type']!);
        return http.Response(jsonEncode({'results': []}), 200);
      });

      await http.runWithClient(
        () async {
          await YoutubeService.search(query: 'q', type: YT_TYPE.PLAYLIST);
          await YoutubeService.search(query: 'q', type: YT_TYPE.CHANNEL);
        },
        () => mockClient,
      );

      expect(requestedTypes, ['playlist', 'channel']);
    });
  });

  group('YoutubeService.getPlaylistItems', () {
    test('hits /playlist/{id} and parses the list response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/playlist/PL123');

        return http.Response(
          jsonEncode({
            'results': [
              {
                'id': 'song1',
                'type': 'video',
                'title': 'Track 1',
                'thumbnail': 'https://example.com/1.jpg',
              }
            ],
            'nextPageToken': null,
          }),
          200,
        );
      });

      final response = await http.runWithClient(
        () => YoutubeService.getPlaylistItems(playlistId: 'PL123'),
        () => mockClient,
      );

      expect(response.results, hasLength(1));
      expect(response.results.first.title, 'Track 1');
    });
  });

  group('YoutubeService.getChannelDetail', () {
    test('hits /channel/{id} and parses channel + playlists', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/channel/UC123');

        return http.Response(
          jsonEncode({
            'channel': {
              'id': 'UC123',
              'title': 'Cool Channel',
              'thumbnail': 'https://example.com/c.jpg',
              'subscriberCount': '1000',
            },
            'playlists': [],
          }),
          200,
        );
      });

      final response = await http.runWithClient(
        () => YoutubeService.getChannelDetail(channelId: 'UC123'),
        () => mockClient,
      );

      expect(response.channel.id, 'UC123');
      expect(response.channel.title, 'Cool Channel');
      expect(response.playlists, isEmpty);
    });

    test('propagates an Exception when the backend errors out', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      await http.runWithClient(
        () => expectLater(
          YoutubeService.getChannelDetail(channelId: 'bad-id'),
          throwsA(isA<Exception>()),
        ),
        () => mockClient,
      );
    });
  });
}
