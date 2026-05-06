# 📋 Bookify Implementation Tasks & Plan

This document outlines the necessary tasks to refactor the existing Flutter application, implement new features, address missing UI screens, and refine state management based on the provided `project_analysis.md` and `documentation.md`.

## 1. 🔄 API Endpoint Updates and Refactoring

- [x] **Update Base URL:** Modify `ApiConfig.baseUrl` in `lib/core/constants/api_endpoints.dart` to `http://13.219.191.61`.
- [x] **User Endpoints:**
  - [x] Update `/user/profile` to `/users/profile` in `ApiEndpoints`.
  - [x] Update `/user/update-profile` to `/users/update-profile` in `ApiEndpoints`.
  - [x] Update `/user/delete-profile` to `/users/delete-profile` in `ApiEndpoints`.
- [x] **Notes Endpoints:**
  - [x] Clarify that there is no separate `GET /notes` endpoint.
  - [x] Notes are returned inside the book detail response from `GET /books/:id`.
  - [x] Only add/update/delete note APIs should be implemented explicitly.
  - [x] Change base route from `/notes` to `/note` for all note-related endpoints in `ApiEndpoints`.
  - [x] Refactor `addNote` endpoint to accept `bookId` as a path parameter: `static String addNote(String bookId) => '/note/add-note/$bookId';`.
  - [x] Update `addNoteUri(String bookId)` in `ApiEndpoints` accordingly.
  - [x] Update `updateNoteBase` to `/note/update-note` in `ApiEndpoints`.
  - [x] Update `deleteNoteBase` to `/note/delete-note` in `ApiEndpoints`.

## 2. 🏗️ Models & Data Layer Refactoring

- [x] **Auth Models (`lib/features/auth/data/models/auth_models.dart`):**
  - [x] Ensure `AuthUserModel` accurately reflects `firstName`, `lastName`, `email`, and `bio` fields from the API response.
  - [x] Verify `SignUpRequestModel` and `SignInRequestModel` match the API documentation, including `confirmPassword` for signup.
- [x] **Book Models (`lib/features/books/data/models/books_models.dart`):**
  - [x] Confirm `BookModel` correctly parses: `_id`, `title`, `description`, `totalPages`, `category`, `image` (secure_url, public_id), `pdf` (secure_url, public_id), `createdBy`.
  - [x] Ensure `AddBookRequestModel` and `EditBookRequestModel` align with API for adding/editing, supporting multipart form-data with optional image and pdf fields.
  - [x] For book list responses, handle minimal fields: `_id`, `title`, `totalPages`, `category`.
- [x] **Progress Models (`lib/features/progress/data/models/progress_models.dart`):**
  - [x] Verify `Progress` model correctly handles `percentage`, `currentPage`, and `status`.
- [x] **Note Models (`lib/features/notes/data/models/notes_models.dart`):**
  - [x] Refactor Note models to match API responses: `_id`, `userId`, `bookId`, `content`, `createdAt`, `updatedAt`.
  - [x] Note: Notes field appears as array in GET `/books/:id` response, not via separate endpoint.
- [x] **Repositories:**
  - [x] Update `AuthRemoteRepository` to handle `confirmPassword` in `signUp` request.
  - [x] Update `BooksRemoteRepository` to ensure `addBook` correctly handles `imagePath` and `pdfPath` for multipart requests.
  - [x] Update `NotesRemoteRepository` to pass `bookId` for `addNote` and `noteId` for `updateNote` and `deleteNote`.
  - [x] Review all repositories to ensure correct API endpoint usage and data mapping.

## 3. 🚀 Feature Implementation & UI Updates

### 3.1. Authentication Module

- [x] **Sign Up Screen (`lib/features/auth/presentation/pages/sign_up_screen.dart`):**
  - [x] Implement `bio` field (optional, max 150 characters) in the UI.
  - [x] Add client-side validation for `firstName` (min 3, max 25), `lastName` (min 3, max 25), `email` (valid format, unique check via API), `password` (min 6), and `confirmPassword` (must match password).
  - [x] Integrate `AuthCubit` for `signUp` functionality.
  - [x] Handle `SignUpSuccess` by navigating to the login screen.
  - [x] Display appropriate error messages from `SignUpFailure` (e.g., "Email already registered", "Passwords do not match").
- [x] **Sign In Screen (`lib/features/auth/presentation/pages/login_screen.dart`):**
  - [x] Integrate `AuthCubit` for `signIn` functionality.
  - [x] On `SignInSuccess`, store the JWT access token securely using `appAuthSession` and navigate to the `LibraryScreen`.
  - [x] Display appropriate error messages from `SignInFailure` (e.g., "No account found with this email", "Incorrect password").
  - [x] Implement secure token storage and retrieval.
