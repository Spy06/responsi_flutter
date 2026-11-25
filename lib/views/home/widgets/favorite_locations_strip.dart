import 'package:flutter/material.dart';

import '../../../models/location_model.dart';

class FavoriteLocationsStrip extends StatelessWidget {
  final List<LocationModel> favorites;
  final LocationModel? selectedLocation;
  final ValueChanged<LocationModel> onSelectLocation;

  const FavoriteLocationsStrip({
    super.key,
    required this.favorites,
    required this.selectedLocation,
    required this.onSelectLocation,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.star_rounded,
              size: 18,
              color: Colors.amber.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              'Kota Favorit Tersimpan',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favorites.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final loc = favorites[index];
              final isSelected = selectedLocation != null &&
                  loc.isSameLocation(selectedLocation!);

              return ChoiceChip(
                label: Text(loc.name),
                selected: isSelected,
                showCheckmark: false,
                avatar: Icon(
                  Icons.place_rounded,
                  size: 16,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.primary,
                ),
                onSelected: (_) => onSelectLocation(loc),
              );
            },
          ),
        ),
      ],
    );
  }
}
