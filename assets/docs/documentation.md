# 📚 Bookify API Documentation

This document provides a detailed explanation of all available endpoints, including request formats, authentication requirements, validation rules, and expected responses.

The Bookify system allows users to manage their reading experience by organizing books, tracking progress, adding notes & highlights, and managing favorites.

---

## 📦 Base URL

http://13.219.191.61

---

# 🔐 Authentication APIs

This section provides endpoints responsible for user authentication inside the Bookify system.

Supported operations:

- Sign Up
- Sign In
- Logout

Authentication is handled using JWT tokens.

Authorization header format:

Authorization: bearer ACCESS_TOKEN

Example:

Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

---

# 📝 Sign Up

## Endpoint

POST /auth/signup

---

## Description

Creates a new user account inside the Bookify system.

The system:

- validates request body
- checks if email already exists
- hashes password using bcrypt
- stores user in database
- returns created user data

---

## Request Body

```json
{
  "firstName": "Ibrahim",
  "lastName": "Reda",
  "email": "ibrahimreda@gmail.com",
  "password": "12345678",
  "confirmPassword": "12345678",
  "bio": "Backend developer who loves reading books"
}
```

---

## Validation Rules

- firstName required (min 3 characters – max 25)
- lastName required (min 3 characters – max 25)
- email required and must be valid
- email must be unique
- password required (min 6 characters)
- confirmPassword must match password
- bio optional (max 150 characters)

---

## Success Response

Status: 201 Created

```json
{
  "message": "Sign Up Successfully Enjoy 🥳",
  "data": {
    "user": {
      "_id": "665fd12a9c7e4a0012c9d123",
      "firstName": "Ibrahim",
      "lastName": "Reda",
      "email": "ibrahimreda@gmail.com",
      "bio": "Backend developer who loves reading books",
      "createdAt": "2026-05-03T10:22:11.456Z",
      "updatedAt": "2026-05-03T10:22:11.456Z"
    }
  }
}
```

---

## Error Responses

400 → Please Fill The Form

400 → Confirm Password Must Match Password

409 → Email Already Exist

---

# 🔓 Sign In

## Endpoint

POST /auth/signin

---

## Description

Authenticates user using email and password.

The system:

- verifies email existence
- compares password using bcrypt
- generates JWT token
- returns access_token

---

## Request Body

```json
{
  "email": "ibrahimreda@gmail.com",
  "password": "12345678"
}
```

---

## Validation Rules

- email required and must be valid
- password required

---

## Success Response

Status: 200 OK

```json
{
  "message": "Sign In Successfully Enjoy 🥳",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ey..."
  }
}
```

---

## Error Responses

404 → User Not Found ❗

400 → Invalid Password ❗

---

# 🚪 Logout

## Endpoint

POST /auth/logout

---

## Description

Logs out authenticated user from Bookify system.

Supports logout from:

- current device only
- all devices

Implemented using Redis token revocation system.

---

## Authentication

Authorization header required:

Authorization: bearer ACCESS_TOKEN

Example:

Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

---

## Query Parameters

flag?: string

Possible values:

all → logs out from all devices

Example:

POST /auth/logout?flag=all

---

## Success Response

Status: 200 OK

```json
{
  "message": "Done"
}
```

---

## Error Responses

401 → Token is required

401 → Invalid authorization prefix

401 → Invalid token

401 → Invalid token user not found

403 → Invalid token session

403 →

Token revoked for this device

---

# 📚 Books APIs

This section provides endpoints for managing books inside the Bookify system.

Supported operations:

- Add Book
- Edit Book
- Get Book By ID
- Delete Book
- Get Books List

All endpoints in this section require authentication using JWT tokens.

Authorization header format:

Authorization: bearer ACCESS_TOKEN

Example:

Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

Supported book categories:

sports  
religion  
horror  
eduction  
other

---

# ➕ Add Book

## Endpoint

POST /books/add-book

---

## Description

Creates a new book for the authenticated user.

The system:

