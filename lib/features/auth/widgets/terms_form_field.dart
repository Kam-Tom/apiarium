import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TermsFormField extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsTap;
  final String? Function(bool?)? validator;

  const TermsFormField({
    required this.value,
    required this.onChanged,
    required this.onTermsTap,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.height < 700;

    return FormField<bool>(
      initialValue: value,
      validator: validator ?? (value) {
        if (value == null || !value) {
          return 'auth.sign_up.please_accept_terms'.tr();
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: isSmallScreen ? 0.8 : 0.9,
                  child: Checkbox(
                    value: value,
                    onChanged: (newValue) {
                      onChanged(newValue ?? false);
                      field.didChange(newValue ?? false);
                    },
                    activeColor: field.hasError ? Colors.red.shade600 : theme.primaryColor,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: field.hasError 
                      ? BorderSide(color: Colors.red.shade600, width: 2)
                      : null,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 2 : 4),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: isSmallScreen ? 10 : 12),
                    child: RichText(
                      text: TextSpan(
                        text: '${('auth.sign_up.accept_terms').tr()} ',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          color: field.hasError ? Colors.red.shade600 : Colors.grey.shade700,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: 'auth.sign_up.terms_conditions'.tr(),
                            style: TextStyle(
                              color: field.hasError ? Colors.red.shade600 : theme.primaryColor,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: EdgeInsets.only(
                  left: isSmallScreen ? 28 : 32,
                  top: 4,
                ),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
