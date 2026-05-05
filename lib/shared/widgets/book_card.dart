import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final int pages;
  final String description;
  final bool isFavorite;
  final String? imageUrl;
  final VoidCallback? onDetailsPressed;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final int? progressPercentage;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.pages,
    required this.description,
    this.isFavorite = false,
    this.imageUrl,
    this.onDetailsPressed,
    this.onFavoritePressed,
    this.onEditPressed,
    this.onDeletePressed,
    this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImageUrl = imageUrl != null && imageUrl!.isNotEmpty;
    final bool isNetworkImage =
        hasImageUrl &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2E35), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: hasImageUrl
                ? (isNetworkImage
                      ? Image.network(
                          imageUrl!,
                          width: 62,
                          height: 92,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 62,
                              height: 92,
                              color: AppColors.grey,
                              child: const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 62,
                                height: 92,
                                color: AppColors.grey,
                                child: const Icon(
                                  Icons.book,
                                  color: Colors.white,
                                ),
                              ),
                        )
                      : Image.asset(
                          imageUrl!,
                          width: 62,
                          height: 92,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 62,
                                height: 92,
                                color: AppColors.grey,
                                child: const Icon(
                                  Icons.book,
                                  color: Colors.white,
                                ),
                              ),
                        ))
                : Container(
                    width: 62,
                    height: 92,
                    color: AppColors.grey,
                    child: const Icon(Icons.book, color: Colors.white),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (onEditPressed != null)
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: onEditPressed,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFFB4BAC5),
                          size: 18,
                        ),
                      ),
                    if (onDeletePressed != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: onDeletePressed,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFB4BAC5),
                          size: 18,
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: onFavoritePressed,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? Colors.red
                            : const Color(0xFFB4BAC5),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Author: $author',
                  style: const TextStyle(
                    color: Color(0xFFA8ADBA),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Pages: $pages',
                  style: const TextStyle(
                    color: Color(0xFFA8ADBA),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE3E6ED),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                if (progressPercentage != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Progress: ',
                            style: TextStyle(
                              color: Color(0xFFA8ADBA),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$progressPercentage%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progressPercentage! / 100.0,
                        backgroundColor: const Color(0xFF2A2E35),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressPercentage! >= 75
                              ? Colors.green
                              : progressPercentage! >= 50
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                if (progressPercentage != null) const SizedBox(height: 8),
                if (onDetailsPressed != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: onDetailsPressed,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.secondary,
                          foregroundColor: const Color(0xFFE9EEE0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