- uploads image to Cloudinary (optional)
- uploads PDF to Cloudinary (optional)
- extracts total pages automatically if PDF uploaded
- stores book inside database
- links book with authenticated user

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Request Body (form-data)

Fields:

title → book title

description → book description (optional)

totalPages → required if PDF not uploaded

category → book category (required)

image → image file (optional)

pdf → PDF file (optional)

Example:

title = Atomic Habits  
description = Practical guide to build good habits  
category = eduction  
totalPages = 320  
image = atomic-habits.png  
pdf = atomic-habits.pdf

---

## Validation Rules

- title required (min 3 characters – max 200)
- category required
- category must be one of:

sports  
religion  
horror  
eduction  
other

- totalPages required if PDF not uploaded
- image must be valid image file
- pdf must be valid PDF file

---

## Success Response

Status: 201 Created

```json
{
  "message": "Book Created Successfully 🥳🥳",
  "data": {
    "_id": "665fd12a9c7e4a0012c9d888",
    "title": "Atomic Habits",
    "description": "Practical guide to build good habits",
    "totalPages": 320,
    "category": "eduction",
    "image": {
      "secure_url": "https://res.cloudinary.com/bookify/images/atomic-habits.png",
      "public_id": "Bookify/Images/atomic-habits"
    },
    "pdf": {
      "secure_url": "https://res.cloudinary.com/bookify/pdfs/atomic-habits.pdf",
      "public_id": "Bookify/Pdfs/atomic-habits"
    },
    "createdBy": "665fd12a9c7e4a0012c9d123",
    "createdAt": "2026-05-03T12:30:10.200Z"
  }
}
```

---

## Error Responses

400 → Please Fill The Required Fields  
400 → Total Pages Is Required, Please Enter It ❗

---

# ✏️ Edit Book

## Endpoint

PATCH /books/edit-book/:id

---

## Description

Updates book fields created by the authenticated user.

Image and PDF cannot be modified after book creation.

---

## Authentication

Authorization: bearer ACCESS_TOKEN

---

## Path Parameters

:id → Book ID (MongoDB ObjectId of the book created by authenticated user)

Example:

PATCH /books/edit-book/665fd12a9c7e4a0012c9d888

---

## Request Body

```json
{
  "title": "Atomic Habits Updated",
  "category": "sports"
}
```

---

## Validation Rules

- at least one field required
- category must be one of:

sports  
religion  
horror  
eduction  
other

- cannot update image
- cannot update pdf
- cannot update totalPages if book already has PDF

---

## Success Response

Status: 200 OK

```json
{
  "message": "Book Updated Successfully 🥳🥳",
  "data": {
    "_id": "665fd12a9c7e4a0012c9d888",
    "title": "Atomic Habits Updated",
    "description": "Practical guide to build good habits",
    "totalPages": 320,
    "category": "sports"
  }
}
```

---

## Error Responses

404 → Book Is Not Exist ❗  
400 → PDF or Image cannot be updated after book creation ❗  
400 → Cannot update totalPages when book has PDF❗

---

# 📖 Get Book By ID

## Endpoint

GET /books/:id

---

## Description

Returns book details with:

- notes created by authenticated user on this book
- reading progress info
- favorite status

---

## Authentication

Authorization: bearer ACCESS_TOKEN

---

## Path Parameters

:id → Book ID (MongoDB ObjectId of the requested book)

Example:

GET /books/665fd12a9c7e4a0012c9d888

---

## Success Response

Status: 200 OK

```json
{
  "message": "Book Fetched Successfully 🥳🥳",
  "data": {
    "book": {
      "_id": "665fd12a9c7e4a0012c9d888",
      "title": "Atomic Habits",
      "totalPages": 320,
      "category": "eduction"
    },
    "notes": [
      {
        "_id": "665fd12a9c7e4a0012c9d999",
        "content": "Great explanation in chapter 3"
      }
    ],
    "progressInfo": {
      "percentage": 40,
      "currentPage": 128,
      "status": "reading"
    },
    "isFavorite": true
  }
}
```

---

## Error Responses

404 → Book Not Exist ❗

