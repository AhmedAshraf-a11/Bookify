# 📚 Bookify Mobile App - Project Analysis

## Business Logic & Feature Specifications

**Version:** 1.0  
**Last Updated:** 2026-05-04  
**Purpose:** This document describes WHAT the app should do, not HOW to implement it. Implementation details are left to the developer.

---

## 🎯 Product Vision

Bookify is a **private digital library** where users can upload their own PDF books, read them inside the app, track reading progress automatically, add notes, organize by categories, and manage favorites. Each user has their own isolated library — no sharing, no social features.

---

## 👤 Authentication Module

### Sign Up

**Business Rules:**
- User must provide firstName, lastName, email, password, confirmPassword
- Bio field is optional (max 150 characters)
- Password must be at least 6 characters
- First name and last name: min 3 characters, max 25 characters
- Email must be unique in the system
- Password and confirmPassword must match exactly

**Success Outcome:**
- User account is created
- User is NOT automatically signed in (must call sign in separately)

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| Email already exists | Show error: "Email already registered" |
| Passwords don't match | Show error: "Passwords do not match" |
| Missing required field | Show error: "Please fill all required fields" |
| Network failure | Show error: "No internet connection. Please try again." |

---

### Sign In

**Business Rules:**
- User must provide email and password
- Email must exist in the system
- Password must match the stored hashed password

**Success Outcome:**
- JWT access token is returned
- Token must be stored securely on device
- User is redirected to Library screen

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| Email not found | Show error: "No account found with this email" |
| Wrong password | Show error: "Incorrect password" |
| Account was deleted | Show error: "Account no longer exists" |

---

### Logout

**Business Rules:**
- User must be authenticated
- Token must be valid and not revoked

**Two Logout Modes:**
| Mode | Behavior |
|------|----------|
| Current device only | Only this session is invalidated |
| All devices | All sessions for this user are invalidated |

**Success Outcome:**
- Token is revoked on backend
- Local token is deleted
- User is redirected to Sign In screen

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| Token already expired | Still logout locally, show "Session already expired" |
| Network error during logout | Delete local token anyway, user can reconnect later |

---

## 📚 Library Module (Home Screen)

### Display Books List

**Business Rules:**
- Shows ONLY books uploaded by the authenticated user
- Each book card displays: title, category, cover image (if exists), reading progress percentage
- Results are paginated (10 books per page)
- Infinite scroll: load more when reaching bottom

**Filtering:**
- User can filter by category
- Available categories: sports, religion, horror, education, other
- Filter resets page to 1

**Sorting:**
- NOT required (removed from scope)

**Success Outcome:**
- Grid or list of books is displayed
- Empty state shown if user has no books

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| User has 0 books | Show "No books yet. Tap + to add your first book" |
| Network error while loading | Show error message with retry button |
| Category has 0 books | Show "No books in this category" |
| Last page reached | No more loading indicator |

---

### Add New Book

**Business Rules:**
- User must provide: title, category, PDF file
- User can optionally provide: cover image, description
- Category must be one of the fixed list
- Title: min 3 characters, max 200 characters
- Description: max 500 characters (optional)
- PDF file is uploaded to Cloudinary
- Backend automatically extracts total pages from PDF
- Cover image (if provided) is uploaded to Cloudinary

**Success Flow:**
1. User fills form and selects PDF
2. App uploads to backend
3. Backend creates book record
4. **CRITICAL:** After book is created, app must call "Create Progress" endpoint
5. User sees success message and is taken to Library screen

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| PDF upload fails | Show error, keep form data, allow retry |
| PDF is corrupted | Backend may return totalPages=null, still create book |
| Network fails during upload | Show error, user must retry |
| No PDF selected | Disable submit button |
| Title already exists | Allowed (user can have duplicate titles) |

---

### Edit Book

**Business Rules:**
- User can ONLY edit books they created
- Editable fields: title, category, description
- NOT editable: PDF file, cover image, totalPages
- At least one field must be provided for update
- Category must remain in fixed list

**Success Outcome:**
- Book is updated in database
- User returns to Book Detail screen with updated info

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| User tries to edit someone else's book | Should not be possible (API returns 403) |
| No changes submitted | Disable save button or show "No changes" error |
| Network error | Show error, keep user on edit screen |

---

### Delete Book

