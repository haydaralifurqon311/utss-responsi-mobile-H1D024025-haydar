import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/location_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';

class WeatherHeader extends StatelessWidget {
  const WeatherHeader({
    required this.weatherViewModel,
    required this.settingsViewModel,
    super.key,
  });

  final WeatherViewModel weatherViewModel;
  final SettingsViewModel settingsViewModel;

  @override
  Widget build(BuildContext context) {
    final location = weatherViewModel.selectedLocation;
    if (location == null) {
      return const SizedBox.shrink();
    }

    final favorites = context.watch<LocationViewModel>().favorites;
    final otherFavorites = favorites.where((favorite) => favorite != location);
    final isFavorite = context.read<LocationViewModel>().isFavorite(location);
    final theme = Theme.of(context);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        PopupMenuButton<LocationModel>(
          onSelected: weatherViewModel.selectLocation,
          itemBuilder: (context) => [
            PopupMenuItem<LocationModel>(
              value: location,
              child: Row(
                children: [
                  const Icon(Icons.my_location, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Lokasi saat ini · ${location.name}')),
                ],
              ),
            ),
            if (otherFavorites.isNotEmpty)
              const PopupMenuItem<LocationModel>(
                enabled: false,
                child: Text('Lokasi favorit'),
              ),
            ...otherFavorites.map(
              (favorite) => PopupMenuItem<LocationModel>(
                value: favorite,
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(favorite.name)),
                  ],
                ),
              ),
            ),
          ],
          child: Container(
            constraints: const BoxConstraints(maxWidth: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    location.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: settingsViewModel.isDark
                  ? 'Ganti ke tema siang'
                  : 'Ganti ke tema gelap',
              onPressed: settingsViewModel.toggleTheme,
              icon: Icon(
                settingsViewModel.isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
            TextButton(
              onPressed: settingsViewModel.toggleUnit,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 40),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(settingsViewModel.isCelsius ? '°C' : '°F'),
            ),
            IconButton(
              tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
              onPressed: () async {
                await context.read<LocationViewModel>().toggleFavorite(
                  location,
                );
              },
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? theme.colorScheme.secondary : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
