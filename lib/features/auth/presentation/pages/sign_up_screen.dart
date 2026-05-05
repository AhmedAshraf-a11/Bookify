import 'package:bookify/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/auth_header.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false; // State to manage loading indicator

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onSignUp() async {
    if (_isLoading) return; // Prevent multiple taps when loading

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true); // Show loading indicator

      // Get values from controllers
      final String firstName = _firstNameController.text.trim();
      final String lastName = _lastNameController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String bio = _bioController.text.trim();

      // Dispatch the SignUpRequested event to the AuthCubit
      // Assuming AuthCubit is provided higher up in the widget tree
      // and accessible via context.read
      try {
        // Use context.read to get the cubit instance
        await context.read<AuthCubit>().signUp(
          firstName,
          lastName,
          email,
          password,
          bio: bio,
        );
        // State changes will be handled by BlocListener
      } catch (e) {
        // In case of an unexpected error not caught by Cubit's catch block
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: ${e.toString()}'),
            ),
          );
          setState(() => _isLoading = false); // Hide loading indicator on error
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Wrap with BlocListener to listen for state changes from AuthCubit
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SignUpLoading) {
            // Loading state is managed by _isLoading, but can also be handled here if needed
            setState(() => _isLoading = true);
          } else if (state is SignUpSuccess) {
            setState(() => _isLoading = false); // Hide loading indicator
            // Navigate to login screen on successful signup
            context.go(AppRoutePaths.login);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully! Please log in.'),
              ),
            );
          } else if (state is SignUpFailure) {
            setState(() => _isLoading = false); // Hide loading indicator
            // Show error message to the user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sign up failed: ${state.error}')),
            );
          } else if (state is AuthInitial) {
            // If state returns to initial, ensure loading is false
            setState(() => _isLoading = false);
          }
        },
        child: Column(
          children: [
            const AuthHeader(title: 'Sign Up', subtitle: 'Create Account'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'First Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomTextField(
                                  hint: 'First Name',
                                  controller: _firstNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length < 3) {
                                      return 'First name must be at least 3 characters';
                                    }
                                    if (value.length > 25) {
                                      return 'First name must be less than 25 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Last Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomTextField(
                                  hint: 'Last Name',
                                  controller: _lastNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length < 3) {
                                      return 'Last name must be at least 3 characters';
                                    }
                                    if (value.length > 25) {
                                      return 'Last name must be less than 25 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Email Address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          // Basic email format validation
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Password',
                        isPassword: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Confirm Password',
                        isPassword: true,
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bio (Optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        hint: 'Tell us about yourself...',
                        controller: _bioController,
                        validator: (value) {
                          if (value != null && value.length > 150) {
                            return 'Bio must be less than 150 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Conditionally show button text or loading indicator
                      PrimaryButton(
                        text: _isLoading
                            ? ''
                            : 'Sign Up', // Empty text when loading
                        onPressed: _isLoading
                            ? null
                            : _onSignUp, // Disable button when loading
                        child:
                            _isLoading // Show CircularProgressIndicator when loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.black, // Color for the indicator
                                ),
                              )
                            : null, // Null child when not loading
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account ? ",
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to login screen if already have an account
                              if (!_isLoading) {
                                context
                                    .pop(); // Use pop to go back to previous route
                              }
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
