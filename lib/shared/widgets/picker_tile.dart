import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String? selectedFileName;
  final String? selectedFileSize;
  final VoidCallback onTap;

  const PickerTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.selectedFileName,
    this.selectedFileSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelection =
        selectedFileName != null && selectedFileName!.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasSelection ? AppColors.primary : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    hasSelection ? selectedFileName! : subtitle,
                    style: TextStyle(
                      color: hasSelection ? Colors.white70 : Colors.white38,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasSelection && selectedFileSize != null)
                    Text(
                      selectedFileSize!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              hasSelection
                  ? Icons.check_circle_rounded
                  : Icons.add_circle_outline_rounded,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
