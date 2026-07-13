import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_player/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // DeviceIdUtil relies on SharedPreferences, so give it a fake backend
    // before every test.
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiService.get', () {
    test('returns decoded JSON body when request succeeds (200)', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/search');
        expect(request.url.queryParameters['q'], 'lofi');
        expect(request.headers['x-api-key'], 'tugas_cak_nanang');
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.headers.containsKey('x-device-id'), isTrue);

        return http.Response(
          jsonEncode({'results': [], 'nextPageToken': null}),
          200,
        );
      });

      final result = await http.runWithClient(
        () => ApiService.get('/search', queryParams: {'q': 'lofi'}),
        () => mockClient,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['results'], isEmpty);
    });

    test('reuses the same device id across multiple calls', () async {
      final deviceIds = <String>[];

      final mockClient = MockClient((request) async {
        deviceIds.add(request.headers['x-device-id']!);
        return http.Response(jsonEncode({'ok': true}), 200);
      });

      await http.runWithClient(
        () async {
          await ApiService.get('/a');
          await ApiService.get('/b');
        },
        () => mockClient,
      );

      expect(deviceIds.length, 2);
      expect(deviceIds[0], deviceIds[1]);
    });

    test('throws an Exception when the server returns a non-200 status',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not found', 404);
      });

      await http.runWithClient(
        () => expectLater(
          ApiService.get('/missing'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('404'),
          )),
        ),
        () => mockClient,
      );
    });

    test('wraps low-level network errors into an Exception', () async {
      final mockClient = MockClient((request) async {
        throw const SocketExceptionStub();
      });

      await http.runWithClient(
        () => expectLater(
          ApiService.get('/anything'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Network error'),
          )),
        ),
        () => mockClient,
      );
    });
  });
}

/// Minimal stand-in for a thrown network error, avoiding a dependency on
/// dart:io's SocketException signature just for this test.
class SocketExceptionStub implements Exception {
  const SocketExceptionStub();

  @override
  String toString() => 'SocketExceptionStub: connection failed';
}