- [x] Implement "Remember me" functionality (if `_rememberMe` is true, persist login credentials).
- [x] Implement "Forgot password?" navigation (currently a TODO).
- [x] Ensure proper navigation after successful login (redirect to `LibraryScreen`).
- [x] Update `splash_screen.dart` to check authentication status and redirect to `login` or `home` accordingly.
- [x] **Logout Functionality (`lib/features/profile/presentation/pages/profile_screen.dart`):**
  - [x] Implement `logout` functionality using `AuthRemoteRepository`.
  - [x] Clear local token using `appAuthSession.clear()` on successful logout.
  - [x] Redirect to `LoginScreen` after logout.
  - [x] Handle `logout` from current device only and all devices (using `flag` query parameter).

### 3.2. Books & Library Management Module

- [x] **Add Book Screen (`lib/features/add_book/presentation/pages/add_book_screen.dart`):**
  - [x] Implement file picker for PDF and image uploads.
  - [x] Utilize `BooksRemoteRepository.addBook` with `postMultipart` for file uploads.
  - [x] **CRITICAL:** After successful book creation, immediately call the `Create Progress` endpoint (`/progress/create-progress/:bookId`) to initialize the reading progress for the new book.
  - [x] Add client-side validation: `title` (min 3-200 chars), `category` (sports/religion/horror/eduction/other), `description` (max 500, optional). Ensure either `pdf` uploaded or `totalPages` provided.
  - [x] Display success/error messages and navigate to `LibraryScreen` on success.
- [x] **Library Screen (`lib/features/library/presentation/pages/library_screen.dart`):**
  - [x] Implement `Get Books List` (`/books`) with pagination (10 books per page) and infinite scroll.
  - [x] Implement category filtering using the provided fixed list (`sports`, `religion`, `horror`, `eduction`, `other`).
  - [x] Display book cards with title, category, cover image, and reading progress percentage.
  - [x] Handle empty states for no books or no books in a selected category.
  - [x] Integrate `Edit Book` and `Delete Book` actions for each book card.
- [x] **Edit Book Screen (`lib/features/books/presentation/pages/edit_book_screen.dart`):**
  - [x] Fetch existing book details to pre-fill the form.
  - [x] Allow editing `title`, `category`, and `description`.
  - [x] Disable editing of PDF file, cover image, and `totalPages` if a PDF is already associated with the book.
  - [x] Implement client-side validation for editable fields.
  - [x] Call `BooksRemoteRepository.editBook` to update book details.
  - [x] Navigate back to `BookDetailsPage` on success.
- [x] **Book Details Page (`lib/features/books/presentation/pages/book_details_page.dart`):**
  - [x] Implement `Get Single Book` (`/books/:id`) to fetch comprehensive book information.
  - [x] Display book metadata (title, category, totalPages, description, cover).
  - [x] Display user's notes for this book.
  - [x] Display reading progress (currentPage, percentage, status).
  - [x] Display favorite status.
  - [x] Implement UI for adding, updating, and deleting notes associated with the book.
  - [x] Implement UI to toggle favorite status.
- [x] **Delete Book Functionality:**
  - [x] Implement confirmation dialog before permanent deletion.
  - [x] Call `BooksRemoteRepository.deleteBook` to remove the book and its associated data.
  - [x] Refresh `LibraryScreen` after successful deletion.

### 3.3. Reading Progress Tracking Module

- [x] **PDF Viewer Integration:**
  - [x] Integrate a PDF viewer to display books.
  - [x] Track `currentPage` as the user reads.
  - [x] Implement debounced updates for reading progress (e.g., every 30 seconds or on app close/pause) to call `Update Reading Progress` endpoint (`/progress/update-progress/:bookId`).
  - [x] Update `Progress` status (`reading` or `completed`) based on `currentPage` vs `totalPages`.

### 3.4. Interactions (Favorites & Notes) Module

- [x] **Favorites:**
  - [x] Connect `Add to Favorites` (`/favorites/add-to-favorites/:bookId`) and `Remove from Favorites` (`/favorites/remove-from-favorites/:bookId`) endpoints.
  - [x] Update UI (heart icon) to reflect favorite status on book cards and detail screens.
  - [x] Handle optimistic UI updates with rollback on API errors.
- [x] **Notes:**
  - [x] Implement UI for adding new notes (title, content, page number) on the `BookDetailsPage`.
  - [x] Call `NotesRemoteRepository.addNote` with `bookId`.
  - [x] Implement UI for updating existing notes.
  - [x] Call `NotesRemoteRepository.updateNote` with `noteId`.
  - [x] Implement UI for deleting notes.
  - [x] Call `NotesRemoteRepository.deleteNote` with `noteId`.
  - [x] Display general notes and book-specific notes.

