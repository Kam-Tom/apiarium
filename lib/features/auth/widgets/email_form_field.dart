import 'package:apiarium/features/auth/widgets/input_label.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A form field specialized for email input with validation
class EmailFormField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onTap;
  
  const EmailFormField({required this.controller, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputLabel('auth.common.email'.tr()),
        TextFormField(
          controller: controller,
          onTap: onTap,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'auth.common.email'.tr(),
            prefixIcon: const Icon(Icons.email_outlined),
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