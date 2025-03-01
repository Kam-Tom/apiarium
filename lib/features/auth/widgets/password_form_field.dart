import 'package:apiarium/features/auth/widgets/input_label.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A form field specialized for password input with validation and visibility toggle
class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  
  const PasswordFormField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.onTap,
    this.validator,
    super.key,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputLabel(widget.labelText),
        TextFormField(
          controller: widget.controller,
          onTap: widget.onTap,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          validator: widget.validator ?? (value) {
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