### 3.5. Home Dashboard Module

- [x] **Currently Reading List:**
  - [x] Connect `Get Currently Reading` (`/home/currently-reading`) to populate the dashboard.
  - [x] Display books with status `reading`, ordered by most recently updated.
  - [x] Handle empty state: "No books in progress."
- [x] **Favorites List:**
  - [x] Connect `Get Favorites` (`/home/favorites`) to populate the dashboard.
  - [x] Display user's favorite books.
- [x] **Total Progress Statistics:**
  - [x] Connect `Get Total Progress` (`/home/total-progress`) to display reading completion percentage for favorite books.
  - [x] Calculate percentage: `(completedBooks ÷ totalFavorites) × 100`.
  - [x] Handle case where there are no favorites (percentage = 0).

## 4. 🧹 Refactoring & Code Quality

- [x] **State Management:** Review and potentially refactor state management (e.g., using `bloc`/`cubit` consistently across all features) to handle new data flows and UI states.
- [x] **Error Handling:** Implement robust error handling across all API calls, mapping backend error messages to user-friendly messages as specified in `project_analysis.md`.
- [x] **UI/UX:** Ensure all new features and updated screens adhere to the existing design system and provide a consistent user experience.
- [x] **Code Structure:** Maintain a clean and modular code structure, following Flutter best practices (e.g., separation of concerns, DRY principle).

## 5. State Management Fix

### 5.1. Create BooksCubit for Library State Management
- [x] Create `lib/features/books/presentation/cubit/books_cubit.dart` with:
  - [x] Events: `LoadBooks`, `LoadMoreBooks`, `RefreshBooks`, `AddBook`, `EditBook`, `DeleteBook`, `ToggleFavorite`
  - [x] States: `BooksInitial`, `BooksLoading`, `BooksLoaded` (with books list, pagination info, loading states), `BooksError`
  - [x] Methods: `loadBooks()`, `loadMoreBooks()`, `refreshBooks()`, `addBook()`, `editBook()`, `deleteBook()`, `toggleFavorite()`
  - [x] Handle pagination with 10 books per page and infinite scroll
  - [x] Handle category filtering (All, sports, religion, horror, education, other)
  - [x] Integrate with `BooksRemoteRepository` for all CRUD operations
  - [x] Emit state changes that other screens can listen to

### 5.2. Create FavoritesCubit for Global Favorites Management
- [x] Create `lib/features/favorites/data/favorites_cubit.dart` with:
  - [x] Events: `LoadFavorites`, `AddToFavorites`, `RemoveFromFavorites`, `RefreshFavorites`
  - [x] States: `FavoritesInitial`, `FavoritesLoading`, `FavoritesLoaded` (with favorites list), `FavoritesError`
  - [x] Methods: `loadFavorites()`, `addToFavorites(bookId)`, `removeFromFavorites(bookId)`, `refreshFavorites()`
  - [x] Integrate with `FavoritesRemoteRepository`
  - [x] Emit state changes when favorites are added/removed so all screens update automatically

### 5.3. Create NotesCubit for Notes Management
- [x] Create `lib/features/notes/data/notes_cubit.dart` with:
  - [x] Events: `LoadBookNotes`, `AddNote`, `UpdateNote`, `DeleteNote`, `RefreshNotes`
  - [x] States: `NotesInitial`, `NotesLoading`, `NotesLoaded` (with notes list for a book), `NotesError`
  - [x] Methods: `loadBookNotes(bookId)`, `addNote(bookId, content)`, `updateNote(noteId, content)`, `deleteNote(noteId)`, `refreshNotes(bookId)`
  - [x] Integrate with `NotesRemoteRepository`
  - [x] Handle notes for specific books only (no global notes list)

### 5.4. Create ProfileCubit for User Profile Management
- [x] Create `lib/features/profile/data/profile_cubit.dart` with:
  - [x] Events: `LoadProfile`, `UpdateProfile`, `RefreshProfile`
  - [x] States: `ProfileInitial`, `ProfileLoading`, `ProfileLoaded` (with user data, book count, favorite count), `ProfileError`
  - [x] Methods: `loadProfile()`, `updateProfile()`, `refreshProfile()`
  - [x] Integrate with profile-related API endpoints
  - [x] Update profile data when books are added/deleted or favorites change

