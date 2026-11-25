import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/location_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../search/search_screen.dart';
import '../shared/state_views.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/daily_forecast_card.dart';
import 'widgets/favorite_locations_strip.dart';
import 'widgets/weather_metrics_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LocationViewModel>().loadSavedLocations();
      context.read<WeatherViewModel>().initialize();
    });
  }

  Future<void> _openSearchScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  Future<void> _handleToggleFavorite(LocationModel location) async {
    final added =
        await context.read<LocationViewModel>().toggleFavorite(location);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text(
            added
                ? '${location.name} disimpan ke lokasi favorit.'
                : '${location.name} dihapus dari lokasi favorit.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final weatherVm = context.watch<WeatherViewModel>();
    final locationVm = context.watch<LocationViewModel>();
    final themeVm = context.watch<ThemeViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wb_sunny_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('CuacaKu'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openSearchScreen,
            tooltip: 'Cari Kota & Favorit',
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: weatherVm.isLoading ? null : weatherVm.refreshWeather,
            tooltip: 'Muat Ulang Cuaca',
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: themeVm.toggleTheme,
            tooltip: themeVm.isDarkMode ? 'Mode Terang' : 'Mode Gelap',
            icon: Icon(
              themeVm.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: _buildBody(context, weatherVm, locationVm),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherViewModel weatherVm,
    LocationViewModel locationVm,
  ) {
    if (weatherVm.isLoading && !weatherVm.hasData) {
      return const LoadingStateView(
        message: 'Mengambil data cuaca terkini dari Open-Meteo...',
      );
    }

    if (weatherVm.errorMessage != null && !weatherVm.hasData) {
      return ErrorStateView(
        title: 'Gagal Memuat Informasi Cuaca',
        message: weatherVm.errorMessage!,
        onRetry: weatherVm.refreshWeather,
        secondaryActionLabel: 'Cari Kota Lain',
        onSecondaryAction: _openSearchScreen,
      );
    }

    if (weatherVm.isEmptyState ||
        weatherVm.weather == null ||
        weatherVm.selectedLocation == null) {
      return EmptyStateView(
        icon: Icons.travel_explore_rounded,
        title: 'Belum Ada Lokasi Dipilih',
        subtitle:
            'Silakan cari dan pilih kota untuk menampilkan informasi cuaca terkini serta prakiraan harian.',
        actionLabel: 'Cari Lokasi Kota',
        onAction: _openSearchScreen,
      );
    }

    final location = weatherVm.selectedLocation!;
    final weather = weatherVm.weather!;
    final isFav = locationVm.isFavorite(location);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: weatherVm.refreshWeather,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (weatherVm.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: LinearProgressIndicator(minHeight: 3),
              ),
            Card(
              child: InkWell(
                onTap: _openSearchScreen,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cari nama kota atau buka daftar favorit...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                        color: theme.colorScheme.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (locationVm.favorites.isNotEmpty) ...[
              const SizedBox(height: 16),
              FavoriteLocationsStrip(
                favorites: locationVm.favorites,
                selectedLocation: location,
                onSelectLocation: (selected) {
                  locationVm.addToHistory(selected);
                  weatherVm.selectLocation(selected);
                },
              ),
            ],
            const SizedBox(height: 16),
            CurrentWeatherCard(
              location: location,
              weather: weather,
              isFavorite: isFav,
              onToggleFavorite: () => _handleToggleFavorite(location),
              onOpenSearch: _openSearchScreen,
            ),
            const SizedBox(height: 22),
            WeatherMetricsGrid(weather: weather),
            const SizedBox(height: 22),
            DailyForecastSection(forecasts: weather.daily),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Sumber Data: Open-Meteo Weather & Geocoding REST API',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