**Business Rules:**
- User can ONLY delete books they created
- Deletion is PERMANENT and CASCADE
- Automatically deletes: book record, associated notes, progress records, favorites, Cloudinary images, Cloudinary PDFs

**Success Outcome:**
- Book disappears from Library screen
- User sees confirmation message

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| User tries to delete someone else's book | Should not be possible |
| Delete during network failure | Show error, don't remove from UI until confirmed |
| User accidentally deletes | Add confirmation dialog before deletion |

---

### Get Single Book (Detail Screen)

**Business Rules:**
- Fetches complete book information including:
  - Book metadata (title, category, totalPages, description, cover)
  - User's notes for this book (list)
  - Reading progress (currentPage, percentage, status)
  - Whether book is favorited (true/false)
- Anyone can view any book (but books are private, so only user's own books appear)

**Success Outcome:**
- Book detail screen displays all information

---

## 📖 Progress Tracking Module

### Create Progress Record

**Business Rule:**
- **MUST** be called immediately after a book is successfully added
- Each user can have only ONE progress record per book
- Initial values: currentPage = 0, status = "reading"

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| Progress already exists | API returns 409 conflict, ignore and continue |
| Book ID doesn't exist | Show error, but book was just created so shouldn't happen |

---

### Update Reading Progress

**Business Rules:**
- User reads PDF using in-app PDF viewer
- App tracks current page number from PDF viewer
- When user reaches a new page, progress is updated
- Update frequency: debounced (not on EVERY page turn)
- Suggested: update when user pauses reading OR every 30 seconds OR on close

**Validation Rules (Backend):**
- currentPage cannot exceed totalPages of book
- currentPage cannot be negative
- currentPage must be a number

**Status Logic (Backend):**
| Condition | Status |
|-----------|--------|
| currentPage < totalPages | "reading" |
| currentPage >= totalPages | "completed" |

**Success Outcome:**
- Reading progress is saved to backend
- Percentage is automatically calculated
- Book appears in "Currently Reading" list

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| User reads past totalPages | Cap at totalPages when updating |
| User goes back pages | Still update (backend allows going back) |
| No internet when updating | Queue update for when online OR skip and update later |
| User finishes book | Status changes to "completed" automatically |

---

### Currently Reading List (Dashboard)

**Business Rules:**
- Shows all books where progress status = "reading"
- For each book shows: title, progress percentage, currentPage/totalPages
- Ordered by most recently updated

**Success Outcome:**
- User sees all in-progress books

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| No reading books | Show empty state: "No books in progress" |
| Book was just completed | Disappears from this list (shows in completed) |

---

### Total Progress Statistics (Dashboard)

**Business Rules:**
- Shows statistics for books in user's favorites list
- Returns: totalFavorites count, completed count, percentage
- Formula: percentage = (completedBooks ÷ totalFavorites) × 100
- If no favorites: percentage = 0

**Success Outcome:**
- User sees reading completion percentage for favorite books only

---

## ❤️ Favorites Module

### Add to Favorites

**Business Rules:**
- User can favorite any book in their library
- One favorite per user per book (no duplicates)
- Favorite status is visible on book card and detail screen

**Success Outcome:**
- Book appears in Favorites list
- Heart icon becomes filled

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| Book already favorited | Show "Already in favorites" or ignore API error |
| Network error | Show error, UI should not toggle optimistically |

---

### Remove from Favorites

**Business Rules:**
- User can remove any book from favorites
- Does NOT delete the book itself

**Success Outcome:**
- Book disappears from Favorites list
- Heart icon becomes outline

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| Book not in favorites | Show error or ignore |
| Network error | Show error, UI should revert |

---

### Favorites List (Dashboard)

**Business Rules:**
- Shows all books user has favorited
- Includes full book details (title, category, cover)
- Shows count of favorites

**Success Outcome:**
- User sees all favorite books

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| No favorites | Show empty state |

---

## 📝 Notes Module

### Add Note to Book

**Business Rules:**
- User can add multiple notes to the same book (list, not single)
- Each note has: content (string), createdAt timestamp
- Note is linked to specific book and specific user

**Success Outcome:**
- Note appears in book's notes list

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| Empty note content | Disable submit button |
| Very long note (1000+ chars) | Should be allowed (no documented limit) |

---

### Update Note

**Business Rules:**
- User can edit only their own notes
- Note content can be completely changed

**Success Outcome:**
- Note content is updated

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| Note doesn't belong to user | Should not be possible (API returns 404) |
| Empty content after edit | Allow? (API accepts empty strings) |

---

### Delete Note

**Business Rules:**
- User can delete only their own notes
- Deletion is permanent

**Success Outcome:**
- Note disappears from book's notes list

---

### View Notes (on Book Detail)

**Business Rules:**
- Notes are fetched via GET /books/:id endpoint (not separate endpoint)
- Notes display in chronological order (oldest first or newest first — decide)

**Success Outcome:**
- User sees all notes for the book

---

## 👤 Profile Module

### View Profile

**Business Rules:**
- Shows user information: firstName, lastName, email, bio (if exists)
- Shows statistics: total books uploaded, total favorites

**Success Outcome:**
- Profile screen displays user data

---

### Update Profile

**Business Rules:**
- Editable fields: firstName, lastName, bio
- At least one field must be changed
- Same validation as signup (min/max lengths)

**Success Outcome:**
- Profile is updated

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| No changes submitted | Disable save button |
| Bio exceeds 150 chars | Show validation error before submission |

---

### Delete Account

**Business Rules:**
- Deletion is PERMANENT
- Cascades to: all user's books, all notes, all favorites, all progress records
- Deletes Cloudinary files (images and PDFs)

**Important:** After deletion, any existing JWT tokens will still exist but will fail on any API call

**Success Outcome:**
- Account is deleted
- Local token is cleared
- User is redirected to Sign Up screen

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| User deletes by accident | Add confirmation dialog with warning text |
| Network error during deletion | Show error, account may be partially deleted |

---

## 📄 PDF Viewer Module

### Open PDF

**Business Rules:**
- PDF is loaded from Cloudinary URL (from book record)
- User must be authenticated
- PDF viewer displays the actual book content

**Success Outcome:**
- PDF opens and user can read

---

### Restore Last Reading Position

**Business Rules:**
- When PDF opens, app must fetch current progress from backend
- PDF viewer jumps to saved currentPage
- If no progress exists (shouldn't happen), start at page 1

**Success Outcome:**
- User continues reading from where they left off

---

### Track Reading Progress (Local → Backend)

**Business Rules:**
- PDF viewer provides current page number
- App detects when page changes
- App sends update to backend (debounced to avoid too many requests)
- Recommended triggers for update:
  - User pauses reading (app background)
  - User closes PDF viewer
  - Every 30 seconds of reading
  - After 5 consecutive page turns without update

**Success Outcome:**
- Backend progress stays in sync with user's reading

**Edge Cases:**
| Scenario | Expected Behavior |
|----------|-------------------|
| User rapidly flips pages | Don't update on every page (debounce) |
| No internet while reading | Queue updates locally, sync when online |
| User jumps to specific page using slider | Update progress to that page |
| App crashes mid-read | Last saved progress is preserved |

---

### Offline Reading (Optional Feature)

If implemented:

**Business Rules:**
- User can download PDF to device storage
- Downloaded PDFs can be read without internet
- App tracks progress locally when offline
- When back online, sync progress to backend
- User can delete downloaded PDF to free space

---

## 🏠 Dashboard / Home Screen

### Components to Display

The dashboard/home screen should show:

| Component | Source Endpoint |
|-----------|-----------------|
| Currently reading books | GET /home/currently-reading |
| Favorites list | GET /home/favorites |
| Total progress stats | GET /home/total-progress |

**Success Outcome:**
- User sees reading summary at a glance

---

## 🎨 UI/UX Requirements

### Loading States
| Element | Loading Indicator |
|---------|-------------------|
| Full screen | Centered circular progress indicator |
| List loading | Shimmer effect OR loading skeleton cards |
| Button action | Disabled button with loading spinner inside |

### Empty States
| Screen | Empty Message |
|--------|---------------|
| Library (no books) | "Your library is empty. Tap + to add your first book" |
| Favorites | "No favorites yet. Heart a book to see it here" |
| Currently Reading | "No books in progress. Start reading a book!" |
| Notes (on a book) | "No notes yet. Tap + to add your first note" |

### Error Messages
All errors must be user-friendly:

| Technical Error | User Message |
|----------------|--------------|
| SocketException | "No internet connection. Please check your network." |
| TimeoutException | "Request took too long. Please try again." |
| 401 Unauthorized | "Session expired. Please sign in again." |
| 403 Forbidden | "You don't have permission to do this." |
| 404 Not Found | "The requested content was not found." |
| 500 Server Error | "Something went wrong on our end. Please try later." |
| Any other | "Something went wrong. Please try again." |

### Confirmation Dialogs
| Action | Dialog Text |
|--------|-------------|
| Delete book | "Delete this book? This will also delete all notes and progress. This cannot be undone." |
| Delete account | "Delete your account? This will permanently delete all your books, notes, and favorites. This cannot be undone." |
| Logout | "Are you sure you want to log out?" |

---

## 🔄 Critical Flows (Step by Step)

### Flow 1: New User Onboarding
1. User opens app → sees Sign Up screen
2. User fills form → taps Sign Up
3. App calls signup API
4. On success: automatically navigate to Sign In screen (or show success message)
5. User signs in with email/password
6. App stores token
7. User sees empty Library screen with "+" button

### Flow 2: Adding First Book
1. User taps "+" button
2. User fills: title, selects category, optionally adds description
3. User picks cover image (optional)
4. User picks PDF file (required)
5. User taps Submit
6. App uploads to backend
7. On success: **IMMEDIATELY call Create Progress**
8. Navigate to Library screen
9. New book appears in library

### Flow 3: Reading a Book
1. User taps on book from Library
2. Book Detail screen opens (shows metadata, notes, progress)
3. User taps "Read Book" button
4. PDF Viewer opens
5. PDF Viewer fetches saved progress from backend
6. Viewer jumps to saved page
7. User reads
8. App tracks page changes (debounced)
9. App updates progress to backend
10. User closes viewer → returns to Book Detail
11. Book Detail shows updated progress percentage

### Flow 4: Adding a Note
1. User on Book Detail screen
2. User taps "Add Note" button
3. Dialog or new screen opens with text field
4. User enters note content
5. User taps Save
6. App calls Add Note API
7. On success: refresh notes list
8. New note appears

---

## 🗂️ Category Definitions

| Category Value | Display Name (UI) |
|----------------|-------------------|
| sports | Sports |
| religion | Religion |
| horror | Horror |
| education | Education |
| other | Other |

**Note:** Backend uses lowercase values exactly as above. Frontend must map to display names.

---

## 🔐 Authentication State Management Rules

| User State | Expected Behavior |
|------------|-------------------|
| Not signed in & not signed up | Show Sign In screen |
| Signed in & token valid | Show Library screen |
| Signed in but token expired | Show Sign In screen with "Session expired" message |
| Token revoked by logout elsewhere | Next API call fails → show Sign In screen |

---

## 📡 API Error Handling Map

Map backend errors to user-facing messages:

| Backend Message | User Message |
|----------------|--------------|
| "Email Already Exist" | "This email is already registered" |
| "Confirm Password Must Match Password" | "Passwords do not match" |
| "User Not Found" | "No account found with this email" |
| "Invalid Password" | "Incorrect password" |
| "Token is required" | "Session expired. Please sign in again." |
| "Invalid token" | "Session expired. Please sign in again." |
| "Token revoked for this device" | "You have been logged out" |
| "Book Not Exist" | "Book not found" |
| "Favorite Already Exists" | "Book is already in favorites" |
| "Favorite Not Found" | "Book not found in favorites" |
| "Progress Already Exists For This Book" | Ignore (silent failure, continue app) |
| "Progress Not Found" | "No progress record found. Please restart reading." |

---

## ✅ Feature Completion Checklist

| Feature | Status |
|---------|--------|
| Sign Up | Required |
| Sign In | Required |
| Logout (current device) | Required |
| Logout (all devices) | Required |
| Add book with PDF | Required |
| Add optional cover image | Required |
| Auto-extract PDF pages | Backend handles |
| Edit book (title, category, description) | Required |
| Delete book | Required |
| View library (paginated) | Required |
| Filter by category | Required |
| View single book details | Required |
| Create progress on book add | Required |
| Update reading progress | Required |
| View currently reading books | Required |
| View favorites list | Required |
| View favorites progress stats | Required |
| Add to favorites | Required |
| Remove from favorites | Required |
| Add note to book | Required |
| Update note | Required |
| Delete note | Required |
| View profile | Required |
| Update profile | Required |
| Delete account | Required |
| PDF viewer with page tracking | Required |
| Restore last reading position | Required |
| Offline PDF access | Optional |
| Search books | NOT required |

---

## 📌 Document Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-04 | Initial analysis, all features documented |

---

**End of Project Analysis**