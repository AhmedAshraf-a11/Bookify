import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/books_models.dart';

class BookInfoCard extends StatelessWidget {
  const BookInfoCard({
    required this.book,
    required this.progress,
    required this.isFavorite,
    required this.isFavoriteUpdating,
    required this.onFavoritePressed,
    this.bookId,
    super.key,
  });

  final BookModel book;
  final BookProgressInfoModel? progress;
  final bool isFavorite;
  final bool isFavoriteUpdating;
  final VoidCallback onFavoritePressed;
  final String? bookId;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = book.image?.secureUrl;
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final progressValue = (progress?.percentage ?? 0) / 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: hasImage
                ? Image.network(
                    imageUrl,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 150,
                      color: AppColors.grey,
                      child: const Icon(
                        Icons.book,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 150,
                    color: AppColors.grey,
                    child: const Icon(
                      Icons.book,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: isFavoriteUpdating ? null : onFavoritePressed,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  book.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.menu_book_rounded,
                  '${book.totalPages} Pages',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.category_outlined, book.category),
                const SizedBox(height: 12),
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reading Progress',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          '${progress?.percentage ?? 0}%',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: AppColors.lightGrey,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: book.pdf != null
                        ? () {
                            context.push(
                              '${AppRoutePaths.library}/pdf-viewer',
                              extra: {
                                'pdfUrl': book.pdf!.secureUrl,
                                'bookId': book.id,
                                'totalPages': book.totalPages,
                                'lastPage': progress?.currentPage ?? 0,
                              },
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Continue Reading'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 18),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white60, fontSize: 14)),
      ],
    );
  }
}
