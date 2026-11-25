import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/local_storage_service.dart';
import 'services/weather_api_service.dart';
import 'utils/app_theme.dart';
import 'viewmodels/location_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = WeatherApiService();
  final storageService = LocalStorageService();

  runApp(
    CuacaKuApp(
      apiService: apiService,
      storageService: storageService,
    ),
  );
}

class CuacaKuApp extends StatelessWidget {
  final WeatherApiService apiService;
  final LocalStorageService storageService;

  const CuacaKuApp({
    super.key,
    required this.apiService,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeViewModel>(
          create: (_) =>
              ThemeViewModel(storageService: storageService)..loadTheme(),
        ),
        ChangeNotifierProvider<LocationViewModel>(
          create: (_) => LocationViewModel(
            apiService: apiService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(
            apiService: apiService,
            storageService: storageService,
          ),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVm, _) {
          return MaterialApp(
            title: 'CuacaKu - Responsi Flutter',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeVm.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
