import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/weather_model.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/view_state.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/weather_cards.dart';
import 'widgets/weather_forecasts.dart';
import 'widgets/weather_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherViewModel = context.watch<WeatherViewModel>();
    final settingsViewModel = context.watch<SettingsViewModel>();

    return RefreshIndicator(
      onRefresh: weatherViewModel.refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 44,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WeatherHeader(
                        weatherViewModel: weatherViewModel,
                        settingsViewModel: settingsViewModel,
                      ),
                      const SizedBox(height: 18),
                      _buildWeatherContent(
                        context,
                        weatherViewModel,
                        settingsViewModel,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherContent(
    BuildContext context,
    WeatherViewModel weatherViewModel,
    SettingsViewModel settingsViewModel,
  ) {
    switch (weatherViewModel.state) {
      case ViewState.loading:
        return const SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator()),
        );
      case ViewState.error:
        return _WeatherMessage(
          icon: Icons.cloud_off_outlined,
          message: weatherViewModel.errorMessage ?? 'Data cuaca gagal dimuat.',
          action: OutlinedButton.icon(
            onPressed: weatherViewModel.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        );
      case ViewState.empty:
        return const _WeatherMessage(
          icon: Icons.cloud_queue,
          message: 'Data cuaca tidak tersedia.',
        );
      case ViewState.success:
        final weather = weatherViewModel.weather;
        if (weather == null) {
          return const _WeatherMessage(
            icon: Icons.cloud_queue,
            message: 'Data cuaca tidak tersedia.',
          );
        }
        return _buildForecastContent(
          context,
          weatherViewModel,
          settingsViewModel,
          weather,
        );
    }
  }

  Widget _buildForecastContent(
    BuildContext context,
    WeatherViewModel weatherViewModel,
    SettingsViewModel settingsViewModel,
    WeatherModel weather,
  ) {
    final today = _todayForecast(weather);
    final theme = Theme.of(context);
    final current = weather.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WeatherMainCard(
          current: current,
          today: today,
          airQuality: weatherViewModel.airQuality,
          timeLabel:
              '${weatherViewModel.waktuLokal} ${weatherViewModel.zonaWaktu}',
          timeQuote: weatherViewModel.kutipanWaktu,
          formatTemp: settingsViewModel.formatTemp,
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final spacing = 8.0;
            final cardWidth = (constraints.maxWidth - spacing * 2) / 3;
            return Wrap(
              spacing: spacing,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: WeatherMetricCard(
                    label: 'Kelembapan',
                    value: '${current.relativeHumidity}%',
                    icon: Icons.water_drop_outlined,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: WeatherMetricCard(
                    label: 'Angin km/j',
                    value: current.windSpeed.toStringAsFixed(1),
                    icon: Icons.air,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: WeatherMetricCard(
                    label: 'Hujan',
                    value: weatherViewModel.peluangHujanSaatIni == null
                        ? '—'
                        : '${weatherViewModel.peluangHujanSaatIni}%',
                    icon: Icons.grain,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        Text('Prakiraan Per Jam', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        HourlyForecastStrip(
          hours: weatherViewModel.jamJamKeDepan,
          currentTime: current.time,
          isDay: current.isDay,
          formatTemp: settingsViewModel.formatTemp,
        ),
        const SizedBox(height: 22),
        Text('Indeks Aktivitas', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        ActivitySummaryCard(activityIndex: weatherViewModel.activityIndex),
        const SizedBox(height: 22),
        Text('Prakiraan 5 Hari', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        FiveDayForecast(
          days: weather.daily,
          currentTime: current.time,
          isDay: current.isDay,
          formatTemp: settingsViewModel.formatTemp,
        ),
      ],
    );
  }

  DailyWeather? _todayForecast(WeatherModel weather) {
    final currentDate = weather.current.time.length >= 10
        ? weather.current.time.substring(0, 10)
        : weather.current.time;
    for (final forecast in weather.daily) {
      if (forecast.date.startsWith(currentDate)) {
        return forecast;
      }
    }
    return weather.daily.isEmpty ? null : weather.daily.first;
  }
}

class _WeatherMessage extends StatelessWidget {
  const _WeatherMessage({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 300,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}
