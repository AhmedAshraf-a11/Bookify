import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_repositories.dart';
import '../widgets/pdf_reader_widget.dart';
import '../cubit/reading_progress_cubit.dart';

class ReadingProgressPage extends StatefulWidget {
  const ReadingProgressPage({super.key, required this.bookId});

  final String bookId;

  @override
  State<ReadingProgressPage> createState() => _ReadingProgressPageState();
}

class _ReadingProgressPageState extends State<ReadingProgressPage> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _pdfUrl;
  int? _totalPages;
  String? _title;
  int _initialPage = 0;

  @override
  void initState() {
    super.initState();
    _loadBookData();
  }

  Future<void> _loadBookData() async {
    try {
      // Fetch book details and saved reading progress
      final bookResponse = await booksRemoteRepository.getBook(widget.bookId);
      final book = bookResponse.book;
      final savedPage = bookResponse.progressInfo?.currentPage ?? 1;

      setState(() {
        _pdfUrl = book.pdf?.secureUrl;
        _totalPages = book.totalPages;
        _title = book.title;
        _initialPage = savedPage > 0 ? savedPage - 1 : 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load book: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null || _pdfUrl == null || _pdfUrl!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_title ?? 'Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage ?? 'No PDF available for this book'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) =>
          ReadingProgressCubit(progressRepository: progressRemoteRepository),
      child: PdfReaderWidget(
        bookId: widget.bookId,
        pdfUrl: _pdfUrl!,
        totalPages: _totalPages ?? 0,
        initialPage: _initialPage,
      ),
    );
  }
}
