import 'package:bookify/features/books/presentation/cubit/books_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_repositories.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/books_models.dart';

class EditBookScreen extends StatefulWidget {
  const EditBookScreen({required this.bookId, super.key});

  final String bookId;

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalPagesController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  BookModel? _book;

  final List<String> _categories = [
    'sports',
    'religion',
    'horror',
    'education',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalPagesController.dispose();
    super.dispose();
  }

  Future<void> _loadBookData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await booksRemoteRepository.getBook(widget.bookId);
      _book = response.book;
      _titleController.text = _book!.title;
      _descriptionController.text = _book!.description;
      _totalPagesController.text = _book!.totalPages.toString();
      if (_categories.contains(_book!.category)) {
        _selectedCategory = _book!.category;
      }
    } on ApiException catch (_) {
      _errorMessage = 'Could not retrieve book data. Please try again.';
    } catch (_) {
      _errorMessage = 'Failed to load book information';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final hasPdf = _book?.pdf != null;
      final category = _selectedCategory;
      final totalPages = int.tryParse(_totalPagesController.text.trim());

      final response = await booksRemoteRepository.editBook(
        widget.bookId,
        EditBookRequestModel(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: category ?? '',
          totalPages: hasPdf ? null : totalPages,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
        // Notify Cubit to refresh list
        context.read<BooksCubit>().loadBooks();
        context.pop(true); // Return true to indicate success
      }
    } on ApiException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update book. Please check your connection.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update book')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPdf = _book?.pdf != null;

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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Book',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBookData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel(label: 'Book Title'),
                        _StyledTextField(
                          controller: _titleController,
                          hint: 'Enter book title',
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),
                        _FieldLabel(
                          label: hasPdf
                              ? 'Total Pages (Cannot change, book has PDF)'
                              : 'Total Pages',
                        ),
                        _StyledTextField(
                          controller: _totalPagesController,
                          hint: 'Enter total pages',
                          keyboardType: TextInputType.number,
                          enabled: !hasPdf,
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel(label: 'Category'),
                        _CategoryDropdown(
                          categories: _categories,
                          value: _selectedCategory,
                          onChanged: (value) => setState(() => _selectedCategory = value),
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel(label: 'Description'),
                        _StyledTextField(
                          controller: _descriptionController,
                          hint: 'Enter book description',
                          maxLines: 4,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Note: Image and PDF cannot be updated after creation.',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        const SizedBox(height: 40),
                        PrimaryButton(
                          text: _isSubmitting ? 'Saving...' : 'Save Changes',
                          onPressed: _isSubmitting ? null : _onSubmit,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: TextStyle(color: enabled ? Colors.white : Colors.white38),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text(
            'Select category',
            style: TextStyle(color: Colors.white38),
          ),
          dropdownColor: AppColors.surface,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white70,
          ),
          items: categories
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c, style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