---

# 🗑 Delete Book

## Endpoint

DELETE /books/:id

---

## Description

Deletes book created by authenticated user.

Also deletes:

- progress records
- favorites
- notes
- image from Cloudinary
- pdf from Cloudinary

---

## Authentication

Authorization: bearer ACCESS_TOKEN

---

## Path Parameters

:id → Book ID (MongoDB ObjectId of the book created by authenticated user)

Example:

DELETE /books/665fd12a9c7e4a0012c9d888

---

## Success Response

Status: 200 OK

```json
{
  "message": "Book Deleted Successfully 🗑️"
}
```

---

## Error Responses

404 → Book Not Exist❗

---

# 📚 Get Books List

## Endpoint

GET /books

---

## Description

Returns paginated list of books created by authenticated user.

Supports filtering by category.

---

## Authentication

Authorization: bearer ACCESS_TOKEN

---

## Query Parameters

page → page number (default = 1)

limit → number of books per page (default = 10)

category → filter books by category

Allowed values:

sports  
religion  
horror  
eduction  
other

Example:

GET /books?page=1&limit=5&category=sports

---

## Success Response

Status: 200 OK

```json
{
  "message": "Books Fetched Successfully 🥳🥳",
  "data": [
    {
      "_id": "665fd12a9c7e4a0012c9d888",
      "title": "Atomic Habits",
      "totalPages": 320,
      "category": "eduction"
    },
    {
      "_id": "665fd12a9c7e4a0012c9d777",
      "title": "Football Basics",
      "totalPages": 210,
      "category": "sports"
    }
  ]
}
```

---

## Error Responses

404 → Books Not Found

---

# ❤️ Favorites APIs

This section provides endpoints for managing favorite books inside the Bookify system.

Supported operations:

- Add Book To Favorites
- Remove Book From Favorites

All endpoints require authentication using JWT tokens.

Authorization header format:

Authorization: bearer ACCESS_TOKEN

Example:

Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

---

# ➕ Add Book To Favorites

## Endpoint

POST /favorites/add-to-favorites/:bookId

---

## Description

Adds a book to the authenticated user's favorites list.

The system:

- verifies book exists
- creates favorite record
- links book with authenticated user
- prevents duplicate favorites using unique index

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Path Parameters

:bookId → Book ID (MongoDB ObjectId of the book to be added to favorites)

Example:

POST /favorites/add-to-favorites/665fd12a9c7e4a0012c9d888

---

## Success Response

Status: 201 Created

```json
{
  "message": "Added To Favorites Successfully ❤️",
  "data": {
    "_id": "665fd12a9c7e4a0012c9d555",
    "userId": "665fd12a9c7e4a0012c9d123",
    "bookId": "665fd12a9c7e4a0012c9d888",
    "createdAt": "2026-05-03T14:10:22.300Z",
    "updatedAt": "2026-05-03T14:10:22.300Z"
  }
}
```

---

## Error Responses

400 → Book Not Exist ❗  
409 → Favorite Already Exists (Duplicate favorite not allowed)

---

# 🗑 Remove Book From Favorites

## Endpoint

DELETE /favorites/remove-from-favorites/:bookId

---

## Description

Removes a book from the authenticated user's favorites list.

The system:

- verifies book exists
- verifies favorite record exists
- deletes favorite record from database

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Path Parameters

:bookId → Book ID (MongoDB ObjectId of the book to be removed from favorites)

Example:

DELETE /favorites/remove-from-favorites/665fd12a9c7e4a0012c9d888

---

## Success Response

Status: 200 OK

```json
{
  "message": "Book Removed Successfully From Favorites 🗑️"
}
```

---

## Error Responses

404 → Book Not Exist ❗  
404 → Favorite Not Found ❗

---

# 📊 Progress APIs

This section provides endpoints for tracking reading progress inside the Bookify system.

Supported operations:

- Start Reading Progress
- Update Reading Progress

Progress status values:

reading  
completed

All endpoints require authentication using JWT tokens.

Authorization header format:

