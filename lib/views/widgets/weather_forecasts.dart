import 'package:flutter/material.dart';

import '../../core/utils/weather_code.dart';
import '../../models/weather_model.dart';

class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({
    required this.hours,
    required this.currentTime,
    required this.isDay,
    required this.formatTemp,
    super.key,
  });

  final List<HourlyWeather> hours;
  final String currentTime;
  final bool isDay;
  final String Function(double) formatTemp;

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) {
      return const _ForecastEmptyMessage();
    }

    final theme = Theme.of(context);
    final currentHour = _hourKey(currentTime);
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hours.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final hour = hours[index];
          final isCurrentHour = _hourKey(hour.time) == currentHour;
          return SizedBox(
            width: 92,
            child: Card(
              color: isCurrentHour
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(hour.time),
                      style: theme.textTheme.labelSmall,
                    ),
                    Icon(
                      weatherCodeToIcon(hour.weatherCode, isDay: isDay),
                      color: theme.colorScheme.primary,
                    ),
                    Text(
                      formatTemp(hour.temperature),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${hour.precipitationProbability}%',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ActivitySummaryCard extends StatelessWidget {
  const ActivitySummaryCard({required this.activityIndex, super.key});

  final Map<String, String> activityIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = activityIndex['Ringkasan'] ?? 'Data belum tersedia';
    final activities = [
      ('Lari Sore', activityIndex['Lari sore'] ?? 'Data belum tersedia'),
      ('Jemur', activityIndex['Jemur'] ?? 'Data belum tersedia'),
      ('Berkendara', activityIndex['Berkendara'] ?? 'Data belum tersedia'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(summary, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...activities.map(
              (activity) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(child: Text(activity.$1)),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        activity.$2,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FiveDayForecast extends StatelessWidget {
  const FiveDayForecast({
    required this.days,
    required this.currentTime,
    required this.isDay,
    required this.formatTemp,
    super.key,
  });

  final List<DailyWeather> days;
  final String currentTime;
  final bool isDay;
  final String Function(double) formatTemp;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const _ForecastEmptyMessage();
    }

    final theme = Theme.of(context);
    final currentDate = _dateKey(currentTime);
    return Card(
      child: Column(
        children: [
          for (var index = 0; index < days.length; index++) ...[
            _DailyForecastRow(
              day: days[index],
              label: _dayLabel(days[index].date, currentDate),
              isDay: isDay,
              formatTemp: formatTemp,
            ),
            if (index < days.length - 1)
              Divider(height: 1, color: theme.colorScheme.outline),
          ],
        ],
      ),
    );
  }
}

class _DailyForecastRow extends StatelessWidget {
  const _DailyForecastRow({
    required this.day,
    required this.label,
    required this.isDay,
    required this.formatTemp,
  });

  final DailyWeather day;
  final String label;
  final bool isDay;
  final String Function(double) formatTemp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Icon(
            weatherCodeToIcon(day.weatherCode, isDay: isDay),
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${weatherCodeToText(day.weatherCode)} · '
              '${day.precipitationProbabilityMax}%',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${formatTemp(day.tempMin)} / ${formatTemp(day.tempMax)}',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _ForecastEmptyMessage extends StatelessWidget {
  const _ForecastEmptyMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Prakiraan tidak tersedia',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

String _hourKey(String value) {
  return value.length >= 13 ? value.substring(0, 13) : value;
}

String _dateKey(String value) {
  return value.length >= 10 ? value.substring(0, 10) : value;
}

String _formatTime(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return '--:--';
  return '${parsed.hour.toString().padLeft(2, '0')}:'
      '${parsed.minute.toString().padLeft(2, '0')}';
}

String _dayLabel(String value, String currentDate) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  if (_dateKey(value) == currentDate) return 'Hari Ini';

  const weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
}
