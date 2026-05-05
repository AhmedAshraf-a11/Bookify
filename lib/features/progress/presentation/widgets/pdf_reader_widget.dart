import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../data/models/progress_models.dart';
import '../bloc/reading_progress_cubit.dart';

class PdfReaderWidget extends StatefulWidget {
  const PdfReaderWidget({
    super.key,
    required this.bookId,
    required this.pdfUrl,
    required this.totalPages,
    this.initialPage = 0,
  });

  final String bookId;
  final String pdfUrl;
  final int totalPages;
  final int initialPage;

  @override
  State<PdfReaderWidget> createState() => _PdfReaderWidgetState();
}

class _PdfReaderWidgetState extends State<PdfReaderWidget>
    with WidgetsBindingObserver {
  late PdfViewerController _pdfController;
  Timer? _progressUpdateTimer;
  int _currentPage = 0;
  bool _hasUnsavedProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pdfController = PdfViewerController();
    _currentPage = widget.initialPage;

    // Start debounced timer for progress updates
    _startProgressUpdateTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressUpdateTimer?.cancel();
    _saveProgressIfNeeded(); // Save progress on dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _saveProgressIfNeeded();
        break;
      case AppLifecycleState.resumed:
        _startProgressUpdateTimer();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _startProgressUpdateTimer() {
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _saveProgressIfNeeded(),
    );
  }

  void _onPageChanged(int newPage) {
    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
        _hasUnsavedProgress = true;
      });
    }
  }

  Future<void> _saveProgressIfNeeded() async {
    if (_hasUnsavedProgress && mounted) {
      _hasUnsavedProgress = false;

      final progressRequest = UpdateProgressRequestModel(
        currentPage:
            _currentPage + 1, // PDF pages are 0-indexed, API expects 1-indexed
      );

      context.read<ReadingProgressCubit>().updateReadingProgress(
        widget.bookId,
        progressRequest,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page ${_currentPage + 1} of ${widget.totalPages}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProgressIfNeeded,
            tooltip: 'Save Progress',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / widget.totalPages,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),

          // PDF Viewer
          Expanded(
            child: BlocListener<ReadingProgressCubit, ReadingProgressState>(
              listener: (context, state) {
                if (state is ReadingProgressError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to save progress: ${state.message}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is ReadingProgressUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progress saved'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: SfPdfViewer.network(
                widget.pdfUrl,
                controller: _pdfController,
                initialPageNumber: widget.initialPage + 1,
                onDocumentLoaded: (document) {
                  // Ensure we don't exceed total pages
                  final pageCount = _pdfController.pageCount;
                  if (_currentPage >= pageCount) {
                    setState(() {
                      _currentPage = pageCount - 1;
                    });
                  }
                },
                onPageChanged: (newPage) {
                  _onPageChanged(
                    newPage.newPageNumber - 1,
                  ); // Convert to 0-indexed
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "prev_page",
            onPressed: _currentPage > 0
                ? () {
                    _pdfController.previousPage();
                    _onPageChanged(_currentPage - 1);
                  }
                : null,
            child: const Icon(Icons.keyboard_arrow_up),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "next_page",
            onPressed: _currentPage < widget.totalPages - 1
                ? () {
                    _pdfController.nextPage();
                    _onPageChanged(_currentPage + 1);
                  }
                : null,
            child: const Icon(Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }
}