Authorization: bearer ACCESS_TOKEN

Example:

Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

---

# 📖 Start Reading Progress

## Endpoint

POST /progress/create-progress/:bookId

---

## Description

Creates a reading progress record for the authenticated user on a specific book.

The system:

- verifies bookId exists in params
- creates progress record
- links progress with authenticated user
- sets default status = reading
- sets default currentPage = 0

Each user can create only one progress record per book.

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Path Parameters

:bookId → Book ID (MongoDB ObjectId of the book the user starts reading)

Example:

POST /progress/create-progress/665fd12a9c7e4a0012c9d888

---

## Success Response

Status: 201 Created

```json
{
  "message": "Reading Started 📖",
  "data": {
    "_id": "665fd12a9c7e4a0012c9d321",
    "userId": "665fd12a9c7e4a0012c9d123",
    "bookId": "665fd12a9c7e4a0012c9d888",
    "currentPage": 0,
    "status": "reading",
    "createdAt": "2026-05-03T15:20:10.220Z",
    "updatedAt": "2026-05-03T15:20:10.220Z"
  }
}
```

---

## Error Responses

400 → Book Id Is Required In Params ❗  
409 → Progress Already Exists For This Book

---

# ✏️ Update Reading Progress

## Endpoint

PATCH /progress/update-progress/:bookId

---

## Description

Updates reading progress for a specific book.

The system:

- verifies progress exists
- updates currentPage
- calculates percentage automatically
- updates status depending on progress

Status logic:

if currentPage >= totalPages → completed  
otherwise → reading

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Path Parameters

:bookId → Book ID (MongoDB ObjectId of the book whose progress is being updated)

Example:

PATCH /progress/update-progress/665fd12a9c7e4a0012c9d888

---

## Request Body

```json
{
  "currentPage": 120
}
```

---

## Validation Rules

- currentPage required
- currentPage must be number
- bookId required in params

---

## Success Response

Status: 200 OK

```json
{
  "message": "Progress Updated Successfully 🥳🥳",
  "data": {
    "progress": {
      "_id": "665fd12a9c7e4a0012c9d321",
      "userId": "665fd12a9c7e4a0012c9d123",
      "bookId": {
        "_id": "665fd12a9c7e4a0012c9d888",
        "title": "Atomic Habits",
        "description": "Practical guide to build good habits",
        "totalPages": 320,
        "category": "eduction"
      },
      "currentPage": 120,
      "status": "reading"
    },
    "percentage": 38
  }
}
```

---

## Error Responses

400 → Current Page Is Required❗  
400 → Body Is Required❗  
400 → Book Id Is Required In Params ❗  
404 → Progress Not Found ❗

---

# 🏠 Home APIs

This section provides dashboard endpoints for retrieving reading activity summaries inside the Bookify system.

Supported operations:

- Get Favorites Reading Progress
- Get Favorites Books List
- Get Currently Reading Books

All endpoints require authentication using JWT tokens.

Authorization header format:

Authorization: bearer ACCESS_TOKEN

Example:

Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

---

# 📊 Get Favorites Progress Statistics

## Endpoint

GET /home/total-progress

---

## Description

Returns reading progress statistics for books added to the user's favorites list.

The system:

- retrieves all favorite books
- checks how many are completed
- calculates completion percentage

Formula:

percentage = (completedBooks ÷ totalFavorites) × 100

If no favorite books exist → percentage = 0

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Success Response

Status: 200 OK

```json
{
  "message": "Total Progress Fetched Successfully 🥳🥳",
  "data": {
    "completed": 3,
    "totalFavorites": 8,
    "percentage": 38
  }
}
```

---

## Error Responses

401 → Token is required  
401 → Invalid authorization prefix  
401 → Invalid token  
403 → Token revoked for this device

---

# ❤️ Get Favorites Books

## Endpoint

GET /home/favorites

---

## Description

Returns all books added to the authenticated user's favorites list.

The system:

- retrieves favorite records
- populates book details
- returns books array
- returns favorites count

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Success Response

Status: 200 OK

