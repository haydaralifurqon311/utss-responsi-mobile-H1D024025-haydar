import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/weather_code.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/view_state.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../services/gps_service.dart';
import 'main_shell.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationViewModel = context.watch<LocationViewModel>();
    final settingsViewModel = context.watch<SettingsViewModel>();
    final weatherViewModel = context.read<WeatherViewModel>();
    final isQueryEmpty = _searchController.text.trim().isEmpty;
    final queryMatchesInput =
        _searchController.text.trim() == locationViewModel.query;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi & Favorit'),
        actions: [
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
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchField(locationViewModel),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: locationViewModel.isLocating
                        ? null
                        : _useCurrentLocation,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (locationViewModel.isLocating)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(Icons.my_location),
                        const SizedBox(width: 8),
                        const Text('Gunakan Lokasi GPS Saat Ini'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Semua Kota'),
                      selected:
                          locationViewModel.filter == LocationFilter.semua,
                      onSelected: (_) =>
                          locationViewModel.setFilter(LocationFilter.semua),
                    ),
                    ChoiceChip(
                      label: Text(
                        'Favorit (${locationViewModel.favorites.length})',
                      ),
                      selected:
                          locationViewModel.filter == LocationFilter.favorit,
                      onSelected: (_) =>
                          locationViewModel.setFilter(LocationFilter.favorit),
                    ),
                  ],
                ),
                if (isQueryEmpty && locationViewModel.history.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text('Riwayat Pencarian', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: locationViewModel.history
                        .map(
                          (search) => ActionChip(
                            label: Text(search),
                            onPressed: () => _searchHistory(search),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (locationViewModel.filter == LocationFilter.semua ||
                    locationViewModel.filter == LocationFilter.favorit) ...[
                  const SizedBox(height: 20),
                  Text('Lokasi Favorit', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _buildFavorites(
                    context,
                    locationViewModel,
                    weatherViewModel,
                    settingsViewModel,
                  ),
                ],
                if (locationViewModel.filter == LocationFilter.semua &&
                    !isQueryEmpty &&
                    queryMatchesInput) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Hasil Pencarian Kota '
                    '(${locationViewModel.results.length} kota)',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildSearchResults(
                    context,
                    locationViewModel,
                    weatherViewModel,
                    settingsViewModel,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(LocationViewModel viewModel) {
    final searchInput = TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => _searchCity(),
      decoration: InputDecoration(
        hintText: 'Cari kota, misal: Bandung, Denpasar.',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Hapus pencarian',
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close),
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    final searchButton = FilledButton(
      onPressed: viewModel.state == ViewState.loading ? null : _searchCity,
      child: const Text('Cari'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 380) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [searchInput, const SizedBox(height: 8), searchButton],
          );
        }
        return Row(
          children: [
            Expanded(child: searchInput),
            const SizedBox(width: 8),
            searchButton,
          ],
        );
      },
    );
  }

  Widget _buildFavorites(
    BuildContext context,
    LocationViewModel locationViewModel,
    WeatherViewModel weatherViewModel,
    SettingsViewModel settingsViewModel,
  ) {
    final favorites = locationViewModel.favorites;
    if (favorites.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('Belum ada lokasi favorit.'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favorites.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 156,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final location = favorites[index];
        return _FavoriteLocationCard(
          location: location,
          weatherViewModel: weatherViewModel,
          settingsViewModel: settingsViewModel,
          onTap: () => _selectLocation(location),
          onToggleFavorite: () async {
            await locationViewModel.toggleFavorite(location);
          },
        );
      },
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    LocationViewModel viewModel,
    WeatherViewModel weatherViewModel,
    SettingsViewModel settingsViewModel,
  ) {
    switch (viewModel.state) {
      case ViewState.loading:
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        );
      case ViewState.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(viewModel.errorMessage ?? 'Pencarian gagal.'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _searchCity,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        );
      case ViewState.empty:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('Kota tidak ditemukan'),
        );
      case ViewState.success:
        if (viewModel.results.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Kota tidak ditemukan'),
          );
        }
        return Column(
          children: viewModel.results
              .map(
                (location) => _SearchLocationTile(
                  location: location,
                  locationViewModel: viewModel,
                  weatherViewModel: weatherViewModel,
                  settingsViewModel: settingsViewModel,
                  onTap: () => _selectLocation(location),
                ),
              )
              .toList(),
        );
    }
  }

  Future<void> _searchCity() async {
    await context.read<LocationViewModel>().search(_searchController.text);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _searchHistory(String search) async {
    _searchController.text = search;
    setState(() {});
    await _searchCity();
  }

  Future<void> _selectLocation(LocationModel location) async {
    final weatherViewModel = context.read<WeatherViewModel>();
    final tabController = context.read<MainShellTabController>();
    final selection = weatherViewModel.selectLocation(location);
    tabController.selectTab(0);
    await selection;
  }

  Future<void> _useCurrentLocation() async {
    final locationViewModel = context.read<LocationViewModel>();
    final error = await locationViewModel.useCurrentLocation(
      onLocationSelected: _selectLocation,
    );
    if (!mounted || error == null) {
      return;
    }

    SnackBarAction? action;
    if (error.type == GpsErrorType.locationServiceDisabled) {
      action = SnackBarAction(
        label: 'Buka Pengaturan',
        onPressed: () async {
          await locationViewModel.openLocationSettings();
        },
      );
    } else if (error.type == GpsErrorType.permissionDeniedForever) {
      action = SnackBarAction(
        label: 'Buka Pengaturan',
        onPressed: () async {
          await locationViewModel.openAppSettings();
        },
      );
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error.message), action: action));
  }
}

