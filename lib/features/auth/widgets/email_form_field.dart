import 'package:apiarium/features/auth/widgets/input_label.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A form field specialized for email input with validation
class EmailFormField extends StatelessWidget {
  final TextEditingController controller;
  
  const EmailFormField({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputLabel('auth.common.email'.tr()),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'auth.common.email'.tr(),
            prefixIcon: const Icon(Icons.email_outlined),
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