```json
{
  "message": "Favorites Retrieved Successfully 📚",
  "data": {
    "favoritesCount": 2,
    "favorites": [
      {
        "_id": "665fd12a9c7e4a0012c9d888",
        "title": "Atomic Habits",
        "description": "Practical guide to build good habits",
        "totalPages": 320,
        "category": "eduction",
        "image": {
          "secure_url": "https://res.cloudinary.com/bookify/images/atomic.png",
          "public_id": "Bookify/Images/atomic"
        }
      },
      {
        "_id": "665fd12a9c7e4a0012c9d777",
        "title": "Football Basics",
        "description": "Learn football fundamentals",
        "totalPages": 210,
        "category": "sports"
      }
    ]
  }
}
```

---

## Error Responses

401 → Token is required  
401 → Invalid authorization prefix  
401 → Invalid token  
403 → Token revoked for this device

---

# 📖 Get Currently Reading Books

## Endpoint

GET /home/currently-reading

---

## Description

Returns books currently being read by the authenticated user.

The system:

- retrieves progress records where status = reading
- calculates reading percentage for each book
- returns pages progress in format:

currentPage / totalPages

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Success Response

Status: 200 OK

```json
{
  "message": "Recently Reading Books Fetched Successfully 🥳🥳",
  "data": [
    {
      "book": {
        "_id": "665fd12a9c7e4a0012c9d888",
        "title": "Atomic Habits",
        "totalPages": 320,
        "category": "eduction"
      },
      "pages": "120 / 320",
      "percentage": 38
    },
    {
      "book": {
        "_id": "665fd12a9c7e4a0012c9d777",
        "title": "Football Basics",
        "totalPages": 210,
        "category": "sports"
      },
      "pages": "50 / 210",
      "percentage": 24
    }
  ]
}
```

---

## Error Responses

401 → Token is required  
401 → Invalid authorization prefix  
401 → Invalid token  
403 → Token revoked for this device

---

# 📝 Notes APIs

This section provides endpoints for managing notes on books inside the Bookify system.

Supported operations:

- Add Note To Book
- Update Note
- Delete Note

Each note is linked with:

- authenticated user
- specific book

All endpoints require authentication using JWT tokens.

Authorization header format:

Authorization: bearer ACCESS_TOKEN

Example:

Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

---

# ➕ Add Note

## Endpoint

POST /note/add-note/:bookId

---

## Description

Creates a note for a specific book belonging to the authenticated user.

The system:

- validates bookId from params
- validates content from body
- links note with authenticated user
- links note with selected book
- stores note in database

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Path Parameters

:bookId → Book ID (MongoDB ObjectId of the book the note will be attached to)

Example:

POST /note/add-note/665fd12a9c7e4a0012c9d888

---

## Request Body

```json
{
  "content": "Important concept explained in chapter 2"
}
```

---

## Validation Rules

- content required
- content must be valid string
- bookId required in params

---

## Success Response

Status: 201 Created

```json
{
  "message": "Note Created Successfully !",
  "data": {
    "_id": "665fd12a9c7e4a0012c9d555",
    "userId": "665fd12a9c7e4a0012c9d123",
    "bookId": "665fd12a9c7e4a0012c9d888",
    "content": "Important concept explained in chapter 2",
    "createdAt": "2026-05-03T17:10:20.200Z",
    "updatedAt": "2026-05-03T17:10:20.200Z"
  }
}
```

---

## Error Responses

400 → Please Fill The Required Fields  
400 → Book Id Is Required In Params ❗

---

# ✏️ Update Note

## Endpoint

PATCH /note/update-note/:id

---

## Description

Updates content of an existing note belonging to the authenticated user.

The system:

- verifies note exists
- verifies note belongs to authenticated user
- updates note content

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Path Parameters

:id → Note ID (MongoDB ObjectId of the note to be updated)

Example:

PATCH /note/update-note/665fd12a9c7e4a0012c9d555

---

## Request Body

```json
{
  "content": "Updated explanation after reviewing chapter 2 again"
}
```

