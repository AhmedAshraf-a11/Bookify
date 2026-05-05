import 'package:bookify/features/books/presentation/cubit/books_cubit.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_repositories.dart';
import '../../../../core/network/api_exception.dart';
import '../../../books/data/models/books_models.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/field_label.dart';
import '../../../../shared/widgets/styled_text_field.dart';
import '../../../../shared/widgets/picker_tile.dart';
import '../../../../shared/widgets/category_dropdown.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController =
      TextEditingController(); // This is handled by createdBy in API, but keeping for UI if needed or remove if strictly following API
  final _descriptionController = TextEditingController();
  final _totalPagesController = TextEditingController();
  PlatformFile? _selectedCoverImage;
  PlatformFile? _selectedPdfFile;
  String? _selectedCategory;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'sports',
    'religion',
    'horror',
    'education',
    'other',
  ];
  static const int _maxCoverBytes = 5 * 1024 * 1024;
  static const int _maxPdfBytes = 20 * 1024 * 1024;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _totalPagesController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Validate title length
    final title = _titleController.text.trim();
    if (title.length < 3 || title.length > 200) {
      _showError('Title must be between 3 and 200 characters');
      return;
    }

    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }

    // Validate description length (optional but max 500 if provided)
    final description = _descriptionController.text.trim();
    if (description.length > 500) {
      _showError('Description must be 500 characters or less');
      return;
    }

    // totalPages is required if PDF is not uploaded
    if (_selectedPdfFile == null && _totalPagesController.text.trim().isEmpty) {
      _showError('Total pages is required if no PDF is uploaded');
      return;
    }

    // Validate totalPages if provided
    if (_totalPagesController.text.trim().isNotEmpty) {
      final totalPages = int.tryParse(_totalPagesController.text.trim());
      if (totalPages == null || totalPages <= 0) {
        _showError('Total pages must be a positive number');
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await booksRemoteRepository.addBook(
        AddBookRequestModel(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory!,
          totalPages: int.tryParse(_totalPagesController.text.trim()),
        ),
        imagePath: _selectedCoverImage?.path,
        pdfPath: _selectedPdfFile?.path,
      );

      // CRITICAL: Create progress for the new book
      try {
        await progressRemoteRepository.createProgress(response.book.id);
      } catch (e) {
        // Log error but don't fail the operation
        print('Failed to create progress for new book: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
        // Notify Cubit to refresh list
        context.read<BooksCubit>().loadBooks();
        // After adding, go to details of the new book
        context.push('${AppRoutePaths.home}/book-details/${response.book.id}');
        _resetForm();
      }
    } on ApiException catch (_) {
      _showError('Could not add book. Please ensure all fields are correct.');
    } catch (_) {
      _showError('Something went wrong. Please try again later.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _authorController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedCoverImage = null;
      _selectedPdfFile = null;
    });
  }

  Future<void> _pickCoverImage() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final PlatformFile file = result.files.first;
    if (file.size > _maxCoverBytes) {
      _showError('Cover image must be 5MB or less');
      return;
    }

    setState(() => _selectedCoverImage = file);
  }

  Future<void> _pickPdfFile() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.isEmpty) return;

    final PlatformFile file = result.files.first;
    if (file.size > _maxPdfBytes) {
      _showError('PDF file must be 20MB or less');
      return;
    }

    setState(() => _selectedPdfFile = file);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => context.go(AppRoutePaths.home),
        ),
        title: const Text(
          'Add New Book',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel(label: 'Book Title'),
              StyledTextField(
                controller: _titleController,
                hint: 'Enter book title',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              const FieldLabel(label: 'Total Pages (Optional if PDF provided)'),
              StyledTextField(
                controller: _totalPagesController,
                hint: 'Enter total pages',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const FieldLabel(label: 'Category'),
              CategoryDropdown(
                categories: _categories,
                value: _selectedCategory,
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 20),
              const FieldLabel(label: 'Description'),
              StyledTextField(
                controller: _descriptionController,
                hint: 'Enter book description',
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              PickerTile(
                icon: Icons.image_outlined,
                label: 'Cover Image',
                subtitle: 'Select book cover image',
                selectedFileName: _selectedCoverImage?.name,
                selectedFileSize: _selectedCoverImage == null
                    ? null
                    : _formatBytes(_selectedCoverImage!.size),
                onTap: _pickCoverImage,
              ),
              const SizedBox(height: 16),
              PickerTile(
                icon: Icons.picture_as_pdf_outlined,
                label: 'PDF File',
                subtitle: 'Select book PDF file',
                selectedFileName: _selectedPdfFile?.name,
                selectedFileSize: _selectedPdfFile == null
                    ? null
                    : _formatBytes(_selectedPdfFile!.size),
                onTap: _pickPdfFile,
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: _isSubmitting ? 'Adding...' : 'Add Book',
                onPressed: _isSubmitting ? null : _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
