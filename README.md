# CuacaKu: Responsi Pemrograman Mobile

Farhan Hakim (H1D024064)

Aplikasi informasi cuaca real-time berbasis **Flutter** & **Dart** yang mengimplementasikan pola arsitektur **MVVM (Model-View-ViewModel)**, komunikasi REST API dari **Open-Meteo**, serta penyimpanan lokal menggunakan **SharedPreferences**.

---

## Fitur Utama

1. **Home / Weather Screen**
   - Menampilkan nama kota dan wilayah/negara yang sedang dipilih.
   - Menampilkan suhu terkini (`temperature_2m`), kondisi cuaca & kode WMO (`weather_code`), serta suhu yang dirasakan (`apparent_temperature`).
   - Menampilkan detail metrik cuaca tambahan:
     - Kelembapan udara (`relative_humidity_2m`)
     - Kecepatan angin (`wind_speed_10m`)
     - Peluang hujan maksimum (`precipitation_probability_max`)
     - Curah hujan terkini (`precipitation`)
     - Zona waktu otomatis (`timezone=auto`)
   - Menampilkan prakiraan cuaca 7 hari ke depan beserta suhu minimum (`temperature_2m_min`), suhu maksimum (`temperature_2m_max`), dan peluang hujan harian.
   - Bar pintasan cepat (*quick chips*) untuk memilih kota favorit yang tersimpan di penyimpanan lokal.
   - Mendukung *Pull-to-Refresh*, *Light/Dark Theme* Material Design 3, serta penanganan kondisi *Loading*, *Empty State*, dan *Error State* (lengkap dengan tombol *Coba Lagi*).

2. **Search / Location Screen**
   - Kolom pencarian lokasi berdasarkan nama kota secara *real-time* ke Open-Meteo Geocoding API.
   - Menampilkan daftar hasil pencarian kota beserta wilayah administrasi dan koordinat (`latitude`, `longitude`).
   - Memilih lokasi dari hasil pencarian untuk langsung memperbarui informasi cuaca di Home Screen.
   - Menyimpan dan menghapus lokasi sebagai **Favorit** maupun **Riwayat Pencarian** ke dalam *Local Storage* (`SharedPreferences`), sehingga data tetap tersedia ketika aplikasi ditutup dan dibuka kembali.

---

## Struktur Aplikasi & Penerapan Arsitektur MVVM

Proyek ini memisahkan tanggung jawab kode secara tegas menggunakan pola **Model - View - ViewModel (MVVM)** dengan bantuan package `provider` (`ChangeNotifier`):

```text
lib/
├── main.dart                              # Entry point aplikasi & konfigurasi MultiProvider
├── models/                                # [MODEL] Representasi data & parsing JSON
│   ├── location_model.dart                # Model data lokasi kota (Geocoding API & Local Storage)
│   └── weather_model.dart                 # Model cuaca terkini (CurrentWeather) & harian (DailyForecast)
├── services/                              # [SERVICE / DATA LAYER] Sumber data eksternal & lokal
│   ├── weather_api_service.dart           # HTTP GET request ke REST API Open-Meteo
│   └── local_storage_service.dart         # Penyimpanan lokal favorit & riwayat (SharedPreferences)
├── viewmodels/                            # [VIEWMODEL] Pengelolaan state & logika bisnis
│   ├── weather_viewmodel.dart             # State cuaca aktif, loading, empty state, dan error handling
│   ├── location_viewmodel.dart            # State pencarian kota, daftar favorit, dan riwayat pencarian
│   └── theme_viewmodel.dart               # State tema aplikasi (Light / Dark Mode)
├── views/                                 # [VIEW] Antarmuka pengguna (StatelessWidget & StatefulWidget)
│   ├── home/
│   │   ├── home_screen.dart               # Layar utama informasi cuaca
│   │   └── widgets/
│   │       ├── current_weather_card.dart  # Kartu utama suhu & kondisi cuaca terkini
│   │       ├── weather_metrics_grid.dart  # Grid responsif metrik kelembapan, angin, & hujan
│   │       ├── daily_forecast_card.dart   # Daftar prakiraan cuaca beberapa hari ke depan
│   │       └── favorite_locations_strip.dart # Pintasan chip kota favorit tersimpan
│   ├── search/
│   │   ├── search_screen.dart             # Layar pencarian lokasi, favorit, & riwayat
│   │   └── widgets/
│   │       └── location_list_tile.dart    # Item daftar kota & tombol bintang favorit
│   └── shared/
│       └── state_views.dart               # Widget reusable untuk Loading, Empty, dan Error state
└── utils/                                 # Utilitas pendukung UI & konversi data
    ├── app_theme.dart                     # Konfigurasi Material Design 3 Theme & Typography
    ├── date_formatter.dart                # Format tanggal dan nama hari Bahasa Indonesia
    └── weather_code_helper.dart           # Pemetaan kode cuaca WMO ke deskripsi & ikon cuaca
```

