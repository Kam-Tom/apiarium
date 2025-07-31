import 'package:apiarium/core/core.dart';
import 'package:apiarium/features/auth/widgets/country_dropdown.dart';
import 'package:apiarium/features/auth/widgets/widgets.dart';
import 'package:apiarium/shared/utils/countries.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import '../bloc/auth_bloc.dart';

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
  String? _selectedCountry;
  bool _hasInitializedCountry = false;

  @override
  void initState() {
    super.initState();
    // Remove the _getDeviceCountry() call from here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize country only once after dependencies are available
    if (!_hasInitializedCountry) {
      _selectedCountry = _getDeviceCountry();
      _hasInitializedCountry = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getDeviceCountry() {
    try {
      final locale = context.locale;
      final countryCode = locale.countryCode ?? 
          Platform.localeName.split('_').last.substring(0, 2).toUpperCase();
      return Countries.list.any((c) => c.code == countryCode) ? countryCode : 'US';
    } catch (e) {
      // Fallback if locale is not available yet
      return 'US';
    }
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate() && _selectedCountry != null) {
      context.read<AuthBloc>().add(SignUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        country: _selectedCountry!,
        language: context.locale.languageCode,
        consentAccepted: _acceptTerms,
      ));
    }
  }

  void _handleAnonymousSignUp() {
    if (_selectedCountry != null) {
      context.read<AuthBloc>().add(SignInAnonymously(
        country: _selectedCountry!,
        language: context.locale.languageCode,
      ));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'auth.sign_up.terms_title'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              'auth.sign_up.terms_content'.tr(),
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final containerHeight = isSmallScreen ? size.height * 0.9 : size.height * 0.8;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          _showError(state.message ?? 'auth.sign_up.registration_failed'.tr());
        } else if (state is Authenticated) {
          _showSuccess('auth.sign_up.sign_up_successful'.tr());
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: containerHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: EdgeInsets.only(top: isSmallScreen ? 8 : 12, bottom: isSmallScreen ? 4 : 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 20 : 24,
                        vertical: isSmallScreen ? 4 : 8,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Text(
                              'auth.sign_up.create_account'.tr(),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 2 : 4),
                            Text(
                              'auth.sign_up.get_started'.tr(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            
                            SizedBox(height: isSmallScreen ? 16 : 32),
                            
                            // Email field
                            EmailFormField(controller: _emailController),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            
                            // Password field
                            PasswordFormField(
                              controller: _passwordController,
                              labelText: 'auth.common.password'.tr(),
                              hintText: 'auth.sign_up.password_hint'.tr(),
                            ),
                            
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            
                            // Country selection
                            Text(
                              'auth.common.country'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CountryDropdown(
                              value: _selectedCountry,
                              onChanged: (value) => setState(() => _selectedCountry = value),
                              hasError: _selectedCountry == null,
                              errorText: _selectedCountry == null ? 'auth.common.country_required'.tr() : null,
                            ),
                            
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            
                            // Terms form field
                            TermsFormField(
                              value: _acceptTerms,
                              onChanged: (value) => setState(() => _acceptTerms = value),
                              onTermsTap: _showTermsAndConditions,
                            ),
                            
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            
                            // Sign up button
                            SizedBox(
                              width: double.infinity,
                              height: isSmallScreen ? 48 : 50,
                              child: ElevatedButton(
                                onPressed: state is AuthLoading ? null : _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor: theme.primaryColor.withOpacity(0.6),
                                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                                ),
                                child: state is AuthLoading
                                    ? SizedBox(
                                        height: isSmallScreen ? 18 : 20,
                                        width: isSmallScreen ? 18 : 20,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'auth.sign_up.sign_up_button'.tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            
                            SizedBox(height: isSmallScreen ? 12 : 20),
                            
                            // OR divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade300)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                                  child: Text(
                                    'auth.common.or'.tr(),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade300)),
                              ],
                            ),
                            
                            SizedBox(height: isSmallScreen ? 12 : 20),
                            
                            // Anonymous sign up button
                            SizedBox(
                              width: double.infinity,
                              height: isSmallScreen ? 48 : 50,
                              child: OutlinedButton(
                                onPressed: state is AuthLoading ? null : _handleAnonymousSignUp,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: theme.primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                                ),
                                child: Text(
                                  'auth.sign_up.sign_up_anonymously'.tr(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            
                            // Sign in link
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: '${('auth.sign_up.have_account').tr()} ',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'auth.sign_up.sign_in'.tr(),
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => context.push(AppRouter.signIn),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: isSmallScreen ? 8 : 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}