---

## Validation Rules

- content required
- at least one field required
- note must belong to authenticated user

---

## Success Response

Status: 200 OK

```json
{
  "message": "Note Updated Successfully 🥳🥳",
  "data": {
    "_id": "665fd12a9c7e4a0012c9d555",
    "userId": "665fd12a9c7e4a0012c9d123",
    "bookId": "665fd12a9c7e4a0012c9d888",
    "content": "Updated explanation after reviewing chapter 2 again",
    "updatedAt": "2026-05-03T17:25:10.120Z"
  }
}
```

---

## Error Responses

400 → Please Fill The Required Fields  
404 → Note Not Found !

---

# 🗑 Delete Note

## Endpoint

DELETE /note/delete-note/:id

---

## Description

Deletes an existing note from database.

The system:

- verifies note exists
- deletes note permanently

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Path Parameters

:id → Note ID (MongoDB ObjectId of the note to be deleted)

Example:

DELETE /note/delete-note/665fd12a9c7e4a0012c9d555

---

## Success Response

Status: 200 OK

```json
{
  "message": "Note Deleted Successfully 🥳🥳"
}
```

---

## Error Responses

404 → Note Is Not Exist ❗

---

# 👤 Users APIs

This section provides endpoints for managing authenticated user profile inside the Bookify system.

Supported operations:

- Get Profile
- Update Profile
- Delete Profile

All endpoints require authentication using JWT tokens.

Authorization header format:

Authorization: bearer ACCESS_TOKEN

Example:

Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

---

# 📄 Get Profile

## Endpoint

GET /users/profile

---

## Description

Returns authenticated user profile information.

The system:

- retrieves user data from decoded token
- excludes password from response
- counts number of books created by user
- counts number of favorite books

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Success Response

Status: 200 OK

```json
{
  "message": "User Profile",
  "data": {
    "user": {
      "_id": "665fd12a9c7e4a0012c9d123",
      "firstName": "Ibrahim",
      "lastName": "Reda",
      "email": "ibrahimreda@gmail.com",
      "bio": "Backend developer who loves reading books",
      "createdAt": "2026-05-03T10:22:11.456Z",
      "updatedAt": "2026-05-03T10:22:11.456Z"
    },
    "favoriteCount": 4,
    "bookCount": 7
  }
}
```

---

## Error Responses

401 → Token is required  
401 → Invalid authorization prefix  
401 → Invalid token  
403 → Token revoked for this device

---

# ✏️ Update Profile

## Endpoint

PATCH /users/update-profile

---

## Description

Updates authenticated user profile information.

Allowed fields:

- firstName
- lastName
- bio

At least one field must be provided.

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Request Body

```json
{
  "firstName": "Ibrahim",
  "bio": "Backend developer specialized in Node.js and MongoDB"
}
```

---

## Validation Rules

- at least one field required
- firstName min 3 characters – max 25
- lastName min 3 characters – max 25
- bio max 150 characters

---

## Success Response

Status: 200 OK

```json
{
  "message": "User Updated Successfully",
  "data": {
    "_id": "665fd12a9c7e4a0012c9d123",
    "firstName": "Ibrahim",
    "lastName": "Reda",
    "email": "ibrahimreda@gmail.com",
    "bio": "Backend developer specialized in Node.js and MongoDB",
    "updatedAt": "2026-05-03T18:20:11.210Z"
  }
}
```

---

## Error Responses

400 → At least one field must be provided  
404 → User Not Exist

---

# 🗑 Delete Profile

## Endpoint

DELETE /users/delete-profile

---

## Description

Deletes authenticated user account permanently.

Cascade deletion removes:

- all books created by user
- all favorites
- all notes
- user account

---

## Authentication

Required header:

Authorization: bearer ACCESS_TOKEN

---

## Success Response

Status: 200 OK

```json
{
  "message": "User Deleted Successfully🥳🥳"
}
```

---

## Error Responses

401 → Token is required  
401 → Invalid authorization prefix  
401 → Invalid token  
403 → Token revoked for this device
