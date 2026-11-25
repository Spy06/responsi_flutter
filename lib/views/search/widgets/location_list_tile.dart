import 'package:flutter/material.dart';

import '../../../models/location_model.dart';

class LocationListTile extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final IconData leadingIcon;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onRemoveHistory;

  const LocationListTile({
    super.key,
    required this.location,
    required this.isFavorite,
    this.leadingIcon = Icons.location_city_rounded,
    required this.onTap,
    required this.onToggleFavorite,
    this.onRemoveHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  leadingIcon,
                  size: 22,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lat ${location.latitude.toStringAsFixed(2)}, Lon ${location.longitude.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 11.5,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavorite,
                tooltip:
                    isFavorite ? 'Hapus dari Favorit' : 'Simpan sebagai Favorit',
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFavorite
                      ? Colors.amber.shade600
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              if (onRemoveHistory != null)
                IconButton(
                  onPressed: onRemoveHistory,
                  tooltip: 'Hapus dari Riwayat',
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: colorScheme.outline,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
