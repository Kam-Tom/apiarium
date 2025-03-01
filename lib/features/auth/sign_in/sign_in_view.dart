import 'package:apiarium/features/auth/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../bloc/auth_bloc.dart';

/// SignInView handles the UI presentation and user interactions for login
class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      // Dispatch sign in event to the AuthBloc
      context.read<AuthBloc>().add(SignIn(
        email: _emailController.text,
        password: _passwordController.text,
      ));
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'auth.sign_in.reset_password'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'auth.sign_in.reset_instructions'.tr(),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'auth.common.email'.tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'auth.validation.email_required'.tr();
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'auth.validation.email_invalid'.tr();
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text('auth.common.cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Dispatch reset password event to the AuthBloc
                  context.read<AuthBloc>().add(ResetPassword(
                    email: emailController.text,
                  ));
                  context.pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(120, 36), // Ensure the button has a minimum width
              ),
              child: Text(
                'auth.sign_in.send_reset_link'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final containerHeight = screenHeight * 0.75;
    
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          // Show error message when authentication fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'auth.sign_in.authentication_failed'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is Authenticated) {
          // Navigate to the main app when authentication succeeds
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('auth.sign_in.login_successful'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          
        } else if (state is PasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('auth.sign_in.reset_link_sent'.tr(args: [state.email])),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
            ),
            height: containerHeight,
            child: Column(
              children: [
                // Drag handle remains outside of scroll view
                const Padding(
                  padding: EdgeInsets.only(top: 12.0, bottom: 4.0),
                  child: DragHandle(),
                ),
                
                // Everything else becomes scrollable
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with back button and title
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16.0, 
                                bottom: 8.0,
                                left: 4.0,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => context.pop(),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'auth.sign_in.welcome_back'.tr(),
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            Text(
                              'auth.sign_in.continue'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Email Field
                            EmailFormField(controller: _emailController),
                            const SizedBox(height: 16),
                            
                            // Password Field
                            PasswordFormField(
                              controller: _passwordController,
                              labelText: 'auth.common.password'.tr(),
                              hintText: 'auth.sign_in.password_hint'.tr(),
                            ),
                            
                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  minimumSize: const Size(0, 30),
                                ),
                                child: Text('auth.sign_in.forgot_password'.tr()),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Sign In Button
                            state is AuthLoading
                              ? const Center(child: CircularProgressIndicator())
                              : PrimaryButton(
                                  text: 'auth.sign_in.sign_in_button'.tr(),
                                  onPressed: _handleSignIn,
                                ),
                            
                            const SizedBox(height: 24),
                            
                            // Don't have an account text
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: '${('auth.sign_in.no_account').tr()} ',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                                  children: [
                                    TextSpan(
                                      text: 'auth.sign_in.sign_up'.tr(),
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          context.pop();
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Add extra space at the bottom for better scrolling experience
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}