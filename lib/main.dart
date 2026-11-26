import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/geocoding_service.dart';
import 'services/gps_service.dart';
import 'services/storage_service.dart';
import 'services/weather_service.dart';
import 'viewmodels/location_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final weatherService = WeatherService();
  final geocodingService = GeocodingService();
  final gpsService = GpsService();
  final settingsViewModel = SettingsViewModel(storageService);
  await settingsViewModel.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsViewModel>.value(
          value: settingsViewModel,
        ),
        ChangeNotifierProvider(
          create: (_) =>
              WeatherViewModel(weatherService, storageService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              LocationViewModel(geocodingService, storageService, gpsService)
                ..init(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kataware-doki',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      home: const MainShell(),
    );
  }
}
