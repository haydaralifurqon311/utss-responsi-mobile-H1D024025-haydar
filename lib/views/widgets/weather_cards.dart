import 'package:flutter/material.dart';

import '../../core/utils/weather_code.dart';
import '../../models/air_quality_model.dart';
import '../../models/weather_model.dart';

class WeatherMainCard extends StatelessWidget {
  const WeatherMainCard({
    required this.current,
    required this.today,
    required this.airQuality,
    required this.timeLabel,
    required this.timeQuote,
    required this.formatTemp,
    super.key,
  });

  final CurrentWeather current;
  final DailyWeather? today;
  final AirQualityModel? airQuality;
  final String timeLabel;
  final String timeQuote;
  final String Function(double) formatTemp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uvIndex = today?.uvIndexMax;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WAKTU · $timeLabel', style: theme.textTheme.labelSmall),
            if (timeQuote.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                timeQuote,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(
                  weatherCodeToIcon(current.weatherCode, isDay: current.isDay),
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatTemp(current.temperature2m),
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Terasa ${formatTemp(current.apparentTemperature)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              weatherCodeToText(current.weatherCode),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              today == null
                  ? 'Min / Maks tidak tersedia'
                  : 'Min ${formatTemp(today!.tempMin)}  ·  '
                        'Maks ${formatTemp(today!.tempMax)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (uvIndex != null)
                  _WeatherChip(
                    icon: Icons.wb_sunny_outlined,
                    label:
                        'UV ${uvIndex.toStringAsFixed(1)} · '
                        '${_uvLabel(uvIndex)}',
                  ),
                _WeatherChip(
                  icon: Icons.air,
                  label: airQuality == null
                      ? 'AQI tidak tersedia'
                      : 'AQI ${airQuality!.usAqi} · ${airQuality!.label}',
                ),
                if (today != null)
                  _WeatherChip(
                    icon: Icons.wb_twilight,
                    label: 'Terbenam ${_formatTime(today!.sunset)}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherMetricCard extends StatelessWidget {
  const WeatherMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherChip extends StatelessWidget {
  const _WeatherChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

String _uvLabel(double value) {
  if (value <= 2) return 'Rendah';
  if (value <= 5) return 'Sedang';
  return 'Tinggi';
}

String _formatTime(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return '--:--';
  return '${parsed.hour.toString().padLeft(2, '0')}:'
      '${parsed.minute.toString().padLeft(2, '0')}';
}
