# bookify

A feature-rich Flutter application designed for book management.

## Project Structure
The project follows a feature-first architectural pattern, organizing code by business features rather than layers.
- `lib/`: Root directory for application source code.
  - `core/`: Global utilities, network client, routing, themes, and repositories.
  - `features/`: Business-logic grouped by modules (e.g., `auth`, `books`, `home`, `profile`).
  - `shared/`: Reusable UI components and widgets.
  - `styles/`: Shared theme and style definitions.
- `assets/`: Static resources including images, icons, and documentation.

## Architecture
- **Feature-first:** Code is encapsulated within feature modules to improve maintainability and scalability.
- **Data Layer:** Centralized in `lib/core` with an `ApiClient` wrapper around `Dio` to manage API requests and authentication headers.
- **Repository Pattern:** Used to abstract data sources, providing a clean API to the BLoC layer.

## API Endpoints Handling
API communication is managed by a custom `ApiClient` in `lib/core/network/api_client.dart`.
- Uses **Dio** for HTTP requests.
- Implements **JWT-based authentication** using `AuthSession` to inject `Authorization` headers.
- Standardizes error handling through an `ApiException` class to map network errors to readable messages.
- Supports `multipart/form-data` for file uploads (e.g., book covers or PDF files).

## State Management
- **Cubit:** Chosen for robust, event-driven state management, separating business logic from UI. Uses `flutter_bloc` and `bloc` packages.

## Dependencies
- **bloc / flutter_bloc**: State management.
- **dio**: HTTP client for API networking.
- **equatable**: Simplifies object equality checks for BLoC states/events.
- **file_picker**: Selecting local files.
- **flutter_screenutil**: Responsive UI design and scaling.
- **flutter_secure_storage**: Securely storing sensitive data (e.g., auth tokens).
- **flutter_svg**: Rendering SVG assets.
- **go_router**: Declarative routing and deep linking.
- **syncfusion_flutter_pdfviewer**: PDF file viewing capabilities.
