import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/edit_hive_type/bloc/edit_hive_type_bloc.dart';
import 'package:apiarium/features/managment/edit_hive_type/edit_hive_type_view.dart';
import 'package:apiarium/shared/shared.dart';

class EditHiveTypePage extends StatelessWidget {
  final String? hiveTypeId;

  const EditHiveTypePage({
    this.hiveTypeId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditHiveTypeBloc(
        hiveService: getIt<HiveService>(),
        hiveTypeId: hiveTypeId,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            hiveTypeId == null ? 'Create Hive Type' : 'Edit Hive Type',
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade800, Colors.amber.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: const EditHiveTypeView(),
      ),
    );
  }
}