class _FavoriteLocationCard extends StatelessWidget {
  const _FavoriteLocationCard({
    required this.location,
    required this.weatherViewModel,
    required this.settingsViewModel,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final LocationModel location;
  final WeatherViewModel weatherViewModel;
  final SettingsViewModel settingsViewModel;
  final VoidCallback onTap;
  final Future<void> Function() onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      location.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Hapus dari favorit',
                    onPressed: onToggleFavorite,
                    icon: Icon(Icons.star, color: theme.colorScheme.secondary),
                  ),
                ],
              ),
              Text(
                location.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _LocationWeatherLine(
                  location: location,
                  weatherViewModel: weatherViewModel,
                  settingsViewModel: settingsViewModel,
                  compact: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchLocationTile extends StatelessWidget {
  const _SearchLocationTile({
    required this.location,
    required this.locationViewModel,
    required this.weatherViewModel,
    required this.settingsViewModel,
    required this.onTap,
  });

  final LocationModel location;
  final LocationViewModel locationViewModel;
  final WeatherViewModel weatherViewModel;
  final SettingsViewModel settingsViewModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFavorite = locationViewModel.isFavorite(location);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        title: Text(location.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${location.subtitle} • '
              '${location.latitude.toStringAsFixed(2)}, '
              '${location.longitude.toStringAsFixed(2)}',
            ),
            _LocationWeatherLine(
              location: location,
              weatherViewModel: weatherViewModel,
              settingsViewModel: settingsViewModel,
              compact: false,
            ),
          ],
        ),
        trailing: IconButton(
          tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
          onPressed: () async {
            await locationViewModel.toggleFavorite(location);
          },
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? theme.colorScheme.secondary : null,
          ),
        ),
      ),
    );
  }
}

class _LocationWeatherLine extends StatelessWidget {
  const _LocationWeatherLine({
    required this.location,
    required this.weatherViewModel,
    required this.settingsViewModel,
    required this.compact,
  });

  final LocationModel location;
  final WeatherViewModel weatherViewModel;
  final SettingsViewModel settingsViewModel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<WeatherModel>(
      future: weatherViewModel.fetchWeatherForLocation(location),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Text(
            'Cuaca belum tersedia',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          );
        }

        final current = snapshot.data!.current;
        final icon = Icon(
          weatherCodeToIcon(current.weatherCode, isDay: current.isDay),
          size: compact ? 18 : 20,
          color: theme.colorScheme.primary,
        );
        final weatherText =
            '${settingsViewModel.formatTemp(current.temperature2m)} · '
            '${weatherCodeToText(current.weatherCode)}';
        if (compact) {
          return Row(
            children: [
              icon,
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  weatherText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            icon,
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                weatherText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        );
      },
    );
  }
}
