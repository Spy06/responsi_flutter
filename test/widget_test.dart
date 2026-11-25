import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:responsi_flutter/main.dart';
import 'package:responsi_flutter/models/location_model.dart';
import 'package:responsi_flutter/models/weather_model.dart';
import 'package:responsi_flutter/services/local_storage_service.dart';
import 'package:responsi_flutter/services/weather_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final sampleForecastJson = {
    'latitude': -7.7972,
    'longitude': 110.3688,
    'timezone': 'Asia/Jakarta',
    'timezone_abbreviation': 'WIB',
    'current': {
      'time': '2026-11-25T14:00',
      'temperature_2m': 29.5,
      'relative_humidity_2m': 76,
      'apparent_temperature': 33.2,
      'precipitation': 1.4,
      'weather_code': 61,
      'wind_speed_10m': 12.8,
    },
    'daily': {
      'time': ['2026-11-25', '2026-11-26', '2026-11-27'],
      'weather_code': [61, 1, 95],
      'temperature_2m_max': [31.2, 32.0, 30.4],
      'temperature_2m_min': [24.1, 23.8, 24.5],
      'precipitation_probability_max': [80, 35, 90],
    },
  };

  final sampleGeocodingJson = {
    'results': [
      {
        'id': 1621177,
        'name': 'Yogyakarta',
        'latitude': -7.7972,
        'longitude': 110.3688,
        'country': 'Indonesia',
        'country_code': 'ID',
        'admin1': 'Daerah Istimewa Yogyakarta',
        'timezone': 'Asia/Jakarta',
      },
      {
        'id': 1642911,
        'name': 'Jakarta',
        'latitude': -6.2146,
        'longitude': 106.8451,
        'country': 'Indonesia',
        'country_code': 'ID',
        'admin1': 'Jakarta',
        'timezone': 'Asia/Jakarta',
      },
    ],
  };

  test('WeatherModel.fromJson mengolah seluruh field Open-Meteo dengan benar', () {
    final model = WeatherModel.fromJson(sampleForecastJson);

    expect(model.current.temperature2m, 29.5);
    expect(model.current.relativeHumidity2m, 76);
    expect(model.current.apparentTemperature, 33.2);
    expect(model.current.precipitation, 1.4);
    expect(model.current.weatherCode, 61);
    expect(model.current.windSpeed10m, 12.8);

    expect(model.daily.length, 3);
    expect(model.daily.first.temperature2mMax, 31.2);
    expect(model.daily.first.temperature2mMin, 24.1);
    expect(model.daily.first.precipitationProbabilityMax, 80);
  });

  test('LocalStorageService menyimpan dan memuat ulang lokasi favorit & riwayat',
      () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();

    const yogya = LocationModel(
      id: 1621177,
      name: 'Yogyakarta',
      latitude: -7.7972,
      longitude: 110.3688,
      country: 'Indonesia',
      admin1: 'Daerah Istimewa Yogyakarta',
    );

    await storage.saveFavoriteLocations([yogya]);
    await storage.saveSearchHistory([yogya]);
    await storage.saveLastSelectedLocation(yogya);

    final loadedFavs = await storage.getFavoriteLocations();
    final loadedHistory = await storage.getSearchHistory();
    final loadedLast = await storage.getLastSelectedLocation();

    expect(loadedFavs.length, 1);
    expect(loadedFavs.first.name, 'Yogyakarta');
    expect(loadedHistory.length, 1);
    expect(loadedLast?.name, 'Yogyakarta');
  });

  testWidgets(
      'Alur MVVM: menampilkan cuaca dari API, mencari kota, dan menyimpan favorit',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final mockClient = MockClient((http.Request request) async {
      if (request.url.host.contains('geocoding-api.open-meteo.com')) {
        return http.Response(
          jsonEncode(sampleGeocodingJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      return http.Response(
        jsonEncode(sampleForecastJson),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final apiService = WeatherApiService(client: mockClient);
    final storageService = LocalStorageService();

    await tester.pumpWidget(
      CuacaKuApp(
        apiService: apiService,
        storageService: storageService,
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi Home Screen menampilkan data cuaca dari API
    expect(find.text('Yogyakarta'), findsOneWidget);
    expect(find.text('29.5°C'), findsOneWidget);
    expect(find.text('Hujan Ringan'), findsOneWidget);
    expect(find.text('76%'), findsOneWidget);
    expect(find.text('12.8 km/j'), findsOneWidget);

    // Navigasi ke Search Screen & simpan favorit
    await tester.tap(find.byTooltip('Cari Kota & Favorit'));
    await tester.pumpAndSettle();

    expect(find.text('Cari Lokasi & Favorit'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Jakarta');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    final jakartaResultCard = find.widgetWithText(Card, 'Jakarta');
    expect(jakartaResultCard, findsOneWidget);

    // Klik bintang favorit pada kartu Jakarta lalu pilih Jakarta
    await tester.tap(
      find.descendant(
        of: jakartaResultCard,
        matching: find.byTooltip('Simpan sebagai Favorit'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(jakartaResultCard);
    await tester.pumpAndSettle();

    // Kembali di Home Screen dengan kota terpilih dan chip favorit muncul
    expect(find.text('Kota Favorit Tersimpan'), findsOneWidget);
    expect(find.text('Jakarta'), findsWidgets);
  });

  testWidgets('Menampilkan ErrorStateView saat API gagal dan berhasil Coba Lagi',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    bool shouldFail = true;

    final mockClient = MockClient((http.Request request) async {
      if (shouldFail) {
        return http.Response('Server Error', 500);
      }
      if (request.url.host.contains('geocoding-api.open-meteo.com')) {
        return http.Response(jsonEncode(sampleGeocodingJson), 200);
      }
      return http.Response(jsonEncode(sampleForecastJson), 200);
    });

    await tester.pumpWidget(
      CuacaKuApp(
        apiService: WeatherApiService(client: mockClient),
        storageService: LocalStorageService(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal Memuat Informasi Cuaca'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);

    shouldFail = false;
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Yogyakarta'), findsOneWidget);
    expect(find.text('29.5°C'), findsOneWidget);
  });
}
