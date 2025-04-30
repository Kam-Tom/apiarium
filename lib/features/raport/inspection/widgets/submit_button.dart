import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isFormValid = context.select((InspectionBloc bloc) => 
      bloc.state.selectedHiveId != null && 
      bloc.state.fields.isNotEmpty);
      
    final isSubmitting = context.select((InspectionBloc bloc) => 
      bloc.state.isSubmitting);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isFormValid && !isSubmitting 
            ? () {
                context.read<InspectionBloc>().add(
                  const SaveInspectionReport(),
                );
              } 
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isSubmitting 
            ? const SizedBox(
                width: 24, 
                height: 24, 
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
            : const Text(
                'Save Inspection Report',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
