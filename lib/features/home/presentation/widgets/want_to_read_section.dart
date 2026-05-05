import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/home_models.dart';

class WantToReadSection extends StatelessWidget {
  const WantToReadSection({
    required this.currentlyReading,
    required this.onBookTap,
    super.key,
  });

  final List<CurrentlyReadingItemModel> currentlyReading;
  final ValueChanged<String> onBookTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Want to read',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: currentlyReading.isEmpty
                        ? 1
                        : currentlyReading.length,
                    itemBuilder: (context, index) => Container(
                      width: 68,
                      margin: const EdgeInsets.only(right: 8),
                      child: currentlyReading.isEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                color: AppColors.grey.withValues(alpha: 0.2),
                                child: const Icon(
                                  Icons.book,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () =>
                                  onBookTap(currentlyReading[index].book.id),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    currentlyReading[index].book.imageUrl !=
                                            null &&
                                        currentlyReading[index]
                                            .book
                                            .imageUrl!
                                            .isNotEmpty
                                    ? Image.network(
                                        currentlyReading[index].book.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  color: AppColors.grey,
                                                  child: const Icon(
                                                    Icons.book,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                      )
                                    : Container(
                                        color: AppColors.grey,
                                        child: const Icon(
                                          Icons.book,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bookmark_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutePaths.addBook),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      'Add Book',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
