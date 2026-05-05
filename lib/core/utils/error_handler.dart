import 'package:flutter/material.dart';
import '../network/api_exception.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return _mapApiErrorToUserMessage(error);
    } else if (error is Exception) {
      return 'Something went wrong. Please try again.';
    } else {
      return 'An unexpected error occurred.';
    }
  }

  static String _mapApiErrorToUserMessage(ApiException error) {
    // Check for specific authentication issues first
    if (error.message.toLowerCase().contains('access token is missing')) {
      return 'Please log in to access this feature.';
    }

    switch (error.statusCode) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'You need to be logged in to perform this action.';
      case 403:
        return 'You don\'t have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 422:
        return 'Invalid data provided. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        if (error.message.toLowerCase().contains('network') ||
            error.message.toLowerCase().contains('connection')) {
          return 'Network error. Please check your internet connection.';
        } else if (error.message.toLowerCase().contains('timeout')) {
          return 'Request timed out. Please try again.';
        } else if (error.message.toLowerCase().contains('already exists') ||
            error.message.toLowerCase().contains('duplicate')) {
          return 'This item already exists.';
        } else if (error.message.toLowerCase().contains('not found')) {
          return 'The requested item was not found.';
        } else if (error.message.toLowerCase().contains('invalid') ||
            error.message.toLowerCase().contains('validation')) {
          return 'Invalid information provided. Please check your input.';
        } else {
          return error.message.isNotEmpty
              ? error.message
              : 'Something went wrong. Please try again.';
        }
    }
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static bool isNetworkError(dynamic error) {
    if (error is ApiException) {
      return error.message.toLowerCase().contains('network') ||
          error.message.toLowerCase().contains('connection') ||
          error.message.toLowerCase().contains('timeout');
    }
    return false;
  }

  static bool isAuthError(dynamic error) {
    if (error is ApiException) {
      return error.statusCode == 401 || error.statusCode == 403;
    }
    return false;
  }

  static bool isServerError(dynamic error) {
    if (error is ApiException) {
      return error.statusCode != null && error.statusCode! >= 500;
    }
    return false;
  }
}
