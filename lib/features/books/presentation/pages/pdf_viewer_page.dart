import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../progress/data/models/progress_models.dart';
import '../../../../core/app_repositories.dart';

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({
    required this.pdfUrl,
    this.bookId,
    this.totalPages,
    this.lastPage,
    super.key,
  });

  final String pdfUrl;
  final String? bookId;
  final int? totalPages;
  final int? lastPage;

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfViewerController _pdfViewerController;
  bool _isSaving = false;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _currentPage = widget.lastPage ?? 0;
    _totalPages = widget.totalPages ?? 0;

    // Jump to last page if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentPage > 0) {
        _pdfViewerController.jumpToPage(_currentPage);
      }
    });
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    if (_totalPages == 0) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Extract bookId from the route or pass it as parameter
      final bookId = _extractBookIdFromUrl();
      if (bookId != null) {
        await progressRemoteRepository.updateProgress(
          bookId,
          UpdateProgressRequestModel(currentPage: _currentPage),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save progress: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String? _extractBookIdFromUrl() {
    // Extract bookId from the widget parameters
    return widget.bookId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PDF Viewer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SfPdfViewer.network(
                  widget.pdfUrl,
                  controller: _pdfViewerController,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  pageSpacing: 4,
                  enableTextSelection: true,
                  enableHyperlinkNavigation: true,
                  onDocumentLoadFailed: (details) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load PDF: ${details.error}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  onDocumentLoaded: (details) {
                    setState(() {
                      // Get total pages from the controller after document is loaded
                      _totalPages = _pdfViewerController.pageCount;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF loaded successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  onPageChanged: (details) {
                    setState(() {
                      _currentPage = details.newPageNumber;
                    });
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _isSaving ? null : _saveProgress,
                backgroundColor: AppColors.primary,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
