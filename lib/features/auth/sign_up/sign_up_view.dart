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
      // You need to provide country and consent data for the new signup flow
      context.read<AuthBloc>().add(SignUp(
        email: _emailController.text,
        password: _passwordController.text,
        country: 'US', // TODO: Get user's country - maybe from device locale
        consentAccepted: _acceptTerms,
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
    if (_acceptTerms) {
      context.read<AuthBloc>().add(SignInAnonymously(
        country: 'US', // TODO: Get user's country
      ));
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
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive calculations
    final isSmallDevice = screenHeight < 700; // Small phones
    final isVerySmallDevice = screenHeight < 600; // Very small phones
    final isTablet = screenWidth > 600;
    
    // Dynamic container height based on device size
    final containerHeight = isVerySmallDevice 
        ? screenHeight * 0.85  // Take more space on tiny devices
        : isSmallDevice 
            ? screenHeight * 0.82  // Take more space on small devices
            : screenHeight * 0.75; // Original for normal devices
    
    // Dynamic padding based on device size
    final horizontalPadding = isTablet ? 48.0 : (isSmallDevice ? 16.0 : 24.0);
    final verticalSpacing = isVerySmallDevice ? 8.0 : (isSmallDevice ? 12.0 : 16.0);
    final headerSpacing = isVerySmallDevice ? 12.0 : (isSmallDevice ? 16.0 : 24.0);
    
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'auth.sign_up.registration_failed'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('auth.sign_up.sign_up_successful'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          // User is authenticated, router will handle navigation automatically
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
                // Drag handle - smaller on small devices
                Padding(
                  padding: EdgeInsets.only(
                    top: isSmallDevice ? 8.0 : 12.0, 
                    bottom: 4.0
                  ),
                  child: const DragHandle(),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header - responsive text sizes
                            Padding(
                              padding: EdgeInsets.only(
                                top: isSmallDevice ? 8.0 : 16.0, 
                                bottom: 4.0,
                              ),
                              child: Text(
                                'auth.sign_up.create_account'.tr(),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontSize: isVerySmallDevice ? 20 : (isSmallDevice ? 22 : null),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            
                            Text(
                              'auth.sign_up.get_started'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: isSmallDevice ? 13 : null,
                                color: Colors.black54,
                              ),
                            ),
                            
                            SizedBox(height: headerSpacing),
                            
                            // Email Field
                            _ResponsiveEmailField(
                              controller: _emailController,
                              isSmallDevice: isSmallDevice,
                            ),
                            SizedBox(height: verticalSpacing),
                            
                            // Password Field
                            _ResponsivePasswordField(
                              controller: _passwordController,
                              isSmallDevice: isSmallDevice,
                            ),
                            
                            SizedBox(height: verticalSpacing * 0.5),
                            
                            // Terms Checkbox - responsive
                            _ResponsiveTermsCheckbox(
                              acceptTerms: _acceptTerms,
                              onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                              onTermsTap: _showTermsAndConditions,
                              isSmallDevice: isSmallDevice,
                            ),
                            
                            SizedBox(height: verticalSpacing + 4),
                            
                            // Sign Up Button
                            state is AuthLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _ResponsivePrimaryButton(
                                  text: 'auth.sign_up.sign_up_button'.tr(),
                                  onPressed: _handleSignUp,
                                  isSmallDevice: isSmallDevice,
                                ),
                            
                            SizedBox(height: verticalSpacing),
                            
                            // OR Divider - responsive
                            _ResponsiveDivider(isSmallDevice: isSmallDevice),
                            
                            SizedBox(height: verticalSpacing),
                            
                            // Anonymous Button
                            _ResponsiveOutlinedButton(
                              text: 'auth.sign_up.sign_up_anonymously'.tr(),
                              onPressed: state is AuthLoading ? null : _handleAnonymousSignUp,
                              isSmallDevice: isSmallDevice,
                            ),
                            
                            SizedBox(height: verticalSpacing + 4),
                            
                            // Sign in link - responsive
                            _ResponsiveSignInLink(isSmallDevice: isSmallDevice),
                            
                            SizedBox(height: isSmallDevice ? 8.0 : 16.0),
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

// Responsive Widget Components
class _ResponsiveEmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isSmallDevice;

  const _ResponsiveEmailField({
    required this.controller,
    required this.isSmallDevice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputLabel('auth.common.email'.tr()),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(fontSize: isSmallDevice ? 14 : 16),
          decoration: InputDecoration(
            hintText: 'auth.common.email'.tr(),
            hintStyle: TextStyle(fontSize: isSmallDevice ? 13 : null),
            prefixIcon: Icon(Icons.email_outlined, size: isSmallDevice ? 20 : 24),
            contentPadding: EdgeInsets.symmetric(
              vertical: isSmallDevice ? 8 : 12,
              horizontal: 12,
            ),
            // ...existing decoration...
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
    );
  }
}

class _ResponsivePasswordField extends StatefulWidget {
  final TextEditingController controller;
  final bool isSmallDevice;

  const _ResponsivePasswordField({
    required this.controller,
    required this.isSmallDevice,
  });

  @override
  State<_ResponsivePasswordField> createState() => _ResponsivePasswordFieldState();
}

class _ResponsivePasswordFieldState extends State<_ResponsivePasswordField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputLabel('auth.common.password'.tr()),
        TextFormField(
          controller: widget.controller,
          obscureText: !_isPasswordVisible,
          style: TextStyle(fontSize: widget.isSmallDevice ? 14 : 16),
          decoration: InputDecoration(
            hintText: 'auth.sign_up.password_hint'.tr(),
            hintStyle: TextStyle(fontSize: widget.isSmallDevice ? 13 : null),
            prefixIcon: Icon(Icons.lock_outline, size: widget.isSmallDevice ? 20 : 24),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                size: widget.isSmallDevice ? 18 : 20,
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: widget.isSmallDevice ? 8 : 12,
              horizontal: 12,
            ),
            // ...existing decoration...
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'auth.validation.password_required'.tr();
            } else if (value.length < 6) {
              return 'auth.validation.password_length'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _ResponsiveTermsCheckbox extends StatelessWidget {
  final bool acceptTerms;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsTap;
  final bool isSmallDevice;

  const _ResponsiveTermsCheckbox({
    required this.acceptTerms,
    required this.onChanged,
    required this.onTermsTap,
    required this.isSmallDevice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Transform.scale(
          scale: isSmallDevice ? 0.9 : 1.0,
          child: Checkbox(
            value: acceptTerms,
            onChanged: onChanged,
            activeColor: theme.primaryColor,
            visualDensity: VisualDensity.compact,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '${('auth.sign_up.accept_terms').tr()} ',
              style: TextStyle(
                fontSize: isSmallDevice ? 12 : 14,
                color: Colors.grey.shade700,
              ),
              children: [
                TextSpan(
                  text: 'auth.sign_up.terms_conditions'.tr(),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallDevice ? 12 : 14,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResponsivePrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSmallDevice;

  const _ResponsivePrimaryButton({
    required this.text,
    required this.onPressed,
    required this.isSmallDevice,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isSmallDevice ? 44 : 50,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: isSmallDevice ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ResponsiveOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSmallDevice;

  const _ResponsiveOutlinedButton({
    required this.text,
    this.onPressed,
    required this.isSmallDevice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      height: isSmallDevice ? 44 : 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: theme.primaryColor),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: isSmallDevice ? 14 : 16),
        ),
      ),
    );
  }
}

class _ResponsiveDivider extends StatelessWidget {
  final bool isSmallDevice;

  const _ResponsiveDivider({required this.isSmallDevice});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallDevice ? 12.0 : 16.0),
          child: Text(
            'auth.common.or'.tr(),
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: isSmallDevice ? 12 : 14,
            ),
          ),
        ),
        const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
      ],
    );
  }
}

class _ResponsiveSignInLink extends StatelessWidget {
  final bool isSmallDevice;

  const _ResponsiveSignInLink({required this.isSmallDevice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: RichText(
        text: TextSpan(
          text: '${('auth.sign_up.have_account').tr()} ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
            fontSize: isSmallDevice ? 13 : null,
          ),
          children: [
            TextSpan(
              text: 'auth.sign_up.sign_in'.tr(),
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: isSmallDevice ? 13 : null,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.push(AppRouter.signIn),
            ),
          ],
        ),
      ),
    );
  }
}