### Penjelasan Alur MVVM:
1. **Model (`lib/models/`)**: Mengubah respons JSON dari API menjadi objek Dart (`fromJson`) dan mengubah objek Dart kembali ke JSON (`toJson`) untuk disimpan di `SharedPreferences`. Tidak memiliki ketergantungan pada UI.
2. **Service (`lib/services/`)**: Menangani operasi I/O seperti pemanggilan HTTP `GET` (`WeatherApiService`) dan baca/tulis penyimpanan lokal (`LocalStorageService`).
3. **ViewModel (`lib/viewmodels/`)**: Menghubungkan *Service* dan *View*. Mengelola state (`isLoading`, `errorMessage`, `weather`, `searchResults`, `favorites`, `searchHistory`) melalui `ChangeNotifier` dan memberi tahu *View* menggunakan `notifyListeners()` saat state berubah.
4. **View (`lib/views/`)**: Hanya bertugas menampilkan UI berdasarkan state dari *ViewModel* (`context.watch`) dan meneruskan aksi pengguna ke *ViewModel* (`context.read`), tanpa mencampur logika pemanggilan API di dalam kode widget.

---

## Implementasi REST API (Open-Meteo)

Seluruh data cuaca diambil secara dinamis menggunakan metode **HTTP GET** menggunakan package `http` (tanpa data statis/*hardcoded*):

### 1. Geocoding API (Pencarian Lokasi Kota)
- **Endpoint**: `https://geocoding-api.open-meteo.com/v1/search`
- **Method**: `GET`
- **Query Parameters**:
  - `name`: Kata kunci nama kota yang dicari pengguna
  - `count`: `15`
  - `language`: `id`
  - `format`: `json`

### 2. Weather Forecast API (Cuaca Terkini & Prakiraan Harian)
- **Endpoint**: `https://api.open-meteo.com/v1/forecast`
- **Method**: `GET`
- **Query Parameters**:
  - `latitude` & `longitude`: Koordinat lokasi terpilih
  - `timezone`: `auto`
  - `current`:
    - `temperature_2m` (Suhu saat ini)
    - `relative_humidity_2m` (Kelembapan udara)
    - `apparent_temperature` (Suhu yang dirasakan)
    - `precipitation` (Curah hujan)
    - `weather_code` (Kode kondisi cuaca WMO)
    - `wind_speed_10m` (Kecepatan angin)
  - `daily`:
    - `weather_code` (Kode kondisi cuaca harian)
    - `temperature_2m_max` (Suhu maksimum harian)
    - `temperature_2m_min` (Suhu minimum harian)
    - `precipitation_probability_max` (Peluang hujan maksimum harian)

---
## SCREENSHOOT APLIKASI
<img width="537" height="845" alt="Screenshot 2026-11-26 001817" src="https://github.com/user-attachments/assets/d1b00b2c-cf8e-4c2a-a0df-2bc8e0d6b43f" />
<img width="540" height="838" alt="Screenshot 2026-11-26 003225" src="https://github.com/user-attachments/assets/2e183dcc-c739-4fc2-accb-aa883fd732b6" />
<img width="542" height="843" alt="Screenshot 2026-11-26 003232" src="https://github.com/user-attachments/assets/d503117f-2354-44f9-9298-4aa258f194ba" />
<img width="537" height="838" alt="Screenshot 2026-11-26 003606" src="https://github.com/user-attachments/assets/11972774-2195-489f-83ac-51e52cd4775e" />

---

## Cara Menjalankan Proyek

1. Pastikan **Flutter SDK** sudah terpasang di perangkat Anda.
2. Unduh seluruh dependensi package:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi pada emulator / perangkat fisik / desktop / browser:
   ```bash
   flutter run
   ```
4. Menjalankan pengujian otomatis (*unit & widget test*):
   ```bash
   flutter test
   ```