### 5.5. Update main.dart with Global BLoC Providers
- [x] Modify `lib/main.dart` to use `MultiBlocProvider` instead of single `BlocProvider`
- [x] Add providers for all new BLoCs:
  - [x] `BlocProvider(create: (context) => BooksCubit()..loadBooks())`
  - [x] `BlocProvider(create: (context) => FavoritesCubit()..loadFavorites())`
  - [x] `BlocProvider(create: (context) => NotesCubit())`
  - [x] `BlocProvider(create: (context) => ProfileCubit()..loadProfile())`
  - [x] Keep existing `AuthCubit` and `HomeCubit` providers
- [x] Ensure all BLoCs are initialized with their initial data loading

### 5.6. Convert LibraryScreen to Use BooksCubit
- [x] Remove all local state management from `LibraryScreen` (StatefulWidget, setState calls)
- [x] Convert to StatelessWidget that consumes `BooksCubit`
- [x] Use `BlocBuilder<BooksCubit, BooksState>` to rebuild UI based on state changes
- [x] Handle loading states, error states, and empty states through BLoC states
- [x] Implement pagination and infinite scroll through BLoC events
- [x] Category filtering should trigger `LoadBooks` event with category parameter
- [x] Favorite toggling should call `context.read<BooksCubit>().toggleFavorite(bookId)`
- [x] Add book and edit book actions should navigate and then trigger refresh on return

### 5.7. Convert BookDetailsPage to Use Global BLoCs
- [x] Remove local state management for book details, favorites, and notes
- [x] Use `BooksCubit` for book data and favorite toggling
- [x] Use `NotesCubit` for notes management (load, add, update, delete)
- [x] Use `BlocListener` to refresh data when returning from edit screen
- [x] Favorite toggle should use `context.read<FavoritesCubit>().addToFavorites()` or `removeFromFavorites()`
- [x] Notes operations should use `NotesCubit` methods
- [x] Ensure UI updates immediately when favorites or notes change

### 5.8. Update HomePage to Listen to Global State Changes
- [x] Modify `HomeCubit` to listen to changes from other BLoCs
- [x] Add methods to refresh home data when books/favorites change
- [x] Use `BlocListener` on `BooksCubit` and `FavoritesCubit` to trigger `HomeCubit.refreshHomeData()`
- [x] Ensure currently reading and favorites sections update automatically

### 5.9. Implement Cross-BLoC Communication
- [x] Add event emission when operations complete successfully:
  - [x] After adding book in `AddBookScreen` → emit `BooksAdded` event to `BooksCubit`
  - [x] After editing book → emit `BookUpdated` event to `BooksCubit`
  - [x] After deleting book → emit `BookDeleted` event to `BooksCubit`
  - [x] After toggling favorite → emit `FavoriteToggled` event to `FavoritesCubit` and `HomeCubit`
  - [x] After adding/updating/deleting notes → emit `NotesChanged` event to `NotesCubit`
- [x] Use `BlocListener` in relevant screens to react to these events and refresh data
- [x] Ensure all screens that display related data update automatically

### 5.10. Update AddBookScreen and EditBookScreen
- [x] After successful book creation/editing, emit events to notify other BLoCs
- [x] Navigate back and ensure parent screens refresh automatically
## 6. 🏗️ Clean Architecture Refactoring & Cleanup

- [x] **Feature-Level UI Decoupling:**
  - [x] `lib/features/home/presentation/screens/home_page.dart`: The home page is becoming a "God" widget. Extract `_ProgressCard`, `_WantToReadSection`, and `_FavoritesSection` into dedicated files under `lib/features/home/presentation/widgets/`.
  - [x] `lib/features/books/presentation/pages/book_details_page.dart`: This file contains too much logic and local state (`_BookDetailsViewState`). Extract `_BookInfoCard` and `_NotesSection` into separate widget files in `lib/features/books/presentation/widgets/`.
  - [x] `lib/features/library/presentation/pages/library_screen.dart`: Extract the category filter chip list and the delete confirmation dialog into standalone widgets.
- [ ] **Dependency & Repository Injection:**
  - [ ] Consolidate repository access: Many files currently import `lib/core/app_repositories.dart` and access global repositories directly. Refactor Cubits/Blocs to receive repositories via constructor injection for better testability.
- [ ] **Consolidated Widget Library:**
  - [ ] Move repetitive UI components (e.g., `_FieldLabel`, `_StyledTextField`, `_PickerTile` found in multiple files) into `lib/shared/widgets/` to ensure consistency and reduce code duplication.
- [ ] **State Management Cleanup:**
  - [ ] `lib/features/progress/presentation/bloc/reading_progress_bloc.dart` vs `..._cubit.dart`: The progress feature has duplicated/redundant files. Delete the redundant class and standardize on `Cubit`.
- [ ] **Code Organization:**
  - [ ] Verify that every `feature` folder strictly follows the pattern: `data/` (models, datasources, repositories), `presentation/` (cubit/bloc, pages, widgets).


