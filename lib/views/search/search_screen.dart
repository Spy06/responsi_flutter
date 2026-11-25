import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/location_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../shared/state_views.dart';
import 'widgets/location_list_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  bool _hasInputText = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LocationViewModel>().clearSearch();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final nonEmpty = value.trim().isNotEmpty;
    if (nonEmpty != _hasInputText) {
      setState(() {
        _hasInputText = nonEmpty;
      });
    }

    _debounceTimer?.cancel();
    if (!nonEmpty) {
      context.read<LocationViewModel>().clearSearch();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<LocationViewModel>().searchCities(value);
    });
  }

  void _submitSearch() {
    _debounceTimer?.cancel();
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    _focusNode.unfocus();
    context.read<LocationViewModel>().searchCities(query);
  }

  void _clearInput() {
    _debounceTimer?.cancel();
    _searchController.clear();
    setState(() {
      _hasInputText = false;
    });
    context.read<LocationViewModel>().clearSearch();
    _focusNode.requestFocus();
  }

  Future<void> _selectLocation(LocationModel location) async {
    final locationVm = context.read<LocationViewModel>();
    final weatherVm = context.read<WeatherViewModel>();

    await locationVm.addToHistory(location);
    weatherVm.selectLocation(location);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _toggleFavorite(LocationModel location) async {
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
                ? '${location.name} ditambahkan ke favorit.'
                : '${location.name} dihapus dari favorit.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final locationVm = context.watch<LocationViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Lokasi & Favorit'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: _onSearchChanged,
                    onSubmitted: (_) => _submitSearch(),
                    decoration: InputDecoration(
                      hintText: 'Cari nama kota (misal: Yogyakarta, Bandung, Tokyo)...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      suffixIcon: _hasInputText
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: _clearInput,
                                  tooltip: 'Bersihkan Pencarian',
                                  icon: const Icon(Icons.clear_rounded),
                                ),
                                IconButton(
                                  onPressed: _submitSearch,
                                  tooltip: 'Cari Sekarang',
                                  icon: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: _hasInputText
                      ? _buildSearchResultsView(locationVm)
                      : _buildSavedLocationsView(context, locationVm),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsView(LocationViewModel locationVm) {
    if (locationVm.isSearching) {
      return LoadingStateView(
        message: 'Mencari kota "${_searchController.text.trim()}"...',
      );
    }

    if (locationVm.errorMessage != null) {
      return ErrorStateView(
        title: 'Gagal Mencari Lokasi',
        message: locationVm.errorMessage!,
        onRetry: _submitSearch,
      );
    }

    if (locationVm.isSearchResultEmpty) {
      return EmptyStateView(
        icon: Icons.location_off_rounded,
        title: 'Kota Tidak Ditemukan',
        subtitle:
            'Tidak ditemukan hasil untuk "${locationVm.currentQuery}". Coba gunakan kata kunci kota lain.',
      );
    }

    if (locationVm.searchResults.isEmpty) {
      return const LoadingStateView(message: 'Menyiapkan pencarian...');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: locationVm.searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final location = locationVm.searchResults[index];
        final isFav = locationVm.isFavorite(location);
        return LocationListTile(
          location: location,
          isFavorite: isFav,
          leadingIcon: Icons.location_on_rounded,
          onTap: () => _selectLocation(location),
          onToggleFavorite: () => _toggleFavorite(location),
        );
      },
    );
  }

  Widget _buildSavedLocationsView(
    BuildContext context,
    LocationViewModel locationVm,
  ) {
    final theme = Theme.of(context);
    final favorites = locationVm.favorites;
    final history = locationVm.searchHistory;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: [
        Row(
          children: [
            Icon(
              Icons.star_rounded,
              size: 20,
              color: Colors.amber.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              'Lokasi Favorit (${favorites.length})',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (favorites.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(
                    Icons.star_outline_rounded,
                    size: 28,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Belum ada lokasi favorit. Cari kota lalu tekan ikon bintang untuk menyimpannya di penyimpanan lokal.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...favorites.map(
            (loc) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LocationListTile(
                location: loc,
                isFavorite: true,
                leadingIcon: Icons.star_rounded,
                onTap: () => _selectLocation(loc),
                onToggleFavorite: () => _toggleFavorite(loc),
              ),
            ),
          ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Riwayat Pencarian',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            if (history.isNotEmpty)
              TextButton.icon(
                onPressed: locationVm.clearHistory,
                icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                label: const Text('Hapus Semua'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (history.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(
                    Icons.manage_search_rounded,
                    size: 28,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Riwayat lokasi yang Anda pilih akan tersimpan otomatis dan ditampilkan kembali saat aplikasi dibuka.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...history.map(
            (loc) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LocationListTile(
                location: loc,
                isFavorite: locationVm.isFavorite(loc),
                leadingIcon: Icons.history_rounded,
                onTap: () => _selectLocation(loc),
                onToggleFavorite: () => _toggleFavorite(loc),
                onRemoveHistory: () => locationVm.removeFromHistory(loc),
              ),
            ),
          ),
      ],
    );
  }
}
