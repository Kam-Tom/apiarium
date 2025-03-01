import 'package:apiarium/core/core.dart';
import 'package:apiarium/features/auth/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../bloc/auth_bloc.dart';

/// SignUpView handles the UI presentation and user interactions for registration
class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _acceptTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      // Dispatch sign up event to the AuthBloc
      context.read<AuthBloc>().add(SignUp(
        email: _emailController.text,
        password: _passwordController.text,
      ));
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.sign_up.please_accept_terms'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleAnonymousSignUp() {
    // Check if user has accepted terms before anonymous sign-up
    if (_acceptTerms) {
      context.read<AuthBloc>().add(SignInAnonymously());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.sign_up.please_accept_terms'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTermsAndConditions() {
    // Show a more compact terms dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'auth.sign_up.terms_title'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              'auth.sign_up.terms_content'.tr(),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text('auth.common.close'.tr()),
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
    final containerHeight = screenHeight * 0.75; // Reduced height
    
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'auth.sign_up.registration_failed'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is SignedUp) {
          // Show appropriate message based on whether email verification is required
          String message = state.requiresEmailVerification 
            ? 'auth.sign_up.email_verification'.tr(args: [state.email ?? ""])
            : 'auth.sign_up.registration_successful'.tr();
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 6), // Longer duration for important message
              action: state.requiresEmailVerification ? SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to sign in page after successful registration
                  context.push(AppRouter.signIn);
                },
              ) : null,
            ),
          );
          
          // If email verification is not required, automatically navigate to sign in
          if (!state.requiresEmailVerification) {
            context.push(AppRouter.signIn);
          }
        } else if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('auth.sign_up.sign_up_successful'.tr()),
              backgroundColor: Colors.green,
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
                // Drag handle
                const Padding(
                  padding: EdgeInsets.only(top: 12.0, bottom: 4.0),
                  child: DragHandle(),
                ),
                
                // Content
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
                            // Header without back button, just the title
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16.0, 
                                bottom: 4.0,
                              ),
                              child: Text(
                                'auth.sign_up.create_account'.tr(),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            
                            Text(
                              'auth.sign_up.get_started'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                            
                            const SizedBox(height: 24), // reduced spacing
                            
                            // Email Field
                            EmailFormField(controller: _emailController),
                            const SizedBox(height: 16),
                            
                            // Password Field
                            PasswordFormField(
                              controller: _passwordController,
                              labelText: 'auth.common.password'.tr(),
                              hintText: 'auth.sign_up.password_hint'.tr(),
                            ),
                            
                            const SizedBox(height: 4), // reduced spacing
                            
                            // Terms and Conditions Checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _acceptTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptTerms = value ?? false;
                                    });
                                  },
                                  activeColor: theme.primaryColor,
                                  visualDensity: VisualDensity.compact, // more compact checkbox
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      text: '${('auth.sign_up.accept_terms').tr()} ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'auth.sign_up.terms_conditions'.tr(),
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = _showTermsAndConditions,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20), // reduced spacing
                            
                            // Sign Up Button
                            state is AuthLoading
                              ? const Center(child: CircularProgressIndicator())
                              : PrimaryButton(
                                  text: 'auth.sign_up.sign_up_button'.tr(),
                                  onPressed: _handleSignUp,
                                ),
                            
                            const SizedBox(height: 16), // spacing after sign up button
                            
                            // OR Divider
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    'auth.common.or'.tr(),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16), // spacing after divider
                            
                            // Sign Up Anonymously Button
                            OutlinedButton(
                              onPressed: state is AuthLoading ? null : _handleAnonymousSignUp,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: theme.primaryColor),
                              ),
                              child: Text('auth.sign_up.sign_up_anonymously'.tr()),
                            ),
                            
                            const SizedBox(height: 20), // reduced spacing
                            
                            // Already have an account text
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: '${('auth.sign_up.have_account').tr()} ',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                                  children: [
                                    TextSpan(
                                      text: 'auth.sign_up.sign_in'.tr(),
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          context.push(AppRouter.signIn);
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16), // reduced spacing
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